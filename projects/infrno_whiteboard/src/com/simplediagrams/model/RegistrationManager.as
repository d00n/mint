package com.simplediagrams.model
{
	import com.simplediagrams.util.Logger;
	
//	import flash.data.EncryptedLocalStore;
	import flash.events.EventDispatcher;
//	import flash.filesystem.*;
	import flash.utils.ByteArray;
	
	[Bindable]
	public class RegistrationManager extends EventDispatcher
	{
		
		public static const VIEW_TRIAL_MODE:String = "trialModeView"
		public static const VIEW_TRIAL_MODE_FINISHED:String = "trialModeFinishedView"
		public static const VIEW_REGISTER:String = "registerView"
		public static const VIEW_REGISTRATON_SUCCESS:String = "registrationSuccessView"
		public static const VIEW_SERVER_UNAVALABLE:String = "serverUnavailableView"
		public static const VIEW_BUY_NOW:String = "buyNowView"
						
		public static const REGISTER_VIEW_NORMAL:String = "registerViewNormal"
		public static const REGISTER_VIEW_ERROR:String = "registerViewError"
		public static const REGISTER_VIEW_WAITING:String = "registerViewWaiting"
		public static const REGISTER_VIEW_TIMEOUT:String = "registerViewTimeout"
		
		//possible responses from server
		public static const STATUS_REGISTRATION_OK:int = 1	
		public static const STATUS_UNREGISTERED_OK:int = 2		
		public static const STATUS_ERROR_RESPONSE_UNRECOGNIZED:int = 99
		public static const STATUS_ERROR_MAXCOUNT:int = 101
		public static const STATUS_ERROR_EMAIL_AND_KEY_COMBINATION_NOT_FOUND:int = 102	
		public static const STATUS_ERROR_KEY_REVOKED:int = 103
			
		public static const TRIAL_DAYS:uint = 7
			
		/* Number of milliseconds in a day. (1000 milliseconds per second * 60 seconds per minute * 60 minutes per hour * 24 hours per day) */
		private const MILLISECONDS_PER_DAY:uint = 1000 * 60 * 60 * 24;
		
		protected var _trialDaysRemaining:int = TRIAL_DAYS
		
		public var errorMsg:String = ""
		
		//holds the entered license key and email until we get a validation
		public var tryingToValidateWithKey:String = ""
		public var tryingToValidateWithEmail:String = ""
			
		//manages the state of the RegistrationView window (which holds the individual register windows)
		protected var _viewing:String = VIEW_TRIAL_MODE 
					
		//manages the state of the RegisterView window within the Registration process
		protected var _registerViewing:String = REGISTER_VIEW_NORMAL
									
		public var buyNowMessage:String = "Buying SimpleDiagrams is easy. Just click the button below to launch the payment site hosted at FastSpring.com."
		public var buyNowMessage2:String = "After you've purchased SimpleDiagrams and received your license via email, click the 'Register Application' text below."
			
		public var trialVersionMsg:String = "You're using a trial version of SimpleDiagrams. If you like it, why not purchase a license today? It's quick, simple and cheap. " 	
					
			
			
		public var trialFinishedMsg:String = "<p>Your SimpleDiagrams 2.0 trial has ended.</p><br/><p>If you haven't " + 
					"purchased a license yet, no problem. Just click the Buy Now button below to get started.</p>"
			
		public var timeoutMsg:String = "Couldn't contact server. Please try again."			
					
					
		public var registrationSuccessMsg:String = "You have successfully registered this copy of SimpleDiagrams 2.0. You can find links to tutorials and help information via the 'help' menu above.\n\nPlease restart the program to see your new library plugins."
		
		protected var _isDialog:Boolean = false
					
		public var cancelRegistrationText:String = "No thanks, I'll use the trial version"
		
		public var finalDoneButtonText:String = "Start SimpleDiagrams"
				
		//only show the trial vs. free explanation if the user is upgrading from earlier SD. 
		//The test for this is if they have 
		public var showTrialVsFreeExplanation:Boolean = false
		
		public function RegistrationManager()
		{
			
		}
		
		public function get trialOver():Boolean
		{
			return trialDaysRemaining < 1
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
		
				
		public function registerApplication(key:String, email:String):void
		{
			licenseKey = key
			licenseEmail = email
		}
		
		
		
		
		
		
		/* BASIC LICENSE INFORMATION */
		
		public function get licenseKey():String
		{
//			try
//			{
//				var licenseKeyBA:ByteArray = EncryptedLocalStore.getItem("com.simplediagrams.licenseKey")
//			}
//			catch(error:Error)
//			{
//				Logger.error("Can't get licenseKey", this)
//				return null
//			}						
//			if (licenseKeyBA==null) return null
//			return licenseKeyBA.readUTFBytes(licenseKeyBA.length)			
			return null;
		}
		
		public function set licenseKey(key:String):void
		{
//			var licenseKeyBA:ByteArray = new ByteArray()
//			licenseKeyBA.writeUTFBytes(key)
//			EncryptedLocalStore.setItem("com.simplediagrams.licenseKey", licenseKeyBA)
		}
				
		
		public function get licenseEmail():String
		{
//			try
//			{
//				var licenseEmailBA:ByteArray = EncryptedLocalStore.getItem("com.simplediagrams.licenseEmail")
//			}
//			catch(error:Error)
//			{
//				Logger.error("Can't get licenseEmail", this)
//				return null
//			}						
//			if (licenseEmailBA==null) return null
//			return licenseEmailBA.readUTFBytes(licenseEmailBA.length)
			return null;
		}
		
		public function set licenseEmail(email:String):void
		{
//			var licenseEmailBA:ByteArray = new ByteArray()
//			licenseEmailBA.writeUTFBytes(email)
//			EncryptedLocalStore.setItem("com.simplediagrams.licenseEmail", licenseEmailBA)
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
//			EncryptedLocalStore.removeItem("com.simplediagrams.licenseKey")
		}
				
		[Bindable("trialDaysRemainingChanged")]
		public function get trialDaysRemaining():uint
		{	
			var startDate:Date = dateTrialStarted
							
			if (startDate ==null)
			{
				return 0
			}
							
			var today:Date = new Date()
			_trialDaysRemaining = TRIAL_DAYS - Math.floor(( today.getTime() - startDate.getTime()) / MILLISECONDS_PER_DAY);
			
			if (_trialDaysRemaining<0)
			{
				_trialDaysRemaining = 0
			}
							
			return _trialDaysRemaining
		}
		
		 
		public function set dateTrialStarted(installDate:Date):void
		{			
//			var dateBA:ByteArray = new ByteArray()
//			var timeInMilli:String = installDate.time.toString()
//			dateBA.writeUTFBytes(timeInMilli)
//			EncryptedLocalStore.setItem("dateTrialStarted", dateBA)	
//				
//			this.dispatchEvent(new Event("trialDaysRemainingChanged", true))	
		}
		
		public function get dateTrialStarted():Date
		{
//			var dateBA:ByteArray = EncryptedLocalStore.getItem("dateTrialStarted")
//			if (dateBA==null) 
//			{
//				return null	
//			}			
//			var timeInMilli:Number = Number(dateBA.readUTFBytes(dateBA.length))
//			var d:Date = new Date(timeInMilli) 
//			return d
			return null
		}
		
		public function recordDateTrialStarted():void
		{			
			dateTrialStarted = new Date()							
		}
		
		
		
		
		
		
	}
}