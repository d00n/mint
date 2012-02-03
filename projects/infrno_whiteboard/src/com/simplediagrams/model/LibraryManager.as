package com.simplediagrams.model
{
	import com.simplediagrams.business.RemoteLibraryDelegate;
	import com.simplediagrams.business.RemoteLibraryDelegateManager;
	import com.simplediagrams.events.LibraryItemEvent;
	import com.simplediagrams.model.libraries.ImageBackground;
	import com.simplediagrams.model.libraries.ImageShape;
	import com.simplediagrams.model.libraries.LibrariesRegistry;
	import com.simplediagrams.model.libraries.Library;
	import com.simplediagrams.model.libraries.LibraryInfo;
	import com.simplediagrams.model.libraries.LibraryItem;
	import com.simplediagrams.model.libraries.SWFBackground;
	import com.simplediagrams.model.libraries.SWFShape;
	import com.simplediagrams.model.libraries.VectorShape;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.vo.RecentFileVO;
	
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import mx.collections.ArrayCollection;
	import mx.core.BitmapAsset;
	import mx.core.ByteArrayAsset;
	import mx.effects.easing.Back;
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import spark.collections.Sort;
	import spark.collections.SortField;


	[Bindable]
	public class LibraryManager extends EventDispatcher 
	{		
		[Inject]
		public var remoteLibraryDelegateManager:RemoteLibraryDelegateManager;
		
		public var librariesRegistry:LibrariesRegistry = new LibrariesRegistry();
		public var libraries:ArrayCollection = new ArrayCollection();
		private var librariesDictionary:Dictionary = new Dictionary();
		
		
		public var shapesLibraries:ArrayCollection = new ArrayCollection();
		public var backgroundLibraries:ArrayCollection = new ArrayCollection();
		private var localLibrary:Library;
		
		public function LibraryManager()
		{		
			localLibrary = new Library();
			localLibrary.name = "local";
			librariesDictionary[localLibrary.name] = localLibrary;
			
			var defaultLibrary:Library = new Library();
			defaultLibrary.name = "default";
			initDefaultLibrary(defaultLibrary);
			librariesDictionary[defaultLibrary.name] = defaultLibrary;
		
			var sort:Sort = new Sort();
			sort.fields = [new SortField("displayName")];
			shapesLibraries.sort = sort;
			shapesLibraries.refresh();
			backgroundLibraries.sort = sort;
			backgroundLibraries.refresh();
		}

		
		[Embed(source='assets/img/backgrounds/chalkboard.png', mimeType="application/octet-stream")]
		public var Chalkboard:Class
		
		private var defaultShape:VectorShape;
		private var defaultBackground:ImageBackground;
		private var resourceDictionary:Dictionary = new Dictionary();
		
		private function initDefaultLibrary(defaultLibrary:Library):void
		{
			defaultShape = new VectorShape();
			defaultShape.width = 30;
			defaultShape.height = 50;
			defaultShape.path = "M12.2 10.4Q11.9 10.5 11.6 10.55L11.1 10.85Q9.88125 10.964648 9.5 13.075 9.1101562 15.182813 9.3 17.05L4.125 16.95Q4.3556641 16.942187 4.15 16.175 3.9451172 15.412695 4.3 14.35 4.6511719 13.293555 4.85 12.65 5.2 11.35 5.65 10.1 6.55 8.95 7.6 8.35 7.9 8.2 8.15 8.1 8.3 8.1 8.4 7.65 8.45 7.5 8.45 7.3 8.45 7.2 8.45 7.15 8.3 6.1 7.8 5.25 7.7 5 7.55 4.85 7.15 4.55 6.8 4.35 5.85 4 4.95 4.2 4.55 4.3 4.05 4.55L2.95 5.15 2.35 6.4 0.05 3.05 0 2.1 0.7 1.6Q5.45 -1.3 10.65 1L12.55 3.1Q12.6 3.2 12.65 3.35 13.1 4.55 13.35 5.55 14 8.7 12.2 10.4M7.9 14.95 8.7 14.5M7.65 14.2Q7.85 14.2 8.5 13.7M7.65 16.55 8.2 16.35M7.525 15.775Q7.7845703 15.699414 8.7 15.2M4.8 22.9Q4.85 22.95 4.9 22.95 5.55 23.55 6.65 23.55 9.1 23.55 9.1 20.6 9.1 19.85 8.45 19.4 7.9 18.95 7.2 18.95 7.1 18.95 6.95 19 6.6 19.05 6.35 18.95 5.55 19.1 4.95 20 4.3 20.85 4.3 21.7 4.3 22.4 4.8 22.9M7.55 21.45Q8 21.3 8.25 21.05 8.5 20.8 8.55 20.7M6.95 19Q6.75 18.95 6.65 18.95 6.45 18.95 6.35 18.95M7.7 22.8 8.1 22.6 M7.3 20.85Q7.5 20.7 8.35 20.2M7.55 22.1Q8.1 21.9 8.25 21.75";
			defaultShape.name = "DefaultShape";
			defaultShape.displayName = "Default Shape";
			defaultShape.libraryName = defaultLibrary.name;
			defaultLibrary.items.addItem(defaultShape);
			
			defaultBackground = new ImageBackground();
			defaultBackground.name = "DefaultBackground";
			defaultBackground.displayName = "Default Background";
			defaultBackground.libraryName = defaultLibrary.name;
			defaultLibrary.items.addItem(defaultBackground);
		}
		
		public function getLibrary(libName:String):Library
		{
			return librariesDictionary[libName];
		}
		
		public function getFirstLibraryWithDisplayName(libDisplayName:String):Library
		{
			for each (var library:Library in this.libraries)
			{
				if (library.displayName==libDisplayName)
				{
					return library
				}
			}
			return null
		}
		
		
		/* Pre v1.5 libraries were stored in a sqlite database. When migrated to 1.5 and above
		   these libraries are stored in xml with the libraryName assigned to "prevName" in the new libraries */ 
		public function getLibraryWithPrevName(prevName:String):Library
		{
			for each (var library:Library in this.libraries)
			{
				if (library.prevName==prevName)
				{
					return library
				}
			}
			return null
		}
		
		
		public function getDefaultShape():LibraryItem
		{
			return defaultShape;
		}
		
		public function getDefaultBackground():LibraryItem
		{
			return defaultBackground;
		}
		
		public function getLibraryItem(libName:String, name:String):LibraryItem
		{
			var lib:Library = librariesDictionary[libName];
			if(lib == null)
			{
				return null;
			}
			return lib.getLibraryItem(name);
		}
		
		public function loadLibraries(registry:LibrariesRegistry, libraries:ArrayCollection):void
		{
			this.librariesRegistry = registry;
			this.libraries = libraries;
			var i:int = 0;
			for each(var library:Library in libraries)
			{
				var libInfo:LibraryInfo = librariesRegistry.libraries.getItemAt(i) as LibraryInfo; 
				i++;
				loadLibrary(libInfo, library);
			}
		}
		
		public function loadLibrary(libInfo:LibraryInfo, library:Library):void
		{
			librariesDictionary[library.name] = library;
			if(libInfo.enabled)
			{
				if(library.type == "backgrounds")
				{
					backgroundLibraries.addItem(library);
				}
				else
				{
					shapesLibraries.addItem(library);
				}
			}
		}
		
		public function registerItem(libName:String, libraryItem:LibraryItem):void
		{
			var lib:Library = librariesDictionary[libName];
			lib.items.addItem(libraryItem);
		}
		
		public function enableLibrary(libInfo:LibraryInfo):void
		{
			if(libInfo.enabled == false)
			{
				libInfo.enabled = true;
				var lib:Library = librariesDictionary[libInfo.name];
				if(libInfo.type == "backgrounds")
				{
					backgroundLibraries.addItem(lib);
				}
				else
				{
					shapesLibraries.addItem(lib);
				}
			}
		}
		
		public function disableLibrary(libInfo:LibraryInfo):void
		{
			libInfo.enabled = false;
			var lib:Library = getLibrary(libInfo.name);
			if (lib==null)
			{
				Logger.warn("disableLibrary() Couldn't find library by libInfo name: " + libInfo.name, this)
				return
			}
								
			if(libInfo.type == "backgrounds")
			{
				var index:int = backgroundLibraries.getItemIndex(lib);
				if (index>-1)
				{
					backgroundLibraries.removeItemAt(index);
				}
			}
			else
			{
				index = shapesLibraries.getItemIndex(lib);
				if (index>-1)
				{
					shapesLibraries.removeItemAt(index);
				}
			}
		}
		
		public function newLibrary(name:String, type:String):Library
		{
			var library:Library = new Library();
			library.custom = true;
			library.type = type;
			library.displayName = name;
			library.name = UIDUtil.createUID();
			libraries.addItem(library);
			
			var libInfo:LibraryInfo = new LibraryInfo();
			libInfo.custom = true;
			libInfo.type = type;
			libInfo.displayName = name;
			libInfo.name = library.name;
			libInfo.enabled = true;
			librariesRegistry.libraries.addItem(libInfo);
			
			loadLibrary(libInfo,library);
			
			if(library.type == "backgrounds")
			{
				selectedLibraryTypeIndex = 1;
				selectedBackgroundsLibraryIndex = backgroundLibraries.getItemIndex(library);
			}
			else 
			{
				selectedLibraryTypeIndex = 0;
				selectedShapesLibraryIndex = shapesLibraries.getItemIndex(library);
			}
			return library;
		}
		
		public function importLibrary(library:Library):void
		{
			var oldLib:Library = getLibrary(library.name);
			var libInfo:LibraryInfo ;
			if(oldLib == null)
			{
				libInfo = new LibraryInfo();
				libInfo.custom = library.custom;
				libInfo.type = library.type;
				libInfo.displayName = library.displayName;
				libInfo.name = library.name;
				libInfo.enabled = true;
				librariesRegistry.libraries.addItem(libInfo);
				libraries.addItem(library);
				loadLibrary(libInfo,library);
			}
			else
			{
				libInfo = librariesRegistry.getLibraryInfo(library.name);
				libInfo.custom = library.custom;
				libInfo.type = library.type;
				libInfo.displayName = library.displayName;
				libInfo.name = library.name;
				
				var index:int = libraries.getItemIndex(oldLib);
				libraries.setItemAt(library, index);
				librariesDictionary[library.name] = library;
				if(libInfo.enabled)
				{
					if(libInfo.type == "backgrounds")
					{
						index = backgroundLibraries.getItemIndex(oldLib);
						backgroundLibraries.setItemAt(library, index);
					}
					else
					{
						index = shapesLibraries.getItemIndex(oldLib);
						shapesLibraries.setItemAt(library, index);
					}
				}
			}
		}
		
		public function removeLibrary(libInfo:LibraryInfo):Library
		{
			var lib:Library = getLibrary(libInfo.name);
			disableLibrary(libInfo);
						
			//DMcQ: Match library by name to delete rather than using same index from libInfo...since this might not always match up
			//      using LibInfo's index to find Library was problematic when library couldn't be loaded and the indices didn't match
			//      (although now I've changed this as well so LibInfo is deleted when library can't be loaded))
			for each (var library:Library in libraries)
			{
				if (library.name == libInfo.name)
				{
					libraries.removeItemAt(libraries.getItemIndex(library))
					break
				}
			}
			
			delete librariesDictionary[libInfo.name];
			librariesRegistry.libraries.removeItemAt(librariesRegistry.libraries.getItemIndex(libInfo));
			return lib;
			
		}
		
		public function renameLibrary(libInfo:LibraryInfo, name:String):Library
		{
			var lib:Library = librariesDictionary[libInfo.name];
			lib.displayName = name;
			libInfo.displayName = name;
			return lib;
		}
		
		public function addNewLibraryItem(lib:Library, name:String, displayName:String, path:String, importType:String):void
		{
			var libItem:LibraryItem;
			if(lib.type == "backgrounds")
			{
				if (importType==LibraryItemEvent.IMPORT_TYPE_SWF)
				{
					var bgSWF:SWFBackground = new SWFBackground();
					bgSWF.thumbnailPath = path;
					bgSWF.path = path;			
					libItem = LibraryItem(bgSWF)			
				}
				else if (importType==LibraryItemEvent.IMPORT_TYPE_IMAGE)
				{
					var bgImage:ImageBackground = new ImageBackground();	
					bgImage.thumbnailPath = path;
					bgImage.path = path;			
					libItem = LibraryItem(bgImage)
				}
				else
				{
					throw new Error("Couldn't add library background item. Unrecognized image type " + importType + ".")
				}
								
				libItem.libraryName = lib.name;
				libItem.displayName = displayName;
				libItem.name = name;
				libItem = bgImage;
			}
			else
			{				
				if (importType==LibraryItemEvent.IMPORT_TYPE_SWF)
				{
					var swfShape:SWFShape = new SWFShape();						
					swfShape.path = path;				
					libItem = LibraryItem(swfShape)			
				}
				else if (importType==LibraryItemEvent.IMPORT_TYPE_IMAGE)
				{
					var imageShape:ImageShape = new ImageShape();						
					imageShape.path = path;
					libItem = LibraryItem(imageShape)
				}
				else
				{
					throw new Error("Couldn't add library item. Unrecognized image type " + importType + ".")
				}
				
				libItem.libraryName = lib.name;
				libItem.displayName = displayName;
				libItem.name = name;
				
				libItem = libItem;
			}
						
			lib.items.addItem(libItem);
			
			
		}
		
		public function removeLibraryItem(lib:Library, item:LibraryItem):void
		{
			lib.items.removeItemAt(lib.items.getItemIndex(item));	
		}
		
		public function renameLibraryItem(lib:Library, item:LibraryItem, newName:String):void
		{
			item.displayName = newName;
		}

		
		public function addLibraryItem(name:String, libItem:LibraryItem):void
		{
			var lib:Library = getLibrary(name);
			lib.items.addItem(libItem);
		}
		
		public function getDefaultBackgroundModel():SDBackgroundModel
		{
			var sdBackgroundModel:SDBackgroundModel = new SDBackgroundModel();
			sdBackgroundModel.libraryName = "default";
			sdBackgroundModel.symbolName = "DefaultBackground";
			return sdBackgroundModel;
		}
		
		public function getDefaultSDObjectModel():SDObjectModel
		{
			var sdSymbolModel:SDSymbolModel = new SDSymbolModel();
			sdSymbolModel.libraryName = "default";
			sdSymbolModel.symbolName = "DefaultShape";
			sdSymbolModel.text = "?"
			sdSymbolModel.colorizable = true;
			sdSymbolModel.textAlign = "center"
			sdSymbolModel.fontSize = 12
			sdSymbolModel.fontFamily = "Arial"
			sdSymbolModel.textPosition = SDSymbolModel.TEXT_POSITION_MIDDLE
			sdSymbolModel.color = 0xcccccc;
			sdSymbolModel.width = 30;
			sdSymbolModel.height = 50;
			return sdSymbolModel
		}
		
		private var chalkboard:ByteArray = new Chalkboard() as ByteArray;
		
		public function getAssetData(libItem:LibraryItem, path:String):Object
		{
			if(libItem.libraryName == "local")
				return resourceDictionary[path];
			if(libItem.libraryName =="default")
				return chalkboard;
			else
//				return ApplicationModel.baseStorageDir.resolvePath("libraries/" + libItem.libraryName + "/" + path).url;
   			return remoteLibraryDelegateManager.assetPath(libItem);
		}
		
		public static function getAssetPath(libItem:LibraryItem, path:String):String
		{
//			return ApplicationModel.baseStorageDir.resolvePath("libraries/" + libItem.libraryName + "/" + path).url;
			return remoteLibraryDelegateManager.assetPath(libItem);
		}
		
		private function getByteContent(libName:String, path:String):ByteArray
		{
//			var file:File = ApplicationModel.baseStorageDir.resolvePath("libraries/" + libName + "/" + path);
//			var readStream:FileStream = new FileStream();
//			readStream.open(file, FileMode.READ);
//			var content:ByteArray = new ByteArray();
//			readStream.readBytes(content, 0, readStream.bytesAvailable);
//			readStream.close();
//			return content;
			return null;
		}
		
		private function getExt(path:String):String
		{
			var arr:Array = path.split(".");
			return arr[arr.length - 1];
		}
		
		public function importToLocalLibrary(item:LibraryItem):LibraryItem
		{
			var lib:Library = getLibrary(item.libraryName);
			//Import only custom assets
			if(!lib.custom)
				return item;
			var result:LibraryItem = null;			
			result = CopyUtil.clone(item) as LibraryItem;
			result.libraryName = "local";
			result.name = UIDUtil.createUID();
			var path:String;
			if(result is ImageBackground)
			{
				path = (item as ImageBackground).path;
				var pathExt:String = getExt(path);
				path = result.name + "." + pathExt;
				(result as ImageBackground).path = path;
				(result as ImageBackground).thumbnailPath = path;
				resourceDictionary[path] = getByteContent(item.libraryName, (item as ImageBackground).path);
			}
			else if(result is ImageShape)
			{
				path = (item as ImageShape).path
				pathExt = getExt(path);
				path = result.name + "." + pathExt;
				(result as ImageShape).path = path;
				resourceDictionary[path] = getByteContent(item.libraryName, (item as ImageShape).path);
			}
			else if(result is SWFShape)
			{
				path = (item as SWFShape).path
				pathExt = getExt(path);
				path = result.name + "." + pathExt;
				(result as SWFShape).path = path;
				resourceDictionary[path] = getByteContent(item.libraryName, (item as SWFShape).path);
			}
			else if (result is SWFBackground)
			{
				path = (item as SWFBackground).path
				pathExt = getExt(path);
				path = result.name + "." + pathExt;
				(result as SWFBackground).path = path;
				resourceDictionary[path] = getByteContent(item.libraryName, (item as SWFBackground).path);
			}
			else
			{
				throw new Error("Can't import library item into local library. Unrecognized type: " + result)
			}
				
				
				
			localLibrary.items.addItem(result);
			return result;
		}
		
		public function addToLocalLibrary(item:LibraryItem, data:ByteArray):void
		{
			item.libraryName = "local";
			if(data)
			{
				resourceDictionary[Object(item).path]  = data;
			}
			localLibrary.items.addItem(item);
		}

		public function clearLocalLibrary():void
		{
			localLibrary.items.removeAll();
			resourceDictionary = new Dictionary();
		}
		
		public var selectedLibraryTypeIndex:int = 0;
		
		public var selectedShapesLibraryIndex:int = 0;
		
		public var selectedBackgroundsLibraryIndex:int = 0;

	}
}