package com.simplediagrams.events
{
	import com.simplediagrams.model.libraries.LibraryInfo;
	
	import flash.events.Event;
//	import flash.filesystem.File;
	
	public class LibraryEvent extends Event
	{
		public static const ENABLE_LIBRARY:String = "enableLibrary";
		public static const DISABLE_LIBRARY:String = "disableLibrary";
		public static const REMOVE_LIBRARY:String = "removeLibrary";
		public static const RENAME_LIBRARY:String = "renameLibrary";
		public static const EXPORT_LIBRARY:String = "exportLibrary";
		public static const ADD_LIBRARY:String = "addLibrary";
		public static const IMPORT_LIBRARY:String = "importLibrary";
		public static const IMPORT_LIBRARIES_DATABASE:String = "importLibrariesDatabase";
		public static const IMPORT_DEFAULT_DATABASE:String = "importDefaultDatabase";
		public static const COPY_LIBRARIES:String = "copyLibraries";

		
//		public var libraryFile:File //if set, import this library during IMPORT_LIBRARY event
		
		public var libraryInfo:LibraryInfo;
		public var name:String;
		public var libType:String;

		public function LibraryEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}