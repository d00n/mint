package com.simplediagrams.controllers
{
	
	import com.simplediagrams.business.FileManager;
	import com.simplediagrams.commands.AddCommand;
	import com.simplediagrams.commands.ChangeCommand;
	import com.simplediagrams.commands.ChangeDepthCommand;
	import com.simplediagrams.commands.CompositeCommand;
	import com.simplediagrams.commands.IUndoRedoCommand;
	import com.simplediagrams.commands.RemoveCommand;
	import com.simplediagrams.commands.TransformCommand;
	import com.simplediagrams.errors.DiagramIncompleteDueToMissingSymbolsError;
	import com.simplediagrams.errors.SymbolNotFoundError;
	import com.simplediagrams.events.*;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.CopyUtil;
	import com.simplediagrams.model.DepthUtil;
	import com.simplediagrams.model.DiagramManager;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.RegistrationManager;
	import com.simplediagrams.model.SDBackgroundModel;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDPencilDrawingModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.model.SDTextAreaModel;
	import com.simplediagrams.model.SettingsModel;
	import com.simplediagrams.model.ToolsManager;
	import com.simplediagrams.model.TransformData;
	import com.simplediagrams.model.UndoRedoManager;
	import com.simplediagrams.model.libraries.ImageShape;
	import com.simplediagrams.model.libraries.LibraryItem;
	import com.simplediagrams.model.libraries.SWFBackground;
	import com.simplediagrams.model.libraries.SWFShape;
	import com.simplediagrams.model.tools.Tools;
	import com.simplediagrams.util.ExportTimer;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.SDComponents.SDBase;
	import com.simplediagrams.view.SDComponents.SDImage;
	import com.simplediagrams.view.SDComponents.SDLine;
	import com.simplediagrams.view.dialogs.DiagramPropertiesDialog;
	import com.simplediagrams.view.dialogs.UnavailableFontsDialog;
	import com.simplediagrams.view.drawingBoard.SDObjContainer;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.charts.AreaChart;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FileEvent;
	import mx.graphics.BitmapFillMode;
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import org.swizframework.controller.AbstractController;
	
	import spark.components.Group;
	
	public class DiagramController extends AbstractController 
	{
		public function DiagramController()
		{			
			
		}

		[Autowire(bean="remoteSharedObjectController")]
		public var remoteSharedObjectController:RemoteSharedObjectController    
		
		[Inject]
		public var appModel:ApplicationModel
		
		[Inject]
		public var diagramManager:DiagramManager
		
		[Inject]
		public var libraryManager:LibraryManager
		
		[Inject]
		public var fileManager:FileManager
		
		[Inject]
		public var undoRedoManager:UndoRedoManager
		
		[Inject]
		public var settingsModel:SettingsModel
		
		[Inject]
		public var dialogsController:DialogsController	
		
		[Inject]
		public var registrationManager:RegistrationManager
		
		[ViewAdded]
		public var sdObjContainer:SDObjContainer
		
		protected var imageByteArray:ByteArray		
		protected var _diagramPropertiesDialog:DiagramPropertiesDialog
		protected var _viewToExport:Group
		
		[Mediate(event='LoadDiagramEvent.DIAGRAM_BUILT')]
		public function diagramBuilt(event:Event):void
		{
			dialogsController.removeDialog()
			
			//show warning and list fonts if some fonts aren't available			
			//			var unavailableFontsArr:Array = fileManager.unavailableFontsArr
			//			if (fileManager.unavailableFontsArr && fileManager.unavailableFontsArr.length>0)
			//			{
			//				var dialog:UnavailableFontsDialog = dialogsController.showUnavailableFontsDialog() 
			//				dialog.setUnavailableFonts(fileManager.unavailableFontsArr)
			//				dialog.addEventListener("OK", onUnavailableFontsDialogOK)
			//			}
			
		}
		
		protected function onUnavailableFontsDialogOK(event:Event):void
		{			
			event.target.removeEventListener("OK", onUnavailableFontsDialogOK)
			dialogsController.removeDialog(UIComponent(event.target) )			
		}
		
		
		
		
		[Mediate(event='DrawingBoardItemDroppedEvent.LIBRARY_ITEM_ADDED')]
		public function onLibraryItemAdded(event:DrawingBoardItemDroppedEvent):void
		{						
			returnToPointerTool()
			var libItem:LibraryItem = libraryManager.importToLocalLibrary(event.libraryItem);
			var newSymbolModel:SDSymbolModel = new SDSymbolModel(libItem.libraryName,  libItem.name);	
			newSymbolModel.x = event.dropX
			newSymbolModel.y = event.dropY;
			newSymbolModel.width = libItem.width;
			newSymbolModel.height = libItem.height;
			newSymbolModel.textAlign = settingsModel.defaultTextAlign
			newSymbolModel.fontSize = settingsModel.defaultFontSize
			newSymbolModel.fontFamily = settingsModel.defaultFontFamily
			newSymbolModel.fontWeight = settingsModel.defaultFontWeight
			newSymbolModel.textPosition = settingsModel.defaultTextPosition
			newSymbolModel.lineWeight = settingsModel.defaultSymbolLineWeight
			newSymbolModel.color = settingsModel.selectedColor;
			
			if (libItem is SWFShape)
			{
				newSymbolModel.maintainAspectRatio= SWFShape(libItem).maintainAspectRatio
				newSymbolModel.startWithDefaultColor = SWFShape(libItem).startWithShapeDefaultColor					
			}
			
			var cmd:AddCommand = new AddCommand(diagramManager.diagramModel, newSymbolModel);
			cmd.execute()
			undoRedoManager.push(cmd)			
			
			diagramManager.diagramModel.select([newSymbolModel]);
		}
		
		
		
		[Mediate(event="DiagramEvent.FIT_DIAGRAM_SIZE_TO_DEFAULT_BG_SIZE")]
		public function fitDiagramSizeToDefaultBackgroundSize(event:DiagramEvent):void
		{
			
			var bg:SDBackgroundModel = diagramManager.diagramModel.background
			if (bg.libraryName!="" && bg.symbolName!="")
			{
				var libItem:LibraryItem = libraryManager.getLibraryItem(bg.libraryName, bg.symbolName)
				diagramManager.diagramModel.width = libItem.width
				diagramManager.diagramModel.height = libItem.height
				diagramManager.diagramModel.background.fillMode = BitmapFillMode.SCALE
			}
			
		}
		
		[Mediate(event='DrawingBoardItemDroppedEvent.IMAGE_ITEM_ADDED')]
		public function onImageItemAdded(event:DrawingBoardItemDroppedEvent):void
		{
			returnToPointerTool();
			var image:SDImageModel = new SDImageModel();
			image.x = event.dropX;
			image.y = event.dropY;
			var cmd:AddCommand = new AddCommand(diagramManager.diagramModel, image)
			cmd.execute()
			undoRedoManager.push(cmd)			
		}
		
		
		
		[Mediate(event='BackgroundItemDroppedEvent.BACKGROUND_ITEM_DROPPED_EVENT')]
		public function onBackgroundItemDropped(event:BackgroundItemDroppedEvent):void
		{			
			var libModel:LibraryItem = libraryManager.importToLocalLibrary(event.libItem);
			
			var oldBG:SDBackgroundModel = diagramManager.diagramModel.background;
			var newSDBackgroundModel:SDBackgroundModel = CopyUtil.clone(oldBG) as SDBackgroundModel;
			newSDBackgroundModel.libraryName = libModel.libraryName;
			newSDBackgroundModel.symbolName = libModel.name;
			
			if (libModel is SWFBackground)
			{
				newSDBackgroundModel.fillMode = BitmapFillMode.SCALE
			}
			
			
			var copy:DiagramModel = new DiagramModel();
			CopyUtil.copyFrom(copy, diagramManager.diagramModel);
			copy.background = newSDBackgroundModel;
			var cmd:ChangeCommand = new ChangeCommand(diagramManager.diagramModel, copy);
			cmd.execute()			
			undoRedoManager.push(cmd)	
		}
		
		
		[Mediate(event='DrawingBoardItemDroppedEvent.STICKY_NOTE_ADDED')]
		[Mediate(event='DrawingBoardItemDroppedEvent.INDEX_CARD_ADDED')]
		public function onTextWidgetAdded(event:DrawingBoardItemDroppedEvent):void
		{			
			returnToPointerTool()
			var sdTextAreaModel:SDTextAreaModel = new SDTextAreaModel();
			sdTextAreaModel.color = settingsModel.selectedColor;
			sdTextAreaModel.x = event.dropX
			sdTextAreaModel.y = event.dropY
			
			switch(event.type)
			{
				case DrawingBoardItemDroppedEvent.STICKY_NOTE_ADDED:
					sdTextAreaModel.styleName = SDTextAreaModel.STICKY_NOTE
					sdTextAreaModel.maintainProportion = true
					sdTextAreaModel.backgroundColor = settingsModel.defaultStickyNoteBGColor
					sdTextAreaModel.width = settingsModel.defaultStickyNoteWidth
					sdTextAreaModel.height = settingsModel.defaultStickyNoteHeight
					break
				
				case DrawingBoardItemDroppedEvent.INDEX_CARD_ADDED:					
					sdTextAreaModel.styleName = SDTextAreaModel.INDEX_CARD
					sdTextAreaModel.maintainProportion = true
					sdTextAreaModel.backgroundColor = settingsModel.defaultIndexCardBGColor
					sdTextAreaModel.width = settingsModel.defaultIndexCardWidth
					sdTextAreaModel.height = settingsModel.defaultIndexCardHeight
					sdTextAreaModel.showTape = settingsModel.defaultIndexCardShowTape
					break
				
				default:
					Logger.warn("Unrecognized event type: " + event.type,this)
					
			}
			var cmd:AddCommand = new AddCommand(diagramManager.diagramModel, sdTextAreaModel)
			cmd.execute()			
			undoRedoManager.push(cmd)		
			diagramManager.diagramModel.select([sdTextAreaModel]);
      
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.TEXT_WIDGET_ADDED);	
			rsoEvent.changedSDObjectModelArray = new Array;
			rsoEvent.changedSDObjectModelArray.push(diagramModel.getModelByID(cmd.sdID));
			dispatcher.dispatchEvent(rsoEvent);			      
		}
		
		
		[Mediate(event='TextAreaCreatedEvent.CREATED')]
		public function onTextAreaCreated(event:TextAreaCreatedEvent):void
		{
			returnToPointerTool()	
			var textArea:SDTextAreaModel = new SDTextAreaModel();
			textArea.x = event.dropX - 5
			textArea.y = event.dropY - 5
			textArea.color = settingsModel.selectedColor;
			textArea.width = 150
			textArea.height = 50
			textArea.styleName = SDTextAreaModel.NO_BACKGROUND
			textArea.textAlign = settingsModel.defaultTextAlign
			textArea.fontSize = settingsModel.defaultFontSize
			textArea.fontWeight = settingsModel.defaultFontWeight	
			textArea.fontFamily = settingsModel.defaultFontFamily
			var cmd:AddCommand = new AddCommand(diagramManager.diagramModel,textArea);
			cmd.execute();
			undoRedoManager.push(cmd);
			diagramManager.diagramModel.select([textArea]);
			
			//			remoteSharedObjectController.dispatchUpdate_TextAreaCreated(cmd);
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.TEXT_WIDGET_CREATED);	
			rsoEvent.changedSDObjectModelArray = new Array;
			rsoEvent.changedSDObjectModelArray.push(diagramModel.getModelByID(cmd.sdID));
			dispatcher.dispatchEvent(rsoEvent);				
		}
		
		[Mediate(event='TransformEvent.TRANSFORM')]
		public function transform(event:TransformEvent):void
		{
			var sourceArray:Array = diagramManager.diagramModel.selectedObjects.source;
			var targets:Array = sourceArray.concat();
			var translateCommand:TransformCommand = new TransformCommand(targets, event.newTransforms, event.oldTransforms, event.backup);
			undoRedoManager.push(translateCommand)	
		}
		
		[Mediate(event='PencilDrawingEvent.DRAWING_CREATED')]
		public function onPencilDrawingCreated(event:PencilDrawingEvent):void
		{
			var pencilDrawing:SDPencilDrawingModel = new SDPencilDrawingModel();
			pencilDrawing.linePath = event.path
			pencilDrawing.x = event.initialX
			pencilDrawing.y = event.initialY
			pencilDrawing.width = event.width
			pencilDrawing.height = event.height
			pencilDrawing.color = event.color
			var cmd:AddCommand = new AddCommand(diagramManager.diagramModel, pencilDrawing)
			cmd.execute()		
			undoRedoManager.push(cmd)	
			
			//			remoteSharedObjectController.dispatchUpdate_PencilDrawingCreated(cmd);
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.PENCIL_DRAWING_CREATED);	
			rsoEvent.changedSDObjectModelArray = new Array;
			rsoEvent.changedSDObjectModelArray.push(diagramModel.getModelByID(cmd.sdID));
			dispatcher.dispatchEvent(rsoEvent);				
		}
		
		
		[Mediate(event='CreateLineComponentEvent.CREATE')]
		public function onCreateLineComponent(event:CreateLineComponentEvent):void
		{
			var line:SDLineModel = event.line;
			line.color = settingsModel.selectedColor;
			line.startLineStyle = settingsModel.defaultStartLineStyle;
			line.endLineStyle = settingsModel.defaultEndLineStyle;
			line.lineWeight = settingsModel.defaultLineWeight
			line.lineStyle = settingsModel.defaultLineStyle
			var cmd:AddCommand = new AddCommand(diagramManager.diagramModel, line);
			cmd.execute()	
			undoRedoManager.push(cmd)
			diagramManager.diagramModel.select([line]);
		}
		
		
		[Mediate(event="LoadImageEvent.LOAD_IMAGE_FILE")]
		public function loadImageFromFile(event:LoadImageEvent):void 
		{
			Logger.debug("loadImageFromFile()", this)			
			
			var file:File = event.file
			
			var stream:FileStream = new FileStream()
			stream.open(file, FileMode.READ)
			
			var ba:ByteArray = new ByteArray()
			stream.readBytes(ba,0, stream.bytesAvailable)
			stream.close();
			
			var objModel:SDImageModel = new SDImageModel()
			objModel.x = event.dropX
			objModel.y = event.dropY
				

			objModel.symbolName = UIDUtil.createUID();
			objModel.libraryName = "local";
			var byteItem:ImageShape = new ImageShape();
			byteItem.libraryName = "local";
			byteItem.name = objModel.symbolName;
			byteItem.path = byteItem.name+ "." + file.extension;
			libraryManager.addToLocalLibrary( byteItem, ba);
			
			diagramManager.diagramModel.sdObjects.addItem(objModel)
			
		}
		
		
		[Mediate(event='DeleteSDObjectModelEvent.DELETE_SELECTED_FROM_MODEL')]
		public function onDeleteSelectedSDObjectModel(event:DeleteSDObjectModelEvent):void
		{
			var selectedItems:IList = diagramManager.diagramModel.selectedObjects;
			var commands:Array = [];
			for each(var item:SDObjectModel in selectedItems)
			{
				for each(var dependencyItem:SDObjectModel in diagramManager.diagramModel.sdObjects)
				{
					if(dependencyItem is SDLineModel)
					{
						var lineModel:SDLineModel = dependencyItem as SDLineModel;
						if(lineModel.fromObject == item || lineModel.toObject == item)
						{
							var newState:SDLineModel = ObjectUtil.clone(lineModel) as SDLineModel;
							if(lineModel.fromObject == item )
							{
								newState.fromObject = null;
								newState.fromPoint = null;
							}
							if(lineModel.toObject == item )
							{
								newState.toObject = null;
								newState.toPoint = null;
							}
							var changeCommand:ChangeCommand = new ChangeCommand(lineModel, newState);
							commands.push(changeCommand);
						}
					}
				}
				var removeCommand:RemoveCommand = new RemoveCommand(diagramManager.diagramModel, item);
				commands.push(removeCommand);
			}
			execCommands(commands);
      
			// doon: should this go in DiagramModel.deleteSDObjectModel ?
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.DELETE_SELECTED_SD_OBJECT_MODEL);	
			rsoEvent.sdIDArray = sdIDArray;
			dispatcher.dispatchEvent(rsoEvent);      
		}
		
	// Deletes get handled by processing the RSO event for broadcasting it	
//		[Mediate(event='DeleteSDObjectModelEvent.DELETE_FROM_MODEL')]
		public function onDeleteSDObjectModel(event:DeleteSDObjectModelEvent):void
		{
			var sdObjectModel:SDObjectModel = event.sdObjectModel
			var cmd:RemoveCommand = new RemoveCommand(diagramManager.diagramModel, sdObjectModel)
			cmd.execute()
			undoRedoManager.push(cmd)		
		}
				
		
		
		
		[Mediate(event='ExportDiagramEvent.EXPORT_TO_CLIPBOARD')]
		[Mediate(event='ExportDiagramEvent.CREATE_IMAGE_FOR_EXPORT')]
		public function exportDiagramToFile(event:ExportDiagramEvent):void
		{
			var totPix:Number = diagramManager.diagramModel.width*diagramManager.diagramModel.height
			if (diagramManager.diagramModel.width>8191 || diagramManager.diagramModel.height>8191 || totPix>16777215)
			{
				Alert.show("The diagram is too large to be exported. The maximum size for a diagram object is 8,191 pixels in width or height," +
					"and the total number of pixels cannot exceed 16,777,215 pixels.", "Diagram size error")
				return
			}			
			//flip to 100 percent zoom before exporting, otherwise the exported image will reflect the zoom width and height
			_viewToExport = event.view as Group
			
			if (settingsModel.hideBGOnExport)
			{
				diagramManager.diagramModel.backgroundVisible = false
			}	
			var t:ExportTimer = new ExportTimer(50)
			t.sourceEventType = event.type
			t.addEventListener(TimerEvent.TIMER, startExportDiagramToFile)
			t.start()
		}
		
		protected function startExportDiagramToFile(event:TimerEvent):void
		{
//			var t:ExportTimer = event.target as ExportTimer
//			t.removeEventListener(TimerEvent.TIMER, startExportDiagramToFile)
//			t.stop()
//			
//			diagramManager.diagramModel.selectedObjects.removeAll();	
//			
//			var currScaleX:Number = diagramManager.diagramModel.scaleX
//			var currScaleY:Number = diagramManager.diagramModel.scaleY
//			
//			diagramManager.diagramModel.scaleX = 1
//			diagramManager.diagramModel.scaleY = 1
//			
//			_viewToExport.clipAndEnableScrolling = false
//			var bd:BitmapData = new BitmapData(diagramManager.diagramModel.width, diagramManager.diagramModel.height, true, 0x00ffffff)
//			bd.draw(_viewToExport)
//			imageByteArray = new PNGEncoder().encode(bd)		
//				
//			if (t.sourceEventType == ExportDiagramEvent.EXPORT_TO_CLIPBOARD)
//			{
//				Clipboard.generalClipboard.clearData(ClipboardFormats.BITMAP_FORMAT);				
//				Clipboard.generalClipboard.setData(ClipboardFormats.BITMAP_FORMAT, bd);
//			}
//			else
//			{
//				var evt:ExportDiagramEvent = new ExportDiagramEvent(ExportDiagramEvent.SAVE_IMAGE_TO_FILE, true)
//				evt.imageByteArray = imageByteArray
//				dispatcher.dispatchEvent(evt)
//			}
//						
//			diagramManager.diagramModel.backgroundVisible = true
//					
//			//now set back the zoom to what the user had selected
//			_viewToExport.clipAndEnableScrolling = true
//			diagramManager.diagramModel.scaleX = currScaleX
//			diagramManager.diagramModel.scaleY = currScaleY
			
			_viewToExport = null
			t = null
		}	
	
		
		
		
		[Mediate(event='PropertiesEvent.EDIT_PROPERTIES')]
		public function editProperties(event:PropertiesEvent):void
		{
			_diagramPropertiesDialog = dialogsController.showDiagramPropertiesDialog()
			_diagramPropertiesDialog.diagramManager = diagramManager
			_diagramPropertiesDialog.addEventListener("OK", onSaveDiagramProperties)
			_diagramPropertiesDialog.addEventListener(Event.CANCEL, onCancelDiagramProperties)	
		}	
		
		protected function onSaveDiagramProperties(event:Event):void
		{
			var evt:PropertiesEvent = new PropertiesEvent(PropertiesEvent.PROPERTIES_EDITED, true)
			dispatcher.dispatchEvent(evt)
			dialogsController.removeDialog(_diagramPropertiesDialog)
			_diagramPropertiesDialog.removeEventListener("OK", onSaveDiagramProperties)
			_diagramPropertiesDialog.removeEventListener(Event.CANCEL, onCancelDiagramProperties)	
		}
		
		protected function onCancelDiagramProperties(event:Event):void
		{
			
			dialogsController.removeDialog(_diagramPropertiesDialog)
			_diagramPropertiesDialog.removeEventListener("OK", onSaveDiagramProperties)
			_diagramPropertiesDialog.removeEventListener(Event.CANCEL, onCancelDiagramProperties)	 
		}
		
		
		[Mediate(event='ZoomEvent.ZOOM_IN')]
		public function onZoomIn():void
		{
			diagramManager.diagramModel.scaleX += .1
			diagramManager.diagramModel.scaleY += .1
			
			if (diagramManager.diagramModel.scaleX > 3) diagramManager.diagramModel.scaleX = 3
			if (diagramManager.diagramModel.scaleY > 3) diagramManager.diagramModel.scaleY = 3 
			
			//			remoteSharedObjectController.dispatchUpdate_RefreshZoom();
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.REFRESH_ZOOM);	
			dispatcher.dispatchEvent(rsoEvent);
		}
		
		[Mediate(event='ZoomEvent.ZOOM_OUT')]
		public function onZoomOut():void
		{
			diagramManager.diagramModel.scaleX -= .1
			diagramManager.diagramModel.scaleY -= .1
			
			if (diagramManager.diagramModel.scaleX < .1) diagramManager.diagramModel.scaleX = .1
			if (diagramManager.diagramModel.scaleY < .1) diagramManager.diagramModel.scaleY = .1
			
			//			remoteSharedObjectController.dispatchUpdate_RefreshZoom();
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.REFRESH_ZOOM);	
			dispatcher.dispatchEvent(rsoEvent);
		}
		
		[Mediate(event='ColorEvent.CHANGE_COLOR')]
		public function onChangeColor(event:ColorEvent):void
		{
			settingsModel.selectedColor = event.color;
			
			//update all selected symbols
			var selectedArr:IList = diagramManager.diagramModel.selectedObjects;
			var commands:Array = [];
			for each (var objModel:SDObjectModel in selectedArr)
			{
				var newState:SDObjectModel = CopyUtil.clone(objModel) as SDObjectModel;
				newState.color = event.color;
				var cmd:ChangeCommand = new ChangeCommand(objModel, newState);
				commands.push(cmd);
			}			
			execCommands(commands);
		}
		
		private function execCommands(commands:Array):void
		{
			if(commands.length > 0)
			{
				var resultCmd:IUndoRedoCommand;
				if(commands.length > 1)
					resultCmd = new CompositeCommand(commands);
				else
					resultCmd = commands[0];
				resultCmd.execute();
				undoRedoManager.push(resultCmd);
			}	
		}
		
		protected var _currModelForImageLoad:SDImageModel
//		protected var _imageFile:File
		
		
		[Mediate(event='LoadImageEvent.BROWSE_FOR_IMAGE')]
		public function onBrowseForImage(event:LoadImageEvent):void
		{
			_currModelForImageLoad = event.model  		
			
			_imageFile = new File()			
			_imageFile.addEventListener(Event.SELECT, onLoadImage)
			_imageFile.addEventListener(Event.CANCEL, onCancelLoadImage)
			//var imagesFilter:FileFilter = new FileFilter("Images", "*.jpg;*.jpeg;*.gif;*.png;*.swf;");
			var imagesFilter:FileFilter = new FileFilter("Images", "*.jpg;*.jpeg;*.gif;*.png;");
			try
			{
				_imageFile.browseForOpen("Select an image to import.", [imagesFilter])
			}
			catch(error:Error)
			{
				Logger.error("onBrowseForImage() error:" + error,this)
			}
		}
		
		public function onLoadImage(event:Event):void
		{	
			
			var stream:FileStream = new FileStream()
			var ba:ByteArray = new ByteArray()
			stream.open(_imageFile, FileMode.READ)
			stream.readBytes(ba,0, stream.bytesAvailable)
			stream.close();
			
			var id:String = UIDUtil.createUID();
			var byteItem:ImageShape = new ImageShape();
			byteItem.libraryName = "local";
			byteItem.name = id;
			byteItem.path = id + "." + _imageFile.extension;
			libraryManager.addToLocalLibrary(byteItem, ba);
						
			var copyImage:SDImageModel = CopyUtil.clone(_currModelForImageLoad) as SDImageModel;
			copyImage.libraryName = "local";
			copyImage.symbolName = id;
			var cmd:ChangeCommand = new ChangeCommand(_currModelForImageLoad, copyImage);
			cmd.execute();
			undoRedoManager.push(cmd);
			
			// Load the image locally for the uploading user
			// ..and fire the rsoEvent from DiagramModel.addSDObjectModel when imageURL is valid
			// TODO: Throw a SimpleDiagramsImageLoadCompleteEvent instead 	
			var remoteSharedObjectEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.LOAD_IMAGE, true, true);
			remoteSharedObjectEvent.imageData = _fileReference.data;
			remoteSharedObjectEvent.imageName = _fileReference.name;
			remoteSharedObjectEvent.sdImageModel = _currModelForImageLoad;
			dispatcher.dispatchEvent(remoteSharedObjectEvent);	
		}
		
		protected function onCancelLoadImage(event:Event):void
		{			
			_imageFile.removeEventListener(Event.SELECT, onLoadImage)
			_imageFile.removeEventListener(Event.CANCEL, onCancelLoadImage)
		}
		
		protected function returnToPointerTool():void
		{
			var evt:ToolPanelEvent = new ToolPanelEvent(ToolPanelEvent.TOOL_SELECTED, true)
			evt.toolTypeSelected = Tools.POINTER_TOOL
			dispatcher.dispatchEvent(evt)	
		}
		
		
		
		[Mediate(event='SelectionEvent.SELECT_ALL')]
		public function onSelectAll(event:SelectionEvent):void
		{
			diagramManager.diagramModel.select( diagramManager.diagramModel.sdObjects.source);									
		}
		
		[Mediate(event='SelectionEvent.SELECT_IN_RECT')]
		public function onSelectInRect(event:SelectionEvent):void
		{
			diagramManager.diagramModel.selectInRect(event.rect.x,event.rect.y,event.rect.width,event.rect.height);
		}
		
		
		[Mediate(event='LineTransformEvent.TRANSFORM_LINE')]
		public function onLineTransform(event:LineTransformEvent):void
		{
			var changeCommand:ChangeCommand = new ChangeCommand(event.newState, CopyUtil.clone(event.newState) );
			changeCommand.oldState = event.oldState;
			undoRedoManager.push(changeCommand);
		}
		
		public function alignLeft(targets:Array,oldTransforms:Array, newTransforms:Array, backups:Array):void
		{
			var leftMin:Number = Number.MAX_VALUE;
			var transformData:TransformData;
			var item:SDObjectModel;
			for each(item in diagramManager.diagramModel.selectedObjects)
			{
				transformData = item.getTransform();
				leftMin = Math.min(leftMin, transformData.left);
			}
			for each(item in diagramManager.diagramModel.selectedObjects)
			{
				transformData = item.getTransform();
				var currentLeft:Number = transformData.left;
				if(currentLeft != leftMin)
				{
					targets.push(item);
					backups.push(CopyUtil.clone(item));
					oldTransforms.push(transformData);
					transformData = transformData.clone();
					transformData.x -= (currentLeft - leftMin);
					newTransforms.push(transformData);
				}
			}
		}
		
		public function alignCenter(targets:Array,oldTransforms:Array, newTransforms:Array, backups:Array):void
		{
			var center:Number = 0;
			var transformData:TransformData;
			var item:SDObjectModel;
			for each(item in diagramManager.diagramModel.selectedObjects)
			{
				transformData = item.getTransform();
				center += transformData.center;
			}
			center /= diagramManager.diagramModel.selectedObjects.length;
			for each(item in diagramManager.diagramModel.selectedObjects)
			{
				transformData = item.getTransform();
				var currentCenter:Number = transformData.center;
				if(currentCenter != center)
				{
					targets.push(item);
					backups.push(CopyUtil.clone(item));
					oldTransforms.push(transformData);
					transformData = transformData.clone();
					transformData.x += (center - currentCenter);
					newTransforms.push(transformData);
				}
			}
		}
		
		public function alignRight(targets:Array,oldTransforms:Array, newTransforms:Array, backups:Array):void
		{
			var rightMax:Number = Number.MIN_VALUE;
			var transformData:TransformData;
			var item:SDObjectModel;
			for each(item in diagramManager.diagramModel.selectedObjects)
			{
				transformData = item.getTransform();
				rightMax = Math.max(rightMax, transformData.right);
			}
			for each(item in diagramManager.diagramModel.selectedObjects)
			{
				transformData = item.getTransform();
				var currentRight:Number = transformData.right;
				if(currentRight != rightMax)
				{
					targets.push(item);
					backups.push(CopyUtil.clone(item));
					oldTransforms.push(transformData);
					transformData = transformData.clone();
					transformData.x += (rightMax - currentRight);
					newTransforms.push(transformData);
				}
			}
		}
		
		public function alignTop(targets:Array,oldTransforms:Array, newTransforms:Array, backups:Array):void
		{
			var topMin:Number = Number.MAX_VALUE;
			var transformData:TransformData;
			var item:SDObjectModel;
			for each(item in diagramManager.diagramModel.selectedObjects)
			{
				transformData = item.getTransform();
				topMin = Math.min(topMin, transformData.top);
			}
			for each(item in diagramManager.diagramModel.selectedObjects)
			{
				transformData = item.getTransform();
				var currentLeft:Number = transformData.top;
				if(currentLeft != topMin)
				{
					targets.push(item);
					backups.push(CopyUtil.clone(item));
					oldTransforms.push(transformData);
					transformData = transformData.clone();
					transformData.y -= (currentLeft - topMin);
					newTransforms.push(transformData);
				}
			}
		}
		
		public function alignMiddle(targets:Array,oldTransforms:Array, newTransforms:Array, backups:Array):void
		{
			var middle:Number = 0;
			var transformData:TransformData;
			var item:SDObjectModel;
			for each(item in diagramManager.diagramModel.selectedObjects)
			{
				transformData = item.getTransform();
				middle += transformData.middle;

			}
			middle /= diagramManager.diagramModel.selectedObjects.length;
			for each(item in diagramManager.diagramModel.selectedObjects)
			{
				transformData = item.getTransform();
				var currentMiddle:Number = transformData.middle;
				if(currentMiddle != middle)
				{
					targets.push(item);
					backups.push(CopyUtil.clone(item));
					oldTransforms.push(transformData);
					transformData = transformData.clone();
					transformData.y += (middle - currentMiddle);
					newTransforms.push(transformData);
				}
			}
		}
		
		
		public function alignBottom(targets:Array,oldTransforms:Array, newTransforms:Array, backups:Array):void
		{
			var bottomMax:Number = Number.MIN_VALUE;
			var transformData:TransformData;
			var item:SDObjectModel;
			for each(item in diagramManager.diagramModel.selectedObjects)
			{
				transformData = item.getTransform();
				bottomMax = Math.max(bottomMax, transformData.bottom);
			}
			for each(item in diagramManager.diagramModel.selectedObjects)
			{
				transformData = item.getTransform();
				var currentBottom:Number = transformData.bottom;
				if(currentBottom != bottomMax)
				{
					targets.push(item);
					backups.push(CopyUtil.clone(item));
					oldTransforms.push(transformData);
					transformData = transformData.clone();
					transformData.y += (bottomMax - currentBottom);
					newTransforms.push(transformData);
				}
			}
		}
		
		[Mediate(event='AlignEvent.ALIGN_TOP')]
		[Mediate(event='AlignEvent.ALIGN_BOTTOM')]
		[Mediate(event='AlignEvent.ALIGN_MIDDLE')]
		[Mediate(event='AlignEvent.ALIGN_LEFT')]
		[Mediate(event='AlignEvent.ALIGN_RIGHT')]
		[Mediate(event='AlignEvent.ALIGN_CENTER')]
		public function onAlign(event:AlignEvent):void
		{			
			var xPos:Number = -1
			var yPos:Number = -1				
			var sdObjectsArr:ArrayCollection = diagramManager.diagramModel.selectedObjects;	

			if (sdObjectsArr.length < 2) return;
			var targets:Array = [];
			var newTransforms:Array = [];
			var oldTransforms:Array = [];
			var backups:Array = [];
			switch(event.type)
			{
				case AlignEvent.ALIGN_TOP:
					alignTop(targets, oldTransforms, newTransforms, backups);
					break
				
				case AlignEvent.ALIGN_LEFT:			
					alignLeft(targets, oldTransforms, newTransforms, backups);

					break
				
				case AlignEvent.ALIGN_CENTER:
					alignCenter(targets, oldTransforms, newTransforms, backups);
					break
				
				case AlignEvent.ALIGN_RIGHT:
					alignRight(targets, oldTransforms, newTransforms, backups);
					break
				
				case AlignEvent.ALIGN_BOTTOM:
					alignBottom(targets, oldTransforms, newTransforms, backups);
					break
				
				case AlignEvent.ALIGN_MIDDLE:
					alignMiddle(targets, oldTransforms, newTransforms, backups);
					break
			}
			if(targets.length)
			{
				var transformCommand:TransformCommand = new TransformCommand(targets, newTransforms, oldTransforms, backups);
				transformCommand.execute();
				undoRedoManager.push(transformCommand);
			}
			
			
			//remoteSharedObjectController.dispatchUpdate_ObjectChanged(cmd);	
			
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.changedSDObjectModelArray = sdObjectsArr;
			dispatcher.dispatchEvent(rsoEvent);
		}
		
		
		
		[Mediate(event='ChangeDepthEvent.MOVE_TO_BACK')]
		public function moveToBack(event:ChangeDepthEvent):void
		{
			var seletedItems:Array = diagramManager.diagramModel.selectedObjects.source;
			if(seletedItems.length > 0)
			{
				var newDepths:Array = DepthUtil.calculateNewDepths(diagramManager.diagramModel, seletedItems, DepthUtil.MOVE_TO_BACK);
				if(newDepths)
				{
					var changeDepthCommand:ChangeDepthCommand = new ChangeDepthCommand( diagramManager.diagramModel,newDepths );
					changeDepthCommand.execute();
					undoRedoManager.push(changeDepthCommand);
				}
			}
			var evt:ChangeDepthEvent = new ChangeDepthEvent(ChangeDepthEvent.OBJECT_MOVED, true)
      dispatcher.dispatchEvent(evt)
			
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.UPDATE_DEPTHS);
			rsoEvent.changedSDObjectModelArray = diagramModel.sdObjectModelsAC.toArray();
			dispatcher.dispatchEvent(rsoEvent);
		}
		
		[Mediate(event='ChangeDepthEvent.MOVE_TO_FRONT')]
		public function moveToFront(event:ChangeDepthEvent):void
		{
			var seletedItems:Array = diagramManager.diagramModel.selectedObjects.source;
			if(seletedItems.length > 0)
			{
				var newDepths:Array = DepthUtil.calculateNewDepths(diagramManager.diagramModel, seletedItems, DepthUtil.MOVE_TO_FRONT);
				if(newDepths)
				{
					var changeDepthCommand:ChangeDepthCommand = new ChangeDepthCommand( diagramManager.diagramModel,newDepths );
					changeDepthCommand.execute();
					undoRedoManager.push(changeDepthCommand);
				}
			}
			
			var evt:ChangeDepthEvent = new ChangeDepthEvent(ChangeDepthEvent.OBJECT_MOVED, true)
			dispatcher.dispatchEvent(evt)
      
      var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.UPDATE_DEPTHS);
			rsoEvent.changedSDObjectModelArray = diagramModel.sdObjectModelsAC.toArray();
			dispatcher.dispatchEvent(rsoEvent);
			
		}
		
		
		[Mediate(event='ChangeDepthEvent.MOVE_BACKWARD')]
		public function moveBackward(event:ChangeDepthEvent):void
		{
			var seletedItems:Array = diagramManager.diagramModel.selectedObjects.source;
			if(seletedItems.length > 0)
			{
				var newDepths:Array = DepthUtil.calculateNewDepths(diagramManager.diagramModel, seletedItems, DepthUtil.MOVE_BACKWARD);
				if(newDepths)
				{
					var changeDepthCommand:ChangeDepthCommand = new ChangeDepthCommand( diagramManager.diagramModel,newDepths );
					changeDepthCommand.execute();
					undoRedoManager.push(changeDepthCommand);
				}
			}
			var evt:ChangeDepthEvent = new ChangeDepthEvent(ChangeDepthEvent.OBJECT_MOVED, true)
			dispatcher.dispatchEvent(evt)
      
      var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.UPDATE_DEPTHS);
			rsoEvent.changedSDObjectModelArray = diagramModel.sdObjectModelsAC.toArray();
			dispatcher.dispatchEvent(rsoEvent);	
		}
		
		[Mediate(event='ChangeDepthEvent.MOVE_FORWARD')]
		public function moveForward(event:ChangeDepthEvent):void
		{
			var seletedItems:Array = diagramManager.diagramModel.selectedObjects.source;
			if(seletedItems.length > 0)
			{
				var newDepths:Array = DepthUtil.calculateNewDepths(diagramManager.diagramModel, seletedItems, DepthUtil.MOVE_FORWARD);
				if(newDepths)
				{
					var changeDepthCommand:ChangeDepthCommand = new ChangeDepthCommand( diagramManager.diagramModel,newDepths );
					changeDepthCommand.execute();
					undoRedoManager.push(changeDepthCommand);
				}
			}
			var evt:ChangeDepthEvent = new ChangeDepthEvent(ChangeDepthEvent.OBJECT_MOVED, true)
			dispatcher.dispatchEvent(evt)
      
      var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.UPDATE_DEPTHS);
			rsoEvent.changedSDObjectModelArray = diagramModel.sdObjectModelsAC.toArray();
			dispatcher.dispatchEvent(rsoEvent);
		}
		
		[Mediate(event="ChangeDepthEvent.OBJECT_MOVED")]
		public function onObjectChangedDepth(event:ChangeDepthEvent):void
		{
			sdObjContainer.invalidateDisplayList()
		}
		
		
		
		
		protected function onContinueEditingHandler(event:CloseEvent):void
		{
			if (event.detail==Alert.YES)
			{				
				dispatcher.dispatchEvent(new LoadDiagramEvent(LoadDiagramEvent.DIAGRAM_BUILT))					
			}
			else
			{				
				dispatcher.dispatchEvent(new CloseDiagramEvent(CloseDiagramEvent.CLOSE_DIAGRAM))
			}
		}
		
		/* If a custom symbol is deleted from library, remove it from working diagram */		
		[Mediate(event="DeleteItemFromCustomLibrary.ITEM_DELETED")]
		public function onItemDeletedFromCustomLibrary(event:DeleteItemFromCustomLibrary):void
		{
			
			//go backwards through arrayCollection so we can delete without messing up index
			var len:uint=diagramManager.diagramModel.sdObjects.length 
			if (len==0) return
			for (var i:uint=len;i>0;i--)
			{
				var sdObjectModel:SDObjectModel = diagramManager.diagramModel.sdObjects.getItemAt(i-1) as SDObjectModel
				if(sdObjectModel is SDSymbolModel)
				{
					var sdSymbolModel:SDSymbolModel = SDSymbolModel(sdObjectModel)
					if (sdSymbolModel.libraryName==event.libraryName && sdSymbolModel.symbolName==event.symbolName)
					{
						diagramManager.diagramModel.sdObjects.removeItemAt(diagramManager.diagramModel.sdObjects.getItemIndex(sdSymbolModel))
					}
				}
			}
		}
		
		
		[Mediate("RebuildDiagramEvent.REBUILD_DIAGRAM_EVENT")]
		public function rebuildDiagram(event:RebuildDiagramEvent):void
		{

		}
		
		[Mediate("DiagramEvent.CHANGE_DIAGRAM_PROPERTIES")]
		public function changeDiagramProperties(event:DiagramEvent):void
		{
			var cmd:ChangeCommand = new ChangeCommand(diagramManager.diagramModel, event.diagramModel);
			cmd.execute();
			undoRedoManager.push(cmd);
		}
		
		[Mediate("DiagramEvent.MOVE_SELECTION")]
		public function moveSelection(event:DiagramEvent):void
		{
			if(diagramManager.diagramModel == null || diagramManager.diagramModel.selectedObjects.length== 0)
				return;
			var targets:Array = diagramManager.diagramModel.selectedObjects.source.concat();
			var backups:Array = CopyUtil.clone(targets) as Array;
			var oldTransforms:Array = new Array(targets.length);
			var newTransforms:Array = new Array(targets.length);
			var i:int = 0;
			for each(var target:SDObjectModel in targets)
			{
				var transform:TransformData = target.getTransform();
				var newTransform:TransformData = transform.clone();
				newTransform.x += event.x;
				newTransform.y += event.y;
				newTransforms[i] = newTransform;
				oldTransforms[i] = transform;
				i++;
			}
			var transformCommand:TransformCommand = new TransformCommand(targets, newTransforms, oldTransforms, backups);
			transformCommand.execute();
			undoRedoManager.push(transformCommand);
		}
		
		
	}
}