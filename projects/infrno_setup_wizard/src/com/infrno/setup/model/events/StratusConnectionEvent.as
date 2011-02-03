package com.infrno.setup.model.events
{
	import flash.events.Event;
	
	public class StratusConnectionEvent extends Event
	{
		public static const STRATUSCONNECTION_CONNECTED			:String = "stratusconnection_connected";
		public static const STRATUSCONNECTION_CONNECTING		:String = "stratusconnection_connecting";
		public static const STRATUSCONNECTION_DISCONNECTED		:String = "stratusconnection_disconnected";
		
		public function StratusConnectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}