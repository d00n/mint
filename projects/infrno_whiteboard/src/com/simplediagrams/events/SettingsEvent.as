package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class SettingsEvent extends Event
	{
		public static const SETTINGS_LOADED:String = "applicationSettingsLoaded"
		
		public function SettingsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}