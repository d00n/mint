package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class PluginEvent extends Event
	{
		public static const COPY_DEFAULT_PLUGINS_TO_USER_DIR:String = "copyDefaultPluginsToUserDir"
		
		public function PluginEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}