package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class RegistrationViewEvent extends Event
	{
		public static const SHOW_BUY_NOW_SCREEN:String = "showBuyNowScreen"
		public static const SHOW_REGISTRATION_SCREEN:String = "showRegistrationScreen"
		public static const USE_IN_TRIAL_MODE:String = "useInTrialMode"
		public static const USE_IN_FULL_MODE:String = "useInFullMode"
		public static const TRY_REGISTERING_AGAIN:String = "tryRegisteringAgain"
		public static const CANCEL_REGISTRATION_HTTP_REQUEST:String ="cancelRegistrationHTTPRequest"
		public static const CANCEL_REGISTRATION:String = "cancelRegistration"
		
		public function RegistrationViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}