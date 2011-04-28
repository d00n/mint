package com.simplediagrams.controllers
{
	  
//	import com.simplediagrams.business.DBManager;
	import com.simplediagrams.business.LibraryPluginsDelegate;
	import com.simplediagrams.business.SettingsDelegate;
	import com.simplediagrams.events.ApplicationEvent;
	import com.simplediagrams.events.CloseDiagramEvent;
	import com.simplediagrams.events.CreateNewDiagramEvent;
	import com.simplediagrams.events.LoadDiagramEvent;
	import com.simplediagrams.events.LoadLibraryPluginEvent;
	import com.simplediagrams.events.OpenDiagramEvent;
	import com.simplediagrams.events.SaveDiagramEvent;
	import com.simplediagrams.events.SelectionEvent;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.BasecampModel;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.DiagramStyleManager;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.RegistrationManager;
	import com.simplediagrams.model.SettingsModel;
	import com.simplediagrams.model.YammerModel;
	import com.simplediagrams.util.AboutInfo;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.AboutWindow;
	import com.simplediagrams.view.dialogs.CustomAlert;
	import com.simplediagrams.view.dialogs.LoadingLibraryPluginsDialog;
	import com.simplediagrams.view.dialogs.VerifyQuitDialog;
	
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import org.swizframework.controller.AbstractController;

	public class ApplicationController extends AbstractController 
	{       
		
		[Inject]
		public var appModel:ApplicationModel;
		
		[Inject]
		public var registrationManager:RegistrationManager;
		
		[Inject]
		public var settingsManager:SettingsDelegate
		
		[Inject]
		public var settingsModel:SettingsModel
		
		[Inject]
		public var diagramModel:DiagramModel;
		
		[Inject]
		public var libraryManager:LibraryManager;
		
		[Inject]
		public var yammerModel:YammerModel;
		
		[Inject]
		public var basecampModel:BasecampModel;
		
		[Inject]
		public var diagramStyleManager:DiagramStyleManager
		
		[Inject]
		public var dialogsController:DialogsController;
		
//		[Inject]
//		public var dbManager:DBManager;
					
		
		protected var _verifyQuitDialog:VerifyQuitDialog
		protected var _loadLibraryPluginsDialog:LoadingLibraryPluginsDialog
		protected var _libraryPluginsDelegate:LibraryPluginsDelegate
		protected var _aboutWindow:AboutWindow
		
				   
		public function ApplicationController() 
		{				
			
			Logger.debug("ApplicationController created.", this)
			
			//add close listener to intercept application close event
//			FlexGlobals.topLevelApplication.addEventListener(Event.CLOSING, onWindowClose, false,0,true);
			
		}
		
		[Mediate(event="SelectionEvent.SELECTION_CLEARED")]
		public function selectionCleared(event:SelectionEvent):void
		{
			FlexGlobals.topLevelApplication.setFocus()
		}
		
		[Mediate(event="CreateNewDiagramEvent.NEW_DIAGRAM_CREATED")]
		public function createNewDiagram(event:CreateNewDiagramEvent):void
		{			
			appModel.viewing = ApplicationModel.VIEW_DIAGRAM	
			appModel.currFileName = "New SimpleDiagram"
		}
		
		[Mediate(event="LoadDiagramEvent.DIAGRAM_LOADED")]
		public function diagramLoaded(event:LoadDiagramEvent):void
		{	
			Logger.debug("diagramLoaded() ",this)
			appModel.viewing = ApplicationModel.VIEW_DIAGRAM	
			appModel.currFileName = "File: " + event.fileName
		}
		
		[Mediate(event="SaveDiagramEvent.DIAGRAM_SAVED")]
		public function diagramSaved(event:SaveDiagramEvent):void
		{
			appModel.currFileName = "File: " + event.fileName
		}
		
		[Mediate(event="CloseDiagramEvent.DIAGRAM_CLOSED")]
		public function diagramClosed(event:CloseDiagramEvent):void
		{
			appModel.currFileName = "SimpleDiagrams"
		}
		
		[Mediate("mx.events.FlexEvent.APPLICATION_COMPLETE" )] 
		public function onApplicationComplete():void
		{ 
			FlexGlobals.topLevelApplication.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
		}
		
		private function onUncaughtError(e:UncaughtErrorEvent):void
		{
			var msg:String;
			if (e.error is Error)
			{
				var error:Error = e.error as Error
				msg = "Error: "+error.errorID + " " + error.name +" " +error.message
				Logger.error(msg, this);
			}
			else
			{
				var errorEvent:ErrorEvent = e.error as ErrorEvent;  
				msg = "ErrorEvent: " + errorEvent.errorID.toString()
				Logger.error(msg, this);
			}
			Alert.show(msg, "Your table has become corrupted. The authorities have been alerted. Please reset your table.")
		}		
		
		[Mediate("mx.events.FlexEvent.APPLICATION_COMPLETE" )] 
		public function initApp(event:FlexEvent):void
		{	
			Logger.info("initApp()", this)
				
			//UNCOMMENT FOR TESTING			
			//registrationManager.deleteLicense()
			//EncryptedLocalStore.removeItem("userAgreedToEULA")
			//basecampModel.clearFromEncryptedStore()
			//yammerModel.clearFromEncryptedStore()
							
			Logger.info("checking EULA...",this)
			//CHECK AGREED TO EULA				
			var agreedToEULA:Boolean 
			try
			{
				agreedToEULA = appModel.didUserAgreeToEULA()
			}
			catch(err:Error)
			{
				Logger.error("Couldn't read 'agreedToEULA' string from model", this)
				agreedToEULA = false
			}
			Logger.info("agreedToEULA: " + agreedToEULA.toString(),this)
			
			if (agreedToEULA==false)
			{
				appModel.menuEnabled = false 
				appModel.viewing=ApplicationModel.VIEW_EULA	
				return
			}
			else
			{
				doStartupTasks()
			}
		}
				
//		[Mediate(event="EULAEvent.USER_AGREED_TO_EULA")]
		public function onUserAgreedToEULA():void
		{
			appModel.userAgreedToEULA()
			doStartupTasks()
		}
		
					
		public function doStartupTasks():void
		{
					
			Logger.info("loading settings...",this)						
			//load in settings
			try
			{
				settingsManager.loadSettings()
			}
			catch(error:Error)
			{
				Logger.error("Couldn't load settings", this)
			}
					
			//setup log
			Logger.info("initLogFile...",this)
			try
			{				
				initLogFile()
			}
			catch(error:Error)
			{
				Logger.error("Couldn't init log. Error: " + error, this)
			}
						
			
			//CHECK LICENSE			
//			Logger.debug("isLicensed: " + registrationManager.isLicensed,this)
//			if (registrationManager.isLicensed)
//			{	
//				//show dialog that we're loading stored libraries
//				_loadLibraryPluginsDialog = dialogsController.showLoadLibraryPluginsDialog()
//				_loadLibraryPluginsDialog.addEventListener(Event.CANCEL, onLoadLibraryPluginsCancel)
//				
//				Logger.debug("LOADING LIBRARY PLUG-INS...", this)
//				//load library plug-ins
//				try
//				{
//					_libraryPluginsDelegate = new LibraryPluginsDelegate()
//					_libraryPluginsDelegate.addEventListener(LibraryPluginsDelegate.LOADING_FINISHED, onLoadingLibraryPluginsFinished)
//					_libraryPluginsDelegate.addEventListener(LibraryPluginsDelegate.LOADING_FAILED, onLoadingLibraryPluginsFailed)
//					_libraryPluginsDelegate.loadLibraries(libraryManager)
//				}
//				catch(err:Error)
//				{
//					Logger.error("Error when loading library plug-ins. Error: " + err, this)	
//						
//					var msg:String = "An error occurred when loading library plug-ins. One of the library plug-ins may be corrupt. Please delete the library plug-ins and reload them to fix this problem. "
//					Alert.show(msg, "Library Load Error")	
//				}	
//				
//			}
//			else
//			{
//				Logger.debug("showing view registration...",this)
//				appModel.menuEnabled = false //will be turned on when user clicks continue
//				appModel.viewing=ApplicationModel.VIEW_REGISTRATION
//				libraryManager.hidePremiumLibraries()
//			}			
			
			Logger.debug("settings styles to:" + settingsModel.defaultDiagramStyle,this)
			//set initial styles -- this should be loaded from a settings folder later
			diagramStyleManager.changeStyle(settingsModel.defaultDiagramStyle)	
															
		}
		
		protected function onLoadingLibraryPluginsFinished(event:LoadLibraryPluginEvent):void
		{	
//			if (_libraryPluginsDelegate.errorsEncountered)
//			{
//				var msg:String = "The following errors occurred when loading library plugins:\n\n<ul>"
//				for (var i:uint=0;i<_libraryPluginsDelegate.errorsErr.length;i++)
//				{	
//					msg += "<li>" + _libraryPluginsDelegate.errorsErr[i] + "</li>"
//				}
//				msg += "</ul>\nPlease download the latest libraries from SimpleDiagrams.com"	
//				var alert:CustomAlert = new CustomAlert()
//				alert.width=400
//				alert.height=250			
//				alert.text=msg
//				alert.title =  "Plugin Library Load Error"
//				alert.invalidateSize()
//				PopUpManager.addPopUp(alert, FlexGlobals.topLevelApplication as DisplayObject)
//				PopUpManager.centerPopUp(alert)	
//					
//			}			
//			dialogsController.removeDialog(_loadLibraryPluginsDialog)
//			_loadLibraryPluginsDialog = null
//			appModel.viewing = ApplicationModel.VIEW_STARTUP			
		}
		
		protected function onLoadingLibraryPluginsFailed(event:LoadLibraryPluginEvent):void
		{	
			Alert.show("An error occurred when loading library plug-ins. Some library plug-ins may not have loaded correctly. Please see log for details.", "Library Load Error")			
			dialogsController.removeDialog(_loadLibraryPluginsDialog)
			_loadLibraryPluginsDialog = null
			appModel.viewing = ApplicationModel.VIEW_STARTUP			
		}
		
		protected function onLoadLibraryPluginsCancel(event:Event):void
		{
			_loadLibraryPluginsDialog.removeEventListener(Event.CANCEL, onLoadLibraryPluginsCancel)
			dialogsController.removeDialog(_loadLibraryPluginsDialog)			
			_loadLibraryPluginsDialog = null
			_libraryPluginsDelegate.cancelLoad()
			appModel.viewing = ApplicationModel.VIEW_STARTUP	
		}
		
		
		public function onWindowClose(event:Event):void
		{
			Logger.debug("onWindowClose()",this)
			event.preventDefault();
			quitApp(null)
		}
		
		
		
		[Mediate(event="ApplicationEvent.QUIT")]
		public function quitApp(event:ApplicationEvent):void
		{			
			Logger.debug("quitApp()",this)
			if (diagramModel.isDirty && ApplicationModel.testMode==false)
			{
				_verifyQuitDialog = dialogsController.showVerifyQuitDialog()
				_verifyQuitDialog.addEventListener(VerifyQuitDialog.QUIT, onQuit)
				_verifyQuitDialog.addEventListener(Event.CANCEL, onCancelSaveBeforeQuit)
			}
			else
			{			
				onQuit(null)
			}
			
		}
		
		
		public function onCancelSaveBeforeQuit(event:Event):void
		{			
			dialogsController.removeDialog(_verifyQuitDialog)
			
			_verifyQuitDialog.removeEventListener(VerifyQuitDialog.QUIT, onQuit)
			_verifyQuitDialog.removeEventListener(Event.CANCEL, onCancelSaveBeforeQuit)
			_verifyQuitDialog = null
			//and then let user continue working...
		}	
		
		public function onQuit(event:Event):void
		{
			settingsManager.saveSettings()
			FlexGlobals.topLevelApplication.exit()
		}
		
	
				
		
		protected function initLogFile():void
		{
//			Logger.debug("initLogFile()", this)
//			
//			//make sure directory exists
//			var logFileDir:File = File.applicationStorageDirectory.resolvePath(ApplicationModel.logFileDir)
//			if (!logFileDir.exists)
//			{
//				try
//				{
//					logFileDir.createDirectory()
//				}
//				catch(error:Error)
//				{
//					Logger.error("Couldn't create log file directory: " + logFileDir.nativePath,this)
//				}
//			}
//				
//			//Clear out any old files							
//			var logFile:File = logFileDir.resolvePath(ApplicationModel.logFileName)
//			if (logFile.exists)
//			{
//				logFile.deleteFile()
//			}
//			
//			Logger.info("SimpleDiagrams version: " + AboutInfo.applicationVersion, this)
//			Logger.info("Flash player version: " + AboutInfo.flashPlayerVersion, this)
//			Logger.info("Writing log file to: " + File.applicationStorageDirectory.resolvePath(ApplicationModel.logFileDir).nativePath, this)
//				
				
		}       
					 
		protected function initLibrary():void
        {
			Logger.debug("initLibrary()", this)
        	libraryManager.loadInitialData()
        }
         
         
      	
		
		
        
        
        
	}
  
}