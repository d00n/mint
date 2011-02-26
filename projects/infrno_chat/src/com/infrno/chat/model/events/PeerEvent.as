package com.infrno.chat.model.events
{
	import flash.events.Event;
	
	public class PeerEvent extends Event
	{
		public static const PEER_NETCONNECTION_CONNECTED:String			= "pe_peer_netconnection_connected";
		public static const PEER_NETCONNECTION_CONNECTING:String		= "pe_peer_netconnection_connecting";
		public static const PEER_NETCONNECTION_DISCONNECTED:String	= "pe_peer_netconnection_disconnected";
		public static const PEER_ENABLE_VIDEO:String								= "pe_peer_enable_video";
		public static const PEER_DISABLE_VIDEO:String								= "pe_peer_disable_video";

		
		public var value:String;
		
		public function PeerEvent(type:String,valueIn:String=null)
		{
			super(type);
			value = valueIn;
		}
		
		override public function clone():Event
		{
			trace("PeerEvent.clone() value:"+value);
			return new PeerEvent(type);
		}
	}
}