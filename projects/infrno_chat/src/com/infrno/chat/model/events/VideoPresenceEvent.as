package com.infrno.chat.model.events
{
	import com.infrno.chat.model.vo.StatsVO;
	import com.infrno.chat.model.vo.UserInfoVO;
	
	import flash.events.Event;
	
	public class VideoPresenceEvent extends Event
	{
		public static const AUDIO_LEVEL:String													= "vpe_audio_level";
		public static const AUDIO_MUTED:String													= "vpe_audio_muted";
		public static const AUDIO_UNMUTED:String												= "vpe_audio_unmuted";
		public static const VIDEO_MUTED:String													= "vpe_video_muted";
		public static const VIDEO_UNMUTED:String												= "vpe_video_unmuted";
		public static const SETUP_PEER_NETSTREAM:String									= "vpe_setup_peer_netstream";
		public static const SETUP_PEER_VIDEOPRESENCE_COMPONENT:String 	= "vpe_setup_peer_videopresence_component";
		public static const SHOW_NETWORK_GRAPHS:String 									= "vpe_show_network_graphs";
		public static const HIDE_NETWORK_GRAPHS:String 									= "vpe_hide_network_graphs";
		
//		public static const DISPLAY_PEER_STATS:String 									= "vpe_display_peer_stats";
//		public static const DISPLAY_SERVER_STATS:String 								= "vpe_display_server_stats";
		

		private var _value:Number;
		public var userInfoVO:UserInfoVO;

		
		public function VideoPresenceEvent(type:String, bubbles:Boolean=false, value:Number=0)
		{
			super(type,bubbles);
			_value = value;
		}
		
		public function get value():Number
		{
			return _value;
		}
	}
}