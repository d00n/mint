package com.simplediagrams.business
{
	import com.simplediagrams.events.RemoteLibraryEvent;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.libraries.LibrariesRegistry;
	import com.simplediagrams.model.libraries.LibraryInfo;
	import com.simplediagrams.util.Logger;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import org.swizframework.controller.AbstractController;

	public class RemoteLibraryRegistryDelegate extends AbstractController
	{
		private var HOST:String = "http://localhost";
		private var PATH:String = "/libraries/libraries.xml";
		
		private var _urlLoader:URLLoader;
		
		public function RemoteLibraryRegistryDelegate()
		{
		}
		
		public function loadRegistry():void
		{
			var urlRequest:URLRequest = new URLRequest(HOST + PATH);
			_urlLoader = new URLLoader(urlRequest);
			_urlLoader.addEventListener(Event.COMPLETE, onComplete);			
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onFault);			
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onFault);			
		}
		
		protected function onComplete(e:Event):void{
			var remoteLibraryEvent:RemoteLibraryEvent = new RemoteLibraryEvent(RemoteLibraryEvent.PROCESS_LIBRARY_REGISTRY);		
			var contentXML:XML = XML(_urlLoader.data);
			remoteLibraryEvent.librariesRegistry = readRegistry(contentXML);
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
				
		/* If we're missing the registry, copy default libraries and registry from install directory */		
		protected function copyDefaultLibrariesAndRegistry():void
		{
//			var origDir:File = File.applicationDirectory.resolvePath(ApplicationModel.LIBRARY_PATH)				
//			var libDir:File = ApplicationModel.baseStorageDir.resolvePath(ApplicationModel.LIBRARY_PATH)
//			if (libDir.exists==false)
//			{
//				libDir.createDirectory()
//			}
//			var filesToCopyArr:Array = origDir.getDirectoryListing()
//			for each (var file:File in filesToCopyArr)
//			{
//				var targetFile:File = libDir.resolvePath(file.name)
//				file.copyTo(targetFile, true)
//			}
			
		}
		
		
		public function readRegistry(contentXML:XML):LibrariesRegistry
		{
			var librariesRegistry:LibrariesRegistry = new LibrariesRegistry();
			for each(var libXML:XML in contentXML.libraries.library)
			{
				var libInfo:LibraryInfo = new LibraryInfo();
				libInfo.custom = libXML.custom == "true";
				libInfo.name = libXML.@name;
				libInfo.type = libXML.type;
				libInfo.enabled = libXML.enabled == "true";
				libInfo.displayName = libXML.@displayName;
				librariesRegistry.libraries.addItem(libInfo);
			}
			return librariesRegistry;
		}
		
		public function saveRegistry(value:LibrariesRegistry):void
		{
//			var xml:XML = <registry></registry>;
//			var librariesXML:XML = <libraries></libraries>;
//			for each(var item:LibraryInfo in value.libraries)
//			{
//				var libraryXML:XML = <library name={item.name} displayName={item.displayName}>
//										<custom>{item.custom}</custom>
//										<type>{item.type}</type>
//										<enabled>{item.enabled}</enabled>
//									</library>;
//				librariesXML.appendChild(libraryXML);
//
//			}
//			xml.appendChild(librariesXML);
//			
//			var file:File = ApplicationModel.baseStorageDir.resolvePath(ApplicationModel.LIBRARY_PATH + "libraries.xml");
//			var s:FileStream = new FileStream();
//			s.open(file, FileMode.WRITE);
//			s.writeUTFBytes(xml);
//			s.close();
		}
	}
}