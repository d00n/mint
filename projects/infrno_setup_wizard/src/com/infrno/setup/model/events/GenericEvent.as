package com.infrno.setup.model.events
{
	import flash.events.Event;
	
	public class GenericEvent extends Event
	{
		public static const HIDE_VIDEO		:String = "hide_video";
		public static const SHOW_VIDEO		:String = "show_video";
		public static const REMOVE_VIDEO	:String = "remove_video";
		
		public function GenericEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}