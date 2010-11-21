package com.simplediagrams.model
{
	import com.simplediagrams.util.Logger;
	
	import flash.data.EncryptedLocalStore;
	import flash.events.EventDispatcher;
//	import flash.filesystem.*;
	import flash.utils.ByteArray;
	
	[Bindable]
	public class RegistrationManager extends EventDispatcher
	{
		
		public static const VIEW_FREE_MODE:String = "freeModeView"
		public static const VIEW_REGISTER:String = "registerView"
		public static const VIEW_REGISTRATON_SUCCESS:String = "registrationSuccessView"
		public static const VIEW_SERVER_UNAVALABLE:String = "serverUnavailableView"
						
		public static const REGISTER_VIEW_NORMAL:String = "registerViewNormal"
		public static const REGISTER_VIEW_ERROR:String = "registerViewError"
		public static const REGISTER_VIEW_WAITING:String = "registerViewWaiting"
		public static const REGISTER_VIEW_TIMEOUT:String = "registerViewTimeout"
		
		//possible responses from server
		public static const STATUS_REGISTRATION_OK:int = 1		
		public static const STATUS_ERROR_RESPONSE_UNRECOGNIZED:int = 99
		public static const STATUS_ERROR_MAXCOUNT:int = 101
		public static const STATUS_ERROR_EMAIL_AND_KEY_COMBINATION_NOT_FOUND:int = 102	
		public static const STATUS_ERROR_KEY_REVOKED:int = 103
			
		public var trialDaysRemaining:Number = 0
		public var trialOver:Boolean = false
		
		public var errorMsg:String = ""
		
		//holds the entered license key until we get a validation
		protected var _tryingToValidateWithKey:String = ""
			
		//manages the state of the RegistrationView window (which holds the individual register windows)
		protected var _viewing:String = VIEW_FREE_MODE 
					
		//manages the state of the RegisterView window within the Registration process
		protected var _registerViewing:String = REGISTER_VIEW_NORMAL
		
		
		/*
		protected var _timeStillRemainingMsg:String = "You're using the SimpleDiagrams Beta free version. And that's great. But after the trial period is over you'll get a periodic" +
					" reminder to upgrade to SimpleDiagrams Premium.<br/><br/>So, why not purchase the Premium version today? Getting a license is quick, simple and cheap. " + 
					"<b>Click the \"Upgrade Now\" button below to get started.</b>"			
					
		protected var _noTimeRemainingMsg:String = "Your trial period is finished. However, you can still use this free version of SimpleDiagrams, you'll just get a periodic" +
					" reminder to upgrade to SimpleDiagrams Premium.<br/><br/>So, why not purchase the Premium version today? Getting a license is quick, simple and cheap. " + 
					"<b>Click the \"Upgrade Now\" button below to get started.</b>"	
		*/
					
		public var freeVersionMsg:String = "You're using the SimpleDiagrams Free Version. And that's great. But you're missing some great features only available " +
			"in the SimpleDiagrams Full Version, like the ability to save files or use different fonts.<br/><br/>So, why not purchase the Full Version today? Getting a license is quick, simple and cheap. " + 
			"<b>Click the \"Upgrade Now\" button below to get started.</b>"	
					
		public var timeoutMsg:String = "Your SimpleDiagrams trial has ended. Please enter your email and the license number you purchased from the SimpleDiagrams.com site. If you haven't " + 
					"purchased a license yet, no problem. Just <font color='#3c69e1'><a href='http://www.simplediagrams.com/purchase'>visit the purchase page</a></font> to get started."
			
					
		public var registrationSuccessMsg:String = "You have successfully registered this copy of SimpleDiagrams. You can find links to tutorials and help information via the 'help' menu above."
		
		protected var _isDialog:Boolean = false
					
		public var cancelRegistrationText:String = "No thanks, I'll use the free version"
		
		public var finalDoneButtonText:String = "Start SimpleDiagrams"
		
		public function RegistrationManager()
		{
			
		}
		
		public function set isDialog(value:Boolean):void
		{
			_isDialog = value
			cancelRegistrationText = "Cancel"
			finalDoneButtonText = "Return to SimpleDiagrams"
		}
		
		public function get isDialog():Boolean
		{
			return _isDialog
		}
				
		public function get viewing():String
		{
			return _viewing
		}
		
		public function set viewing(v:String):void
		{
			_viewing =v
		}
		
		
		public function get registerViewing():String
		{
			return _registerViewing
		}
		
		public function set registerViewing(v:String):void
		{
			Logger.debug("setting registerViewing to : " + v, this)
			_registerViewing =v
		}
		
				
		public function registerApplication(key:String):void
		{
			licenseKey = key
		}
		
		
		
		
		public function get tryingToValidateWithKey():String
		{
			return _tryingToValidateWithKey
		}
		
		public function set tryingToValidateWithKey(v:String):void
		{
			_tryingToValidateWithKey = v
		}
		
		/* BASIC LICENSE INFORMATION */
		
		public function get licenseKey():String
		{
			return null
//			var licenseKeyBA:ByteArray = EncryptedLocalStore.getItem("com.simplediagrams.licenseKey")
//			if (licenseKeyBA==null) return null
//			return licenseKeyBA.readUTFBytes(licenseKeyBA.length)
		}
		
		public function set licenseKey(key:String):void
		{
//			var licenseKeyBA:ByteArray = new ByteArray()
//			licenseKeyBA.writeUTFBytes(key)
//			EncryptedLocalStore.setItem("com.simplediagrams.licenseKey", licenseKeyBA)
		}
				
		
		public function get isLicensed():Boolean
		{
			//doon
			return true;
			
			//legacy stuff for users pre 1.0.12
			try
			{
				var isLicensed:ByteArray = EncryptedLocalStore.getItem("sdIsLicensed")
				if (isLicensed && isLicensed.readUTFBytes(isLicensed.length) == "true") return true
			}
			catch(error:Error)
			{
				Logger.error("Error trying to read sdIsLicensed",this)
			}
			//more recent stuff...
			return (licenseKey!=null && licenseKey!="")
		}
		
		public function deleteLicense():void
		{
			EncryptedLocalStore.removeItem("com.simplediagrams.licenseKey")
		}
				
		
		
		
	}
}