package com.simplediagrams.controllers
{
	import com.simplediagrams.business.DBManager;
	import com.simplediagrams.business.LibraryPluginsDelegate;
	import com.simplediagrams.errors.SDObjectModelNotFoundError;
	import com.simplediagrams.events.*;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.RegistrationManager;
	import com.simplediagrams.model.SDCustomSymbolModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.model.dao.CustomLibraryDAO;
	import com.simplediagrams.model.dao.CustomSymbolDAO;
	import com.simplediagrams.model.libraries.CustomLibrary;
	import com.simplediagrams.model.libraries.ILibrary;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.dialogs.CreateCustomLibraryDialog;
	import com.simplediagrams.view.dialogs.DeleteCustomSymbolDialog;
	import com.simplediagrams.view.dialogs.LoadingLibraryPluginProgressDialog;
	import com.simplediagrams.view.dialogs.ManageLibrariesDialog;
	import com.simplediagrams.view.dialogs.RenameCustomLibraryItemDialog;
	
	import flash.display.Sprite;
	import flash.events.Event;
//	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.utils.UIDUtil;
	
	import org.swizframework.controller.AbstractController;
	
	public class LibraryController extends AbstractController
	{
		[Bindable]
		[Inject]
		public var libraryManager:LibraryManager;
		
		[Bindable]
		[Inject]
		public var appModel:ApplicationModel;
		
		
		[Bindable]
		[Inject]
		public var registrationManager:RegistrationManager;
		
		[Bindable]	
		[Inject]
		public var diagramModel:DiagramModel
		
		
		[Bindable]	
		[Inject]
		public var dbManager:DBManager
				
		[Bindable]	
		[Inject]
		public var dialogsController:DialogsController
				
		protected var _manageLibrariesDialog:ManageLibrariesDialog
		protected var _loadingLibraryProgressDialog:LoadingLibraryPluginProgressDialog
//		protected var _selectedLibraryPluginToLoad:File
//		protected var _imageForCustomSymbolFile:File
		protected var _currLibraryID:uint = 0
			
		public function LibraryController()
		{
		}
		
		[Mediate(event="LibraryEvent.MANAGE_LIBRARIES")]
		public function onManageLibraries(event:LibraryEvent):void
		{
			_manageLibrariesDialog = dialogsController.showManageLibrariesDialog()
			_manageLibrariesDialog.addEventListener("OK", onManageLibrariesComplete)
			_manageLibrariesDialog.addEventListener(Event.CANCEL, onManageLibariesCancel)
		}
		
		
		protected function onManageLibrariesComplete(event:Event):void
		{
			for each(var library:ILibrary in libraryManager.librariesAC)
			{
				Logger.debug("library: " + library.displayName + " showInPanel: " + library.showInPanel, this)
				//Save DAO's in case showInPanel changed
				if (library is CustomLibrary)
				{
					CustomLibrary(library).save(dbManager)
				}
			}
			
			libraryManager.panelNeedsUpdating = true
			dispatcher.dispatchEvent(new LibraryEvent(LibraryEvent.LIBRARIES_UPDATED, true))	
			clearDialog()
		}
		
		protected function onManageLibariesCancel(event:Event):void
		{
			clearDialog()
		}
		
		protected function clearDialog():void
		{
			dialogsController.removeDialog(_manageLibrariesDialog)
			_manageLibrariesDialog.removeEventListener("OK", onManageLibrariesComplete)
			_manageLibrariesDialog.removeEventListener(Event.CANCEL, onManageLibariesCancel)
			_manageLibrariesDialog = null
		}
		
		
		[Mediate(event="DeleteLibraryEvent.DELETE_LIBRARY")]
		public function onDeleteLibrary(event:DeleteLibraryEvent):void
		{
			var library:ILibrary = event.library
			try
			{
				deleteLibrary(library)
			}
			catch(err:Error)
			{
				Logger.error("Error deleting library : " + library.libraryName + " error: " + err, this)
				Alert.show("Couldn't delete library. Please see log for details.", "Error")
			}
		}
		
		protected function deleteLibrary(library:ILibrary):void
		{
			if (library.isPlugin==false && library.isCustom==false)
			{
				Logger.warn("selected library to delete wasn't a plugin or a custom library",this)
				return
			}
			
			if (library.isCustom)
			{
				CustomLibrary(library).deleteLibraryFromDB(dbManager)
			}		
			
			libraryManager.removeLibrary(library.libraryName)	
			libraryManager.panelNeedsUpdating = true
			dispatcher.dispatchEvent(new LibraryEvent(LibraryEvent.LIBRARIES_UPDATED, true))
				
			//get rid of folder if library is a plugin
			if (library.isPlugin)
			{
				var delegate:LibraryPluginsDelegate = new LibraryPluginsDelegate()
				try
				{
					Logger.debug("deleting library folder: " + library.fileName, this)
					delegate.deleteLibraryFolder(library.fileName)	
				}
				catch(err:Error)
				{					
					Alert.show(err.message, "Error")
				}
			}
			
			try
			{
				library.deleteLibrary()
			}
			catch(error:Error)
			{
				Logger.error("Couldn't delete library " + library.displayName + " error: " + error)
				Alert.show("Couldn't delete library. Please see log for details", "Database Error")
				return
			}
			
		}
		
		
		[Mediate(event="LoadLibraryPluginEvent.LOAD_LIBRARY_PLUGIN_FROM_FILE")]
		public function onLoadLibraryPlugin(event:LoadLibraryPluginEvent):void
		{
//			//make sure user is licensed
//			if (registrationManager.isLicensed==false)
//			{
//				Alert.show("Sorry. This feature is only available to Full Version users. Visit simpledigrams.com and upgrade to Full Version today!", "Full Version Only")
//				return
//			}
//			
//			var libraryFile:File = new File()
//			var fileFilter:FileFilter = new FileFilter("SimpleDiagrams library plugin file","*.zip")
//			var filtersArr:Array = [fileFilter]
//			libraryFile.addEventListener(Event.SELECT, loadSelectedLibraryPluginFile)
//			libraryFile.browseForOpen("Select the SimpleDiagrams library plugin file (.zip) to load", filtersArr)			
		}
		
		protected function loadSelectedLibraryPluginFile(event:Event):void
		{
//			_selectedLibraryPluginToLoad = File(event.currentTarget)
//			Logger.debug("Load library plugin file: " + _selectedLibraryPluginToLoad.nativePath,this)
//			
//			//check to see whether this library is already loaded...if so get confirmation from user
//			var fileName:String = _selectedLibraryPluginToLoad.name
//			if (fileName.indexOf(".zip")!=-1)
//			{
//				fileName = fileName.slice(0,fileName.indexOf(".zip"))
//			}
//			
//			Logger.debug("looking to see if " + fileName + " is already loaded.", this)
//			if (libraryManager.libraryFileExists(fileName))
//			{
//				Alert.show("You already have this plugin installed. Do you want to overwrite it?", "Plugin already installed", Alert.OK | Alert.CANCEL, FlexGlobals.topLevelApplication as Sprite, onLoadLibraryPluginConfirm)
//			}
//			else
//			{				
//				loadLibraryPlugin()
//			}
		}
		
		protected function onLoadLibraryPluginConfirm(event:CloseEvent):void
		{
//			if (event.detail == Alert.CANCEL)
//			{
//				_selectedLibraryPluginToLoad = null
//				return
//			}
//			
//			//delete the existing library
//			
//			var libraryFileName:String = _selectedLibraryPluginToLoad.name
//			if (libraryFileName.indexOf(".zip")!=-1)
//			{
//				libraryFileName = libraryFileName.slice(0, libraryFileName.indexOf(".zip"))
//			}
//			
//			var existingLibrary:ILibrary = libraryManager.getLibraryByFileName(libraryFileName)
//			try
//			{	
//				deleteLibrary(existingLibrary)
//			}
//			catch(err:Error)
//			{
//				Logger.error("Error deleting library : " + existingLibrary.libraryName + " error: " + err, this)
//				Alert.show("Couldn't overwrite the existing library plugin. Please delete it manually first before loading the new library plugin.", "Error")
//				return
//			}
//						
//			loadLibraryPlugin()
		}
		
		protected function loadLibraryPlugin():void
		{			
			
			
//			if (_loadingLibraryProgressDialog)
//			{
//				dialogsController.removeDialog(_loadingLibraryProgressDialog)
//			}
//			_loadingLibraryProgressDialog = dialogsController.showLoadingLibraryPluginProgressDialog()
//								
//			var delegate:LibraryPluginsDelegate = new LibraryPluginsDelegate()
//			delegate.addEventListener(LibraryPluginsDelegate.LOADING_FINISHED, onLoadSelectedLibraryPluginComplete)
//			delegate.addEventListener(LibraryPluginsDelegate.LOADING_FAILED, onLoadSelectedLibraryPluginFailed)
//			try
//			{
//				delegate.loadOneLibrary(_selectedLibraryPluginToLoad, libraryManager)
//			}
//			catch(error:Error)
//			{
//				Alert.show("There was a problem loading the selected library plugin. Please make sure that this plugin file was downloaded correctly from SimpleDiagrams.","Library Load Error")
//				delegate.deleteLibraryFolder(_selectedLibraryPluginToLoad.name)
//				libraryManager.removeLibrary(_selectedLibraryPluginToLoad.name)
//				removeLoadSelectedLibraryListeners(delegate)
//			}
		}

		
		protected function onLoadSelectedLibraryPluginComplete(event:Event):void
		{
			
//			_selectedLibraryPluginToLoad = null
//			if (_loadingLibraryProgressDialog)
//			{
//				dialogsController.removeDialog(_loadingLibraryProgressDialog)
//			}
//			_loadingLibraryProgressDialog = null
//			Alert.show("SimpleDiagrams library plugin loaded. The library should now appear in your libraries panel.","Load complete")
//			var loader:LibraryPluginsDelegate = event.target as LibraryPluginsDelegate
//			libraryManager.updatePanel()
//			removeLoadSelectedLibraryListeners(loader)
		}
		
//		protected function onLoadSelectedLibraryPluginFailed(event:LoadLibraryEvent):void
//		{
//			if (_loadingLibraryProgressDialog)
//			{
//				dialogsController.removeDialog(_loadingLibraryProgressDialog)
//			}
//			_loadingLibraryProgressDialog = null
//				
//			if (event.isInvalid)	
//			{
//				Alert.show("The " + _selectedLibraryPluginToLoad.name + " library plugin is an outdated version. Please download the most recent version from SimpleDiagrams and reload this library.","Library Error")
//			}
//			else
//			{
//				Alert.show("SimpleDiagrams could not load the selected library plugin. Please make sure the file is a valid SimpleDiagrams library plugin file", "Load Error")
//			}
//			_selectedLibraryPluginToLoad = null
//			if (_loadingLibraryProgressDialog)
//			{
//				dialogsController.removeDialog(_loadingLibraryProgressDialog)
//			}
//			_loadingLibraryProgressDialog = null
//			
//		}
		
		protected function removeLoadSelectedLibraryListeners(loader:LibraryPluginsDelegate):void
		{			
//			loader.removeEventListener(LoadLibraryEvent.LOADING_FINISHED, onLoadSelectedLibraryPluginComplete)
//			loader.removeEventListener(LoadLibraryEvent.LOADING_FAILED, onLoadSelectedLibraryPluginFailed)
		}
		
		
		
		[Mediate(event="ClearRecentListEvent.CLEAR_RECENT_LIST")]
		public function onClearRecentList(event:ClearRecentListEvent):void
		{
			libraryManager.clearRecentDiagrams()
		}
		
		
		
		/* ****************** */
		/*  CUSTOM LIBRARIES  */
		/* ****************** */
		
		[Mediate(event="DatabaseEvent.DATABASE_READY")]
		public function loadCustomLibrariesFromDB(event:DatabaseEvent):void
		{
			var customLibraryDAOsAC:ArrayCollection = dbManager.findAll(CustomLibraryDAO)
			for each (var dao:CustomLibraryDAO in customLibraryDAOsAC)
			{
				var lib:CustomLibrary = new CustomLibrary()
				lib.customLibraryDAO = dao
				libraryManager.addLibrary(lib)
				libraryManager.panelNeedsUpdating = true
				dispatcher.dispatchEvent(new LibraryEvent(LibraryEvent.LIBRARIES_UPDATED, true))		
				
				//load symbols in library
				var customSymbolDAOsAC:ArrayCollection = dbManager.findByForeignKey(CustomSymbolDAO, "library_id", lib.id)
				for each (var customSymbolDAO:CustomSymbolDAO in customSymbolDAOsAC)
				{
					var customSymbol:SDCustomSymbolModel = new SDCustomSymbolModel()
					customSymbol.load(dbManager, customSymbolDAO.id)
					customSymbol.libraryName = lib.libraryName
					lib.addLibraryItem(customSymbol)
				}				
			}
		}
		
		
		
		[Mediate(event="CreateCustomLibraryEvent.SHOW_CREATE_CUSTOM_LIBRARY_DIALOG")]
		public function onShowCreateCustomLibraryDialog(event:CreateCustomLibraryEvent):void
		{			
			Logger.debug("onShowCreateCustomLibraryDialog()",this)
			
			var dialog:CreateCustomLibraryDialog = dialogsController.showCreateCustomLibraryDialog()
			dialog.addEventListener("OK", onOKCreateCustomLibraryDialog)
			dialog.addEventListener(Event.CANCEL, onCancelCreateCustomLibraryDialog)					
		}
		
		
		public function onOKCreateCustomLibraryDialog(event:Event):void
		{
			var dialog:CreateCustomLibraryDialog = event.target as CreateCustomLibraryDialog
			var displayName:String = dialog.displayName
			var description:String = dialog.description
			
			removeCreateCustomLibraryDialogEventListeners(dialog)
			dialogsController.removeDialog()
						
			createCustomLibrary(displayName, description)
		}
		
		public function onCancelCreateCustomLibraryDialog(event:Event):void
		{
			removeCreateCustomLibraryDialogEventListeners(event.target as UIComponent)
			dialogsController.removeDialog()
		}
		
		protected function removeCreateCustomLibraryDialogEventListeners(dialog:UIComponent):void
		{
			dialog.removeEventListener("OK", onOKCreateCustomLibraryDialog)
			dialog.removeEventListener(Event.CANCEL, onCancelCreateCustomLibraryDialog)	
		}
		
		
		public function createCustomLibrary(displayName:String, description:String):void
		{
			Logger.debug("createCustomLibrary()",this)
											
			var customLib:CustomLibrary = new CustomLibrary()			
			customLib.displayName = displayName
			customLib.description = description
			customLib.showInPanel = true
			customLib.save(this.dbManager)
			//now that we have an id from the DB, ceate initial libraryName and save again
			customLib.libraryName = "customLibrary" + customLib.id
			customLib.save(this.dbManager)
			libraryManager.addLibrary(customLib)	
			dispatcher.dispatchEvent(new CreateCustomLibraryEvent(CreateCustomLibraryEvent.CUSTOM_LIBRARY_CREATED, true))		
			libraryManager.panelNeedsUpdating = true
			dispatcher.dispatchEvent(new LibraryEvent(LibraryEvent.LIBRARIES_UPDATED, true))					
		}
		
		
		
		
		
//		[Mediate(event="AddImageFileToCustomLibraryEvt.ADD_IMAGE_FROM_FILE")]
//		public function addImageFromFileToCustomLibrary(event:AddImageFileToCustomLibraryEvt):void
//		{
//			Logger.debug("addImageFromFileToCustomLibrary() adding image to library " + event.libraryID+ " from file: " + event.imageFile, this)
//			
//			
//			if (event.imageFile)
//			{
//				//open up image and add byteArray to library
//				var imageFile:File = event.imageFile
//				var imageBA:ByteArray =  new ByteArray()
//				var stream:FileStream = new FileStream()
//				stream.open(imageFile, FileMode.READ)
//				stream.readBytes(imageBA,0, stream.bytesAvailable)
//				addImageDataToCustomLibrary(imageBA, event.libraryID)
//			}
//			else
//			{
//				//browse for file
//				_currLibraryID = event.libraryID
//				_imageForCustomSymbolFile = new File()				
//				_imageForCustomSymbolFile.addEventListener(Event.SELECT, onImageFileForCustomSymbolSelected);
//				var imageFilter:FileFilter = new FileFilter("Image", "*.png;*.jpg;*.gif;");
//				_imageForCustomSymbolFile.browseForOpen("Select an image file", [imageFilter])
//			}
//				
//		}
//		
//		protected function onImageFileForCustomSymbolSelected(event:Event):void
//		{
//			_imageForCustomSymbolFile.removeEventListener(Event.SELECT, onImageFileForCustomSymbolSelected);
//			var imageBA:ByteArray =  new ByteArray()
//			var stream:FileStream = new FileStream()
//			stream.open(_imageForCustomSymbolFile, FileMode.READ)
//			stream.readBytes(imageBA,0, stream.bytesAvailable)
//			addImageDataToCustomLibrary(imageBA, _currLibraryID)
//		}
		
		
		protected function addImageDataToCustomLibrary(imageBA:ByteArray, libraryID:uint):void
		{
			var customLib:CustomLibrary = libraryManager.getCustomLibraryByID(libraryID)	
							
			if (customLib)
			{
				var sdCustomSymbolModel:SDCustomSymbolModel = new SDCustomSymbolModel("customSymbol")
				sdCustomSymbolModel.libraryName = customLib.libraryName
				sdCustomSymbolModel.libraryID = customLib.id
				sdCustomSymbolModel.imageData = imageBA
				sdCustomSymbolModel.sdID = ""
				sdCustomSymbolModel.colorizable = false
				sdCustomSymbolModel.save(dbManager)				
				//use new ID to create first symbolName (user might change later)
				sdCustomSymbolModel.symbolName = "customSymbol"+ sdCustomSymbolModel.id.toString()
				sdCustomSymbolModel.displayName = sdCustomSymbolModel.symbolName
				sdCustomSymbolModel.save(dbManager)										
				customLib.addLibraryItem(sdCustomSymbolModel)
					
			}
			else
			{
				Logger.error("Couldn't find custom library with id: " + libraryID, this)
				Alert.show("Couldn't add image to library. Please see log for details","Library Error")
				return
			}
			
			var evt:AddImageFileToCustomLibraryEvt = new AddImageFileToCustomLibraryEvt(AddImageFileToCustomLibraryEvt.IMAGE_FROM_FILE_ADDED, true)
			evt.libraryID = customLib.id
			dispatcher.dispatchEvent(evt)
					
		}
		
		
		
		[Mediate(event="RenameItemInCustomLibrary.SHOW_RENAME_CUSTOM_SYMBOL_DIALOG")]
		public function onRenameItemInCustomLibrary(event:RenameItemInCustomLibrary):void
		{
			if (event.libraryName=="")
			{
				Logger.error("onRenameItemInCustomLibrary() libraryName is null", this)
				return
			}
			if (event.oldSymbolName=="")
			{
				Logger.error("onRenameItemInCustomLibrary() oldSymbolName is null", this)
				return
			}				
			
			var dialog:RenameCustomLibraryItemDialog = dialogsController.showRenameCustomLibraryItemDialog()
			dialog.libraryName = event.libraryName
			dialog.oldSymbolName = event.oldSymbolName
		}
		
		
		[Mediate(event="RenameItemInCustomLibrary.RENAME_ITEM")]
		public function onRenameItemInCustomLibraryDone(event:RenameItemInCustomLibrary):void
		{
			var oldName:String = event.oldSymbolName
			var newName:String = event.newSymbolName
			var libraryName:String = event.libraryName
															
			var library:CustomLibrary = libraryManager.getCustomLibraryByName(libraryName)
			if (library==null)
			{				
				Logger.error("onRenameItemInCustomLibraryDone() Couldn't find library :" + libraryName,this)
				Alert.show("Couldn't rename symbol. Please see log for details.")
				return
			}
				
			try
			{
				var checkNewObj:SDObjectModel = library.getSDObjectModel(newName)
				if (checkNewObj)
				{
					Logger.error("onRenameItemInCustomLibraryDone() can't rename library " + libraryName + " symbol: " + oldName + " to " + newName + " since it already exists", this)
					Alert.show("A symbol with that name already exists in this library.")
					return
				}
			}
			catch(error:SDObjectModelNotFoundError)
			{
				//no problem if symbol not found
			}
						
			try
			{
				library.renameSymbol(oldName, newName, dbManager)
			}
			catch(error:Error)
			{
				Logger.error("onRenameItemInCustomLibraryDone() Couldn't rename custom library item. Error: "+ error,this)
				Alert.show("Couldn't rename symbol. Please see log for details.")
			}
			
			var evt:RenameItemInCustomLibrary = new RenameItemInCustomLibrary(RenameItemInCustomLibrary.ITEM_RENAMED, true)
			dispatcher.dispatchEvent(evt)
						
		}
		
	
		
		[Mediate(event="DeleteItemFromCustomLibrary.SHOW_DELETE_CUSTOM_SYMBOL_DIALOG")]
		public function onDeleteItemInCustomLibrary(event:DeleteItemFromCustomLibrary):void
		{
			var dialog:DeleteCustomSymbolDialog = dialogsController.showDeleteCustomSymbolDialog()	
			dialog.libraryName = event.libraryName
			dialog.symbolName = event.symbolName		
	
		}
		
		[Mediate(event="DeleteItemFromCustomLibrary.DELETE_ITEM")]
		public function onDeleteCustomSymbolResponse(event:DeleteItemFromCustomLibrary):void
		{			
			var libraryName:String = event.libraryName		
			var symbolName:String = event.symbolName
						
			var library:CustomLibrary = libraryManager.getCustomLibraryByName(libraryName)
			if (library==null)
			{				
				Logger.error("onRenameItemInCustomLibraryDone() Couldn't find library :" + libraryName,this)
				Alert.show("Couldn't delete symbol. Please see log for details.")
				return
			}
			
			library.deleteSymbol(symbolName, dbManager)
				
			var evt:DeleteItemFromCustomLibrary = new DeleteItemFromCustomLibrary(DeleteItemFromCustomLibrary.ITEM_DELETED, true)
			evt.libraryName = libraryName
			evt.symbolName = symbolName
			dispatcher.dispatchEvent(evt)
			
			
		}
		
		
		
	}
}