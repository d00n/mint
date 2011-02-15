package com.infrno.chat.model
{
	import com.infrno.chat.model.vo.UserInfoVO;
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	import org.robotlegs.mvcs.Actor;
	
	public class DataProxy extends Actor
	{
		public static const VERSION:String		= "Chat v0.2.20";
		
		public var peer_enabled:Boolean;
		
		public var peer_capable:Boolean;
		public var use_peer_connection:Boolean;
		public var pubishing_audio:Boolean;
		public var pubishing_video:Boolean;
		
		public var ns:NetStream;
		
		public var users_collection:Object;
		
		// Wowza will accept these values for specified hosts.
		public var auth_key:String		= "sample_auth_key";
		
		public var room_id:String 		= "0";
		public var room_name:String 	= "";
		public var user_name:String 	= "";
		public var user_id:String 		= "";
		
		//using personal stratus key for now
		public var peer_server_key:String		= "4b9d915ef5ee88cfd38eb359-abf46599bf1f";
		public var peer_server:String				= "rtmfp://stratus.adobe.com";
		
		////
		// possible values:
		//
		//  rtmp://gearsandcogs.com
		//  rtmp://admin.infrno.net
		////
		private var m_mediaServer:String	= "rtmp://localhost";
		private var m_mediaApp:String			= "chat";
		private var m_mediaPort:String		= "1935";
		
		//public var my_info:UserInfoVO = new UserInfoVO({user_name:"user"+Math.round(Math.random()*1000),user_id:"sample_user_id"});
		// TODO: rename my_info as local_userInfoVO
		public var my_info:UserInfoVO;
		
		public function DataProxy( )
		{
			users_collection = new Object();
			
			user_name= "user" + Math.round(Math.random()*1000);
			user_id = user_name
			my_info	= new UserInfoVO({user_name:user_name, user_id:user_id});
		}
		
		public function get media_server( ):String 
		{
			if( m_mediaServer != null ) 
			{
				return m_mediaServer;
			}
			
			return "rtmp://localhost";
		}	
		
		public function set media_server( value:String ):void
		{
			m_mediaServer = value;
		}
		
		public function get media_app( ):String 
		{
			if( m_mediaApp != null ) 
			{
				return m_mediaApp;	
			}
			
			return "chat";
		}
		
		public function get media_port( ):String 
		{
			if( m_mediaPort != null ) 
			{
				return m_mediaPort;	
			}
			
			return "1935";
		}
		
		public function set media_app( value:String ):void 
		{
			m_mediaApp = value;
		}
		
		
	}
}