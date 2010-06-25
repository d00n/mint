package com.infrno.chat.model.events
{
	import flash.events.Event;
	
	public class SettingsEvent extends Event
	{
		public static const SHOW_SETTINGS:String = "show_settings";
		
		public function SettingsEvent(type:String)
		{
			super(type,true);
		}
	}
}