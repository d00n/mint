package com.simplediagrams.controllers
{
	
	import com.simplediagrams.business.YammerDelegate;
	import com.simplediagrams.events.ExportDiagramEvent;
	import com.simplediagrams.events.YammerEvent;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.RegistrationManager;
	import com.simplediagrams.model.YammerModel;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.dialogs.ExportDiagramToYammerDialog;
	import com.simplediagrams.view.dialogs.YammerLoginDialog;
	
	import flash.display.BitmapData;
	import flash.events.Event;
//	import flash.filesystem.*;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.graphics.*;
	import mx.graphics.codec.PNGEncoder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.swizframework.controller.AbstractController;
	
	import spark.components.Group;
	
	public class YammerController extends AbstractController
	{
		
		
		[Inject]
		public var dialogsController:DialogsController
		
		[Inject]
		public var applicationModel:ApplicationModel
		
		[Inject]
		public var registrationManager:RegistrationManager
		
		[Inject]
		public var diagramModel:DiagramModel
		
		[Inject]
		public var yammerDelegate:YammerDelegate;
		
		[Inject]
		public var yammerModel:YammerModel;
		
		private var _loginDialog:YammerLoginDialog	
		private var _exportDialog:ExportDiagramToYammerDialog		
		private var _imageByteArray:ByteArray	
		private var _messageBody:String
		private var _extendedMessageBody:String
		private var _messageTitle:String
		private var _view:Group
		private var _uploadImageToken:AsyncToken
//		private var _tempImageFile:File
		
		public function YammerController():void
		{			
			
		}
		
		[PostConstruct]
		public function initialize():void
		{
			yammerDelegate.addEventListener(YammerDelegate.UPLOAD_COMPLETE, uploadImageResultHandler)
			yammerDelegate.addEventListener(YammerDelegate.UPLOAD_ERROR, uploadImageFaultHandler)
		}
		
		[Mediate(event='YammerEvent.CLEAR_LOGIN_CREDENTIALS')]
		public function clearLoginCredentials(event:YammerEvent):void
		{
			yammerModel.clearFromEncryptedStore()	
			yammerModel.permAccessSecret = ""
			yammerModel.permAccessToken = ""
		}
		
		[Mediate(event='ExportDiagramEvent.EXPORT_TO_YAMMER')]
		public function exportDiagramToYammer(event:ExportDiagramEvent):void
		{
			Logger.debug("exportDiagramToYammer()", this)
			
			if (_loginDialog)
			{
				removeLoginInfoDialog()
			}
				
			//make sure user is licensed
			if (registrationManager.isLicensed==false)
			{
				Alert.show("This feature is only available to Full Version users. Visit simpledigrams.com and upgrade to Full Version today!", "Full Version Only")
				return
			}
			
			_view = event.view as Group
			
			//do authorization routine if no perm. token exist
			if (yammerModel.permAccessToken=="" || yammerModel.permAccessSecret=="")
			{					
				executeServiceCall(yammerDelegate.getRequestTokenAndSecret(), getRequestTokenAndSecretResultHandler, getRequestTokenAndSecretFaultHandler)
			}
			else
			{	
				showExportDialog()
			}
		}
		
		
					
		
		protected function getRequestTokenAndSecretResultHandler(event:ResultEvent):void
		{
			Logger.debug("getRequestTokenAndSecretResultHandler() result: " + event.result, this)
							
			yammerModel.oauthToken = event.result.oauth_token
			yammerModel.oauthTokenSecret = event.result.oauth_token_secret
			
			Logger.debug("showing dialog", this)	
			_loginDialog = dialogsController.showGetYammerLoginDialog()		
			_loginDialog.currentState = YammerLoginDialog.STATE_SHOW_AUTHORIZE					
			_loginDialog.addEventListener(Event.CANCEL, onLoginInfoCancel)				
			_loginDialog.addEventListener(YammerEvent.SHOW_AUTHORIZE_WEBPAGE, showAuthorizeWebpage)
			_loginDialog.addEventListener(YammerEvent.AUTHORIZATION_COMPLETE, onAuthorizationComplete)	
			_loginDialog.addEventListener(YammerEvent.AUTHORIZATION_WINDOW_DONE, onAuthorizationWindowDone)	
			_loginDialog.addEventListener(YammerEvent.EXPORT_DIAGRAM, onExportAfterLogin)	
			_loginDialog.currentState = YammerLoginDialog.STATE_SHOW_AUTHORIZE	
							
		}
		
		
		protected function getRequestTokenAndSecretFaultHandler(event:FaultEvent):void
		{
			Logger.debug("error getting request token: " + event, this)
			Alert.show("SimpleDiagrams couldn't contact Yammer to start the authorization process. Please try again later.","Network Error")
		}
		
		protected function onLoginInfoCancel(event:Event):void
		{
			removeLoginInfoDialog()
		}
		
		protected function onExportAfterLogin(event:YammerEvent):void
		{
			removeLoginInfoDialog()
			showExportDialog()
		}
		
		protected function removeLoginInfoDialog():void
		{
			dialogsController.removeDialog(_loginDialog)			
			_loginDialog.removeEventListener(YammerEvent.SHOW_AUTHORIZE_WEBPAGE, showAuthorizeWebpage)
			_loginDialog.removeEventListener(YammerEvent.AUTHORIZATION_COMPLETE, onAuthorizationComplete)	
			_loginDialog.removeEventListener(YammerEvent.AUTHORIZATION_WINDOW_DONE, onAuthorizationWindowDone)			
			_loginDialog.removeEventListener(Event.CANCEL, onLoginInfoCancel)
			_loginDialog.removeEventListener(YammerEvent.EXPORT_DIAGRAM, onExportAfterLogin)	
			_loginDialog = null
		}
			
		
		protected function showAuthorizeWebpage(event:YammerEvent):void
		{			
			yammerDelegate.showAuthorizePage()		
		}
				
		
		public function onAuthorizationComplete(event:Event):void
		{							
			executeServiceCall(yammerDelegate.getPermTokenAndSecretToken(), getPermTokenAndSecretResultHandler, getPermTokenAndSecretFaultHandler)			
			_loginDialog.currentState = YammerLoginDialog.STATE_AUTH_COMPLETE
		}
		
		protected function onAuthorizationWindowDone(event:Event):void
		{				
			removeLoginInfoDialog()			
		}
		
		
		protected function getPermTokenAndSecretResultHandler(event:ResultEvent):void
		{
			
			Logger.debug("getPermTokenAndSecretResultHandler() result: " + event.result, this)
			yammerModel.permAccessToken = event.result.oauth_token
			yammerModel.permAccessSecret = event.result.oauth_token_secret
			yammerModel.saveToEncryptedStore()
				
		}
		
		protected function getPermTokenAndSecretFaultHandler(event:FaultEvent):void
		{
			Logger.debug("error getting token: " + event, this)
			Alert.show("SimpleDiagrams couldn't retrieve a security token from Yammer. Please try the process again later.","Network Error")
		}
		
		
		protected function showExportDialog():void
		{
			_exportDialog = dialogsController.showExportDiagramToYammerDialog()	
			_exportDialog.addEventListener("exportDiagram", uploadImageToYammer)
			_exportDialog.addEventListener("cancel", onUploadCancel)
				
			_view.clipAndEnableScrolling = false
			var bd:BitmapData = new BitmapData(diagramModel.width, diagramModel.height)
			bd.draw(_view)
			_imageByteArray = new PNGEncoder().encode(bd)	
			_exportDialog.imageData = _imageByteArray		
			_view.clipAndEnableScrolling = true												
		}
				
		protected function onUploadCancel(event:Event):void
		{
			removeExportDialog()
		}
		
		
		protected function uploadImageToYammer(event:Event):void
		{				
			Logger.debug("uploadImageToYammer()", this)
			yammerDelegate.postMessage(yammerModel.message, _imageByteArray)			
		}
			
		
		protected function uploadImageResultHandler(event:Event):void
		{
			
			Alert.show("Export completed.")
			removeExportDialog()			
		}
		
		protected function uploadImageFaultHandler(event:Event):void
		{
			Alert.show("Could not upload image to Yammer. Please see log for details.","Upload Error")
			removeExportDialog()		
		}
		
		protected function removeExportDialog():void
		{
			dialogsController.removeDialog(_exportDialog)			
			_exportDialog.removeEventListener("exportDiagram", uploadImageToYammer)
			_exportDialog = null
		}
		
		
		
	}
}