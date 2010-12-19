package com.simplediagrams.model
{

	import com.simplediagrams.errors.SDObjectModelNotFoundError;
	import com.simplediagrams.model.libraries.*;
	import com.simplediagrams.shapelibrary.communication.QuestionMark;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.vo.RecentFileVO;
	
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.effects.easing.Back;
	import mx.utils.ObjectUtil;


	[Bindable]
	public class LibraryManager extends EventDispatcher 
	{		
		
		public static const LIBRARY_TYPE_CUSTOM:String = "Custom";
		public static const LIBRARY_TYPE_PLUGIN:String = "Plugin";
		
		[Inject]
		public var diagramModel:DiagramModel;
		
		//some default background images
		[Embed(source='assets/img/backgrounds/chalkboard_tile.png')]
		public var chalkboardBG:Class;
		
		[Embed(source='assets/img/backgrounds/whiteboard_tile.png')]
		public var whiteboardBG:Class;
		
		public var diagramsAC:ArrayCollection = new ArrayCollection()
		public var recentDiagramsAC:ArrayCollection = new ArrayCollection()
		
		
		public var availableForDownloadLibrariesAC:ArrayCollection = new ArrayCollection()
		protected var rememberShowInPanelSettingsArr:Array = []	
		
		public var panelNeedsUpdating:Boolean = true //this flag helps the panel know to update if it missed the actual event (because it wasn't an active state and therefore wasn't wired)
		public var backgroundPanelNeedsUpdating:Boolean = true	
			
			
		public var librariesAC:ArrayCollection = new ArrayCollection()
			
		//symbol libraries
		public var libraryBasic:LibraryBasic = new LibraryBasic()	
		public var libraryBiz:LibraryBiz = new LibraryBiz()	
		public var libraryMeetings:LibraryMeetings = new LibraryMeetings()	
		public var libraryCommunication:LibraryCommunication = new LibraryCommunication()	
		public var libraryMaterials:LibraryMaterials = new LibraryMaterials()	
					
		//background libraries
		public var backgroundLibraryBasic:BackgroundLibraryBasic = new BackgroundLibraryBasic()
		
			
		public static function getSymbolClass(fullyQualifiedSymbolName:String):Class
		{
			var symbolClass:Class = getDefinitionByName(fullyQualifiedSymbolName) as Class
			if (symbolClass == null)
			{
				return QuestionMark
			}
			return symbolClass
		}
			
			
			
		public function LibraryManager()
		{		
			//symbols
			librariesAC.addItem(libraryBasic)
			librariesAC.addItem(libraryBiz)
			librariesAC.addItem(libraryMeetings)
			librariesAC.addItem(libraryCommunication)
			
			//backgrounds
			librariesAC.addItem(backgroundLibraryBasic)	
				
			librariesAC.refresh()
		}
		
		public function addLibrary(library:ILibrary):void
		{
			librariesAC.addItem(library)
			librariesAC.refresh()
		}
		
		public function removeLibrary(libraryName:String):void
		{
			var len:uint = librariesAC.length
			for(var i:uint=0; i<len;i++)
			{
				var library:ILibrary = librariesAC.getItemAt(i) as ILibrary
				if (library.libraryName == libraryName)
				{
					librariesAC.removeItemAt(i)
					librariesAC.refresh()
					return
				}
			}			
		}
						
		
		public function getSDObjectModel(libraryName:String, templateName:String):SDObjectModel
		{
			for each (var lib:ILibrary in librariesAC)
			{				
				if (libraryName==lib.libraryName)
				{
					var sdObjectModel:SDObjectModel = lib.getSDObjectModel(templateName)					
					return sdObjectModel
				}
			}
			
			Logger.warn("Couldn't find SDObject for libraryName: " + libraryName + " templateName: " + templateName)
			throw new SDObjectModelNotFoundError
		}
	
		
		/* Return the default "missing" object */
		public function getDefaultSDObjectModel():SDObjectModel
		{
			var sdSymbolModel:SDSymbolModel = libraryBasic.getSDObjectModel("Square") as SDSymbolModel
			sdSymbolModel.text = "?"
			sdSymbolModel.colorizable = true
			sdSymbolModel.color = diagramModel.getColor();
			sdSymbolModel.textAlign = "center"
			sdSymbolModel.fontSize = 12
			sdSymbolModel.fontFamily = "Arial"
			sdSymbolModel.textPosition = SDObjectModel.TEXT_POSITION_MIDDLE
			sdSymbolModel.color = diagramModel.getColor();
			return sdSymbolModel
		}
		
	
		
		public function getLibraryByFileName(fileName:String):ILibrary
		{
			for each (var lib:ILibrary in librariesAC)
			{
				if (lib.fileName==fileName)
				{
					return lib
				}
			}
			return null
		}
		
		public function loadInitialData():void
		{			
			loadDiagrams()
		}
				
										
		public function loadDiagrams():void
		{		
			recentDiagramsAC = new ArrayCollection(diagramsAC.source.concat())
			sortRecentDiagrams()
		}
		
		public function sortRecentDiagrams():void
		{
			var sort:Sort = new Sort();
	    	sort.compareFunction = sortDiagramUpdatedAt;
	    	recentDiagramsAC.sort = sort;
			recentDiagramsAC.refresh()						
		}
				
		private function sortDiagramUpdatedAt(a:Object, b:Object, fields:Array = null):int 
		{			
		    return ObjectUtil.dateCompare( b.updatedAt, a.updatedAt);
		}
		
		public function libraryExists(libraryName:String):Boolean
		{
			for each (var library:ILibrary in this.librariesAC)
			{
				if (library.libraryName == libraryName) return true
			}
			
			return false
		}
		
		public function libraryFileExists(fileName:String):Boolean
		{
			for each (var library:ILibrary in this.librariesAC)
			{
				if (library.fileName == fileName) return true
			}
			
			return false
		}
		
		public function addRecentFilePath(path:String, fileName:String):void
		{
			//don't add if already on list
			var len:uint = recentDiagramsAC.length
			for (var i:uint=0; i< len; i++)
			{
				if (recentDiagramsAC.getItemAt(i).data==path)
				{
					if (i==0) return
					//move path to top of list
					var vo:RecentFileVO = recentDiagramsAC.removeItemAt(i) as RecentFileVO
					recentDiagramsAC.addItemAt(vo, 0)
					return
				}
			}
			
			var recentFileVO:RecentFileVO = new RecentFileVO()
			recentFileVO.data = path
			recentFileVO.label = fileName
			recentDiagramsAC.addItemAt(recentFileVO, 0)
			if (recentDiagramsAC.length>10) recentDiagramsAC.removeItemAt(10)
			recentDiagramsAC.refresh()
		}
		
		
		public function rememberShowInPanelSettings():void
		{
			try
			{
				var len:uint = this.librariesAC.length
				for (var i:uint=0; i< len; i++)
				{
					rememberShowInPanelSettingsArr[i] = ILibrary(librariesAC.getItemAt(i)).showInPanel
				}	
			}
			catch(err:Error)
			{
				Logger.error("rememberShowInPanelSettings() Couldn't remember show in panel settings. Err:" + err, this)
			}
		}
		
		public function revertShowInPanelSettings():void
		{
			try
			{
				var len:uint = this.librariesAC.length
				for (var i:uint=0; i< len; i++)
				{
					ILibrary(librariesAC.getItemAt(i)).showInPanel = rememberShowInPanelSettingsArr[i] as Boolean
				}	
			}
			catch(err:Error)
			{
				Logger.error("revertShowInPanelSettings() Couldn't revert to show in panel settings. Err:" + err, this)
			}
		}
		
		
		public function clearRecentDiagrams():void
		{
			this.recentDiagramsAC.removeAll()
		}
		
		public function getCustomLibraryByID(libraryID:int):CustomLibrary
		{
			for each (var library:ILibrary in this.librariesAC)
			{
				if (library is CustomLibrary)
				{
					if (CustomLibrary(library).id==libraryID)
					{
						return library as CustomLibrary
					}
				}
			}
			return null
		}
		
		public function getCustomLibraryByName(libraryName:String):CustomLibrary
		{
			for each (var library:ILibrary in this.librariesAC)
			{
				if (library is CustomLibrary)
				{
					if (CustomLibrary(library).libraryName==libraryName)
					{
						return library as CustomLibrary
					}
				}
			}
			return null
		}
		
		public function getSDBackgroundModel(libraryName:String, bgName:String):SDBackgroundModel
		{
			for each (var lib:ILibrary in librariesAC)
			{				
				if (lib.isBackgroundsLibrary && libraryName==lib.libraryName)
				{
					var bg:SDBackgroundModel = lib.getSDObjectModel(bgName) as SDBackgroundModel				
					return bg
				}		
			}
			
			Logger.warn("Couldn't find SDBackgroundModel for libraryName: " + libraryName + " templateName: " + bgName, this)
			throw new SDObjectModelNotFoundError
		}
		
		public function getDefaultBackgroundModel():SDBackgroundModel
		{
			return backgroundLibraryBasic.getSDObjectModel("Chalkboard") as SDBackgroundModel
		}
		
		
	}
}