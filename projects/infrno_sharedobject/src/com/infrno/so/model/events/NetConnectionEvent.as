package com.infrno.so.model.events
{
	import flash.events.Event;
	
	public class NetConnectionEvent extends Event
	{
		public static const NETCONNECTION_CONNECTED			:String = "netconnection_connected";
		public static const NETCONNECTION_CONNECTING		:String = "netconnection_connecting";
		public static const NETCONNECTION_DISCONNECTED		:String = "netconnection_disconnected";
		
		public function NetConnectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}