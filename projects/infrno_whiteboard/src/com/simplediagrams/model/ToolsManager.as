package com.simplediagrams.model
{
	import com.simplediagrams.model.tools.LineTool;
	import com.simplediagrams.model.tools.PencilTool;
	import com.simplediagrams.model.tools.SelectTool;
	import com.simplediagrams.model.tools.TextTool;
	import com.simplediagrams.model.tools.ToolBase;
	import com.simplediagrams.model.tools.ToolMouseInfo;
	import com.simplediagrams.model.tools.Tools;
	import com.simplediagrams.model.tools.ZoomTool;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import org.swizframework.events.BeanEvent;

	public class ToolsManager extends EventDispatcher
	{
		public function ToolsManager()
		{
			dictionaryTools[Tools.POINTER_TOOL] = new SelectTool;
			dictionaryTools[Tools.PENCIL_TOOL] =  new PencilTool;
			dictionaryTools[Tools.TEXT_TOOL] =  new TextTool;
			dictionaryTools[Tools.PICTURE_TOOL] =  new ToolBase;
			dictionaryTools[Tools.LINE_TOOL] =  new LineTool;
			dictionaryTools[Tools.ZOOM_TOOL] =  new ZoomTool;
			selectedTool = Tools.POINTER_TOOL;
		}
		
		private var _dispatcher:IEventDispatcher;
		
		private var dictionaryTools:Dictionary = new Dictionary();
		
		
		private var _selectedTool:String = Tools.POINTER_TOOL;

		[Bindable("change")]
		public function get selectedTool():String
		{
			return _selectedTool;
		}

		public function set selectedTool(value:String):void
		{
			if(_selectedTool == value && _selectedToolImpl )
				return;
			_selectedTool = value;
			if(_selectedToolImpl)
				_selectedToolImpl.deactivateTool();
			_selectedToolImpl = dictionaryTools[value];
			dispatchEvent(new Event(Event.CHANGE));
			if(_selectedToolImpl)
				_selectedToolImpl.activateTool();
		}
		
		private var _selectedToolImpl:ToolBase;
		
		[Bindable("change")]
		public function get selectedToolImpl():ToolBase
		{
			return _selectedToolImpl;
		}

		[Dispatcher]
		public function get dispatcher():IEventDispatcher
		{
			return _dispatcher;
		}

		public function set dispatcher(value:IEventDispatcher):void
		{
			_dispatcher = value;
			initTools();
		}
		
		private var _selectionModel:SelectionModel;
		
		private function initTools():void
		{
			for each(var toolBase:ToolBase in dictionaryTools)
			{
				toolBase.dispatcher = _dispatcher;
			}
		}
		
		public function onMouseClick(toolMouseInfo:ToolMouseInfo):void
		{
			_selectedToolImpl.onMouseClick(toolMouseInfo);
		}
		
		public function onMouseDown(toolMouseInfo:ToolMouseInfo):void
		{
			_selectedToolImpl.onMouseDown(toolMouseInfo);
		}
		
		public function onMouseUp(toolMouseInfo:ToolMouseInfo):void
		{
			_selectedToolImpl.onMouseUp(toolMouseInfo);
		}
		
		public function onRollOut():void
		{
			_selectedToolImpl.onRollOut();
		}
		
		public function onMouseMove(toolMouseInfo:ToolMouseInfo):void
		{
			_selectedToolImpl.onMouseMove(toolMouseInfo);
		}
	}
}