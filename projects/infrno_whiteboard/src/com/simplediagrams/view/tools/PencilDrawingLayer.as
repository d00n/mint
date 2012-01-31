package com.simplediagrams.view.tools
{
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.PathSegment;
	import com.simplediagrams.model.tools.PencilTool;
	import com.simplediagrams.model.tools.ToolBase;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	import spark.core.SpriteVisualElement;
	
	public class PencilDrawingLayer extends SpriteVisualElement
	{
		public function PencilDrawingLayer()
		{
			super();
		}

		private var _tool:PencilTool;
		
		private var _path:ArrayCollection;

		public function get tool():ToolBase
		{
			return _tool;
		}

		public function set tool(value:ToolBase):void
		{
			if(_tool)
			{
				_tool.removeEventListener(Event.CHANGE, toolChange);
			}
			_tool = value as PencilTool;
			if(_tool)
			{
				path = _tool.segments;
				_tool.addEventListener(Event.CHANGE, toolChange);
			}
			else
				graphics.clear();
		}
		
		public function toolChange(event:Event):void
		{
			scaleX = _tool.scaleX;
			scaleY = _tool.scaleY;
			drawPath();
		}
		
		public function get path():ArrayCollection
		{
			return _path;
		}

		public function set path(value:ArrayCollection):void
		{
			if(_path)
				_path.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onPathChange);
			_path = value;
			drawPath();
			if(_path)
				_path.addEventListener(CollectionEvent.COLLECTION_CHANGE, onPathChange);
		}
		
		private function onPathChange(event:CollectionEvent):void
		{
			switch(event.kind)
			{
				case CollectionEventKind.ADD: 
					for each(var segment:PathSegment in event.items)
					{
						if(segment.type == PathSegment.MOVE)
							graphics.moveTo(segment.x, segment.y);
						else
							graphics.lineTo(segment.x, segment.y);
					}
					break;
				default: drawPath();break;
			}
		}
		
		public function drawPath():void
		{
			graphics.clear();
			graphics.lineStyle(1, _tool.color);
			for each(var segment:PathSegment in _path)
			{
				if(segment.type == PathSegment.MOVE)
					graphics.moveTo(segment.x, segment.y);
				else
					graphics.lineTo(segment.x, segment.y);
			}
		}

	}
}