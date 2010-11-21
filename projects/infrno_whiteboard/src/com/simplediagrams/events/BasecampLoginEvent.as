package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class BasecampLoginEvent extends Event
	{
		public static const BASECAMP_LOGIN_ATTEMPT:String = "basecampLoginAttempt"
		public static const BASECAMP_LOGIN_ATTEMPT_SUCCESS:String = "basecampLoginAttemptSuccess"
		public static const BASECAMP_LOGIN_ATTEMPT_FAILED:String = "basecampLoginAttemptFailed"
		
		public static const BASECAMP_LOGIN_CANCEL:String = "basecampLoginCancel"
		public static const BASECAMP_LOGIN_CANCELED:String = "basecampLoginCanceled"
				
		public var login:String
		public var password:String
		public var url:String
		public var rememberMe:Boolean = false	
		
		public function BasecampLoginEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}