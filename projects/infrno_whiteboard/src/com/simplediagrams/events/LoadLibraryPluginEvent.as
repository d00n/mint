package com.simplediagrams.events
{
	import flash.events.Event;
//	import flash.filesystem.File;
	
	public class LoadLibraryPluginEvent extends Event
	{
		public static const LOAD_LIBRARY_PLUGIN_FROM_FILE:String = "loadLibraryPluginFromFile"
		public static const LIBRARY_PLUGIN_LOADED:String = "libraryPluginLoaded"
		
//		public var libraryFile:File
		
			
		public function LoadLibraryPluginEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}