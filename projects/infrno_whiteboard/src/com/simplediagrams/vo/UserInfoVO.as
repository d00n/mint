package com.simplediagrams.vo
{
	import flash.net.NetStream;

	public class UserInfoVO
	{
		//		public var peer_capable				:Boolean;
		public var suid						:int;
		
		public var peer_connection_status	:String;
		public var user_name				:String;
		public var user_id					:String;
		public var nearID					:String;
		
		private var _ns						:NetStream;
		
		public function UserInfoVO(userInfoObj:Object=null)
		{
			//force server connection
			peer_connection_status = "peer_netconnection_disconnected"; 
			suid = userInfoObj.suid;
			user_id = userInfoObj.user_id;
			user_name = userInfoObj.user_name;
			
			// Looks like virtual group stuff, which we aren't using yet
			nearID = null;
		}
	}
}