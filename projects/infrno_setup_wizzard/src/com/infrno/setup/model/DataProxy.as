package com.infrno.setup.model
{
	import org.robotlegs.mvcs.Actor;
	
	public class DataProxy extends Actor
	{
		public static const VERSION				:String		= "v0.1.4";
		
		public var stream_connection_success	:Boolean;
		public var stratus_connection_success	:Boolean;
		
		public var peer_server					:String		= "rtmfp://stratus.adobe.com";
		public var peer_server_key				:String		= "4b9d915ef5ee88cfd38eb359-abf46599bf1f";
//		public var media_server					:String		= "rtmp://gearsandcogs.com/test";
		public var media_server					:String		= "rtmp://wowza.infrno.net:1935/chat";
		
		public function DataProxy()
		{
			super();
		}
	}
}