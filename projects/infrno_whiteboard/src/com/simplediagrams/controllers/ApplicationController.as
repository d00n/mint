package com.simplediagrams.controllers
{
	  
//	import air.update.ApplicationUpdaterUI;
//	import air.update.events.UpdateEvent;
	
	import com.simplediagrams.business.LibraryDelegate;
	import com.simplediagrams.business.LibraryRegistryDelegate;
	import com.simplediagrams.business.RemoteLibraryDelegate;
	import com.simplediagrams.business.RemoteLibraryDelegateManager;
	import com.simplediagrams.business.RemoteLibraryRegistryDelegate;
	import com.simplediagrams.business.SettingsDelegate;
	import com.simplediagrams.events.ApplicationEvent;
	import com.simplediagrams.events.CloseDiagramEvent;
	import com.simplediagrams.events.CreateNewDiagramEvent;
	import com.simplediagrams.events.LibraryEvent;
	import com.simplediagrams.events.LoadDiagramEvent;
	import com.simplediagrams.events.OpenDiagramEvent;
	import com.simplediagrams.events.PluginEvent;
	import com.simplediagrams.events.RemoteLibraryEvent;
	import com.simplediagrams.events.SaveDiagramEvent;
	import com.simplediagrams.events.SelectionEvent;
	import com.simplediagrams.events.SettingsEvent;
	import com.simplediagrams.events.TestInvoke;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.BasecampModel;
	import com.simplediagrams.model.DiagramManager;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.RegistrationManager;
	import com.simplediagrams.model.SettingsModel;
	import com.simplediagrams.model.UndoRedoManager;
	import com.simplediagrams.model.YammerModel;
	import com.simplediagrams.model.libraries.LibrariesRegistry;
	import com.simplediagrams.model.libraries.Library;
	import com.simplediagrams.model.libraries.LibraryInfo;
	import com.simplediagrams.model.libraries.LibraryItem;
	import com.simplediagrams.model.libraries.VectorShape;
	import com.simplediagrams.util.AboutInfo;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.AboutWindow;
	import com.simplediagrams.view.TrialBar;
	import com.simplediagrams.view.dialogs.CustomAlert;
	import com.simplediagrams.view.dialogs.LoadingLibraryPluginsDialog;
	import com.simplediagrams.view.dialogs.UpdateToTrialModeDialog;
	import com.simplediagrams.view.dialogs.VerifyQuitDialog;
	
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.system.ApplicationDomain;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.InvokeEvent;
	
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
		public var diagramManager:DiagramManager;
		
		[Inject]
		public var undoRedoManager:UndoRedoManager;
		
		[Inject]
		public var yammerModel:YammerModel;
		
		[Inject]
		public var basecampModel:BasecampModel;
		
		
		[Inject]
		public var dialogsController:DialogsController;
					
		
		protected var _verifyQuitDialog:VerifyQuitDialog
		protected var _aboutWindow:AboutWindow
		
				   
		public function ApplicationController() 
		{				
			LibraryRegistryDelegate;
			Logger.debug("ApplicationController created.", this);
			
			//add close listener to intercept application close event
//			FlexGlobals.topLevelApplication.addEventListener(Event.CLOSING, onWindowClose, false,0,true);
			
		}
		
		
		
		private function onUncaughtError(e:UncaughtErrorEvent):void
		{
			if (e.error is Error)
			{
				var error:Error = e.error as Error
				var msg:String = error.errorID + " " + error.name +" " +error.message
				Logger.error(msg, this);
			}
			else
			{
				var errorEvent:ErrorEvent = e.error as ErrorEvent;	
				msg = "error ID " + errorEvent.errorID.toString()
				Logger.error(errorEvent.errorID, this);
			}
			Alert.show(msg, "System Error")
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
		
		[Mediate(event="LoadDiagramEvent.DIAGRAM_READY")]
		public function diagramLoaded(event:LoadDiagramEvent):void
		{	
			appModel.viewing = ApplicationModel.VIEW_DIAGRAM	
			appModel.currFileName = event.fileName
		}
		
		[Mediate(event="SaveDiagramEvent.DIAGRAM_SAVED")]
		public function diagramSaved(event:SaveDiagramEvent):void
		{
			appModel.currFileName =  event.fileName
			undoRedoManager.isDirty = false;
		}
		
		[Mediate(event="CloseDiagramEvent.DIAGRAM_CLOSED")]
		public function diagramClosed(event:CloseDiagramEvent):void
		{
			appModel.currFileName = "SimpleDiagrams"
		}
		
		[Mediate("mx.events.FlexEvent.APPLICATION_COMPLETE" )] 
		public function initApp(event:FlexEvent):void
		{	
			Logger.info("initApp()", this)
				
			
			//UNCOMMENT FOR TESTING			
			//registrationManager.deleteLicense()
			//EncryptedLocalStore.removeItem("userAgreedToEULA")
			//EncryptedLocalStore.removeItem("userAgreedToEULA1.2")
			//EncryptedLocalStore.removeItem("userAgreedToEULA1.2")
			//EncryptedLocalStore.removeItem("dateTrialStarted")
			//basecampModel.clearFromEncryptedStore()
			//yammerModel.clearFromEncryptedStore()
										
			FlexGlobals.topLevelApplication.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
							
			doUpdateCheck()	
			
//			//If we want to do anything special immediately after an upgrade do it here
//			if (appModel.lastInstalledVersion != appModel.version)
//			{				
//				//stuff to do immediately after an upgrade goes here
//				
//				//set the first trial date if this is an upgrade and the date was never set
//				if (registrationManager.isLicensed==false && registrationManager.dateTrialStarted==null)
//				{
//					registrationManager.recordDateTrialStarted()
//				}
//								
//				appModel.lastInstalledVersion = appModel.version
//			}
//							
				
			Logger.info("checking EULA...",this)
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
				
		[Mediate(event="EULAEvent.USER_AGREED_TO_EULA")]
		public function onUserAgreedToEULA():void
		{
			appModel.userAgreedToEULA()				
			registrationManager.recordDateTrialStarted()		
			doStartupTasks()
		}
		
					
		public function doStartupTasks():void
		{
						
			//make sure user folder exists
//			try
//			{
//				var userFolder:File = ApplicationModel.baseStorageDir
//				if (userFolder.exists==false)
//				{
//					userFolder.createDirectory()
//				}
//			}
//			catch(error:Error)
//			{
//				Alert.show("SimpleDiagrams can't create a storage directory here: " + userFolder.nativePath  + " Please create this folder manually and then restart SimpleDiagrams", "Error")
//				return
//			}
//			
//			//load in settings
//			try
//			{
//				settingsManager.loadSettings()
//				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.SETTINGS_LOADED, true));
//				if(appModel.version != settingsModel.appVersion)
//				{
//					dispatcher.dispatchEvent(new LibraryEvent(LibraryEvent.COPY_LIBRARIES));
//					settingsModel.appVersion = appModel.version;
//					settingsManager.saveSettings();
//				}
//				if(settingsModel.promptDatabaseImport)
//				{
//					var oldDir:File = ApplicationModel.baseStorageDir;
//					var doPrompt:Boolean = oldDir.exists;
//					if(doPrompt)
//						doPrompt = oldDir.resolvePath(ApplicationModel.DB_PATH).exists;
//					if(doPrompt)
//					{
//						dispatcher.dispatchEvent(new ApplicationEvent(ApplicationEvent.SHOW_IMPORT_DATABASE_PROMPT))					
//					}
//				}
//			}
//			catch(error:Error)
//			{
//				Logger.error("Couldn't load settings", this)
//			}
					
						
			//Load libraries
			loadLibraries();			
			
			//CHECK LICENSE			
//			if (registrationManager.isLicensed)
//			{					
//				var evt:PluginEvent = new PluginEvent(PluginEvent.COPY_DEFAULT_PLUGINS_TO_USER_DIR, true)
//				dispatcher.dispatchEvent(evt)							
				appModel.viewing = ApplicationModel.VIEW_STARTUP					
//			}
//			else
//			{
//				appModel.menuEnabled = false //will be turned on when user clicks continue
//													
//				var trialDays:uint = registrationManager.trialDaysRemaining														
//				if (trialDays<1)
//				{
//					registrationManager.viewing = RegistrationManager.VIEW_TRIAL_MODE_FINISHED	
//				}
//				else
//				{
//					registrationManager.viewing = RegistrationManager.VIEW_TRIAL_MODE								
//				}					
//				appModel.viewing=ApplicationModel.VIEW_REGISTRATION
//			}			
//			
//				
//			//free/full to trial upgrade message
//			var d:Date = appModel.firstInstallDate
//			if (d.fullYear<=2011 && d.month<=8)
//			{
//				registrationManager.showTrialVsFreeExplanation = true
//			}
			
				
		}
		
		
		/* ******** */
		/* UPDATER  */
		/* ******** */

		
		protected function doUpdateCheck():void
		{			
//			var updater:ApplicationUpdaterUI = new ApplicationUpdaterUI();
//			updater.configurationFile = File.applicationDirectory.resolvePath("config/updaterConfig.xml");
//			updater.addEventListener(UpdateEvent.INITIALIZED, updaterInitialized);	
//			updater.initialize(); 
//			appModel.updater = updater
		}
		
//		protected function updaterInitialized(event:UpdateEvent):void
//		{
//			appModel.updater.checkNow();
//		}
		
		
		
		
		
		
		
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
			if (diagramManager.diagramModel && undoRedoManager.isDirty)
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
		
	
				
		 
					 
		protected function initLibrary():void
        {
			Logger.debug("initLibrary()", this)
        	settingsModel.loadInitialData()
        }
         
         
		
//		[Mediate(event="com.simplediagrams.events.TestInvoke.INVOKE")]
//		public function testInvoke(event:TestInvoke):void
//		{
//			doInvoke(event.arguments)	
//		}
		
		
      	/* ****** */
		/* INVOKE */
		/* ****** */
				
		/* Handle INVOKE arguments */
//		[Mediate(event="flash.events.InvokeEvent.INVOKE")]
//		public function onInvoke(event:flash.events.InvokeEvent):void
//		{
//			doInvoke(event.arguments)
//		}
		
//		protected function doInvoke(arguments:Array):void
//		{
//			
//			Logger.debug("doInvoke() event.arguments " + arguments,this)
//			if (arguments.length==0)
//			{
//				return
//			}
//			
//			var filePath:String = arguments[0]
//							
//			try
//			{
//				var f:File = new File(filePath)	
//				if (f.extension.toLocaleLowerCase()=="sdxml") //simplediagrams file
//				{
//					appModel.fileToOpenOnStart = f		
//					Logger.debug("appModel.fileToOpenOnStart.path " + appModel.fileToOpenOnStart.nativePath,this)
//					var oEvent:OpenDiagramEvent = new OpenDiagramEvent(OpenDiagramEvent.OPEN_DIAGRAM, true)
//					oEvent.openFile = f
//					dispatcher.dispatchEvent(oEvent)
//				}
//				else if (f.extension.toLocaleLowerCase()=="sdlp") //simplediagrams library plugin
//				{
//					var libEvent:LibraryEvent = new LibraryEvent(LibraryEvent.IMPORT_LIBRARY, true)
//					libEvent.libraryFile = f
//					dispatcher.dispatchEvent(libEvent)
//				}
//				else
//				{					
//					Logger.warn("unrecognized extension : " + f.extension, this)
//				}
//				FlexGlobals.topLevelApplication.activate()
//			}
//			catch(error:Error)
//			{
//				Logger.error("onInvoke() Couldn't create file from path: " + filePath, this)
//				return
//			}
//			
//		}
		
//		[Mediate(event="flash.events.NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING")]
//		public function onDisplayStateChanging(event:NativeWindowDisplayStateEvent):void
//		{
//			switch (event.afterDisplayState) // <-- our new state
//			{
//				case "minimized":					
//					appModel.isMinimized = true;
//					break;
//				
//				case "maximized":
//					appModel.isMinimized = false;
//					break;
//			}
//		}
				
    [Inject]
		public var librariesRegistryDelegate:RemoteLibraryRegistryDelegate;
//		public var librariesRegistryDelegate:LibraryRegistryDelegate;
		
		[Inject]
		public var remoteLibraryDelegateManager:RemoteLibraryDelegateManager;
//		public var libraryDelegate:LibraryDelegate;
		
		[Inject]
		public var libraryManager:LibraryManager;
		
    public function loadLibraries():void
		{
			librariesRegistryDelegate.loadRegistry();
		}
		
		[Mediate(event="RemoteLibraryEvent.PROCESS_LIBRARY_REGISTRY")]
		public function processLibraryRegistry(remoteLibraryEvent:RemoteLibraryEvent):void
		{
			var registry:LibrariesRegistry = remoteLibraryEvent.librariesRegistry;
			
			var len:uint = registry.libraries.length;
			for (var index:int=0;index < len;index++)
			{
				var libInfo:LibraryInfo = registry.libraries.getItemAt(index) as LibraryInfo			
				remoteLibraryDelegateManager.readLibrary(libInfo);
			}
		}
				
		[Mediate(event="RemoteLibraryEvent.PROCESS_LIBRARY")]
    public function processLibrary(remoteLibraryEvent:RemoteLibraryEvent):void
		{
			var library:Library = remoteLibraryEvent.library;
			var libInfo:LibraryInfo = remoteLibraryEvent.libInfo;
			
			libraryManager.loadLibrary(libInfo, library);
		}
		
		[Mediate(event="ApplicationEvent.SHOW_MANAGE_LIBRARIES")]
		public function onShowManageLibraries(event:ApplicationEvent):void
		{
			appModel.showManageLibraries = true;
		}
		
		[Mediate(event="ApplicationEvent.HIDE_MANAGE_LIBRARIES")]
		public function onHideManageLibraries(event:ApplicationEvent):void
		{
			appModel.showManageLibraries = false;
		}
		
		[Mediate(event="ApplicationEvent.SHOW_CREATE_LIBRARY")]
		public function onShowCreateLibrary(event:ApplicationEvent):void
		{
			appModel.showCreateCustomLibrary = true;
		}
		
		[Mediate(event="ApplicationEvent.HIDE_CREATE_LIBRARY")]
		public function onHideCreateLibrary(event:ApplicationEvent):void
		{
			appModel.showCreateCustomLibrary = false;
		}
		
		[Mediate(event="ApplicationEvent.SHOW_IMPORT_DATABASE_PROMPT")]
		public function onShowImportDatabasePrompt(event:ApplicationEvent):void
		{
			settingsModel.promptDatabaseImport = false;
			appModel.showImportDatabasePrompt = true;
		}
		
		[Mediate(event="ApplicationEvent.HIDE_IMPORT_DATABASE_PROMPT")]
		public function onHideImportDatabasePrompt(event:ApplicationEvent):void
		{
			settingsModel.promptDatabaseImport = false;
			appModel.showImportDatabasePrompt = false;
		}
        
	}
  
}