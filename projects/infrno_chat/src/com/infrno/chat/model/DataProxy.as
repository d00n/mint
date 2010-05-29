package com.infrno.chat.model
{
	import com.infrno.chat.model.vo.UserInfoVO;
	
	import flash.net.NetStream;
	
	import org.robotlegs.mvcs.Actor;
	
	public class DataProxy extends Actor
	{
		public static const VERSION			:String		= "Infrno v 0.2.9";
		
		public var peer_enabled				:Boolean;
		
		public var peer_capable				:Boolean;
		public var use_peer_connection		:Boolean;
		public var pubishing_audio			:Boolean;
		public var pubishing_video			:Boolean;
		
		public var ns						:NetStream;
		
		public var users_collection			:Object;
		
		public var auth_key					:String;
		public var room_id					:String;
		public var room_name				:String;
		public var user_name				:String;
		
		//using personal stratus key for now
		public var peer_server_key			:String		= "4b9d915ef5ee88cfd38eb359-abf46599bf1f";
		public var peer_server				:String		= "rtmfp://stratus.adobe.com";
		
//		public var media_server				:String		= "rtmp://home.jakehilton.com/infrno";
//		public var media_server				:String		= "rtmp://admin.infrno.net/chat";
		public var media_server				:String		= "rtmp://localhost/chat";
		
		
		public var my_info					:UserInfoVO = new UserInfoVO({"uname":"user"+Math.round(Math.random()*1000)});
		
		public function DataProxy()
		{
			users_collection = new Object();
		}
		
	}
}