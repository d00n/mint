package com.infrno.setup.model.events
{
	import flash.events.Event;
	
	public class MessageEvent extends Event
	{
		public static const ERROR			:String		= "error";
		public static const INFORMATIVE		:String		= "informative";
		public static const WARNING			:String		= "warning";
		
		private var _msg					:String;
		
		public function MessageEvent(type:String, message:String)
		{
			super(type);
			_msg = message;
		}
		
		public function get message():String
		{
			return _msg;
		}
		
	}
}