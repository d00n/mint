package com.simplediagrams.controllers
{
	import com.simplediagrams.business.FileManager;
	import com.simplediagrams.events.*;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.DiagramManager;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.RegistrationManager;
	import com.simplediagrams.model.SettingsModel;
	import com.simplediagrams.model.UndoRedoManager;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.dialogs.MissingSymbolsDialog;
	import com.simplediagrams.view.dialogs.NewDiagramDialog;
	import com.simplediagrams.view.dialogs.SaveBeforeActionDialog;
	import com.simplediagrams.view.dialogs.UnavailableFontsDialog;
	import com.simplediagrams.vo.RecentFileVO;
	
	import flash.events.Event;
	import flash.filesystem.File;
	
	import mx.containers.TitleWindow;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	
	import org.swizframework.controller.AbstractController;


	public class FileController extends AbstractController
	{
		
		
		[Inject]
		public var libraryManager:LibraryManager;
				
		[Inject]
		public var appModel:ApplicationModel;
			
		[Inject]
		public var diagramManager:DiagramManager
		
		[Inject]
		public var fileManager:FileManager
				
		[Inject]
		public var dialogsController:DialogsController
				
		[Inject]
		public var settingsModel:SettingsModel
		
		[Inject]
		public var registrationManager:RegistrationManager
		
		
		public function FileController()
		{
		}
		
		
		
		
		[Mediate(event="LoadDiagramEvent.LOAD_DIAGRAM_FROM_FILE")]
		public function loadDiagram(event:LoadDiagramEvent):void
		{
										
			if(event.nativePath=="")
			{			
				Logger.error("loadDiagram() event didn't have nativePath defined",this)
				return
			}
			
			var f:File = new File()
			f.nativePath = event.nativePath
			if (f.exists)
			{		
				//dialogsController.showLoadingFileDialog()	
				fileManager.loadDiagramFromFile(event.nativePath)	
			}
			else
			{					
				Alert.show("A file no longer exists at " + event.nativePath)
				//remove file from recent list
				for (var i:uint=0;i<settingsModel.recentDiagramsAC.length; i++)
				{
					if (RecentFileVO(settingsModel.recentDiagramsAC.getItemAt(i)).data==event.nativePath)
					{
						settingsModel.recentDiagramsAC.removeItemAt(i)							
					}
				}
				settingsModel.recentDiagramsAC.refresh()
			}			
											
		}	
		
		[Mediate(event="LoadDiagramEvent.DIAGRAM_PARSED")]
		public function onDiagramParsed(event:LoadDiagramEvent):void
		{
			
			appModel.diagramLoaded = true
			appModel.viewing = ApplicationModel.VIEW_DIAGRAM	
			
			//Check to make sure all symbols loaded. If not, show warning
			
			if (fileManager.missingSymbolsArr && fileManager.missingSymbolsArr.length>0)
			{				
				var dialog:MissingSymbolsDialog = dialogsController.showMissingSymbolsDialog()
				dialog.addEventListener(Event.CANCEL, onCancelLoadDiagram)
				dialog.addEventListener("OK", onFinishLoadDiagramAfterResolvingMissingSymbols)
				dialog.missingSymbolsArr = fileManager.missingSymbolsArr
				dialog.nativePath = event.nativePath
				dialog.fileName = event.fileName
				return
			}
			
				
			var evt:LoadDiagramEvent = new LoadDiagramEvent(LoadDiagramEvent.DIAGRAM_LOADED_FROM_FILE, true)
			evt.nativePath = event.nativePath
			evt.fileName = event.fileName
			evt.success = true
			dispatcher.dispatchEvent(evt)
				
			settingsModel.addRecentFilePath(event.nativePath, event.fileName)	
				
			var readyEvt:LoadDiagramEvent = new LoadDiagramEvent(LoadDiagramEvent.DIAGRAM_READY, true)			
			dispatcher.dispatchEvent(readyEvt)
			
			
		}	
		
		protected function onCancelLoadDiagram(event:Event):void
		{			
			removeMissingSymbolDialog(event.target as TitleWindow)
			closeDiagram()
		}
		
		protected function onFinishLoadDiagramAfterResolvingMissingSymbols(event:Event):void
		{			
			removeMissingSymbolDialog(event.target as TitleWindow)
				
			var evt:LoadDiagramEvent = new LoadDiagramEvent(LoadDiagramEvent.DIAGRAM_LOADED_FROM_FILE, true)	
			dispatcher.dispatchEvent(evt)
							
			var readyEvt:LoadDiagramEvent = new LoadDiagramEvent(LoadDiagramEvent.DIAGRAM_READY, true)			
			dispatcher.dispatchEvent(readyEvt)
				
		}
		
		protected function removeMissingSymbolDialog(dialog:TitleWindow):void
		{
			dialog.removeEventListener(Event.CANCEL, onCancelLoadDiagram)
			dialog.removeEventListener("OK", onFinishLoadDiagramAfterResolvingMissingSymbols)
			dialogsController.removeDialog()			
		}
		
				
		[Mediate(event="PluginEvent.COPY_DEFAULT_PLUGINS_TO_USER_DIR")]
		public function copyPlugsToUserDir():void
		{
			//copy default libraries to lib folder if it doesn't exist (will happen on first install of 1.3 and above)
			try
			{
				var libFiles:File = File.applicationDirectory.resolvePath("lib")
				var dest:File = ApplicationModel.baseStorageDir.resolvePath(ApplicationModel.LIBRARY_PLUGIN_PATH)
				if (dest.exists==false)
				{
					dest.createDirectory()
					libFiles.copyTo(dest, true)					
				}					
			}				
			catch(error:Error)
			{
				Logger.error("copyPlugsToUserDir() Couldn't copy lib file. Error: " + error, this)
			}
		}
		
				
		
		
		
		[Mediate(event="LoadDiagramEvent.DIAGRAM_LOAD_CANCELED")]
		public function diagramLoadCancelled(event:LoadDiagramEvent):void
		{
			dialogsController.removeDialog()
		}	
		
		[Mediate(event="LoadDiagramEvent.DIAGRAM_LOAD_ERROR")]
		public function diagramLoadError(event:LoadDiagramEvent):void
		{
			Logger.debug("diagramLoadError()",this)
			Alert.show(event.errorMessage, "Load Error")
			dialogsController.removeDialog()			
			fileManager.clearFilePaths()
		}					

		
		[Mediate(event="SaveDiagramEvent.SAVE_DIAGRAM_AS")]
		public function saveDiagramAs(event:SaveDiagramEvent):void
		{		
			fileManager.saveDiagramAs()		
		}
		
		
		[Mediate(event="SaveDiagramEvent.SAVE_DIAGRAM")]
		public function saveDiagram(event:SaveDiagramEvent):void
		{		
			fileManager.saveDiagram()
		}
		
		[Mediate(event="SaveDiagramEvent.DIAGRAM_SAVED")]
		public function diagramSaved(event:SaveDiagramEvent):void
		{	
			settingsModel.addRecentFilePath(event.nativePath, event.fileName)
			if (fileManager.actionAfterSave) performActionAfterSave()
		}
						
		protected function onSaveNewDiagramResponse(event:Event):void
		{
			fileManager.saveDiagramAs()
							
			//TODO : Add to recently loaded list 			
			
			dialogsController.removeDialog(fileManager.newDiagramDialog)	
			removeSaveNewDiagramListeners()
				
		}
		
		protected function onCancelSaveNewDiagram(event:Event):void
		{
			dialogsController.removeDialog(fileManager.newDiagramDialog)			
			removeSaveNewDiagramListeners()	
		}
		
		protected function removeSaveNewDiagramListeners():void
		{
			fileManager.newDiagramDialog.removeEventListener(NewDiagramDialog.SAVE, onSaveNewDiagramResponse)
			fileManager.newDiagramDialog.removeEventListener(Event.CANCEL, onCancelSaveNewDiagram)	
		}
		
						
		[Inject]
		public var undoRedoManager:UndoRedoManager;
		
		[Mediate(event="OpenDiagramEvent.OPEN_DIAGRAM")]
		public function openDiagram(event:OpenDiagramEvent):void
		{							
			fileManager.filePathToOpen = null
								
			if (undoRedoManager.isDirty)
			{
				checkSaveBeforeOpen()
			}
			else
			{
				if (event.openFile)
				{
					fileManager.loadDiagramFromFile(event.openFile.nativePath)
				}
				else
				{
					fileManager.browseToLoadDiagram()	
				}
				
			}			
		}
				
		
		
		[Mediate(event="CloseDiagramEvent.CLOSE_DIAGRAM")]
		public function onCloseDiagram(event:CloseDiagramEvent):void
		{			
			
			if (undoRedoManager.isDirty)
			{
				checkSaveBeforeClose()
			}
			else
			{
				closeDiagram()
			}
		}
		
		protected function closeDiagram():void
		{
			appModel.viewing = ApplicationModel.VIEW_STARTUP
			diagramManager.clearDiagram();
			undoRedoManager.clear();
			fileManager.clearFilePaths()
			appModel.diagramLoaded = false
			dispatcher.dispatchEvent(new CloseDiagramEvent(CloseDiagramEvent.DIAGRAM_CLOSED, true))
		}
		
		
		[Mediate(event="CreateNewDiagramEvent.CREATE_NEW_DIAGRAM")]
		public function createNewDiagram(event:CreateNewDiagramEvent):void
		{				
			
			if(diagramManager && diagramManager.diagramModel && undoRedoManager.isDirty)
			{
				checkSaveBeforeNew()
			}
			else
			{
				startNewDiagram()
			}			
			
		}
		
		private function startNewDiagram():void
		{
			//setup default background		
			var diagramModel:DiagramModel = new DiagramModel();
			diagramModel.background = libraryManager.getDefaultBackgroundModel()
			diagramModel.width = settingsModel.defaultDiagramWidth
			diagramModel.height = settingsModel.defaultDiagramHeight
			
			appModel.viewing = ApplicationModel.VIEW_DIAGRAM			
			
			diagramManager.newDiagram(diagramModel);
			libraryManager.clearLocalLibrary();
			appModel.diagramLoaded = true;
			fileManager.clearFilePaths()
		}
			
		
		public function checkSaveBeforeOpen():void
		{
			if (fileManager.saveBeforeActionDialog)
			{				
				dialogsController.removeDialog(fileManager.saveBeforeActionDialog)
			}
			
			fileManager.actionAfterSave = FileManager.MODE_SAVE_BEFORE_OPEN
			fileManager.saveBeforeActionDialog = dialogsController.showSaveBeforeActionDialog()
			fileManager.saveBeforeActionDialog.mode = FileManager.MODE_SAVE_BEFORE_OPEN
			fileManager.saveBeforeActionDialog.addEventListener(SaveBeforeActionDialog.SAVE, onSaveBeforeAction)
			fileManager.saveBeforeActionDialog.addEventListener(Event.CANCEL, onCancelSaveBeforeAction)
			fileManager.saveBeforeActionDialog.addEventListener(SaveBeforeActionDialog.DONT_SAVE, onDontSaveBeforeAction)		
									
		}
		
		public function checkSaveBeforeClose():void
		{
			if (fileManager.saveBeforeActionDialog)
			{				
				dialogsController.removeDialog(fileManager.saveBeforeActionDialog)
			}
			
			fileManager.actionAfterSave = FileManager.MODE_SAVE_BEFORE_CLOSE
			fileManager.saveBeforeActionDialog = dialogsController.showSaveBeforeActionDialog()
			fileManager.saveBeforeActionDialog.mode = FileManager.MODE_SAVE_BEFORE_CLOSE
			fileManager.saveBeforeActionDialog.addEventListener(SaveBeforeActionDialog.SAVE, onSaveBeforeAction)
			fileManager.saveBeforeActionDialog.addEventListener(Event.CANCEL, onCancelSaveBeforeAction)
			fileManager.saveBeforeActionDialog.addEventListener(SaveBeforeActionDialog.DONT_SAVE, onDontSaveBeforeAction)		
									
		}
		
		public function checkSaveBeforeNew():void
		{
			if (fileManager.saveBeforeActionDialog)
			{				
				dialogsController.removeDialog(fileManager.saveBeforeActionDialog)
			}
			
			fileManager.actionAfterSave = FileManager.MODE_SAVE_BEFORE_NEW
			fileManager.saveBeforeActionDialog = dialogsController.showSaveBeforeActionDialog()
			fileManager.saveBeforeActionDialog.mode = FileManager.MODE_SAVE_BEFORE_NEW
			fileManager.saveBeforeActionDialog.addEventListener(SaveBeforeActionDialog.SAVE, onSaveBeforeAction)
			fileManager.saveBeforeActionDialog.addEventListener(Event.CANCEL, onCancelSaveBeforeAction)
			fileManager.saveBeforeActionDialog.addEventListener(SaveBeforeActionDialog.DONT_SAVE, onDontSaveBeforeAction)
						
		}
		
		public function onSaveBeforeAction(event:Event):void
		{										
			try
			{				
				fileManager.saveDiagram()
			}
			catch (err:Error)
			{
				Alert.show("Couldn't save current diagram. Error:" + err,"Save Error")
				Logger.error("onSaveBeforeAction() couldn't save the diagram. Error: " + err, this)
				return
			}			
		
		}
		
		public function performActionAfterSave():void
		{
			dialogsController.removeDialog(fileManager.saveBeforeActionDialog)
			removeSaveBeforeActionEventListeners()	
			switch (fileManager.actionAfterSave)		
			{
				case FileManager.MODE_SAVE_BEFORE_NEW:
					startNewDiagram()
					break
					
				case FileManager.MODE_SAVE_BEFORE_CLOSE:					
					closeDiagram()
					break
					
				case FileManager.MODE_SAVE_BEFORE_OPEN:
					fileManager.browseToLoadDiagram()
					break
					
				default:				
			}
			fileManager.actionAfterSave = ""		
		}
		
		
		public function onCancelSaveBeforeAction(event:Event):void
		{			
			fileManager.actionAfterSave = ""
			dialogsController.removeDialog(fileManager.saveBeforeActionDialog)
			removeSaveBeforeActionEventListeners()
			//and then let user continue working...
		}	
		
		public function onDontSaveBeforeAction(event:Event):void
		{
			switch (fileManager.actionAfterSave)		
			{
				case FileManager.MODE_SAVE_BEFORE_NEW:
					startNewDiagram()
					break
					
				case FileManager.MODE_SAVE_BEFORE_CLOSE:
					closeDiagram()
					break
					
				case FileManager.MODE_SAVE_BEFORE_OPEN:
					fileManager.browseToLoadDiagram()
					break
					
				default:				
			}
			
			dialogsController.removeDialog(fileManager.saveBeforeActionDialog)	
			fileManager.actionAfterSave = ""
			removeSaveBeforeActionEventListeners()
		}
		
		private function removeSaveBeforeActionEventListeners():void
		{		
			if (fileManager.saveBeforeActionDialog)
			{
				fileManager.saveBeforeActionDialog.removeEventListener(SaveBeforeActionDialog.SAVE, onSaveBeforeAction)
				fileManager.saveBeforeActionDialog.removeEventListener(Event.CANCEL, onCancelSaveBeforeAction)
				fileManager.saveBeforeActionDialog.removeEventListener(SaveBeforeActionDialog.DONT_SAVE, onDontSaveBeforeAction)		
				fileManager.saveBeforeActionDialog = null
			}
		}
		
		
		[Mediate(event="ExportDiagramEvent.SAVE_IMAGE_TO_FILE")]
		public function exportDiagramImageToFile(event:ExportDiagramEvent):void
		{	
			fileManager.saveDiagramImageToFile(event.imageByteArray)			
		}
		
		
	}
}