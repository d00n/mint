package com.infrno.chat.model.events
{
	import flash.events.Event;

	public class LogEvent extends Event
	{
		public static const		SEND_TO_SERVER:String 	= "send_to_server";
		
		private var _func:String;
		private var _peer:String;
		private var _message:String;
		
		public function LogEvent(type:String, func:String = null, peer:String=null, message:String=null)
		{
			super(type);
			_message = message;			
			_peer = peer;			
			_func = func;			
		}
		
		public function get message():String
		{
			return _message;
		}		
		public function get peer():String
		{
			return _peer;
		}		
		public function get func():String
		{
			return _func;
		}		
	}
}