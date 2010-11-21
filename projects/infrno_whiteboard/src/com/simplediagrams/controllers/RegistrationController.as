package com.simplediagrams.controllers
{
	import com.simplediagrams.events.RegisterLicenseEvent;
	import com.simplediagrams.events.RegistrationViewEvent;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.RegistrationManager;
	import com.simplediagrams.shapelibrary.communication.Dialog;
	import com.simplediagrams.util.Logger;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.rpc.AsyncToken;
	
	;
	import org.swizframework.controller.AbstractController;

	public class RegistrationController extends AbstractController
	{
		[Inject]
		public var appModel:ApplicationModel;
		
		[Inject]
		public var registrationManager:RegistrationManager;		
		
		[Inject]
		public var dialogsController:DialogsController;		
		
		protected var _loader:URLLoader
		
		public function RegistrationController()
		{
			_loader = new URLLoader();
			_loader.addEventListener( Event.COMPLETE, resultHandler)
			_loader.addEventListener( IOErrorEvent.IO_ERROR, faultHandler)
			_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, faultHandler)					
		}
		
		
		[Mediate(event="RegistrationViewEvent.USER_AGREED_TO_LICENSE")]
		public function userAgreedToLicense(event:RegistrationViewEvent):void
		{
			appModel.userAgreedToEULA()
			registrationManager.viewing = RegistrationManager.VIEW_FREE_MODE						
		}
				
		[Mediate(event="RegisterLicenseEvent.VALIDATE_LICENSE")]
		public function validateLicense(event:RegisterLicenseEvent):void
		{			
			Logger.debug("validateLicense()",this)
			registrationManager.registerViewing = RegistrationManager.REGISTER_VIEW_WAITING			
			registrationManager.tryingToValidateWithKey = event.licenseKey				
			var urlRequest:URLRequest = new URLRequest(ApplicationModel.REGISTRATION_URL)
								
			urlRequest.method = URLRequestMethod.POST
			var variables:URLVariables = new URLVariables();
			variables.email = event.email
			variables.key = event.licenseKey
			urlRequest.data = variables;
			
			_loader.load(urlRequest)
			
		}
		
		protected function resultHandler(e:Event):void
		{
			var result:String = e.currentTarget.data;
			Logger.debug("result: " + result, this)
			var status:int
			try
			{
				var resultXML:XML = XML(result)
				status = resultXML.@id
				if (status==RegistrationManager.STATUS_REGISTRATION_OK)
				{
					var unlockHash:String = resultXML.@unlock
				}
			}
			catch(err:Error)
			{
				Logger.error("resultHandler: error converting response: " + resultXML + " to XML. Error: " +err, this)
				status = RegistrationManager.STATUS_ERROR_RESPONSE_UNRECOGNIZED
			}
			
			
			switch(status)
			{							
				case RegistrationManager.STATUS_ERROR_EMAIL_AND_KEY_COMBINATION_NOT_FOUND:
					registrationManager.viewing = RegistrationManager.VIEW_REGISTER
					registrationManager.registerViewing = RegistrationManager.REGISTER_VIEW_ERROR
					registrationManager.errorMsg = "The entered email and/or license key was not found on the security server. Please try again or contact us for help."
					dispatcher.dispatchEvent(new RegisterLicenseEvent(RegisterLicenseEvent.LICENSE_KEY_NOT_FOUND, true))
					break;
				
				case RegistrationManager.STATUS_ERROR_MAXCOUNT:
					registrationManager.viewing = RegistrationManager.VIEW_REGISTER
					registrationManager.registerViewing = RegistrationManager.REGISTER_VIEW_ERROR 
					registrationManager.errorMsg ="The entered key was already used for the alotted number of registrations. Please enter a key that has not been used yet or contact us for help."
					dispatcher.dispatchEvent(new RegisterLicenseEvent(RegisterLicenseEvent.LICENSE_KEY_MAXED_OUT, true))
					break;
				
				case RegistrationManager.STATUS_ERROR_KEY_REVOKED:
					registrationManager.viewing = RegistrationManager.VIEW_REGISTER
					registrationManager.registerViewing = RegistrationManager.REGISTER_VIEW_ERROR
					registrationManager.errorMsg = "This key has been revoked, probably because it was used too many times. Please contact us for help."
					dispatcher.dispatchEvent(new RegisterLicenseEvent(RegisterLicenseEvent.LICENSE_KEY_REVOKED, true))
					break;
											
				case RegistrationManager.STATUS_REGISTRATION_OK:	
					
					//TODO: make sure hash is correct
					Logger.debug("registration OK. unlock hash: " + unlockHash, this)
					var licenseKey:String = registrationManager.tryingToValidateWithKey
					if (licenseKey=="")
					{
						Logger.error("licenseKey was an empty string when it should have had a license key.",this)
						registrationManager.viewing = RegistrationManager.VIEW_REGISTER
						registrationManager.registerViewing = RegistrationManager.REGISTER_VIEW_ERROR 
						registrationManager.errorMsg ="Unfortunately SimpleDiagrams is experiencing an error when trying to validate your key. Please contact support@simplediagrams.com and we'll help you out ASAP."
						return							
					}
					registrationManager.registerApplication(licenseKey)	
					registrationManager.viewing = RegistrationManager.VIEW_REGISTRATON_SUCCESS					
					dispatcher.dispatchEvent(new RegisterLicenseEvent(RegisterLicenseEvent.LICENSE_VALIDATED, true))
					break
				
				default:
					Logger.error("resultHandler() unrecognized event: " + e, this)
					registrationManager.viewing = RegistrationManager.VIEW_REGISTER
					registrationManager.registerViewing = RegistrationManager.REGISTER_VIEW_ERROR
					registrationManager.errorMsg = "There was an error contacting the license server. Please try again or contact us for help."
					dispatcher.dispatchEvent(new RegisterLicenseEvent(RegisterLicenseEvent.UNRECOGNIZED_STATUS, true))
			}
			
							
		}
		
		protected function faultHandler(e:Event):void
		{
			Logger.debug("faultHandler e : " + e, this)
			// a fault event can be IOErrorEvent or SecurityErrorEvent
			
			if(e is IOErrorEvent)
			{
				Logger.debug("faultHandler() IOError: " + IOErrorEvent(e).toString(),this)
			}
			else if (e is SecurityErrorEvent)
			{				
				Logger.debug("faultHandler() Security error: " + e,this)
			}
			else
			{
				Logger.debug("faultHandler() error: " + e,this)
			}
			
			registrationManager.viewing = RegistrationManager.VIEW_SERVER_UNAVALABLE
		}
				      
        
        [Mediate(event="RegistrationViewEvent.USE_IN_FULL_MODE")]
        public function startUsingSD(event:RegistrationViewEvent):void
        {
			//TODO : any kind of extra functionality that gets included with premium version can be activated here
			Logger.debug("startUsingSD",this)		
        	
			if (registrationManager.isDialog==false)
			{
				appModel.viewing = ApplicationModel.VIEW_STARTUP  
				appModel.menuEnabled = true 
			}
			else
			{
				if (appModel.diagramLoaded)
				{
					appModel.viewing = ApplicationModel.VIEW_DIAGRAM 
				}
				else
				{
					appModel.viewing = ApplicationModel.VIEW_STARTUP 
				}
			}
        }
		
		
		[Mediate(event="RegistrationViewEvent.USE_IN_FREE_MODE")]
		public function startFreeVersion(event:RegistrationViewEvent):void
		{
			if (registrationManager.isDialog==false)
			{				
				appModel.viewing = ApplicationModel.VIEW_STARTUP 
				appModel.menuEnabled = true 
			} 		
			else
			{
				if (appModel.diagramLoaded)
				{
					appModel.viewing = ApplicationModel.VIEW_DIAGRAM 
				}
				else
				{
					appModel.viewing = ApplicationModel.VIEW_STARTUP 
				}
			}
		}
		
		[Mediate(event="RegistrationViewEvent.TRY_REGISTERING_AGAIN")]
		public function tryRegisteringAgain(event:RegistrationViewEvent):void
		{
			Logger.debug("trying again...",this)
			registrationManager.viewing = RegistrationManager.VIEW_REGISTER
			registrationManager.registerViewing = RegistrationManager.REGISTER_VIEW_NORMAL
		}
		
        
		[Mediate(event="RegistrationViewEvent.SHOW_REGISTRATION_SCREEN")]
		public function onShowRegistrationScreen(event:RegistrationViewEvent):void
		{
			registrationManager.isDialog = true
			appModel.viewing = ApplicationModel.VIEW_REGISTRATION
			registrationManager.viewing = RegistrationManager.VIEW_REGISTER
		}
		
		[Mediate(event="RegistrationViewEvent.CANCEL_REGISTRATION_HTTP_REQUEST")]
		public function onCancelRegistrationRequestAttempt(event:RegistrationViewEvent):void
		{			
			try
			{
				_loader.close()
			}
			catch(error:Error)
			{
				Logger.debug("onCancelRegistrationRequestAttempt() Error trying to close URLRequest",this)
			}
			registrationManager.viewing = RegistrationManager.VIEW_REGISTER
		}
		
		
		
	}
}