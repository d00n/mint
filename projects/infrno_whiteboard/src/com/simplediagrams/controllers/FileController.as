package com.simplediagrams.controllers
{
	import com.simplediagrams.business.FileManager;
	import com.simplediagrams.events.*;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.RegistrationManager;
	import com.simplediagrams.model.libraries.MissingSymbolInfo;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.dialogs.MissingSymbolsDialog;
	import com.simplediagrams.view.dialogs.NewDiagramDialog;
	import com.simplediagrams.view.dialogs.SaveBeforeActionDialog;
	import com.simplediagrams.view.dialogs.UnavailableFontsDialog;
	import com.simplediagrams.vo.RecentFileVO;
	
	import flash.events.Event;
//	import flash.filesystem.File;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	
	import org.swizframework.controller.AbstractController;


	public class FileController extends AbstractController
	{
		[Bindable]
		[Inject]
		public var libraryManager:LibraryManager;
				
		[Bindable]
		[Inject]
		public var appModel:ApplicationModel;
			
		[Bindable]	
		[Inject]
		public var diagramModel:DiagramModel
		
		[Bindable]	
		[Inject]
		public var fileManager:FileManager
				
		[Bindable]	
		[Inject]
		public var dialogsController:DialogsController
		
		[Bindable]	
		[Inject]
		public var registrationManager:RegistrationManager
		
		private var _saveBeforeActionDialog:SaveBeforeActionDialog
		
		private var _newDiagramDialog:NewDiagramDialog
		
		private var _actionAfterSave:String //remembers what to do after a saveBeforeAction event is processed
		
		public function FileController()
		{
		}
		
		[Mediate(event="LoadDiagramEvent.LOAD_DIAGRAM")]
		public function loadDiagram(event:LoadDiagramEvent):void
		{
//			Logger.debug("loadDiagram() nativePath: " + event.nativePath, this)	
//			
//				
//			if (event.nativePath)
//			{
//				var f:File = new File()
//				f.nativePath = event.nativePath
//				if (f.exists)
//				{		
//					dialogsController.showLoadingFileDialog()	
//					fileManager.loadSimpleDiagramFromFile(event.nativePath)	
//				}
//				else
//				{					
//					Alert.show("This file no longer exists at " + event.nativePath)
//					//remove file from recent list
//					for (var i:uint=0;i<libraryManager.recentDiagramsAC.length; i++)
//					{
//						if (RecentFileVO(libraryManager.recentDiagramsAC.getItemAt(i)).data==event.nativePath)
//						{
//							libraryManager.recentDiagramsAC.removeItemAt(i)							
//						}
//					}
//					libraryManager.recentDiagramsAC.refresh()
//				}
//			}
//			else
//			{			
//				dialogsController.showLoadingFileDialog()	
//				fileManager.loadSimpleDiagramFromFile()	
//			}
//								
		}	
		
		[Mediate(event="LoadDiagramEvent.DIAGRAM_LOADED")]
		public function diagramLoaded(event:LoadDiagramEvent):void
		{
			libraryManager.addRecentFilePath(event.nativePath, event.fileName)	
			//the loading dialog will be removed by the diagramController after the diagram is completely built	
			//we'll show any unavailable fonts at that point
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
		}					

		
		[Mediate(event="SaveDiagramEvent.SAVE_DIAGRAM_AS")]
		public function saveDiagramAs(event:SaveDiagramEvent):void
		{
			Logger.debug("saveDiagramAs()",this)
			//make sure user is licensed
			if (registrationManager.isLicensed==false && appModel.firstInstallDate!=null)
			{
				Alert.show("Only Full Version users have the ability to save files. Visit www.simpledigrams.com and upgrade to Full Version today!", "Full Version Only")
				return
			}			
			fileManager.saveSimpleDiagramAs()		
		}
		
		
		[Mediate(event="SaveDiagramEvent.SAVE_DIAGRAM")]
		public function saveDiagram(event:SaveDiagramEvent):void
		{			
			//make sure user is licensed
			if (registrationManager.isLicensed==false && appModel.firstInstallDate!=null)
			{
				Alert.show("Only Full Version users have the ability to save files. Visit www.simpledigrams.com and upgrade to Full Version today!", "Full Version Only")
				return
			}			
			fileManager.saveSimpleDiagram()
		}
		
		[Mediate(event="SaveDiagramEvent.DIAGRAM_SAVED")]
		public function diagramSaved(event:SaveDiagramEvent):void
		{	
			libraryManager.addRecentFilePath(event.nativePath, event.fileName)
			if (_actionAfterSave) performActionAfterSave()
		}
						
		protected function onSaveNewDiagram(event:Event):void
		{
			fileManager.saveSimpleDiagramAs()
			//TODO : Add to recently loaded list 			libraryManager.loadDiagrams()
			
			dialogsController.removeDialog(_newDiagramDialog)	
			removeSaveNewDiagramListeners()
				
		}
		
		protected function onCancelSaveNewDiagram(event:Event):void
		{
			dialogsController.removeDialog(_newDiagramDialog)			
			removeSaveNewDiagramListeners()	
		}
		
		protected function removeSaveNewDiagramListeners():void
		{
			_newDiagramDialog.removeEventListener(NewDiagramDialog.SAVE, onSaveNewDiagram)
			_newDiagramDialog.removeEventListener(Event.CANCEL, onCancelSaveNewDiagram)	
		}
		
						
			
//		[Mediate(event="OpenDiagramEvent.OPEN_DIAGRAM_EVENT")]
		public function openDiagram(event:OpenDiagramEvent):void
		{							
			if (diagramModel.isDirty)
			{
				checkSaveBeforeOpen()
			}
			else
			{
				fileManager.loadSimpleDiagramFromFile()
			}			
		}
				
		
		
		[Mediate(event="CloseDiagramEvent.CLOSE_DIAGRAM")]
		public function onCloseDiagram(event:CloseDiagramEvent):void
		{			
			
			if (diagramModel.isDirty)
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
			diagramModel.initDiagramModel()
			fileManager.clear()
			appModel.diagramLoaded = false
			dispatcher.dispatchEvent(new CloseDiagramEvent(CloseDiagramEvent.DIAGRAM_CLOSED, true))
		}
		
		
		[Mediate(event="CreateNewDiagramEvent.CREATE_NEW_DIAGRAM")]
		public function createNewDiagram(event:CreateNewDiagramEvent):void
		{				
			if(diagramModel.isDirty)
			{
				checkSaveBeforeNew()
			}
			else
			{
				startNew()
				fileManager.clear()
			}			
			
		}
		
		private function startNew():void
		{
			appModel.viewing = ApplicationModel.VIEW_DIAGRAM
			diagramModel.createNew()		//this will launch an "new diagram created" event
			appModel.diagramLoaded = true
		}
			
		
		public function checkSaveBeforeOpen():void
		{
//			if (_saveBeforeActionDialog)
//			{				
//				dialogsController.removeDialog(_saveBeforeActionDialog)
//			}
//			
//			_saveBeforeActionDialog = dialogsController.showSaveBeforeActionDialog()
//			_saveBeforeActionDialog.mode = SaveBeforeActionDialog.MODE_SAVE_BEFORE_OPEN
//			_saveBeforeActionDialog.addEventListener(SaveBeforeActionDialog.SAVE, onSaveBeforeAction)
//			_saveBeforeActionDialog.addEventListener(Event.CANCEL, onCancelSaveBeforeAction)
//			_saveBeforeActionDialog.addEventListener(SaveBeforeActionDialog.DONT_SAVE, onDontSaveBeforeAction)		
									
		}
		
		public function checkSaveBeforeClose():void
		{
//			if (_saveBeforeActionDialog)
//			{				
//				dialogsController.removeDialog(_saveBeforeActionDialog)
//			}
//			
//			_saveBeforeActionDialog = dialogsController.showSaveBeforeActionDialog()
//			_saveBeforeActionDialog.mode = SaveBeforeActionDialog.MODE_SAVE_BEFORE_CLOSE
//			_saveBeforeActionDialog.addEventListener(SaveBeforeActionDialog.SAVE, onSaveBeforeAction)
//			_saveBeforeActionDialog.addEventListener(Event.CANCEL, onCancelSaveBeforeAction)
//			_saveBeforeActionDialog.addEventListener(SaveBeforeActionDialog.DONT_SAVE, onDontSaveBeforeAction)		
									
		}
		
		public function checkSaveBeforeNew():void
		{
//			if (_saveBeforeActionDialog)
//			{				
//				dialogsController.removeDialog(_saveBeforeActionDialog)
//			}
//			
//			_saveBeforeActionDialog = dialogsController.showSaveBeforeActionDialog()
//			_saveBeforeActionDialog.mode = SaveBeforeActionDialog.MODE_SAVE_BEFORE_NEW
//			_saveBeforeActionDialog.addEventListener(SaveBeforeActionDialog.SAVE, onSaveBeforeAction)
//			_saveBeforeActionDialog.addEventListener(Event.CANCEL, onCancelSaveBeforeAction)
//			_saveBeforeActionDialog.addEventListener(SaveBeforeActionDialog.DONT_SAVE, onDontSaveBeforeAction)
						
		}
		
		public function onSaveBeforeAction(event:Event):void
		{										
			_actionAfterSave = _saveBeforeActionDialog.mode
			try
			{				
				saveDiagram(null)
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
//			switch (_actionAfterSave)		
//			{
//				case SaveBeforeActionDialog.MODE_SAVE_BEFORE_NEW:
//					startNew()
//					break
//					
//				case SaveBeforeActionDialog.MODE_SAVE_BEFORE_CLOSE:					
//					closeDiagram()
//					break
//					
//				case SaveBeforeActionDialog.MODE_SAVE_BEFORE_OPEN:
//					fileManager.loadSimpleDiagramFromFile()
//					break
//					
//				default:				
//			}
//			_actionAfterSave = null
//			fileManager.clear()
//			dialogsController.removeDialog(_saveBeforeActionDialog)			
//			removeSaveBeforeActionEventListeners()
		}
		
		
		public function onCancelSaveBeforeAction(event:Event):void
		{			
			dialogsController.removeDialog(_saveBeforeActionDialog)
			removeSaveBeforeActionEventListeners()
			//and then let user continue working...
		}	
		
		public function onDontSaveBeforeAction(event:Event):void
		{
//			switch (_saveBeforeActionDialog.mode)		
//			{
//				case SaveBeforeActionDialog.MODE_SAVE_BEFORE_NEW:
//					startNew()
//					break
//					
//				case SaveBeforeActionDialog.MODE_SAVE_BEFORE_CLOSE:
//					closeDiagram()
//					break
//					
//				case SaveBeforeActionDialog.MODE_SAVE_BEFORE_OPEN:
//					fileManager.loadSimpleDiagramFromFile()
//					break
//					
//				default:				
//			}
//			
//			dialogsController.removeDialog(_saveBeforeActionDialog)			
//			removeSaveBeforeActionEventListeners()
		}
		
		private function removeSaveBeforeActionEventListeners():void
		{		
//			_saveBeforeActionDialog.removeEventListener(SaveBeforeActionDialog.SAVE, onSaveBeforeAction)
//			_saveBeforeActionDialog.removeEventListener(Event.CANCEL, onCancelSaveBeforeAction)
//			_saveBeforeActionDialog.removeEventListener(SaveBeforeActionDialog.DONT_SAVE, onDontSaveBeforeAction)		
//			_saveBeforeActionDialog = null
		}
		
		
	}
}