package com.simplediagrams.vo
{
	import flash.net.NetStream;

	public class DummyUserInfoVO
	{
		//		public var peer_capable				:Boolean;
		public var suid						:int;
		
		public var peer_connection_status	:String;
		public var uname					:String;
		public var nearID					:String;
		
		private var _ns						:NetStream;
		
		public function DummyUserInfoVO()
		{
			//force server connection
			peer_connection_status = "peer_netconnection_disconnected"; 
			
			// Not sure who sets this
			suid = 0;

			// Looks like any unique-ish string will do
			uname = "whiteboard_user"+Math.round(Math.random()*1000);
			
			
				
			// Looks like virtual group stuff, which we aren't using yet
			nearID = null;
		}
	}
}