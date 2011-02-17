package com.infrno.chat.services
{
	import flash.net.NetStream;

	public interface INetService
	{
		function connect():void;		
		function get ns():NetStream;		
//		function getNewNetStream(streamType:String = NetStream.DIRECT_CONNECTIONS):NetStreamPeer;		
		function updatePublishStream():void;
		
	}
}