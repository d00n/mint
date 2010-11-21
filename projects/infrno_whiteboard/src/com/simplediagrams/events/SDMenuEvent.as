package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class SDMenuEvent extends Event
	{
		
		public static const MENU_COMMAND:String = "menuCommand"
		
		public var command:String 
			
		public function SDMenuEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}