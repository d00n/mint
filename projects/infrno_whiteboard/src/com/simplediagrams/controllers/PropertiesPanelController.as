package com.simplediagrams.controllers
{
	
	import com.simplediagrams.commands.ChangeImageStyleCommand;
	import com.simplediagrams.commands.ChangeLineStyleCommand;
	import com.simplediagrams.commands.ChangeSymbolPropertiesCommand;
	import com.simplediagrams.commands.ChangeTextFieldPropertiesCommand;
	import com.simplediagrams.events.ImageStyleEvent;
	import com.simplediagrams.events.LineStyleEvent;
	import com.simplediagrams.events.MultiSelectEvent;
	import com.simplediagrams.events.RemoteSharedObjectEvent;
	import com.simplediagrams.events.SelectionEvent;
	import com.simplediagrams.events.TextPropertyChangeEvent;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.PropertiesPanelModel;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.model.SDTextAreaModel;
	import com.simplediagrams.model.SettingsModel;
	import com.simplediagrams.model.UndoRedoManager;
	import com.simplediagrams.model.mementos.SDSymbolMemento;
	import com.simplediagrams.model.mementos.SDTextAreaMemento;
	import com.simplediagrams.util.Logger;
	
	import flash.events.Event;
	
	import org.swizframework.controller.AbstractController;

	public class PropertiesPanelController extends AbstractController
	{
		
		[Inject]
		public var diagramModel:DiagramModel
		
		[Inject]
		public var settingsModel:SettingsModel
		
		[Inject]
		public var propertiesPanelModel:PropertiesPanelModel
		
		[Inject]
		public var undoRedoManager:UndoRedoManager
		
		public function PropertiesPanelController()
		{
		}
		
		  		
  		/* Watch which objects are selected within ObjectHandles so we know what properties panel to show */
  		    		 		
  		[Mediate(event="SelectionEvent.ADDED_TO_SELECTION")]
  		public function onAddedToSelection(event:SelectionEvent):void
  		{
  			setPropertiesPanel()
  		}
  		
  		
  		[Mediate(event="SelectionEvent.REMOVED_FROM_SELECTION")]
  		public function onRemovedFromSelection(event:SelectionEvent):void
  		{
  			setPropertiesPanel()
  		}
  		
  		[Mediate(event="SelectionEvent.SELECTION_CLEARED")]
  		public function onSelectionCleared(event:SelectionEvent):void
  		{
  			propertiesPanelModel.viewing = PropertiesPanelModel.PROPERTIES_NONE
  		}	
		
		[Mediate(event="MultiSelectEvent.DRAG_MULTI_SELECTION_FINISHED")]
		public function onSelectionChanged(event:MultiSelectEvent):void
		{
			setPropertiesPanel()
		}	
		
		
  		
  		protected function setPropertiesPanel():void
  		{
  			var selectedArr:Array = diagramModel.selectedArray		
  			
  			if (selectedArr.length==0) 
  			{  				
  				propertiesPanelModel.viewing = PropertiesPanelModel.PROPERTIES_NONE  
  				return
  			}
			
			if (selectedArr.length==1)
			{				
				var selectectObj:SDObjectModel = selectedArr[0] as SDObjectModel
				if (selectectObj is SDSymbolModel) 
				{
					propertiesPanelModel.viewing = PropertiesPanelModel.PROPERTIES_SYMBOL
					return
				}
				else if (selectectObj is SDTextAreaModel)
				{
					propertiesPanelModel.viewing = PropertiesPanelModel.PROPERTIES_TEXT
					return					
				}
				else if (selectectObj is SDLineModel)
				{					
					propertiesPanelModel.viewing = PropertiesPanelModel.PROPERTIES_LINE 
					return
				}
				else if (selectectObj is SDImageModel)
				{					
					propertiesPanelModel.viewing = PropertiesPanelModel.PROPERTIES_IMAGE 
					return
				}
			}
  			
  			var allText:Boolean = true
  			var allLines:Boolean = true  
			var allSymbols:Boolean = true  	
			var allImages:Boolean = true  			
  			for each (var obj:Object in selectedArr)
  			{
  				if (obj is SDTextAreaModel == false)
  				{
  					allText = false
  				}
  				if (obj is SDLineModel == false)
  				{
  					allLines = false
  				}
				if (obj is SDSymbolModel == false)
				{
					allSymbols = false
				}
				if (obj is SDImageModel == false)
				{
					allImages = false
				}
  			}	
  				
			
  			if (allText)
  			{
				if (propertiesPanelModel.viewing == PropertiesPanelModel.PROPERTIES_TEXT)
				{
					propertiesPanelModel.dispatchEvent(new Event(PropertiesPanelModel.SELECTION_CHANGED))
				}
				else
				{
					propertiesPanelModel.viewing = PropertiesPanelModel.PROPERTIES_TEXT
				}
  				
  			}
  			else if (allLines)
  			{
				if (propertiesPanelModel.viewing == PropertiesPanelModel.PROPERTIES_LINE)
				{
					propertiesPanelModel.dispatchEvent(new Event(PropertiesPanelModel.SELECTION_CHANGED))
				}
				else
				{
					propertiesPanelModel.viewing = PropertiesPanelModel.PROPERTIES_LINE
				}			
  			}
			else if (allSymbols)
			{
				if (propertiesPanelModel.viewing == PropertiesPanelModel.PROPERTIES_SYMBOL)
				{
					propertiesPanelModel.dispatchEvent(new Event(PropertiesPanelModel.SELECTION_CHANGED))
				}
				else
				{
					propertiesPanelModel.viewing = PropertiesPanelModel.PROPERTIES_SYMBOL
				}						
			}
			else if (allImages)
			{
				if (propertiesPanelModel.viewing == PropertiesPanelModel.PROPERTIES_IMAGE)
				{
					//do nothing, handled within PropertiesPanelImage
				}
				else
				{
					propertiesPanelModel.viewing = PropertiesPanelModel.PROPERTIES_IMAGE
				}	
			}
  			else
  			{
  				propertiesPanelModel.viewing = PropertiesPanelModel.PROPERTIES_NONE  	
  			}
  		}
  		
  		
  		protected function clearPropertiesPanel():void
  		{
  			
  		}
		
		
		
	
  		  		
  		[Mediate(event="TextPropertyChangeEvent.CHANGE_FONT_SIZE")]
  		public function onFontSizeChange(event:TextPropertyChangeEvent):void
  		{
			
			if (event.fontSize==0)
			{
				Logger.error("onFontSizeChange() event.fontSize cannot be 0")
				return
			}
						
  			var selectedArr:Array = diagramModel.selectedArray		
  			
  			for each (var obj:Object in selectedArr)
  			{
  				if (obj is SDTextAreaModel)
  				{
					var sdTextAreaModel:SDTextAreaModel = SDTextAreaModel(obj)
					var oldMemento:SDTextAreaMemento = sdTextAreaModel.getMemento() as SDTextAreaMemento
					sdTextAreaModel.fontSize = event.fontSize
					var cmd:ChangeTextFieldPropertiesCommand = new ChangeTextFieldPropertiesCommand(diagramModel, oldMemento, sdTextAreaModel)
					cmd.execute()
					undoRedoManager.push(cmd)
  				}
				else if (obj is SDSymbolModel)
				{
					var sdSymbolModel:SDSymbolModel = SDSymbolModel(obj)
					var oldSymbolMemento:SDSymbolMemento = sdSymbolModel.getMemento() as SDSymbolMemento
					sdSymbolModel.fontSize = event.fontSize
					var symbolCmd:ChangeSymbolPropertiesCommand = new ChangeSymbolPropertiesCommand(diagramModel, oldSymbolMemento, sdSymbolModel)
					symbolCmd.execute()
					undoRedoManager.push(symbolCmd)
				}
  			}
			
			settingsModel.defaultFontSize = event.fontSize
				
  		}
		
		[Mediate(event="TextPropertyChangeEvent.CHANGE_FONT_FAMILY")]
		public function onFontFamilyChange(event:TextPropertyChangeEvent):void
		{
			var selectedArr:Array = diagramModel.selectedArray		
			
				
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDTextAreaModel)
				{
					var sdTextAreaModel:SDTextAreaModel = SDTextAreaModel(obj)
					var oldMemento:SDTextAreaMemento = sdTextAreaModel.getMemento() as SDTextAreaMemento
					sdTextAreaModel.fontFamily = event.fontFamily
					var cmd:ChangeTextFieldPropertiesCommand = new ChangeTextFieldPropertiesCommand(diagramModel, oldMemento, sdTextAreaModel)
					cmd.execute()
					undoRedoManager.push(cmd)
				}
				else if (obj is SDSymbolModel)
				{
					var sdSymbolModel:SDSymbolModel = SDSymbolModel(obj)
					var oldSymbolMemento:SDSymbolMemento = sdSymbolModel.getMemento() as SDSymbolMemento
					sdSymbolModel.fontFamily = event.fontFamily
					var symbolCmd:ChangeSymbolPropertiesCommand = new ChangeSymbolPropertiesCommand(diagramModel, oldSymbolMemento, sdSymbolModel)
					symbolCmd.execute()
					undoRedoManager.push(symbolCmd)
				}
			}				
			
			settingsModel.defaultFontFamily = event.fontFamily
			
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.changedSDObjectModelArray = diagramModel.selectedArray;			
			dispatcher.dispatchEvent(rsoEvent);
			
		}
		
		[Mediate(event="TextPropertyChangeEvent.CHANGE_FONT_WEIGHT")]
		public function onChangeFontWeight(event:TextPropertyChangeEvent):void
		{
			var selectedArr:Array = diagramModel.selectedArray		
			
				
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDTextAreaModel)
				{
					var sdTextAreaModel:SDTextAreaModel = SDTextAreaModel(obj)
					var oldMemento:SDTextAreaMemento = sdTextAreaModel.getMemento() as SDTextAreaMemento
					sdTextAreaModel.fontWeight = event.fontWeight
					var cmd:ChangeTextFieldPropertiesCommand = new ChangeTextFieldPropertiesCommand(diagramModel, oldMemento, sdTextAreaModel)
					cmd.execute()
					undoRedoManager.push(cmd)
				}
				else if (obj is SDSymbolModel)
				{
					var sdSymbolModel:SDSymbolModel = SDSymbolModel(obj)
					var oldSymbolMemento:SDSymbolMemento = sdSymbolModel.getMemento() as SDSymbolMemento
					sdSymbolModel.fontWeight = event.fontWeight
					var symbolCmd:ChangeSymbolPropertiesCommand = new ChangeSymbolPropertiesCommand(diagramModel, oldSymbolMemento, sdSymbolModel)
					symbolCmd.execute()
					undoRedoManager.push(symbolCmd)
				}
			}			
			
			settingsModel.defaultFontWeight = event.fontWeight
			
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.changedSDObjectModelArray = diagramModel.selectedArray;			
			dispatcher.dispatchEvent(rsoEvent);				
		}
		
		[Mediate(event="TextPropertyChangeEvent.CHANGE_TEXT_ALIGN")]
		public function onTextAlignChange(event:TextPropertyChangeEvent):void
		{
			var selectedArr:Array = diagramModel.selectedArray		
			
				
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDTextAreaModel)
				{
					var sdTextAreaModel:SDTextAreaModel = SDTextAreaModel(obj)
					var oldMemento:SDTextAreaMemento = sdTextAreaModel.getMemento() as SDTextAreaMemento
					sdTextAreaModel.textAlign = event.textAlign
					var cmd:ChangeTextFieldPropertiesCommand = new ChangeTextFieldPropertiesCommand(diagramModel, oldMemento, sdTextAreaModel)
					cmd.execute()
					undoRedoManager.push(cmd)
				}
				else if (obj is SDSymbolModel)
				{
					var sdSymbolModel:SDSymbolModel = SDSymbolModel(obj)
					var oldSymbolMemento:SDSymbolMemento = sdSymbolModel.getMemento() as SDSymbolMemento
					sdSymbolModel.textAlign = event.textAlign
					var symbolCmd:ChangeSymbolPropertiesCommand = new ChangeSymbolPropertiesCommand(diagramModel, oldSymbolMemento, sdSymbolModel)
					symbolCmd.execute()
					undoRedoManager.push(symbolCmd)
				}
			}			
			settingsModel.defaultTextAlign=event.textAlign
			
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.changedSDObjectModelArray = diagramModel.selectedArray;			
			dispatcher.dispatchEvent(rsoEvent);				
		}
		
		[Mediate(event="TextPropertyChangeEvent.CHANGE_TEXT_POSITION")]
		public function onTextPositionChange(event:TextPropertyChangeEvent):void
		{
			var selectedArr:Array = diagramModel.selectedArray		
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDSymbolModel)
				{
					var sdSymbolModel:SDSymbolModel = SDSymbolModel(obj)
					var oldMemento:SDSymbolMemento = sdSymbolModel.getMemento() as SDSymbolMemento
					sdSymbolModel.textPosition = event.textPosition
					var symbolCmd:ChangeSymbolPropertiesCommand = new ChangeSymbolPropertiesCommand(diagramModel, oldMemento, sdSymbolModel)
					symbolCmd.execute()
					undoRedoManager.push(symbolCmd)
				}
			}
			
			settingsModel.defaultTextPosition=event.textPosition
			
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.changedSDObjectModelArray = diagramModel.selectedArray;			
			dispatcher.dispatchEvent(rsoEvent);				
		}
		
		
  		
  		[Mediate(event="ImageStyleEvent.IMAGE_STYLE_CHANGE")]
  		public function onImageStyleChange(event:ImageStyleEvent):void
  		{  			
			Logger.debug("onImageStyleChange() setting imageStyle to: " + event.imageStyle,this)
			var cmd:ChangeImageStyleCommand = new ChangeImageStyleCommand(diagramModel)	
			cmd.newImageStyle = event.imageStyle
			cmd.execute()
			undoRedoManager.push(cmd)	  			
			settingsModel.defaultImageStyle = event.imageStyle  		
  		}
		
		
		[Mediate(event="LineStyleEvent.LINE_START_STYLE_CHANGE")]
		public function onLineStartStyleChange(event:LineStyleEvent):void
		{  			
			Logger.debug("onLineStartStyleChange() setting startLineStyle to: " + event.lineStyle,this)
			var cmd:ChangeLineStyleCommand = new ChangeLineStyleCommand(diagramModel)	
			cmd.startLineStyle = event.lineStyle
			cmd.execute()
			undoRedoManager.push(cmd)	  			
			settingsModel.defaultStartLineStyle = event.lineStyle  		
		}
  		
  		[Mediate(event="LineStyleEvent.LINE_END_STYLE_CHANGE")]
  		public function onLineEndStyleChange(event:LineStyleEvent):void
  		{			
			var cmd:ChangeLineStyleCommand = new ChangeLineStyleCommand(diagramModel)
			cmd.endLineStyle = event.lineStyle
			cmd.execute()
			undoRedoManager.push(cmd)	
  			  			
			settingsModel.defaultEndLineStyle = event.lineStyle  		
  		}
  		
  		
  		[Mediate(event="LineStyleEvent.LINE_WEIGHT_CHANGE")]
  		public function onLineWeightChange(event:LineStyleEvent):void
  		{
			var cmd:ChangeLineStyleCommand = new ChangeLineStyleCommand(diagramModel)	
			cmd.lineWeight = event.lineWeight
			cmd.execute()
			undoRedoManager.push(cmd)	
  		
			settingsModel.defaultLineWeight = event.lineWeight
  		}
  
		
	}
}