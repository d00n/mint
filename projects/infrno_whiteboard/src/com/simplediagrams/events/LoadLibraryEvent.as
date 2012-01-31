package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class LoadLibraryEvent extends Event
	{
		
		public static const LOADING_FINISHED:String = "looadingLibrariesFinished"
		//These events are only dispatched when loading a single file
		public static const LOADING_FAILED:String = "loadingLibrariesFailed"
		
		public var errorsEncountered:Boolean = false
		public var isInvalid:Boolean = false
			
		public function LoadLibraryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}