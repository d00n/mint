package com.infrno.setup.model
{
	import org.robotlegs.mvcs.Actor;
	import com.infrno.setup.model.vo.UserInfoVO;

	
	public class DataProxy extends Actor
	{
		public static const VERSION				:String		= "Wizard v0.1.6";
		
		public var stream_connection_success	:Boolean;
		public var stratus_connection_success	:Boolean;
		
		public var peer_server					:String		= "rtmfp://stratus.adobe.com";
		public var peer_server_key				:String		= "4b9d915ef5ee88cfd38eb359-abf46599bf1f";
//		public var media_server					:String		= "rtmp://gearsandcogs.com/test";
//		public var media_server					:String		= "rtmp://wowza.infrno.net:1935/chat";
		
		// Wowza will accept these values for specified hosts.
		public var auth_key:String		= "sample_auth_key";		
		public var room_id:String 		= "0";
		public var room_name:String 	= "";
		public var user_id:String 		= "";
		public var user_name:String 	= "";
		
		public var media_server:String	= "rtmp://localhost";
		public var media_app:String		= "setup_wizard";
		public var media_port:String	= "1935";
		
		//		public var my_info					:UserInfoVO = new UserInfoVO({user_name:"user"+Math.round(Math.random()*1000),user_id:"sample_user_id"});
		public var my_info					:UserInfoVO ;
		
		public function DataProxy()
		{
			user_name= "user" + Math.round(Math.random()*1000);
			user_id = user_name
			my_info	= new UserInfoVO({user_name:user_name, user_id:user_id});
			
			super();
		}
		
		public function get connectionUri() :String {
			return media_server +":"+ media_port +"/"+ media_app			
		}
	}
}