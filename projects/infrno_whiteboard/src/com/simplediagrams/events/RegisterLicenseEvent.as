package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class RegisterLicenseEvent extends Event
	{
		
		public static const VALIDATE_LICENSE:String = "validateLicense"
		public static const VALIDATE_LICENSE_RESULT:String = "validateLicenseResult"
		public static const LICENSE_VALIDATED:String = "licenseValidated"
		public static const LICENSE_KEY_NOT_FOUND:String = "licenseKeyNotFound"
		public static const LICENSE_KEY_MAXED_OUT:String = "licenseKeyMaxedOut"
		public static const LICENSE_KEY_REVOKED:String = "licenseKeyRevoked"
		public static const UNRECOGNIZED_STATUS:String = "unrecognizedStatus"
			
		public static const ERROR_HTTP:String="httpError"
		public static const ERROR_SECURITY:String="securityError"
		public static const ERROR_IO:String="ioError"
						
		
		public var email:String
		public var licenseKey:String			
		public var status:Number
		
		public function RegisterLicenseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}