package com.simplediagrams.events
{
	import com.simplediagrams.model.libraries.Library;
	import com.simplediagrams.model.libraries.LibraryInfo;
	import com.simplediagrams.model.libraries.LibraryItem;
	
	import flash.events.Event;
	
	public class LibraryItemEvent extends Event
	{
		
		
		public static const REMOVE_LIBRARY_ITEM:String = "removeLibraryItem";
		public static const RENAME_LIBRARY_ITEM:String = "renameLibraryItem";
		public static const ADD_LIBRARY_ITEM:String = "addLibraryItem";
		public static const IMPORT_LIBRARY_ITEM:String = "importLibraryItem";

		public static const IMPORT_TYPE_SWF:String = "importTypeSWF"
		public static const IMPORT_TYPE_IMAGE:String = "importTypeImage"
		
		
		public var library:Library;
		public var name:String;
		public var item:LibraryItem;
		public var path:String;
		public var importType:String //uses import type constants above  
		
		public function LibraryItemEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}