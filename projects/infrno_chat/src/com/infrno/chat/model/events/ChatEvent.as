package com.infrno.chat.model.events
{
	import flash.events.Event;

	public class ChatEvent extends Event
	{
		public static const		RECEIVE_CHAT:String 	= "receive_chat";
		public static const		SEND_CHAT:String 			= "send_chat";
		
		private var _message:String;
		
		public function ChatEvent(type:String, message:String = null)
		{
			super(type);
			_message = message;
		}
		
		public function get message():String
		{
			return _message;
		}
	}
}