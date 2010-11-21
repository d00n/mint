package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class CreateCustomLibraryEvent extends Event
	{
		public static const SHOW_CREATE_CUSTOM_LIBRARY_DIALOG:String = "showCreateCustomLibraryDialog"
		
		public static const CREATE_CUSTOM_LIBRARY:String = "createCustomLibrary"
		public static const CUSTOM_LIBRARY_CREATED:String = "customLibraryCreated"
		
		public var displayName:String = "My library"
		public var description:String = ""
			
		public function CreateCustomLibraryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}