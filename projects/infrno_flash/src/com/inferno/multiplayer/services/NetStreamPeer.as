package com.inferno.multiplayer.services
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class NetStreamPeer extends NetStream
	{
		public function NetStreamPeer(connection:NetConnection, peerID:String="connectToFMS")
		{
			super(connection, peerID);
		}
	}
}