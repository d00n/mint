package com.infrno.chat.model
{
	import com.infrno.chat.model.vo.UserInfoVO;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	
	import org.robotlegs.mvcs.Actor;
	
	public class DataProxy extends Actor
	{
		public static const VERSION:String		= "Chat v0.2.36";
		
		// TODO move status vars to a VO, maybe UserInfoVO?
		
		// TODO what's the difference between these two?
		public var peer_enabled:Boolean = true;		
		public var peer_capable:Boolean;
		
		public var enable_network_god_mode:Boolean = true;		
		
		// TODO Is this named well? Does it mean:
		// attempt_peer_connection
		// using_peer_connection
		// or other?
		public var use_peer_connection:Boolean;
		
		public var pubishing_audio:Boolean;
		public var pubishing_video:Boolean;
		
		public var ns:NetStream;
				

		// Wowza will accept these values for specified hosts.
		public var auth_key:String		= "sample_auth_key";		
		public var room_id:String 		= "Chat_default";
		public var room_name:String 	= "Chat_default";
		public var user_name:String 	= "Chat_default";
		public var user_id:String 		= "Chat_default";
		
		//public const  peer_server_key:String		= "4b9d915ef5ee88cfd38eb359-abf46599bf1f";
		public const peer_server_key:String		= "6a10a4b24cdfadaebc9765b4-ec2f9e5cf6a2";		
		public const peer_server:String				= "rtmfp://stratus.adobe.com";
		private var m_mediaServer:String	= "rtmp://localhost";
		private var m_mediaApp:String			= "chat";
		private var m_mediaPort:String		= "1935";
		
		// This includes local
		// Should it?
		// TODO remove local from collection, 
		// and rename remote_userInfoVO_array or peer_userInfo_array
		public var userInfoVO_array:Array;
		
		//public var my_info:UserInfoVO = new UserInfoVO({user_name:"user"+Math.round(Math.random()*1000),user_id:"sample_user_id"});
		public var local_userInfoVO:UserInfoVO;
		
		public function DataProxy( )
		{
			userInfoVO_array = new Array();
			
			// TODO eliminate user_id, add display_name, figure out user_name's job
			user_name= "user" + Math.round(Math.random()*1000);
			user_id = user_name
			local_userInfoVO	= new UserInfoVO({user_name:user_name, user_id:user_id});
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