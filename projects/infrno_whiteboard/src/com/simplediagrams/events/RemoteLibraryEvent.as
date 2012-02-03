package com.simplediagrams.events
{
	import com.simplediagrams.model.libraries.LibrariesRegistry;
	
	import flash.events.Event;

	public class RemoteLibraryEvent extends Event
	{
		public static const PROCESS_LIBRARY_REGISTRY:String = "rle_ProcessLibraryRegistry";
		
		public var librariesRegistry:LibrariesRegistry;
		
		public function RemoteLibraryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}