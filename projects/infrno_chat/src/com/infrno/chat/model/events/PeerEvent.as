package com.infrno.chat.model.events
{
	import flash.events.Event;
	
	public class PeerEvent extends Event
	{
		public static const PEER_NETCONNECTION_CONNECTED		:String		= "peer_netconnection_connected";
		public static const PEER_NETCONNECTION_CONNECTING		:String		= "peer_netconnection_connecting";
		public static const PEER_NETCONNECTION_DISCONNECTED		:String		= "peer_netconnection_disconnected";

		public static const PEER_ENABLE_VIDEO					:String		= "peer_enable_video";
		public static const PEER_DISABLE_VIDEO					:String		= "peer_disable_video";
		
		public var value										:String;
		
		public function PeerEvent(type:String,valueIn:String=null)
		{
			super(type);
			value = valueIn;
		}
		
		override public function clone():Event
		{
			return new PeerEvent(type);
		}
	}
}