package com.infrno.chat.model.events
{
	import com.infrno.chat.model.vo.UserInfoVO;
	
	import flash.events.Event;
	
	public class VideoPresenceEvent extends Event
	{
		public static const AUDIO_LEVEL:String													= "VideoPresenceEvent_audio_level";
		public static const AUDIO_MUTED:String													= "VideoPresenceEvent_audio_muted";
		public static const AUDIO_UNMUTED:String												= "VideoPresenceEvent_audio_unmuted";
		public static const VIDEO_MUTED:String													= "VideoPresenceEvent_video_muted";
		public static const VIDEO_UNMUTED:String												= "VideoPresenceEvent_video_unmuted";
		public static const SETUP_PEER_NETSTREAM:String									= "VideoPresenceEvent_setup_peer_netstream";
		public static const SETUP_PEER_VIDEOPRESENCE_COMPONENT:String 	= "VideoPresenceEvent_setup_peer_videopresence_component";

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