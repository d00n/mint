package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class UpdaterEvent extends Event
	{
		public static const CHECK_FOR_UPDATES:String = "checkForUpdates"
		
		public function UpdaterEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}