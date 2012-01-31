package com.simplediagrams.business
{
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.ConnectionPoint;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.IResourceLink;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.SDBackgroundModel;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDPencilDrawingModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.model.SDTextAreaModel;
	import com.simplediagrams.model.libraries.ImageBackground;
	import com.simplediagrams.model.libraries.ImageShape;
	import com.simplediagrams.model.libraries.Library;
	import com.simplediagrams.model.libraries.LibraryItem;
	import com.simplediagrams.model.libraries.SWFShape;
	import com.simplediagrams.view.SDComponents.SDPencilDrawing;
	import com.simplediagrams.view.drawingBoard.Background;
	
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	
//	import flash.filesystem.File;
//	import flash.filesystem.FileMode;
//	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.controls.Text;
	
	public class DiagramDelegate
	{
		public function DiagramDelegate()
		{
			
		}
		
		[Inject]
		public var libraryManager:LibraryManager;
		
		[Inject]
		public var appModel:ApplicationModel;
		
		[Inject]
		public var libDelegate:LibraryDelegate;
		
		public var diagramExporter:DiagramExporter = new DiagramExporter();
		public var diagramImporter:DiagramImporter = new DiagramImporter();

//		public function exportDiagram(resultFile:File, diagram:DiagramModel):void
//		{
//			var fZip:FZip = new FZip();
//			var diagXml:XML = diagramExporter.writeDiagram(diagram, appModel.version);
//			fZip.addFileFromString("diagram.xml", diagXml,"utf-8", false);
//			var library:Library = new Library();
//			library.name = "local";
//			var libName:String = diagram.background.libraryName;
//			var symbolName:String = diagram.background.symbolName;
//			var libItem:LibraryItem;
//			var itemData:ByteArray;
//			var path:String;
//			
//			//save background
//			if(libName == "local")
//			{
//				libItem = libraryManager.getLibraryItem(libName, symbolName);
//				library.items.addItem(libItem);
//				if(libItem is ImageBackground)
//				{
//					path = (libItem as ImageBackground).path;
//					itemData = libraryManager.getAssetData(libItem, path) as ByteArray;					
//					fZip.addFile(path, itemData, false);
//					
//				}
//			}
//			
//			//save shapes
//			for each(var sdObjectModel:SDObjectModel in diagram.sdObjects)
//			{
//				if(sdObjectModel is IResourceLink)
//				{
//					var resLink:IResourceLink = sdObjectModel as IResourceLink;
//					libName = resLink.libraryName;
//					symbolName = resLink.symbolName;
//					if(libName == "local")
//					{
//						libItem = libraryManager.getLibraryItem(libName, symbolName);
//						library.items.addItem(libItem);
//						if(libItem is ImageShape)
//						{
//							path = (libItem as ImageShape).path;
//							var fileExists:FZipFile = fZip.getFileByName(path)
//							if (fileExists)
//							{
//								continue
//							}
//							itemData = libraryManager.getAssetData(libItem, path) as ByteArray;
//							fZip.addFile(path, itemData, false);
//						}
//						if(libItem is SWFShape)
//						{
//							path = (libItem as SWFShape).path;
//							fileExists = fZip.getFileByName(path)
//							if (fileExists)
//							{
//								continue
//							}
//							itemData = libraryManager.getAssetData(libItem, path) as ByteArray;
//							fZip.addFile(path, itemData, false);
//						}
//					}
//				}
//			}
//			var libXml:XML = libDelegate.writeLibrary(library);
//			fZip.addFileFromString("library.xml", libXml,"utf-8", false);
//			var s:FileStream = new FileStream();
//			s.open(resultFile, FileMode.WRITE);
//			fZip.serialize(s);
//			s.close();
//			fZip.close();
//		}
		
//		public function importDiagram(file:File):DiagramModel
//		{
//			var s:FileStream = new FileStream();
//			s.open(file, FileMode.READ);
//			var content:ByteArray = new ByteArray();
//			s.readBytes(content, 0, s.bytesAvailable);
//			s.close();
//			
//			
//			var fZip:FZip = new FZip();
//			fZip.loadBytes(content);
//			var zipFile:FZipFile = fZip.getFileByName("diagram.xml");
//			if (zipFile==null)
//			{
//				throw new Error("Can't find diagram.xml inside " + file.name)
//			}			
//			var zipContent:String = zipFile.getContentAsString()
//			var diagramXML:XML = XML(zipContent);
//			var diagramModel:DiagramModel = diagramImporter.readDiagram(diagramXML);
//				
//			
//			zipFile =  fZip.getFileByName("library.xml");
//			if (zipFile==null)
//			{
//				throw new Error("Can't find library.xml inside " + file.name)
//			}						
//			var zipContent:String = zipFile.getContentAsString()
//			var libraryXML:XML = XML(zipContent);
//			var library:Library = libDelegate.parseLibrary(libraryXML);									
//			
//			
//			libraryManager.clearLocalLibrary();
//			
//			for each(var libItem:LibraryItem in library.items)
//			{
//				var path:String;
//				if(libItem is ImageShape )
//				{
//					
//					zipFile =  fZip.getFileByName((libItem as ImageShape).path);
//					libraryManager.addToLocalLibrary(libItem, zipFile.content);
//				}
//				if(libItem is SWFShape )
//				{
//					zipFile =  fZip.getFileByName((libItem as SWFShape).path);
//					libraryManager.addToLocalLibrary(libItem, zipFile.content);
//				}
//				if(libItem is ImageBackground )
//				{
//					zipFile =  fZip.getFileByName((libItem as ImageBackground).path);
//					libraryManager.addToLocalLibrary(libItem, zipFile.content);
//				}
//			}
//		
//			return diagramModel;
//		}
		
	}
}