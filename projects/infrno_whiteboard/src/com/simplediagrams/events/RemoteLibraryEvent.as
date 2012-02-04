package com.simplediagrams.events
{
	import com.simplediagrams.business.RemoteLibraryDelegate;
	import com.simplediagrams.model.libraries.LibrariesRegistry;
	import com.simplediagrams.model.libraries.Library;
	import com.simplediagrams.model.libraries.LibraryInfo;
	
	import flash.events.Event;

	public class RemoteLibraryEvent extends Event
	{
		public static const PROCESS_LIBRARY_REGISTRY:String = "rle_ProcessLibraryRegistry";
		public static const PROCESS_LIBRARY:String = "rle_ProcessLibrary";
		public static const ON_FAULT:String = "rle_OnFault";
		
		public var librariesRegistry:LibrariesRegistry;
		public var library:Library;
		public var libInfo:LibraryInfo;
		public var remoteLibraryDelegate:RemoteLibraryDelegate;
		public var error:String;
		
		public function RemoteLibraryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}