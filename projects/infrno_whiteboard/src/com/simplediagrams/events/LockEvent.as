package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class LockEvent extends Event
	{
		
		public static const LOCK:String = "le_lock"
		public static const UNLOCK:String = "le_unlock"
			
		public function LockEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}