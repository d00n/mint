package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class LibraryEvent extends Event
	{
		public static const MANAGE_LIBRARIES:String = "manageLibraries"
		public static const LIBRARIES_UPDATED:String = "librariesUpdated"
		
		public function LibraryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}