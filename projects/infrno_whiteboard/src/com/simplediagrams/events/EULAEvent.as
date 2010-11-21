package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class EULAEvent extends Event
	{
		public static const USER_AGREED_TO_EULA:String = "userAgreedToEULA"
		
		public function EULAEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}