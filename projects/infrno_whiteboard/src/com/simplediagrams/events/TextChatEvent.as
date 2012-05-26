package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class TextChatEvent extends Event
	{
		
		public static const TEXT_CHAT_EVENT:String = "textChatEvent"
		
		public function TextChatEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}