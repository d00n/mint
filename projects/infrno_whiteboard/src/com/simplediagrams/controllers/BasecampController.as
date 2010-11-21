package com.simplediagrams.controllers
{
	
	import com.simplediagrams.business.BasecampDelegate;
	import com.simplediagrams.events.BasecampEvent;
	import com.simplediagrams.events.BasecampLoginEvent;
	import com.simplediagrams.events.ExportDiagramEvent;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.BasecampModel;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.RegistrationManager;
	import com.simplediagrams.model.vo.PersonVO;
	import com.simplediagrams.model.vo.ProjectVO;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.dialogs.BasecampLoginDialog;
	import com.simplediagrams.view.dialogs.ExportDiagramToBasecampDialog;
	import com.simplediagrams.view.dialogs.NotifyListDialog;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.graphics.*;
	import mx.graphics.codec.PNGEncoder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.swizframework.controller.AbstractController
	
	import spark.components.Group;

	public class BasecampController extends AbstractController 
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
		public var basecampDelegate:BasecampDelegate;
		
		[Inject]
		public var basecampModel:BasecampModel;
		
		private var _exportInfoDialog:ExportDiagramToBasecampDialog	
		private var _notifyListDialog:NotifyListDialog
		private var _loginDialog:BasecampLoginDialog		
		private var _imageByteArray:ByteArray	
		private var _messageBody:String
		private var _extendedMessageBody:String
		private var _messageTitle:String
		private var _view:Group
		private var _uploadImageToken:AsyncToken
		
		public function BasecampController()
		{
		}
		
		[Mediate(event='BasecampEvent.CLEAR_LOGIN_CREDENTIALS')]
		public function clearLoginCredentials(event:BasecampEvent):void
		{
			basecampModel.clearFromEncryptedStore()	
			basecampModel.basecampLogin = ""
			basecampModel.basecampPassword = ""
			basecampModel.basecampURL = ""
		}
		
		[Mediate(event='ExportDiagramEvent.EXPORT_TO_BASECAMP')]
		public function exportDiagram(event:ExportDiagramEvent):void
		{
			Logger.debug("exportDiagram()", this)
			
			//make sure user is licensed
			if (registrationManager.isLicensed==false)
			{
				Alert.show("This feature is only available to Full Version users. Visit www.simpledigrams.com and upgrade to Full Version today!", "Full Version Only")
				return
			}
				
			_view = event.view as Group
			
			dialogsController.removeDialog()	
				
			//get login information if not already present			
			if (basecampModel.basecampLogin=="")
			{
				_loginDialog = dialogsController.showGetBasecampLoginDialog()		
				
			}
			else if (basecampModel.projectsAC.length==0)
			{
				//show logging in process bar and get projects directly
				_loginDialog = dialogsController.showGetBasecampLoginDialog()
				_loginDialog.currentState = BasecampLoginDialog.STATE_LOGGING_IN			
				doLogin()
			}
			else
			{	
				getExportInfoFromUser()
			}
		}
		
		/* A login is conducted by simply trying to get a list of projects and passing the users credentials with that GET request*/
		[Mediate(event="BasecampLoginEvent.BASECAMP_LOGIN_ATTEMPT")]
		public function onBasecampLogin(event:BasecampLoginEvent):void
		{						
			//test that credentials work
			if (basecampModel.basecampURL != event.url)
			{
				basecampModel.isDirty = true
				basecampModel.basecampURL = event.url
			}
			if (basecampModel.basecampLogin != event.login)
			{
				basecampModel.isDirty = true
				basecampModel.basecampLogin = event.login
			}
			if (basecampModel.basecampPassword != event.password)
			{
				basecampModel.isDirty = true
				basecampModel.basecampPassword = event.password
			}
			
			if (basecampModel.isDirty && event.rememberMe)
			{
				basecampModel.saveToEncryptedStore()
			}
			else if (basecampModel.isDirty && !event.rememberMe)
			{
				basecampModel.clearFromEncryptedStore()
			}
						
			doLogin()
		}
			
		[Mediate(event="BasecampLoginEvent.BASECAMP_LOGIN_CANCEL")]
		public function onLoginInfoCancel(event:Event):void
		{	
			basecampModel.clearFromEncryptedStore()
			removeLoginInfoDialog()
			dispatcher.dispatchEvent(new BasecampLoginEvent(BasecampLoginEvent.BASECAMP_LOGIN_CANCELED, true))
		}
		
		protected function removeLoginInfoDialog():void
		{			
			_loginDialog.removeEventListener(BasecampLoginEvent.BASECAMP_LOGIN_ATTEMPT, onBasecampLogin)	
			_loginDialog.removeEventListener(BasecampLoginEvent.BASECAMP_LOGIN_CANCEL, onLoginInfoCancel)
			dialogsController.removeDialog(_loginDialog)			
			_loginDialog = null
		}
		
			
		/* To login, this function tries to get a list of projects based
		on the current credentials stored in the basecampModel*/
		protected function doLogin():void
		{	
			executeServiceCall(basecampDelegate.getProjects(), doLoginResults, doLoginFaultHandler)	
		}
				
		
		//TODO :: Handle this more gracefully
		protected function doLoginFaultHandler(fe:FaultEvent):void
		{
			Logger.error("doLoginFaultHandler() couldn't login and get projects :" + fe.message, this)
			if (_loginDialog==null)
			{
				_loginDialog = dialogsController.showGetBasecampLoginDialog()	
			}
			_loginDialog.loginFailed()
			Alert.show("An error occurred when trying to login to your Basecamp account. Please re-enter your credentials.", "Basecamp Login Error")	
		}
		
		protected function doLoginResults(re:ResultEvent):void
		{			
			var resultsXML:XML = re.result as XML;		
			
			parseProjectsResults(resultsXML)
			
			if (basecampModel.projectsAC.length==0)
			{
				Alert.show("You do not have any projects created in Basecamp. Please go to your Basecamp account and create a project before exporting a SimpleDiagram.","No Projects Created")
				return
			}
									
			if (_loginDialog)
			{
				removeLoginInfoDialog()
			}
			
			getExportInfoFromUser()						
		}
		
		protected function parseProjectsResults(resultsXML:XML):void
		{
			basecampModel.projectsAC.removeAll()
			
			for each (var project:XML in resultsXML.*)
			{
				var projectVO:ProjectVO = new ProjectVO()
				projectVO.name = project.name
				projectVO.id = project.id
				basecampModel.projectsAC.addItem(projectVO)
			}
			
			basecampModel.projectsAC.refresh()
		}
		
		
		public function onRefreshProjects(event:Event):void
		{					
			executeServiceCall(basecampDelegate.getProjects(), refreshProjectsResults, refreshProjectsFaultHandler)	
		}
	
		protected function refreshProjectsResults(re:ResultEvent):void
		{			
			var resultsXML:XML = re.result as XML;			
			parseProjectsResults(resultsXML)		
			_exportInfoDialog.projectsRefreshed()					
		}
		
		protected function refreshProjectsFaultHandler(fe:FaultEvent):void
		{
			Logger.error("refreshProjectsFaultHandler() couldn't get projects:" + fe.message, this)
			Alert.show("Error occurred when trying to refresh projects. Error: " + fe.fault, "Basecamp Request Error")	
			_exportInfoDialog.projectsRefreshed()		
		}	
		
		
		
		protected function getExportInfoFromUser():void
		{		
			_view.clipAndEnableScrolling = false
			var bd:BitmapData = new BitmapData(diagramModel.width, diagramModel.height)
			bd.draw(_view)			
			_imageByteArray = new PNGEncoder().encode(bd)
			_messageBody = ""
			_extendedMessageBody = ""
			_messageTitle = ""
				
			_exportInfoDialog = dialogsController.showExportDiagramToBasecampDialog()		
			_exportInfoDialog.addEventListener("OK", onExportDialogOK)	
			_exportInfoDialog.addEventListener("changeLogin", onExportDialogChangeLogin)
			_exportInfoDialog.addEventListener(BasecampEvent.REFRESH_PROJECTS, onRefreshProjects)	
			_exportInfoDialog.addEventListener(Event.CANCEL, onExportCancel)
			_exportInfoDialog.addEventListener(BasecampEvent.CANCEL_UPLOAD, onCancelUpload)
			_exportInfoDialog.imageData = _imageByteArray
			_view.clipAndEnableScrolling = true
		}
		
		
		
		protected function onCancelUpload(event:BasecampEvent):void
		{			
			basecampDelegate.cancelServiceCall()
			_exportInfoDialog.currentState = "normal"
		}
		
		protected function onExportDialogChangeLogin(event:Event):void
		{	
			basecampModel.basecampURL = ""
			basecampModel.basecampLogin = ""
			basecampModel.basecampPassword = ""
			basecampModel.clearFromEncryptedStore()
			
			clearExportInfoDialog()	
						
			_loginDialog = dialogsController.showGetBasecampLoginDialog()	
		}
		
		protected function onExportDialogOK(event:Event):void
		{						
			_messageBody = _exportInfoDialog.messageBody
			_extendedMessageBody = _exportInfoDialog.extendedMessageBody
			_messageTitle = _exportInfoDialog.messageTitle
			basecampModel.msgIsPrivate = _exportInfoDialog.msgIsPrivate			
			startImageUpload()			
		}
		
		protected function startImageUpload():void
		{
			executeServiceCall(basecampDelegate.uploadImage(_imageByteArray), uploadImageHandler, uploadImageFaultHandler)
		}
		
		protected function uploadImageHandler(re:ResultEvent):void
		{	
			//if we get an OK after uploading image, now we can add textual data
			
			var resultXML:XML = re.result as XML;
			Logger.debug(" image uploaded image ok:" + resultXML.toXMLString(), this)
				
			var imageUploadID:String = resultXML.id
			Logger.debug(" upload image id is:" + imageUploadID, this)
			
			//now upload the message, which will use the uploaded image			
			uploadMessage(imageUploadID)
		}
		
		protected function uploadImageFaultHandler(fe:FaultEvent):void
		{
			Logger.debug("couldn't upload image:" + fe.message, this)
			// TODO handle fault
			clearExportInfoDialog()	
		}
		
		
		protected function uploadMessage(imageUploadID:String):void
		{	
			//now that image is uploaded, we send the message and refer to the image by upload ID
			executeServiceCall(basecampDelegate.sendMessage(_messageTitle, _messageBody, _extendedMessageBody, imageUploadID, basecampModel.selectedProjectID), resultHandler, faultHandler)
			
		}
		
		protected function resultHandler(re:ResultEvent):void
		{
			Logger.debug("send message result OK :" + re.message, this)
			Alert.show("Export completed.")
			clearExportInfoDialog()
		}
		
		protected function faultHandler(fe:FaultEvent):void
		{
			Logger.debug("send message failed :" + fe.message, this)
			Alert.show("Export failed. Here is the error from Basecamp: " + fe.message, "Basecamp Error")
			clearExportInfoDialog()
		}

		
		
		protected function onExportCancel(event:Event):void
		{			
			clearExportInfoDialog()
		}
				
		protected function clearExportInfoDialog():void
		{
			dialogsController.removeDialog(_exportInfoDialog)
			_exportInfoDialog.removeEventListener("OK", onExportDialogOK)
			_exportInfoDialog.removeEventListener(BasecampEvent.CANCEL_UPLOAD, onCancelUpload)
			_exportInfoDialog.removeEventListener(BasecampEvent.REFRESH_PROJECTS, onRefreshProjects)	
			_exportInfoDialog.removeEventListener(Event.CANCEL, onExportCancel)
			_exportInfoDialog = null
		}	
		
		
		/* ***************/
		/*  NOTIFY LIST  */
		/* ***************/
		
		
		
		[Mediate(event="BasecampEvent.SHOW_CHANGE_NOTIFY_WINDOW")]
		public function showChangeNotifyListWindow(event:BasecampEvent):void
		{
			Logger.debug("Showing change notify list window",this)
			if (_notifyListDialog)
			{
				dialogsController.removeDialog(_notifyListDialog)
			}
			
			_notifyListDialog = dialogsController.showNotifyListDialog()	
			_notifyListDialog.addEventListener("OK", onCloseNotifyListDialog)
			_notifyListDialog.addEventListener(Event.CANCEL, onCancelNotifyListDialog)
				
			if (basecampModel.peopleAC.length==0)
			{				
				_notifyListDialog.currentState="loading"
				executeServiceCall(basecampDelegate.getPeople(), getPeopleHandler, getPeopleHandlerFaultHandler)
			}
			else
			{				
				_notifyListDialog.currentState="normal"
			}
			
		}
		
		protected function onCloseNotifyListDialog(event:Event):void
		{
			basecampModel.selectedPeopleAC.refresh()
			removeNotifyEventListeners()
			this.dialogsController.removeDialog(_notifyListDialog, false)
		}
		
		protected function onCancelNotifyListDialog(event:Event):void
		{
			removeNotifyEventListeners()
			basecampDelegate.cancelServiceCall()
			this.dialogsController.removeDialog(_notifyListDialog, false)
		}
		
		protected function removeNotifyEventListeners():void
		{
			_notifyListDialog.removeEventListener("OK", onCloseNotifyListDialog)
			_notifyListDialog.removeEventListener(Event.CANCEL, onCancelNotifyListDialog)
			
		}
		
		[Mediate(event="BasecampEvent.REFRESH_PEOPLE")]
		public function refreshPeople(event:BasecampEvent):void
		{
			executeServiceCall(basecampDelegate.getPeople(), getPeopleHandler, getPeopleHandlerFaultHandler)
		}
		
		
		protected function getPeopleHandler(re:ResultEvent):void
		{				
			var resultsXML:XML = re.result as XML;			
			
			var peopleArr:Array = new Array()
			for each (var personXML:XML in resultsXML.*)
			{
				var personVO:PersonVO = new PersonVO()				
				personVO.firstName = personXML["first-name"]
				personVO.lastName = personXML["last-name"]
				personVO.id = personXML.id
				Logger.debug("adding firstname: " + personVO.firstName + " to AC",this)
				peopleArr.push(personVO)
			}
			
			basecampModel.peopleArr = peopleArr
				
			Logger.debug("basecampModel.peopleAC.length: " + basecampModel.peopleAC.length,this)
			if (basecampModel.peopleAC.length==0)
			{
				Alert.show("You do not have any people in Basecamp to notify. Maybe it's time to involve others.","No People Available")
				return
			}
			
			basecampModel.peopleAC.refresh()
			
			_notifyListDialog.currentState = "normal"
			
		}
		
		protected function getPeopleHandlerFaultHandler(fe:FaultEvent):void
		{
			Logger.debug("send message failed :" + fe.message, this)
			Alert.show("Couldn't get a list of people from Basecamp. Here is the error from Basecamp: " + fe.message, "Basecamp Error")
		
		}
		
		
		
		
		
	}
}