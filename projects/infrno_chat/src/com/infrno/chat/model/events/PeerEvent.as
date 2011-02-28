package com.infrno.chat.model.events
{
	import flash.events.Event;
	
	public class PeerEvent extends Event
	{
		// WARNING: Some of these connection strings are used on the Wowza side
		// Don't change them without referencing com.infrno.multiplayer.StreamManager.checkStreamSupport()
		public static const PEER_NETCONNECTION_CONNECTED:String			= "peer_netconnection_connected";
		public static const PEER_NETCONNECTION_CONNECTING:String		= "peer_netconnection_connecting";
		public static const PEER_NETCONNECTION_DISCONNECTED:String	= "peer_netconnection_disconnected";
		
		// TODO: These are poorly named, because they affect the peer stream usage via
		// dataProxy.use_peer_connection, set in VideoSourceCommand
		// ..not just video
		public static const PEER_ENABLE_VIDEO:String								= "peer_enable_video";
		public static const PEER_DISABLE_VIDEO:String								= "peer_disable_video";

		
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