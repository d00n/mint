package com.simplediagrams.controllers
{
	import com.simplediagrams.business.DatabaseLibrariesDelegate;
	import com.simplediagrams.business.LibraryDelegate;
	import com.simplediagrams.business.LibraryRegistryDelegate;
	import com.simplediagrams.events.LibraryEvent;
	import com.simplediagrams.events.LibraryItemEvent;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.libraries.ImageBackground;
	import com.simplediagrams.model.libraries.ImageShape;
	import com.simplediagrams.model.libraries.LibrariesRegistry;
	import com.simplediagrams.model.libraries.Library;
	import com.simplediagrams.model.libraries.LibraryInfo;
	
	import flash.events.Event;
//	import flash.events.FileListEvent;
//	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.controls.Alert;
//	import mx.events.FileEvent;
	import mx.utils.UIDUtil;

	public class LibraryController
	{
		public function LibraryController()
		{
		}
		
		[Inject]
		public var librariesRegistryDelegate:LibraryRegistryDelegate;
		
		[Inject]
		public var libraryDelegate:LibraryDelegate;
		
		[Inject]
		public var libraryManager:LibraryManager;

		[Mediate(event="LibraryEvent.COPY_LIBRARIES")]
		public function copyLibraries(event:LibraryEvent):void
		{
//			var source:File = File.applicationDirectory.resolvePath("libraries");			
//			var listing:Array = source.getDirectoryListing();
//			for each(var file:File in listing)
//			{
//				if(file.isDirectory)
//				{
//					var dest:File = ApplicationModel.baseStorageDir.resolvePath("libraries/" + file.name);
//					file.copyTo(dest, true);
//				}
//			}
//			
//			var regFile:File = File.applicationDirectory.resolvePath("libraries/libraries.xml");
//			var currentRegFile:File  = ApplicationModel.baseStorageDir.resolvePath("libraries/libraries.xml");
//			if(currentRegFile.exists)
//			{
//				var currentRegistry:LibrariesRegistry = librariesRegistryDelegate.loadRegistry();
//				var registry:LibrariesRegistry = librariesRegistryDelegate.loadRegistry(regFile);
//				for each(var libInfo:LibraryInfo in registry.libraries)
//				{
//					if(currentRegistry.getLibraryInfo(libInfo.name) == null)
//						currentRegistry.libraries.addItem(libInfo);
//				}
//				librariesRegistryDelegate.saveRegistry(currentRegistry);
//			}
//			else
//			{
//				regFile.copyTo(currentRegFile, true);
//			}
		}
		
		[Mediate(event="LibraryEvent.ENABLE_LIBRARY")]
		public function enableLibrary(event:LibraryEvent):void 
		{		
			libraryManager.enableLibrary(event.libraryInfo);
			librariesRegistryDelegate.saveRegistry(libraryManager.librariesRegistry);
		}
		
		[Mediate(event="LibraryEvent.DISABLE_LIBRARY")]
		public function disableLibrary(event:LibraryEvent):void 
		{		
			libraryManager.disableLibrary(event.libraryInfo);
			librariesRegistryDelegate.saveRegistry(libraryManager.librariesRegistry);
		}
		
		[Mediate(event="LibraryEvent.REMOVE_LIBRARY")]
		public function removeLibrary(event:LibraryEvent):void 
		{		
			var lib:Library = libraryManager.removeLibrary(event.libraryInfo);
			libraryDelegate.deleteLibrary(lib);
			librariesRegistryDelegate.saveRegistry(libraryManager.librariesRegistry);
		}
		
		
		[Mediate(event="LibraryEvent.IMPORT_LIBRARY")]
		public function importLibrary(event:LibraryEvent):void 
		{		
//			if (event.libraryFile)
//			{
//				loadPluginFromFile(event.libraryFile)
//			}
//			else
//			{
//				var libFile:File = new File()				
//				libFile.addEventListener(Event.SELECT, onLibraryFileSelect, false, 0, true);
//				libFile.addEventListener(Event.CANCEL, onLibraryFileCancel, false, 0, true);
//				var libFilter:FileFilter = new FileFilter("Library", "*.sdlp;");
//				libFile.browseForOpen("Select a library file", [libFilter])
//			}			
		}
		
		
		protected function onLibraryFileSelect(event:Event):void
		{
//			var libFile:File = event.target as File
//			libFile.removeEventListener(Event.SELECT, onLibraryFileSelect);
//			libFile.removeEventListener(Event.CANCEL, onLibraryFileCancel);
//			loadPluginFromFile(libFile)
			
		}
		
		protected function onLibraryFileCancel(event:Event):void
		{
//			var libFile:File = event.target as File
//			libFile.removeEventListener(Event.SELECT, onLibraryFileSelect);
//			libFile.removeEventListener(Event.CANCEL, onLibraryFileCancel);
		}
		
//		protected function loadPluginFromFile(libFile:File):void
//		{
//			try
//			{				
//				var lib:Library = libraryDelegate.importLibrary(libFile.nativePath, true);
//			}
//			catch(error:Error)
//			{
//				//TODO: Catch different errors so we can give a better error message
//				Alert.show("The selected library plugin could not be loaded. It might not be structured correctly, or have missing files.","Plugin Error")
//				return
//			}	
//			if(lib)
//			{
//				libraryManager.importLibrary(lib);
//				librariesRegistryDelegate.saveRegistry(libraryManager.librariesRegistry);
//			}
//			else
//			{
//				Alert.show("This library plugin already exists in your library. If you want to reload this library plugin, please delete the existing library via the library manager before loading the plugin.","Plugin Error")
//			}
//			libFile = null;
//			Alert.show("Library plugin loaded.")
//		}
		
		
		
		[Mediate(event="LibraryEvent.ADD_LIBRARY")]
		public function addLibrary(event:LibraryEvent):void 
		{		
			var lib:Library = libraryManager.newLibrary(event.name, event.libType);
			libraryDelegate.saveLibrary(lib);
			librariesRegistryDelegate.saveRegistry(libraryManager.librariesRegistry);
		}
		
		[Mediate(event="LibraryEvent.RENAME_LIBRARY")]
		public function renameLibrary(event:LibraryEvent):void 
		{	
			var lib:Library = libraryManager.renameLibrary(event.libraryInfo, event.name);
			libraryDelegate.saveLibrary(lib);
			librariesRegistryDelegate.saveRegistry(libraryManager.librariesRegistry);
		}
		

		
		[Mediate(event="LibraryItemEvent.ADD_LIBRARY_ITEM")]
		public function addLibraryItem(event:LibraryItemEvent):void 
		{		
			var name:String = UIDUtil.createUID();
			var newPath:String = libraryDelegate.importAsset(event.library, name, event.path);
			libraryManager.addNewLibraryItem(event.library, name, event.name, newPath, event.importType);
			libraryDelegate.saveLibrary(event.library);
		}
		
		protected var itemLibrary:Library;
		
		[Mediate(event="LibraryItemEvent.IMPORT_LIBRARY_ITEM")]
		public function importLibraryItem(event:LibraryItemEvent):void 
		{		
//			itemLibrary = event.library;
//			var itemFile:File = new File()				
//			itemFile.addEventListener(FileListEvent.SELECT_MULTIPLE, onItemsFileSelect, false, 0, true);
//			itemFile.addEventListener(Event.CANCEL, onItemFileCancel, false, 0, true);
//			//var imageFilter:FileFilter = new FileFilter("Image", "*.png;*.jpg;*.jpeg;*.gif;*.swf;");
//			var imageFilter:FileFilter = new FileFilter("Image", "*.png;*.jpg;*.jpeg;*.gif;");
//			itemFile.browseForOpenMultiple("Select image files", [imageFilter])
		}
		
//		protected function onItemsFileSelect(event:FileListEvent):void
//		{
//			var itemFile:File = event.target as File
//			itemFile.removeEventListener(FileListEvent.SELECT_MULTIPLE, onItemsFileSelect);
//			itemFile.removeEventListener(Event.CANCEL, onItemFileCancel);
//				
//			
//			for each(var file:File in event.files)
//			{
//				var filename:String = file.name;
//				var extensionIndex:Number = filename.lastIndexOf( '.' );
//				var extensionless:String = filename.substr( 0, extensionIndex );
//				var ext:String = file.extension.toLowerCase()
//				
//				if (file.extension=="swf")
//				{
//					var importType:String = LibraryItemEvent.IMPORT_TYPE_SWF
//				}
//				else if (ext=="png" || ext=="jpg" || ext=="jpeg" || ext=="gif")
//				{
//					importType = LibraryItemEvent.IMPORT_TYPE_IMAGE
//				}
//				else
//				{
//					Alert.show("Couldn't import files. Unrecognized file extension " + file.extension)
//					return
//				}
//				
//				var name:String = UIDUtil.createUID();
//				var newPath:String = libraryDelegate.importAsset(itemLibrary, name, file.nativePath);
//				libraryManager.addNewLibraryItem(itemLibrary, name, extensionless, newPath, importType);
//				libraryDelegate.saveLibrary(itemLibrary);
//			}
//			libraryDelegate.saveLibrary(itemLibrary);
//
//			itemLibrary = null;
//		}
		
		protected function onItemFileCancel(event:Event):void
		{
//			var itemFile:File = event.target as File
//			itemFile.removeEventListener(FileListEvent.SELECT_MULTIPLE, onItemsFileSelect);
//			itemFile.removeEventListener(Event.CANCEL, onItemFileCancel);
//			itemLibrary = null;
		}
		
		[Mediate(event="LibraryItemEvent.REMOVE_LIBRARY_ITEM")]
		public function removeLibraryItem(event:LibraryItemEvent):void 
		{		
			if(event.item is ImageBackground)
			{
				var imgBG:ImageBackground = ImageBackground(event.item);
				libraryDelegate.deleteLibraryItem(event.library, imgBG.path);
				if(imgBG.thumbnailPath != imgBG.path)
					libraryDelegate.deleteLibraryItem(event.library, imgBG.thumbnailPath);
			}
			if(event.item is ImageShape)
				libraryDelegate.deleteLibraryItem(event.library, ImageShape(event.item).path);
			libraryManager.removeLibraryItem(event.library, event.item);
			libraryDelegate.saveLibrary(event.library);
		}
		
		
		[Mediate(event="LibraryItemEvent.RENAME_LIBRARY_ITEM")]
		public function renameLibraryItem(event:LibraryItemEvent):void 
		{	
			libraryManager.renameLibraryItem(event.library, event.item, event.name);
			libraryDelegate.saveLibrary(event.library);
		}
		
		protected var libraryForExport:Library;
		
		[Mediate(event="LibraryEvent.EXPORT_LIBRARY")]
		public function exportLibrary(event:LibraryEvent):void 
		{		
//			try
//			{
//				libraryForExport = libraryManager.getLibrary(event.libraryInfo.name);
//				var exportFile:File = File.userDirectory.resolvePath("SimpleDiagrams/" + libraryForExport.displayName + ".sdlp");	
//			}
//			catch(error:Error)
//			{
//				Alert.show("Can't export library","Error");
//				return;
//			}						
//			exportFile.addEventListener(Event.SELECT, onExportFileSelect, false, 0, true);
//			exportFile.addEventListener(Event.CANCEL, onExportFileCancel, false, 0, true);
//			exportFile.browseForSave("Export Library");
		}
		
		protected function onExportFileSelect(event:Event):void
		{
//			var exportFile:File = event.target as File
//			exportFile.removeEventListener(Event.SELECT, onExportFileSelect);
//			exportFile.removeEventListener(Event.CANCEL, onExportFileCancel);
//			libraryDelegate.exportLibrary(libraryForExport, exportFile.nativePath);
//			exportFile = null;
//			libraryForExport = null;
		}
		
		protected function onExportFileCancel(event:Event):void
		{
//			var exportFile:File = event.target as File
//			exportFile.removeEventListener(Event.SELECT, onExportFileSelect);
//			exportFile.removeEventListener(Event.CANCEL, onExportFileCancel);
//			exportFile = null;
//			libraryForExport = null;
		} 
		
		
		[Mediate(event="LibraryEvent.IMPORT_LIBRARIES_DATABASE")]
		public function importLibrariesFromDB(event:LibraryEvent):void 
		{		
//			var databaseFile:File = new File();				
//			databaseFile.addEventListener(Event.SELECT, onDatabaseFileSelect, false, 0, true);
//			databaseFile.addEventListener(Event.CANCEL, onDatabaseFileCancel, false, 0, true);
//			databaseFile.browseForOpen("Open Database");
		}
		
		protected function onDatabaseFileCancel(event:Event):void
		{
//			var databaseFile:File = event.target as File
//			databaseFile.removeEventListener(Event.SELECT, onDatabaseFileSelect);
//			databaseFile.removeEventListener(Event.CANCEL, onDatabaseFileCancel);
//			databaseFile = null;
		}
		
		protected function onDatabaseFileSelect(event:Event):void
		{
//			var databaseFile:File = event.target as File
//			databaseFile.removeEventListener(Event.SELECT, onDatabaseFileSelect);
//			databaseFile.removeEventListener(Event.CANCEL, onDatabaseFileCancel);
//			var databaseDelegate:DatabaseLibrariesDelegate = new DatabaseLibrariesDelegate();
//			databaseDelegate.libraryDelegate = libraryDelegate;
//			var libs:Array = databaseDelegate.doImport(databaseFile);
//			for each(var lib:Library in libs)
//			{
//				libraryManager.importLibrary(lib);
//			}
//			databaseFile = null;
//			librariesRegistryDelegate.saveRegistry(libraryManager.librariesRegistry);
		}
		
		[Mediate(event="LibraryEvent.IMPORT_DEFAULT_DATABASE")]
		public function importDefaultDatabase(event:LibraryEvent):void 
		{		
//			var databaseFile:File = ApplicationModel.baseStorageDir.resolvePath(ApplicationModel.DB_PATH);	
//			onDatabaseFileSelect(null);
		}
		
	}
}