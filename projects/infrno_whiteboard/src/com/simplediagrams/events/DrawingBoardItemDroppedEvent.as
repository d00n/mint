package com.simplediagrams.events
{
	import com.simplediagrams.model.libraries.LibraryItem;
	
	import flash.events.Event;
	
	public class DrawingBoardItemDroppedEvent extends Event
	{
		public static const LIBRARY_ITEM_ADDED:String = "libraryItemAdded"
		public static const IMAGE_ITEM_ADDED:String = "imageItemAdded"
		public static const LINE_ITEM_ADDED:String = "lineItemAdded"
		public static const STICKY_NOTE_ADDED:String = "stickyNoteAdded"
		public static const INDEX_CARD_ADDED:String = "indexCardAdded"
		public static const NAPKIN_ADDED:String = "napkinAdded"
		public static const CHAT_VIEW_MOVED:String = "chatViewMoved"
		
		public var libraryName:String 
		public var symbolName:String 
		public var dropX:Number
		public var dropY:Number
		public var depth:Number
		
		public var isCustomSymbol:Boolean = false
		public var customSymbolID:int = 0;
		public var libraryItem:LibraryItem;
		
		public function DrawingBoardItemDroppedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}