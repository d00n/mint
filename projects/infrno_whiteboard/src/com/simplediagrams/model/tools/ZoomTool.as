package com.simplediagrams.model.tools
{
	import com.simplediagrams.events.ZoomEvent;
	
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class ZoomTool extends ToolBase
	{
		public function ZoomTool()
		{
		}
		
		
		public override function onMouseClick(toolMouseInfo:ToolMouseInfo):void
		{
			if (toolMouseInfo.shiftKey)
			{
				var zoomOutEvent:ZoomEvent = new ZoomEvent(ZoomEvent.ZOOM_OUT, true)
				dispatcher.dispatchEvent(zoomOutEvent)
			}
			else
			{
				var zoomInEvent:ZoomEvent = new ZoomEvent(ZoomEvent.ZOOM_IN, true)
				dispatcher.dispatchEvent(zoomInEvent)
			}
		}
	}
}