package com.infrno.chat.model.events
{
	import flash.events.Event;

	public class ChatEvent extends Event
	{
		public static const		RECEIVE_CHAT:String 	= "receive_chat";
		public static const		SEND_CHAT:String 			= "send_chat";
		
		private var _message:String;
		private var _dieRoll:Boolean;
		
		public function ChatEvent(type:String, message:String = null, dieRoll:Boolean = false)
		{
			super(type);
			_message = message;
			_dieRoll = dieRoll;
		}
		
		public function get message():String
		{
			return _message;
		}
		public function get dieRoll():Boolean
		{
			return _dieRoll;
		}
	}
}