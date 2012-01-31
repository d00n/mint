package com.simplediagrams.model.tools
{	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;

	public class ToolBase extends EventDispatcher
	{
		public function ToolBase()
		{
		}
		

		public function activateTool():void
		{
			
		}
		
		public function deactivateTool():void
		{
			
		}
		
		private var _dispatcher:IEventDispatcher;
		
		public function get dispatcher():IEventDispatcher
		{
			return _dispatcher;
		}
		
		public function set dispatcher(value:IEventDispatcher):void
		{
			_dispatcher = value;
		}
		
		public function onMouseClick(toolMouseInfo:ToolMouseInfo):void
		{
			
		}
		
		public function onMouseDown(toolMouseInfo:ToolMouseInfo):void
		{
			
		}
		
		public function onMouseUp(toolMouseInfo:ToolMouseInfo):void
		{
			
		}
		
		public function onRollOut():void
		{
			
		}
		
		
		public function onMouseMove(toolMouseInfo:ToolMouseInfo):void
		{
			
		}
		
	}
}