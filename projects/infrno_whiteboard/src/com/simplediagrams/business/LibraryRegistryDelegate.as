package com.simplediagrams.business
{
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.libraries.LibrariesRegistry;
	import com.simplediagrams.model.libraries.LibraryInfo;
	import com.simplediagrams.util.Logger;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;

	public class LibraryRegistryDelegate
	{
		public function LibraryRegistryDelegate()
		{
		}
		
		/** Load the library registry. 
		 *  If it's missing try to copy it from the application install directory.
		 *  If it can't be copied, create empty registry
		 */
		
		public function loadRegistry(sourceFile:File = null):LibrariesRegistry
		{
			if (sourceFile==null)
			{
				sourceFile=ApplicationModel.baseStorageDir.resolvePath(ApplicationModel.LIBRARY_PATH + "libraries.xml")
			}
			
			if (sourceFile.exists==false)
			{
				Logger.error("Can't find sourcefile " + sourceFile.nativePath, this)
				copyDefaultLibrariesAndRegistry()					
			}
			
			//if still false, create an empty Registry
			if (sourceFile.exists==false)
			{
				return new LibrariesRegistry()
			}
			
			var s:FileStream = new FileStream();
			s.open(sourceFile, FileMode.READ);
			var content:String = s.readUTFBytes(s.bytesAvailable);
			s.close();
			var contentXML:XML = XML(content);
					
			
			return readRegistry(contentXML);
		}
		
		/* If we're missing the registry, copy default libraries and registry from install directory */		
		protected function copyDefaultLibrariesAndRegistry():void
		{
			var origDir:File = File.applicationDirectory.resolvePath(ApplicationModel.LIBRARY_PATH)				
			var libDir:File = ApplicationModel.baseStorageDir.resolvePath(ApplicationModel.LIBRARY_PATH)
			if (libDir.exists==false)
			{
				libDir.createDirectory()
			}
			var filesToCopyArr:Array = origDir.getDirectoryListing()
			for each (var file:File in filesToCopyArr)
			{
				var targetFile:File = libDir.resolvePath(file.name)
				file.copyTo(targetFile, true)
			}
			
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
			var xml:XML = <registry></registry>;
			var librariesXML:XML = <libraries></libraries>;
			for each(var item:LibraryInfo in value.libraries)
			{
				var libraryXML:XML = <library name={item.name} displayName={item.displayName}>
										<custom>{item.custom}</custom>
										<type>{item.type}</type>
										<enabled>{item.enabled}</enabled>
									</library>;
				librariesXML.appendChild(libraryXML);

			}
			xml.appendChild(librariesXML);
			
			var file:File = ApplicationModel.baseStorageDir.resolvePath(ApplicationModel.LIBRARY_PATH + "libraries.xml");
			var s:FileStream = new FileStream();
			s.open(file, FileMode.WRITE);
			s.writeUTFBytes(xml);
			s.close();
		}
	}
}