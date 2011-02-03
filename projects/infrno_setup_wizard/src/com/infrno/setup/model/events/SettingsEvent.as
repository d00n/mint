package com.infrno.setup.model.events
{
	import flash.events.Event;
	
	public class SettingsEvent extends Event
	{
		public static const SHOW_CAMERA_SETTINGS		:String = "show_camera_settings";
		public static const SHOW_MIC_SETTINGS			:String = "show_mic_settings";
		public static const SHOW_SAVE_SETTINGS			:String = "show_save_settings";
		
		public function SettingsEvent(type:String)
		{
			super(type);
		}
	}
}