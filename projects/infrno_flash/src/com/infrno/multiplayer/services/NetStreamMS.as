package com.infrno.multiplayer.services
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class NetStreamMS extends NetStream
	{
		public function NetStreamMS(connection:NetConnection, peerID:String="connectToFMS")
		{
			super(connection, peerID);
		}
	}
}