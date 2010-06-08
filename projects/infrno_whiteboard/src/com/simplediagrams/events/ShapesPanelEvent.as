package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class ShapesPanelEvent extends Event
	{
		
		public static const TOGGLE_DISPLAY:String = "shapesPanelEvent_ToggleDisplay";

		public function ShapesPanelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		

	}
}