package com.simplediagrams.business
{
	import avmplus.getQualifiedClassName;
	
	import com.simplediagrams.controllers.RemoteLibraryController;
	import com.simplediagrams.events.RemoteLibraryEvent;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.CopyUtil;
	import com.simplediagrams.model.libraries.ImageBackground;
	import com.simplediagrams.model.libraries.ImageShape;
	import com.simplediagrams.model.libraries.Library;
	import com.simplediagrams.model.libraries.LibraryInfo;
	import com.simplediagrams.model.libraries.LibraryItem;
	import com.simplediagrams.model.libraries.SWFBackground;
	import com.simplediagrams.model.libraries.SWFShape;
	import com.simplediagrams.model.libraries.VectorShape;
	import com.simplediagrams.util.Logger;
	
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.utils.UIDUtil;
	
	import org.osmf.media.MediaPlayer;
	import org.swizframework.controller.AbstractController;

	public class RemoteLibraryDelegate extends AbstractController
	{
		protected var dictionaryReaders:Dictionary = new Dictionary();
		protected var dictionaryWriters:Dictionary = new Dictionary();
		
		private var _urlLoader:URLLoader;
		
		[Inject]
		public var remoteLibraryController:RemoteLibraryController;
		
		public var libInfo:LibraryInfo;
		private var _libUrl:String;
		
		public function RemoteLibraryDelegate()
		{
			dictionaryReaders["imageBackground"] = readImageBackgroundItem;
			dictionaryReaders["swfBackground"] = readSWFBackgroundItem;
			dictionaryReaders["vectorShape"] = readVectorShapeItem;
			dictionaryReaders["imageShape"] = readImageShapeItem;
			dictionaryReaders["swfShape"] = readSWFShapeItem;
			
			dictionaryWriters[getQualifiedClassName(ImageBackground)] = writeImageBackgroundItem;
			dictionaryWriters[getQualifiedClassName(ImageShape)] = writeImageShapeItem;
			dictionaryWriters[getQualifiedClassName(VectorShape)] = writeVectorShapeItem;
			dictionaryWriters[getQualifiedClassName(SWFShape)] = writeSWFShapeItem;
			
		}
		
		protected function readLibraryItem(xml:XML, libraryItem:LibraryItem):void
		{
			libraryItem.displayName = xml.@displayName;
			libraryItem.name = xml.@name;
			if("@width" in xml)
				libraryItem.width = xml.@width;
			if("@height" in xml)
				libraryItem.height = xml.@height;
			if("scaleGridLeft" in xml)
			{
				libraryItem.scaleGridLeft = xml.scaleGridLeft;
				libraryItem.scaleGridTop = xml.scaleGridTop;
				libraryItem.scaleGridRight = xml.scaleGridRight;
				libraryItem.scaleGridBottom = xml.scaleGridBottom;
			}
		}
		
		protected function readImageBackgroundItem(xml:XML):ImageBackground
		{
			trace("RemoteLibraryDelegate.readImageBackgroundItem: "+ _libUrl + xml.path);

			var imageBackground:ImageBackground = new ImageBackground();
			readLibraryItem(xml, imageBackground);
			imageBackground.path = xml.path;
			imageBackground.assetPath = _libUrl + xml.path;
			imageBackground.thumbnailPath = _libUrl + xml.thumbnailPath;				
			if (imageBackground.thumbnailPath=="")
			{				
				imageBackground.thumbnailPath = _libUrl + imageBackground.path
			}
			return imageBackground;
		}
		
		
		protected function readSWFBackgroundItem(xml:XML):SWFBackground
		{
			var swfBackground:SWFBackground = new SWFBackground();
			readLibraryItem(xml, swfBackground);
			swfBackground.path = xml.path;
			swfBackground.assetPath = _libUrl + xml.path;
			swfBackground.thumbnailPath = _libUrl + xml.thumbnailPath;				
			if (swfBackground.thumbnailPath=="")
			{				
				swfBackground.thumbnailPath = _libUrl + swfBackground.path
			}
			return swfBackground;
		}
		
		protected function readImageShapeItem(xml:XML):ImageShape
		{
			var imageShape:ImageShape = new ImageShape();
			readLibraryItem(xml, imageShape);
			imageShape.path = xml.path;
			imageShape.assetPath = _libUrl + xml.path;
			return imageShape;
		}
		
		protected function readSWFShapeItem(xml:XML):SWFShape
		{
			var swfShape:SWFShape = new SWFShape()
			readLibraryItem(xml,swfShape)
			swfShape.path = xml.path
			swfShape.assetPath = _libUrl + xml.path;
			swfShape.maintainAspectRatio = xml.maintainAspectRatio == "true"
			swfShape.startWithShapeDefaultColor = xml.startWithShapeDefaultColor == "true"
			return swfShape
		}
		
		protected function readVectorShapeItem(xml:XML):VectorShape
		{
			var vectorShape:VectorShape = new VectorShape();
			readLibraryItem(xml, vectorShape);
			vectorShape.path = xml.path;
			return vectorShape;
		}
		
		public function parseLibrary(contentXML:XML):Library
		{
			var libraryXML:XML = contentXML.library[0];
			var library:Library = new Library();
			library.custom = libraryXML.custom == "true";
			library.displayName = libraryXML.@displayName;
			if (libraryXML.@prevName)
			{
				library.prevName = libraryXML.@prevName
			}
			library.name = libraryXML.@name;
			library.type = libraryXML.type;
			var itemsXML:XML = libraryXML.items[0];
			for each(var itemXML:XML in itemsXML.children())
			{
				var reader:Function = dictionaryReaders[itemXML.name()];
				var libraryItem:LibraryItem = reader(itemXML);
				libraryItem.libraryName = library.name;
				library.items.addItem(libraryItem);
			}
			return library;
		}
		
		public function  readLibrary(base_lib_url:String):void
		{
//			var file:File = ApplicationModel.baseStorageDir.resolvePath("libraries/" + name + "/library.xml");
			
			_libUrl = base_lib_url + libInfo.name + "/";

			Logger.info("RemoteLibraryDelegate.readLibrary url: "+ _libUrl +"library.xml", this);
			var urlRequest:URLRequest = new URLRequest(_libUrl + "library.xml");
			
			_urlLoader = new URLLoader(urlRequest);
			_urlLoader.addEventListener(Event.COMPLETE, onComplete);			
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onFault);			
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onFault);			
		}
		
		protected function onComplete(e:Event):void{
			var remoteLibraryEvent:RemoteLibraryEvent = new RemoteLibraryEvent(RemoteLibraryEvent.PROCESS_LIBRARY);		
			var contentXML:XML = XML(_urlLoader.data);
			remoteLibraryEvent.library = parseLibrary(contentXML);
			remoteLibraryEvent.libInfo = libInfo;
			remoteLibraryEvent.remoteLibraryDelegate = this;
			dispatcher.dispatchEvent(remoteLibraryEvent);
			cleanup();
		}
		
		protected function onFault(e:Event):void{
			// RSO TODO mediate this
			var remoteLibraryEvent:RemoteLibraryEvent = new RemoteLibraryEvent(RemoteLibraryEvent.ON_FAULT);		
			remoteLibraryEvent.error = e.toString();
			dispatcher.dispatchEvent(remoteLibraryEvent);			
			cleanup();
		}
		
		protected function cleanup():void{
			_urlLoader.removeEventListener(Event.COMPLETE, onComplete);			
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onFault);			
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onFault);	
			_urlLoader.close();
			_urlLoader = null;
		}		
		
		protected function writeLibraryItem(xml:XML, libraryItem:LibraryItem):void
		{
			xml.@displayName = libraryItem.displayName;
			xml.@name = libraryItem.name;
			xml.@width = libraryItem.width;
			xml.@height = libraryItem.height;
			
			if(isNaN(libraryItem.scaleGridLeft) == false)
			{
				libraryItem.scaleGridLeft = libraryItem.scaleGridLeft;
				libraryItem.scaleGridTop = libraryItem.scaleGridTop;
				libraryItem.scaleGridRight = libraryItem.scaleGridRight;
				libraryItem.scaleGridBottom = libraryItem.scaleGridBottom;
			}
		}
		
		protected function writeImageBackgroundItem(imageBackground:ImageBackground):XML
		{
			var xml:XML = <imageBackground>
	        				<thumbnailPath>{imageBackground.thumbnailPath}</thumbnailPath>
			  			   	<path>{imageBackground.path}</path>
	         			   </imageBackground>;
			writeLibraryItem(xml,imageBackground);
			return xml;
		}
		
		protected function writeImageShapeItem(imageShape:ImageShape):XML
		{
			var xml:XML = <imageShape>
							<path>{imageShape.path}</path>
						   </imageShape>;
			writeLibraryItem(xml,imageShape);
			return xml;
		}
		
		protected function writeVectorShapeItem(vectorShape:VectorShape):XML
		{
			var xml:XML = <vectorShape>
							<path>{vectorShape.path}</path>
						   </vectorShape>;
			writeLibraryItem(xml,vectorShape);
			return xml;
		}
		
		protected function writeSWFShapeItem(swfShape:SWFShape):XML
		{
			var xml:XML = <swfShape>
							<path>{swfShape.path}</path>
							<maintainAspectRatio>{swfShape.maintainAspectRatio.toString()}</maintainAspectRatio>
							<startWithShapeDefaultColor>{swfShape.startWithShapeDefaultColor.toString()}</startWithShapeDefaultColor>
						 </swfShape>;
			writeLibraryItem(xml,swfShape);
			return xml;
		}
		
		
		public function writeLibrary(library:Library):XML
		{
			var xml:XML = <sdxml version="1.5"></sdxml>;
			var libXML:XML = <library name={library.name} displayName={library.displayName}>	
								<custom>{library.custom}</custom>
								<type>{library.type}</type>
							  </library>;
			
			if (library.prevName)
			{
				libXML.@prevName = library.prevName
			}
			
			var itemsXML:XML = <items></items>;
			for each(var libItem:LibraryItem in library.items)
			{
				var func:Function  = dictionaryWriters[getQualifiedClassName(libItem)];
				itemsXML.appendChild(func(libItem));
			}
			libXML.appendChild(itemsXML);
			xml.appendChild(libXML);
			return xml;
		}
		
		public function saveLibrary(library:Library):void
		{
//			var file:File = ApplicationModel.baseStorageDir.resolvePath("libraries/" + library.name + "/library.xml");
//			var s:FileStream = new FileStream();
//			s.open(file, FileMode.WRITE);
//			s.writeUTFBytes(writeLibrary(library));
//			s.close();
		}
		
		public function deleteLibrary(library:Library):void
		{
//			var file:File = ApplicationModel.baseStorageDir.resolvePath("libraries/" + library.name);
//			file.deleteDirectory(true);
		}
		
		public function importAsset(library:Library, name:String, fullPath:String):String
		{
//			var file:File = File.applicationDirectory
//			file = file.resolvePath(fullPath)
//			
//			var path:String =  name + "."+ file.extension;
//			var nfile:File = ApplicationModel.baseStorageDir.resolvePath("libraries/" + library.name + "/" + path);
//			file.copyTo(nfile);
//			return path;
			return '';
		}
		
		public function deleteLibraryItem(library:Library, path:String):void
		{
//			var nfile:File = ApplicationModel.baseStorageDir.resolvePath("libraries/" + library.name + "/" + path);
//			nfile.deleteFile();
		}
		
		public function importLibrary(path:String, overwrite:Boolean):Library
		{			
//			var file:File = File.applicationDirectory
//			file = file.resolvePath(path);	
//			
//			var s:FileStream = new FileStream();
//			s.open(file, FileMode.READ);
//			var header:String = String.fromCharCode(s.readByte()) + String.fromCharCode(s.readByte()) ;
//			var isZip:Boolean = header == "PK";
//			s.close();
//			if(isZip)
//			{
//				return importZipLibrary(path, overwrite);
//			}
//			else
//			{
//				return importXMLLibrary(path, overwrite);
//			}
			return null;
		}
		
		public function importXMLLibrary(path:String, overwrite:Boolean):Library
		{
//			var file:File = File.applicationDirectory
//			file = file.resolvePath(path);
//			var s:FileStream = new FileStream();
//			s.open(file, FileMode.READ);
//			var contentXML:XML = XML(s.readUTFBytes(s.bytesAvailable));		
//			s.close();
//			var library:Library = new Library();
//			var libXml:XML = contentXML.sdLibrary[0];
//			library.name = libXml.@name;
//			library.displayName = libXml.@displayName;
//			library.custom = false;
//			library.type = "shapes";
//			
//			for each (var sdSymbolXML:XML in libXml.sdSymbol)
//			{
//				var vectorShape:VectorShape = new VectorShape();
//				vectorShape.name = sdSymbolXML.@name;
//				vectorShape.path = sdSymbolXML.Path.@data;
//				vectorShape.libraryName = library.name;
//				vectorShape.displayName = vectorShape.name;
//				library.items.addItem(vectorShape);
//			}
//			
//			var destFile:File = ApplicationModel.baseStorageDir.resolvePath("libraries/" + library.name + "/library.xml");
//			if(destFile.exists && overwrite == false)
//				return null;
//			var resultXML:XML = writeLibrary(library);
//			
//			s = new FileStream();
//			s.open(destFile, FileMode.WRITE);
//			s.writeUTFBytes(resultXML);
//			s.close();			
//			return library;
			return null;
		}
		
		public function importZipLibrary(zipPath:String, overwrite:Boolean):Library
		{
//			var file:File = File.applicationDirectory
//			file = file.resolvePath(zipPath);
//			var s:FileStream = new FileStream();
//			s.open(file, FileMode.READ);
//			var content:ByteArray = new ByteArray();
//			s.readBytes(content, 0, s.bytesAvailable);
//			s.close();
//			var fZip:FZip = new FZip();
//			fZip.loadBytes(content);
//			
//			var zipFile:FZipFile = fZip.getFileByName("library.xml");
//			var libFileContent:String = zipFile.getContentAsString();
//			var contentXML:XML = XML(libFileContent);
//			var library:Library = parseLibrary(contentXML);
//			var i:int = 0;
//			var libFile:File = ApplicationModel.baseStorageDir.resolvePath("libraries/" + library.name + "/library.xml");
//			if(libFile.exists && overwrite == false)
//			{
//				fZip.close();
//				return null;
//			}
//			while( i < fZip.getFileCount())
//			{
//				zipFile = fZip.getFileAt(i);
//				var filename:String = zipFile.filename;
//				var destFile:File = ApplicationModel.baseStorageDir.resolvePath("libraries/" + library.name + "/" + filename);
//				s = new FileStream();
//				s.open(destFile, FileMode.WRITE);
//				s.writeBytes(zipFile.content);
//				s.close();
//				i++;
//			}
//			fZip.close();
//			return library;
			return null;
		}
		
		public function exportLibrary(library:Library, zipPath:String):void
		{
//			var fZip:FZip = new FZip();
//			var destFile:File = ApplicationModel.baseStorageDir.resolvePath("libraries/" + library.name);
//			var files:Array = destFile.getDirectoryListing();
//			for each(var file:File in files)
//			{			
//				if(file.isDirectory)
//					continue;
//				var readStream:FileStream = new FileStream();
//				readStream.open(file, FileMode.READ);
//				var content:ByteArray = new ByteArray();
//				readStream.readBytes(content, 0, readStream.bytesAvailable);
//				readStream.close();
//				fZip.addFile(file.name, content,false);			
//			}
//			
//			var resultFile:File = File.applicationDirectory
//			resultFile = resultFile.resolvePath(zipPath);
//			
//			var s:FileStream = new FileStream();
//			s.open(resultFile, FileMode.WRITE);
//			fZip.serialize(s);
//			s.close();
//			fZip.close();
		}

	}
}