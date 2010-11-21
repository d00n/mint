package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class RenameItemInCustomLibrary extends Event
	{
		
		public static const SHOW_RENAME_CUSTOM_SYMBOL_DIALOG:String = "showRenameCustomSymbolDialog"
			
		public static const RENAME_ITEM:String = "renameItemInCustomLibrary"
		public static const ITEM_RENAMED:String = "itemRenamedInCustomLibrary"
		
		public var libraryName:String = ""
		public var oldSymbolName:String = ""
		public var newSymbolName:String = ""
			
		public function RenameItemInCustomLibrary(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}