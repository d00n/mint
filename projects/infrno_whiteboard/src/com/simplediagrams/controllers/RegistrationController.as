package com.simplediagrams.controllers
{
	import com.simplediagrams.events.LoadDiagramEvent;
	import com.simplediagrams.events.PluginEvent;
	import com.simplediagrams.events.RebuildDiagramEvent;
	import com.simplediagrams.events.RegisterLicenseEvent;
	import com.simplediagrams.events.RegistrationViewEvent;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.RegistrationManager;
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
	
	import mx.controls.Alert;
	import mx.rpc.AsyncToken;
	
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
		
		protected var _unregisterLoader:URLLoader
		
		public function RegistrationController()
		{
			_loader = new URLLoader();
			_loader.addEventListener( Event.COMPLETE, resultHandler)
			_loader.addEventListener( IOErrorEvent.IO_ERROR, faultHandler)
			_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, faultHandler)	
				
			_unregisterLoader = new URLLoader()
			_unregisterLoader.addEventListener( Event.COMPLETE, unregisterResultHandler)
			_unregisterLoader.addEventListener( IOErrorEvent.IO_ERROR, unregisterFaultHandler)
			_unregisterLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, unregisterFaultHandler)	
				
		}
		
		[Mediate(event="RegisterLicenseEvent.UNREGISTER_LICENSE")]
		public function unvalidateLicense(event:RegisterLicenseEvent):void
		{
			if (registrationManager.isLicensed==false)
			{
				Alert.show("This installation of SimpleDiagrams is not licensed")
				return
			}
			Logger.debug("unvalidateLicense()",this)			
			var urlRequest:URLRequest = new URLRequest(ApplicationModel.UNREGISTER_URL)
			
			urlRequest.method = URLRequestMethod.POST
			var variables:URLVariables = new URLVariables();
			variables.unregisterKey = registrationManager.licenseKey
			variables.email = registrationManager.licenseEmail
			urlRequest.data = variables;			
			_unregisterLoader.load(urlRequest)
		}
				
		[Mediate(event="RegisterLicenseEvent.VALIDATE_LICENSE")]
		public function validateLicense(event:RegisterLicenseEvent):void
		{			
			Logger.debug("validateLicense()",this)				
			registrationManager.registerViewing = RegistrationManager.REGISTER_VIEW_WAITING			
			registrationManager.tryingToValidateWithKey = event.licenseKey	
			registrationManager.tryingToValidateWithEmail = event.email	
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
			
			try
			{
				var resultXML:XML = XML(result)
				var status:int = resultXML.@id							
			}
			catch(err:Error)
			{
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
					if (status==RegistrationManager.STATUS_REGISTRATION_OK)
					{
						var unlockHash:String = resultXML.@unlock
					}	
					
					var licenseKey:String = registrationManager.tryingToValidateWithKey
					var licenseEmail:String = registrationManager.tryingToValidateWithEmail
					if (licenseKey=="")
					{
						registrationManager.viewing = RegistrationManager.VIEW_REGISTER
						registrationManager.registerViewing = RegistrationManager.REGISTER_VIEW_ERROR 
						registrationManager.errorMsg ="Unfortunately SimpleDiagrams is experiencing an error when trying to validate your key. Please contact support@simplediagrams.com and we'll help you out ASAP."
						return							
					}
										
					registrationManager.registerApplication(licenseKey, licenseEmail)	
					registrationManager.viewing = RegistrationManager.VIEW_REGISTRATON_SUCCESS			
					dispatcher.dispatchEvent(new RegisterLicenseEvent(RegisterLicenseEvent.LICENSE_VALIDATED, true))
					break
				
				default:
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
		
		
		
		
		
		protected function unregisterResultHandler(e:Event):void
		{
			var result:String = e.currentTarget.data;
			var status:int
			try
			{
				var resultXML:XML = XML(result)
				status = resultXML.@id
				if (status==RegistrationManager.STATUS_UNREGISTERED_OK)
				{
					registrationManager.deleteLicense()
					Alert.show("The license for this installation of SimpleDiagrams was removed.","Unregistered")					
					var evt:RegisterLicenseEvent = new RegisterLicenseEvent(RegisterLicenseEvent.LICENSE_UNREGISTERED, true)
					dispatcher.dispatchEvent(evt)					
					return						
				}
			}
			catch(err:Error)
			{
				status = RegistrationManager.STATUS_ERROR_RESPONSE_UNRECOGNIZED
				Alert.show("Couldn't unregister SimpleDiagrams. " + err, "Error")
			}	
			
		}
		
		
		
		
		
		protected function unregisterFaultHandler(e:Event):void
		{
			Logger.debug("faultHandler e : " + e, this)
			// a fault event can be IOErrorEvent or SecurityErrorEvent
			
			Alert.show("Couldn't contact server to unregister license. Please check your internet connection and try again.","Network Error")	
				
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
			
			
		}
		
		
		
		
		
		
		
		
		
		
		
		
				      
        
        [Mediate(event="RegistrationViewEvent.USE_IN_FULL_MODE")]
        public function startUsingSD(event:RegistrationViewEvent):void
        {
			
			appModel.menuEnabled = true 				
			//TODO : any kind of extra functionality that gets included with premium version can be activated here
			Logger.debug("startUsingSD",this)		
        	
			if (registrationManager.isDialog==false)
			{
				appModel.viewing = ApplicationModel.VIEW_STARTUP 
			}
			else
			{
				if (appModel.diagramLoaded)
				{
					appModel.viewing = ApplicationModel.VIEW_DIAGRAM 
					var evt:RebuildDiagramEvent = new RebuildDiagramEvent(RebuildDiagramEvent.REBUILD_DIAGRAM_EVENT, true)
					dispatcher.dispatchEvent(evt)
				}
				else
				{
					appModel.viewing = ApplicationModel.VIEW_STARTUP 
				}
			}
        }
		
		
		[Mediate(event="RegistrationViewEvent.USE_IN_TRIAL_MODE")]
		public function startFreeVersion(event:RegistrationViewEvent):void
		{			
			appModel.menuEnabled = true 
			
			if (this.registrationManager.trialDaysRemaining>0)
			{
				if (registrationManager.isDialog==false)
				{				
					appModel.viewing = ApplicationModel.VIEW_STARTUP 
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
			registrationManager.registerViewing = RegistrationManager.REGISTER_VIEW_NORMAL
		}
		
		[Mediate(event="RegistrationViewEvent.SHOW_BUY_NOW_SCREEN")]
		public function onShowBuyNowScreen(event:RegistrationViewEvent):void
		{
			registrationManager.isDialog = true
			appModel.viewing = ApplicationModel.VIEW_REGISTRATION
			registrationManager.viewing = RegistrationManager.VIEW_BUY_NOW
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