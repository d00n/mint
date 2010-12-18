package com.simplediagrams.controllers
{
	
	import com.simplediagrams.controllers.DialogsController;
	import com.simplediagrams.events.*;
	import com.simplediagrams.model.*;
	import com.simplediagrams.view.AboutWindow;
	import com.simplediagrams.view.dialogs.PreferencesDialog;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
//	import mx.events.FlexNativeMenuEvent;
	
	
	public class MenuController
	{
		
		/* Put any function here that the user can access via the menu but which really can't be put in any other controller */
		
		[Dispatcher]
		public var dispatcher:IEventDispatcher;
		
		[Inject]
		public var dialogsController:DialogsController
				
		[Inject]
		public var applicationModel:ApplicationModel
		
		[Inject]
		public var registrationManager:RegistrationManager
		
		protected var _aboutWindow:AboutWindow
		protected var _preferencesDialog:PreferencesDialog
		
		public function MenuController()
		{
		}
		
				
		
		[Mediate(event="PreferencesEvent.SHOW_PREFERENCES_WINDOW")]
		public function showPreferencesWindow(event:PreferencesEvent):void
		{
			_preferencesDialog = dialogsController.showPreferencesDialog()
			_preferencesDialog.addEventListener("OK", onPreferencesOK)
			_preferencesDialog.addEventListener(Event.CANCEL, onPreferencesCancel)
		}
					
		
		[Mediate(event="LoadDiagramEvent.DIAGRAM_LOADED")]
		[Mediate(event="CreateNewDiagramEvent.NEW_DIAGRAM_CREATED")]
		public function onEnableDiagramMenus(event:Event):void
		{
			toggleMenuItems(true)
		}
			
		[Mediate(event="CloseDiagramEvent.DIAGRAM_CLOSED")]
		public function onDisableDiagramMenus(event:Event):void
		{
			toggleMenuItems(false)
		}
		
		
		[Mediate(event="AboutEvent.SHOW_ABOUT_WINDOW")]
		public function showAboutWindow(event:AboutEvent):void
		{
			
			_aboutWindow = dialogsController.showAboutDialog()
			_aboutWindow.addEventListener("close", onAboutWindowClose)
		}
		
		protected function onAboutWindowClose(event:Event):void
		{
			if (_aboutWindow)
			{
				dialogsController.removeDialog(_aboutWindow)
				_aboutWindow.removeEventListener("close", onAboutWindowClose)	
				_aboutWindow = null			
			}
		}	
		
		protected function toggleMenuItems(state:Boolean):void
		{	
			
			var itemsToToggleArr:Array = ["save_diagram", "save_diagram_as", "close_diagram", "edit_properties", "diagram", "edit", "style","view"]
						
			var numToggleItems:Number = itemsToToggleArr.length	
			var numMenuDataItems:Number = ApplicationModel.menuDataArr.length
			for (var i:uint = 0; i<numMenuDataItems;i++)
			{		
				if (itemsToToggleArr.indexOf(ApplicationModel.menuDataArr[i].id)>-1 )
				{
					ApplicationModel.menuDataArr[i].enabled = state
				}		
				var subItemsArr:Array = ApplicationModel.menuDataArr[i].children	
				if (subItemsArr && subItemsArr.length>0)
				{
					for (var j:uint=0;j<subItemsArr.length;j++)
					{
						if (itemsToToggleArr.indexOf(subItemsArr[j].id)>-1 )
						{
							subItemsArr[j].enabled = state
						}					
					}
				}		
			}
//			FlexGlobals.topLevelApplication.appMenu.dataProvider = ApplicationModel.menuDataArr
			
		}		

		protected function onPreferencesOK(event:Event):void
		{
			closePreferencesDialog()			
		}
		
		protected function onPreferencesCancel(event:Event):void
		{
			closePreferencesDialog()
		}
		
		protected function closePreferencesDialog():void
		{
			if (_preferencesDialog)
			{
				_preferencesDialog.removeEventListener("OK", onPreferencesOK)
				_preferencesDialog.removeEventListener(Event.CANCEL, onPreferencesCancel)
				dialogsController.removeDialog(_preferencesDialog)
				_preferencesDialog = null
			}
		}	
		
		
		[Mediate(event="SDMenuEvent.MENU_COMMAND")]
		public function onMenuCommand(event:SDMenuEvent):void
		{
			
			var cmd:String = event.command

			if (applicationModel.menuEnabled==false) return
				
						
			switch(cmd)
			{
				
				/* SimpleDiagrams */
				case "preferences":						
					var prefEvent:PreferencesEvent = new PreferencesEvent(PreferencesEvent.SHOW_PREFERENCES_WINDOW,true)
					dispatcher.dispatchEvent(prefEvent)
					break
				
				case "registration":
					
					if (registrationManager.isLicensed)
					{
						Alert.show("This SimpleDiagrams application is already registered")
						return
					}
					
					var regEvent:RegistrationViewEvent = new RegistrationViewEvent(RegistrationViewEvent.SHOW_REGISTRATION_SCREEN,true)
					dispatcher.dispatchEvent(regEvent)
					break
				
				case "about":
					var aboutEvent:Registration = new AboutEvent(AboutEvent.SHOW_ABOUT_WINDOW,true)
					dispatcher.dispatchEvent(aboutEvent)
					break
				
				
				/* File */
				
				case "new_diagram":		
					dispatcher.dispatchEvent(new CreateNewDiagramEvent(CreateNewDiagramEvent.CREATE_NEW_DIAGRAM, true))
					break
				
				case "open_diagram":
					dispatcher.dispatchEvent(new OpenDiagramEvent(OpenDiagramEvent.OPEN_DIAGRAM, true))
					break
				
				case "save_diagram":
					dispatcher.dispatchEvent(new SaveDiagramEvent(SaveDiagramEvent.SAVE_DIAGRAM, true))
					break	
				
				case "save_diagram_as":
					dispatcher.dispatchEvent(new SaveDiagramEvent(SaveDiagramEvent.SAVE_DIAGRAM_AS, true))
					break
				
				case "close_diagram":
					dispatcher.dispatchEvent(new CloseDiagramEvent(CloseDiagramEvent.CLOSE_DIAGRAM, true))
					break
				
				
				
				/* Diagram */
				
				case "export_diagram_to_file":
					var exportEvent:ExportDiagramUserRequestEvent = new ExportDiagramUserRequestEvent(ExportDiagramUserRequestEvent.EXPORT_DIAGRAM, true)						
					exportEvent.destination = ExportDiagramUserRequestEvent.DESTINATION_FILE
					dispatcher.dispatchEvent(exportEvent)
					break
				
				case "export_diagram_to_basecamp":
					exportEvent = new ExportDiagramUserRequestEvent(ExportDiagramUserRequestEvent.EXPORT_DIAGRAM, true)							
					exportEvent.destination = ExportDiagramUserRequestEvent.DESTINATION_BASECAMP
					dispatcher.dispatchEvent(exportEvent)
					break
				
				case "export_diagram_to_yammer":
					exportEvent = new ExportDiagramUserRequestEvent(ExportDiagramUserRequestEvent.EXPORT_DIAGRAM, true)							
					exportEvent.destination = ExportDiagramUserRequestEvent.DESTINATION_YAMMER
					dispatcher.dispatchEvent(exportEvent)
					break
				
				case "edit_properties":	
					dispatcher.dispatchEvent(new PropertiesEvent(PropertiesEvent.EDIT_PROPERTIES, true))
					break
				
				case "show_options":						
					break
				
				case "quit_application":	
					dispatcher.dispatchEvent(new ApplicationEvent(ApplicationEvent.QUIT, true))
					break
				
				/* EDIT */
				
				case "selectAll":
					var selectEvt:SelectionEvent = new SelectionEvent(SelectionEvent.SELECT_ALL, true)		
					dispatcher.dispatchEvent(selectEvt)
					break
				
				case "undo":
					var undoEvent:UndoRedoEvent = new UndoRedoEvent(UndoRedoEvent.UNDO, true)		
					dispatcher.dispatchEvent(undoEvent)
					//give focus explicitly back to stage otherwise it gets lost after a SD object is undone
					FlexGlobals.topLevelApplication.appView.setFocus()
					break
				
				case "redo":
					var redoEvent:UndoRedoEvent = new UndoRedoEvent(UndoRedoEvent.REDO, true)		
					dispatcher.dispatchEvent(redoEvent)
					//give focus explicitly back to stage otherwise it gets lost after a SD object is redone
					FlexGlobals.topLevelApplication.appView.setFocus()
					break
				
				case "cut":
					var cutEvent:CutEvent = new CutEvent(CutEvent.CUT, true)
					dispatcher.dispatchEvent(cutEvent)
					break
				
				case "copy":
					var copyEvent:CopyEvent = new CopyEvent(CopyEvent.COPY, true)
					dispatcher.dispatchEvent(copyEvent)
					break
				
				case "paste":
					var pasteEvent:PasteEvent = new PasteEvent(PasteEvent.PASTE, true)
					dispatcher.dispatchEvent(pasteEvent)
					break
				
				case "delete":
					var deleteEvent:DeleteSDObjectModelEvent = new DeleteSDObjectModelEvent(DeleteSDObjectModelEvent.DELETE_SELECTED_FROM_MODEL, true)
					dispatcher.dispatchEvent(deleteEvent)
					break
				
				case "alignLeft":
					var alignEvent:AlignEvent = new AlignEvent(AlignEvent.ALIGN_LEFT, true)
					dispatcher.dispatchEvent(alignEvent)
					break
				
				case "alignRight":
					alignEvent = new AlignEvent(AlignEvent.ALIGN_RIGHT, true)
					dispatcher.dispatchEvent(alignEvent)						
					break
				
				case "alignCenter":
					alignEvent = new AlignEvent(AlignEvent.ALIGN_CENTER, true)
					dispatcher.dispatchEvent(alignEvent)						
					break
				
				case "alignTop":
					alignEvent = new AlignEvent(AlignEvent.ALIGN_TOP, true)
					dispatcher.dispatchEvent(alignEvent)						
					break
				
				case "alignBottom":
					alignEvent = new AlignEvent(AlignEvent.ALIGN_BOTTOM, true)
					dispatcher.dispatchEvent(alignEvent)						
					break
				
				
				case "alignMiddle":
					alignEvent = new AlignEvent(AlignEvent.ALIGN_MIDDLE, true)
					dispatcher.dispatchEvent(alignEvent)						
					break
				
				
				/* STYLE */
				case "chalkboard_style":	
					var styleEvent:StyleEvent = new StyleEvent(StyleEvent.CHANGE_STYLE, true)
					styleEvent.styleName = DiagramStyleManager.CHALKBOARD_STYLE
					dispatcher.dispatchEvent(styleEvent)
					break
				
				case "whiteboard_style":	
					styleEvent = new StyleEvent(StyleEvent.CHANGE_STYLE, true)
					styleEvent.styleName = DiagramStyleManager.WHITEBOARD_STYLE
					dispatcher.dispatchEvent(styleEvent)
					break
				
				case "napkin_style":	
					styleEvent = new StyleEvent(StyleEvent.CHANGE_STYLE, true)
					styleEvent.styleName = DiagramStyleManager.NAPKIN_STYLE
					dispatcher.dispatchEvent(styleEvent)
					break
				
				case "basic_style":	
					styleEvent = new StyleEvent(StyleEvent.CHANGE_STYLE, true)
					styleEvent.styleName = DiagramStyleManager.BASIC_STYLE
					dispatcher.dispatchEvent(styleEvent)
					break
				
				
				/* LIBRARIES */
				
				case "manage_local_libraries":
					dispatcher.dispatchEvent(new LibraryEvent(LibraryEvent.MANAGE_LIBRARIES, true))
					break
				
				case "download_libraries":
					dispatcher.dispatchEvent(new DownloadLibraryEvent(DownloadLibraryEvent.DOWNLOAD_AVAILABLE_LIBARIES_LIST, true))
					break
				
				case "load_library_plugin_from_file":
					dispatcher.dispatchEvent(new LoadLibraryPluginEvent(LoadLibraryPluginEvent.LOAD_LIBRARY_PLUGIN_FROM_FILE, true))
					break
				
				case "new_custom_library":
					dispatcher.dispatchEvent(new CreateCustomLibraryEvent(CreateCustomLibraryEvent.SHOW_CREATE_CUSTOM_LIBRARY_DIALOG, true))
					break
				
				/* VIEW MENU */
				
				case "zoom_out":
					dispatcher.dispatchEvent(new ZoomEvent(ZoomEvent.ZOOM_OUT, true))
					break
				
				case "zoom_in":
					dispatcher.dispatchEvent(new ZoomEvent(ZoomEvent.ZOOM_IN, true))
					break
				
				
				/* Debugger */
				
				case "view_debugger":
					
					/*
					var pnlDebug:DebugPanel = new DebugPanel()
					PopUpManager.addPopUp(pnlDebub
					pnlDebug.width=700
					pnlDebug.height=600
					PopUpManager.centerPopUp(pnlDebug)		
					*/
					
					break
				
				/* HELP MENU */
				
				case "view_help":
					var req:URLRequest = new URLRequest("http://www.simplediagrams.com/support.html")
					navigateToURL(req, "_blank")
					
					
					break
				
				
				
				
			}
			
			
		}
		
		
		
		
		
		
	}
}