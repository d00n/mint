package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class YammerEvent extends Event
	{
		public static const CANCEL_UPLOAD:String = "yammerCancelUpload"
		public static const AUTHORIZATION_COMPLETE:String = "yammerAuthorizationComplete"
		public static const AUTHORIZATION_WINDOW_DONE:String = "yammerAuthorizationWindowDone"
		public static const CLEAR_LOGIN_CREDENTIALS:String = "clearYammerLoginCredentials"
		public static const SHOW_AUTHORIZE_WEBPAGE:String = "showAuthorizeWebpage"
		public static const EXPORT_DIAGRAM:String ="exportDiagramToYammer"
		
		public function YammerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}