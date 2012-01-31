package com.simplediagrams.events
{
	import com.simplediagrams.model.SDBackgroundModel;
	import com.simplediagrams.model.libraries.LibraryItem;
	
	import flash.events.Event;
	
	public class BackgroundItemDroppedEvent extends Event
	{
		public static const BACKGROUND_ITEM_DROPPED_EVENT:String = "backgroundItemDroppedEvent"
			
		public var libItem:LibraryItem;
		
		public function BackgroundItemDroppedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}