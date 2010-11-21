package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class RegistrationViewEvent extends Event
	{
		public static const SHOW_REGISTRATION_SCREEN:String = "showRegistrationScreen"
		public static const USER_AGREED_TO_LICENSE:String = "userAgreedToLicense"
		public static const USE_IN_FREE_MODE:String = "useInFreeMode"
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