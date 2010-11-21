package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class DeleteItemFromCustomLibrary extends Event
	{
		public static const SHOW_DELETE_CUSTOM_SYMBOL_DIALOG:String = "showDeleteCustomSymbolDialog"
		
		public static const DELETE_ITEM:String = "deleteItemFromCustomLibrary"
		public static const ITEM_DELETED:String = "itemDeletedFromCustomLibrary"
			
		public var libraryName:String
		public var symbolName:String 
		
		public function DeleteItemFromCustomLibrary(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}