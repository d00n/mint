package com.infrno.chat.model.events
{
	import flash.events.Event;
	
	public class VideoPresenceEvent extends Event
	{
		public static const AUDIO_LEVEL		:String		= "audio_level";

		public static const AUDIO_MUTED		:String		= "audio_muted";
		public static const AUDIO_UNMUTED	:String		= "audio_unmuted";
		public static const VIDEO_MUTED		:String		= "video_muted";
		public static const VIDEO_UNMUTED	:String		= "video_unmuted";
		
		private var _value					:Number;
		
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