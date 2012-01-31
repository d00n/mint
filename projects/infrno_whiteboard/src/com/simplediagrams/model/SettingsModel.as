package com.simplediagrams.model
{
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.vo.RecentFileVO;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.text.engine.FontWeight;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.utils.ObjectUtil;

	[Bindable]
	public class SettingsModel extends EventDispatcher
	{
				
		public var recentDiagramsAC:ArrayCollection = new ArrayCollection()
		
		public var hideBGOnExport:Boolean = false
		
		//remember the line style last selected (or loaded from settings)
		//this is updated by controller
		public var defaultStartLineStyle:uint = SDLineModel.LINE_ENDING_NONE
		public var defaultLineStyle:uint = SDLineModel.LINE_STYLE_SOLID
		public var defaultEndLineStyle:uint = SDLineModel.LINE_ENDING_ARROW
		public var defaultTextPosition:String = SDSymbolModel.TEXT_POSITION_TOP
		
		protected var _defaultImageStyle:String = SDImageModel.STYLE_BORDER_AND_TAPE
		protected var _defaultLineWeight:uint = 1		
		protected var _defaultSymbolLineWeight:uint = 1		
		protected var _defaultFontSize:Number = 12
		protected var _defaultTextAlign:String = "left"
		protected var _defaultFontWeight:String = "normal"
		protected var _defaultFontFamily:String = ApplicationModel.DEFAULT_SYSTEM_FONT
			
		protected var _defaultPencilLineWeight:uint = 1	
			
		protected var _defaultDirectory:File = File.userDirectory.resolvePath("SimpleDiagrams");
		protected var _defaultExportDirectory:File = File.userDirectory.resolvePath("SimpleDiagrams");
		
		protected var _defaultDiagramWidth:Number = 1800
		protected var _defaultDiagramHeight:Number = 1200
			
		protected var _defaultStickyNoteBGColor:uint = 0xEEEDA2	
		protected var _defaultStickyNoteWidth:uint = 150;
		protected var _defaultStickyNoteHeight:uint = 150;
			
						
		protected var _defaultIndexCardBGColor:uint = 0xFFFFFF
		protected var _defaultIndexCardWidth:uint = 300;
		protected var _defaultIndexCardHeight:uint = 200;
		public var defaultIndexCardShowTape:Boolean = true
		
		
		public var appVersion:String;
		public var promptDatabaseImport:Boolean = true;
		
		protected var _selectedColor:uint = 0xffffff;
		
		public function SettingsModel()
		{
			if (!_defaultDirectory.exists)
			{
				_defaultDirectory.createDirectory()
			}		
		}
		
		public function get selectedColor():uint
		{
			return _selectedColor
		}
		
		//we do a custom event here because we want one to launch even if color was same as previous value
		//If color chip is white but user selected a non-white symbol, selecting white on the chip again has to change the color
		//and therefore we need an event launched, even though the value is the same
		//(see http://nwebb.co.uk/blog/?p=227)
		
		[Bindable(event="colorChipSelectedColorChange")]
		public function set selectedColor(value:uint):void
		{
			_selectedColor = value
			dispatchEvent(new Event("colorChipSelectedColorChange"));
		}
		

		
		
		
		public function set defaultDiagramWidth(value:Number):void
		{
			if (value>0)
			{
				_defaultDiagramWidth = value
			}
		}
		
		
		public function get defaultDiagramWidth():Number
		{
			return _defaultDiagramWidth 
		}
		
		
		
		public function set defaultDiagramHeight(value:Number):void
		{
			if (value>0)
			{
				_defaultDiagramHeight = value
			}
		}
		
		
		public function get defaultDiagramHeight():Number
		{
			return _defaultDiagramHeight 
		}
		
		
		
		
		public function set defaultDirectoryPath(s:String):void
		{
			try
			{
				//if path doesn't exist setting the file object with throw an error
				var f:File = File.userDirectory
				f.nativePath = s
				_defaultDirectory.nativePath = s
			}
			catch(err:Error)
			{
				
			}			
		}
		
		public function get defaultDirectoryPath():String
		{
			return _defaultDirectory.nativePath
		}
		
		public function get defaultDirectory():File
		{
			return _defaultDirectory
		}
		
		
		
		
		public function set defaultExportDirectoryPath(s:String):void
		{
			try
			{
				//if path doesn't exist setting the file object with throw an error
				var f:File = File.userDirectory
				f.nativePath = s
				_defaultExportDirectory.nativePath = s
			}
			catch(err:Error)
			{
				
			}			
		}
		
		public function get defaultExportDirectoryPath():String
		{
			return _defaultExportDirectory.nativePath
		}
		
		public function get defaultExportDirectory():File
		{
			return _defaultExportDirectory
		}
		
		
				
		
		public function set defaultImageStyle(styleName:String):void
		{			
			if (styleName=="")
			{
				styleName = SDImageModel.STYLE_BORDER_AND_TAPE //this is more for backwards compatability, since before we tracked this everything was saved as "photoStyle" which is BORDERS_AND_TAPE
			}
			_defaultImageStyle = styleName
		}
		
		public function get defaultImageStyle():String
		{
			return _defaultImageStyle
		}
		
		
		
		public function get defaultFontSize():Number
		{
			return _defaultFontSize
		}
		
		public function set defaultFontSize(value:Number):void
		{
			if (value<=3) value = 12 
			_defaultFontSize=value
		}
		
		public function get defaultFontWeight():String
		{
			return _defaultFontWeight
		}
		
		public function set defaultFontWeight(value:String):void
		{
			if (value == FontWeight.BOLD || value == FontWeight.NORMAL)	_defaultFontWeight=value		
		}
		
		
		public function get defaultFontFamily():String
		{
			return _defaultFontFamily
		}
		
		public function set defaultFontFamily(value:String):void
		{
			if (value=="")
			{
				_defaultFontFamily = ApplicationModel.DEFAULT_SYSTEM_FONT
			}
			else
			{
				_defaultFontFamily=value
			}
					
		}
		
		
		public function get defaultPencilLineWeight():Number
		{
			return _defaultPencilLineWeight
		}
		
		public function set defaultPencilLineWeight(value:Number):void
		{
			if (value<=0) value=1
			if (value>100) value=100
			_defaultPencilLineWeight=value
		}
		
		public function get defaultLineWeight():Number
		{
			return _defaultLineWeight
		}
		
		public function set defaultLineWeight(value:Number):void
		{
			if (value<=0) value=1
			if (value>100) value=100
			_defaultLineWeight=value
		}
		
		public function get defaultSymbolLineWeight():Number
		{
			return _defaultSymbolLineWeight
		}
		
		public function set defaultSymbolLineWeight(value:Number):void
		{
			if (value<=0) value=1
			if (value>10) value=10
			_defaultSymbolLineWeight=value
		}
		
		
		public function get defaultTextAlign():String
		{
			return _defaultTextAlign
		}
		
		public function set defaultTextAlign(value:String):void
		{
			if (value=="left" || value=="right" || value=="center" || value=="justify")
			{
				_defaultTextAlign=value
			}
			else
			{
				_defaultTextAlign = "left"
				Logger.warn("unrecognized textAlign value: " + value, this)
			}			
		}
		
		public function clearRecentDiagrams():void
		{
			recentDiagramsAC.removeAll()
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
		
		public function clearAllRecent():void
		{
			recentDiagramsAC.removeAll();
		}
		
		public function loadInitialData():void
		{			
			loadDiagrams()
		}
		
		
		public function loadDiagrams():void
		{		
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
		
		
		
		
		/* Sticky note */		
		
		public function set defaultStickyNoteHeight(value:uint):void
		{
			if (value>0)
			{
				_defaultStickyNoteHeight = value
			}
		}
		
		public function get defaultStickyNoteHeight():Number
		{
			return _defaultStickyNoteHeight 
		}
		
		
		public function set defaultStickyNoteWidth(value:uint):void
		{
			if (value>0)
			{
				_defaultStickyNoteWidth = value
			}
		}
		
		public function get defaultStickyNoteWidth():Number
		{
			return _defaultStickyNoteWidth 
		}
		
		
		
		public function set defaultStickyNoteBGColor(value:uint):void
		{
			if (value>=0 && value <= 0xFFFFFF)
			{
				_defaultStickyNoteBGColor = value
			}
		}
		
		
		public function get defaultStickyNoteBGColor():Number
		{
			return _defaultStickyNoteBGColor 
		}
		
		
		
		/* Index card */
		
		
		
		public function set defaultIndexCardBGColor(value:uint):void
		{
			if (value>=0 && value <= 0xFFFFFF)
			{
				_defaultIndexCardBGColor = value
			}
		}
		
		public function get defaultIndexCardBGColor():Number
		{
			return _defaultIndexCardBGColor 
		}
		
		
		
		public function set defaultIndexCardHeight(value:uint):void
		{
			if (value>0)
			{
				_defaultIndexCardHeight = value
			}
		}
		
		public function get defaultIndexCardHeight():Number
		{
			return _defaultIndexCardHeight 
		}
		
		
		public function set defaultIndexCardWidth(value:uint):void
		{
			if (value>0)
			{
				_defaultIndexCardWidth = value
			}
		}
		
		public function get defaultIndexCardWidth():Number
		{
			return _defaultIndexCardWidth 
		}
		
		
		
	}
}