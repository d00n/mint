package com.simplediagrams.controllers
{
	import com.simplediagrams.events.RemoteSharedObjectEvent;
	import com.simplediagrams.commands.ChangeCommand;
	import com.simplediagrams.commands.CompositeCommand;
	import com.simplediagrams.commands.IUndoRedoCommand;
	import com.simplediagrams.events.ImageStyleEvent;
	import com.simplediagrams.events.LineStyleEvent;
	import com.simplediagrams.events.MultiSelectEvent;
	import com.simplediagrams.events.PencilStyleEvent;
	import com.simplediagrams.events.SelectionEvent;
	import com.simplediagrams.events.TextPropertyChangeEvent;
	import com.simplediagrams.model.CopyUtil;
	import com.simplediagrams.model.DiagramManager;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.PropertiesPanelModel;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDPencilDrawingModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.model.SDTextAreaModel;
	import com.simplediagrams.model.SettingsModel;
	import com.simplediagrams.model.UndoRedoManager;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.SDComponents.SDSymbol;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	
	import org.swizframework.controller.AbstractController;

	public class PropertiesPanelController extends AbstractController
	{
		
		[Inject]
		public var diagramManager:DiagramManager
		
		[Inject]
		public var settingsModel:SettingsModel
		
		[Inject]
		public var undoRedoManager:UndoRedoManager
		
		public function PropertiesPanelController()
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
						
			var selectedArr:IList = diagramManager.diagramModel.selectedObjects;	
			var commands:Array = [];
  			for each (var obj:Object in selectedArr)
  			{
  				if (obj is SDTextAreaModel)
  				{
					var sdTextAreaModel:SDTextAreaModel = SDTextAreaModel(obj);
					var newStateText:SDTextAreaModel =  CopyUtil.clone(sdTextAreaModel) as SDTextAreaModel;
					newStateText.fontSize = event.fontSize;
					var cmd:ChangeCommand = new ChangeCommand(sdTextAreaModel, newStateText);
					commands.push(cmd);
  				}
				else if (obj is SDSymbolModel)
				{
					var sdSymbolModel:SDSymbolModel = SDSymbolModel(obj);
					var newState:SDSymbolModel =  CopyUtil.clone(sdSymbolModel) as SDSymbolModel;
					newState.fontSize = event.fontSize;
					var symbolCmd:ChangeCommand = new ChangeCommand(sdSymbolModel, newState);
					commands.push(symbolCmd);
				}
  			}
			execCommands(commands);

			
			settingsModel.defaultFontSize = event.fontSize
			
				
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.sdObjects = diagramManager.diagramModel.selectedObjects;			
			dispatcher.dispatchEvent(rsoEvent);				
		}
		
		[Mediate(event="TextPropertyChangeEvent.CHANGE_FONT_FAMILY")]
		public function onFontFamilyChange(event:TextPropertyChangeEvent):void
		{
			var selectedArr:IList = diagramManager.diagramModel.selectedObjects;	
			var commands:Array = [];
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDTextAreaModel)
				{
					var sdTextAreaModel:SDTextAreaModel = SDTextAreaModel(obj);
					var newStateText:SDTextAreaModel =  CopyUtil.clone(sdTextAreaModel) as SDTextAreaModel;
					newStateText.fontFamily = event.fontFamily;
					var cmd:ChangeCommand = new ChangeCommand(sdTextAreaModel, newStateText);
					commands.push(cmd);
				}
				else if (obj is SDSymbolModel)
				{
					var sdSymbolModel:SDSymbolModel = SDSymbolModel(obj);
					var newState:SDSymbolModel =  CopyUtil.clone(sdSymbolModel) as SDSymbolModel;
					newState.fontFamily = event.fontFamily;
					var symbolCmd:ChangeCommand = new ChangeCommand(sdSymbolModel, newState);
					commands.push(symbolCmd);
				}
			}
			execCommands(commands);

			settingsModel.defaultFontFamily = event.fontFamily
				
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.sdObjects = diagramManager.diagramModel.selectedObjects;			
			dispatcher.dispatchEvent(rsoEvent);			
		}
		
		[Mediate(event="TextPropertyChangeEvent.CHANGE_FONT_WEIGHT")]
		public function onChangeFontWeight(event:TextPropertyChangeEvent):void
		{
			var selectedArr:IList = diagramManager.diagramModel.selectedObjects;	
			var commands:Array = [];
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDTextAreaModel)
				{
					var sdTextAreaModel:SDTextAreaModel = SDTextAreaModel(obj);
					var newStateText:SDTextAreaModel =  CopyUtil.clone(sdTextAreaModel) as SDTextAreaModel;
					newStateText.fontWeight = event.fontWeight;
					var cmd:ChangeCommand = new ChangeCommand(sdTextAreaModel, newStateText);
					commands.push(cmd);
				}
				else if (obj is SDSymbolModel)
				{
					var sdSymbolModel:SDSymbolModel = SDSymbolModel(obj);
					var newState:SDSymbolModel =  CopyUtil.clone(sdSymbolModel) as SDSymbolModel;
					newState.fontWeight = event.fontWeight;
					var symbolCmd:ChangeCommand = new ChangeCommand(sdSymbolModel, newState);
					commands.push(symbolCmd);
				}
			}
			execCommands(commands);
			
			settingsModel.defaultFontWeight = event.fontWeight
				
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.sdObjects = diagramManager.diagramModel.selectedObjects;			
			dispatcher.dispatchEvent(rsoEvent);			
		}
		
		[Mediate(event="TextPropertyChangeEvent.CHANGE_TEXT_ALIGN")]
		public function onTextAlignChange(event:TextPropertyChangeEvent):void
		{
			var selectedArr:IList = diagramManager.diagramModel.selectedObjects;	
			var commands:Array = [];
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDTextAreaModel)
				{
					var sdTextAreaModel:SDTextAreaModel = SDTextAreaModel(obj);
					var newStateText:SDTextAreaModel =  CopyUtil.clone(sdTextAreaModel) as SDTextAreaModel;
					newStateText.textAlign = event.textAlign;
					var cmd:ChangeCommand = new ChangeCommand(sdTextAreaModel, newStateText);
					commands.push(cmd);
				}
				else if (obj is SDSymbolModel)
				{
					var sdSymbolModel:SDSymbolModel = SDSymbolModel(obj);
					var newState:SDSymbolModel =  CopyUtil.clone(sdSymbolModel) as SDSymbolModel;
					newState.textAlign = event.textAlign;
					var symbolCmd:ChangeCommand = new ChangeCommand(sdSymbolModel, newState);
					commands.push(symbolCmd);
				}
			}
			execCommands(commands);		
			settingsModel.defaultTextAlign=event.textAlign
				
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.sdObjects = diagramManager.diagramModel.selectedObjects;			
			dispatcher.dispatchEvent(rsoEvent);		
		}
		
		[Mediate(event="TextPropertyChangeEvent.CHANGE_TEXT_POSITION")]
		public function onTextPositionChange(event:TextPropertyChangeEvent):void
		{
			var selectedArr:IList = diagramManager.diagramModel.selectedObjects;	
			var commands:Array = [];
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDSymbolModel)
				{
					var sdSymbolModel:SDSymbolModel = SDSymbolModel(obj);
					var newState:SDSymbolModel =  CopyUtil.clone(sdSymbolModel) as SDSymbolModel;
					newState.textPosition = event.textPosition;
					var symbolCmd:ChangeCommand = new ChangeCommand(sdSymbolModel, newState);
					commands.push(symbolCmd);
				}
			}
			execCommands(commands);
			settingsModel.defaultTextPosition=event.textPosition;		
      
			
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.sdObjects = diagramManager.diagramModel.selectedObjects;			
			dispatcher.dispatchEvent(rsoEvent);	
		}
		
		
		
		[Mediate(event="TextPropertyChangeEvent.CHANGE_BACKGROUND_COLOR")]
		public function onChangeBackgroundColor(event:TextPropertyChangeEvent):void
		{
			var selectedArr:IList = diagramManager.diagramModel.selectedObjects;	
			var commands:Array = [];
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDTextAreaModel)
				{
					var sdTextAreaModel:SDTextAreaModel = SDTextAreaModel(obj);
					var newState:SDTextAreaModel =  CopyUtil.clone(sdTextAreaModel) as SDTextAreaModel;
					newState.backgroundColor = event.backgroundColor;
					var symbolCmd:ChangeCommand = new ChangeCommand(sdTextAreaModel, newState);
					commands.push(symbolCmd);
				}
			}
			execCommands(commands);			
			
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.sdObjects = diagramManager.diagramModel.selectedObjects;			
			dispatcher.dispatchEvent(rsoEvent);			}
		
		
		
		
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
  		
 		[Mediate(event="ImageStyleEvent.IMAGE_STYLE_CHANGE")]
 		public function onImageStyleChange(event:ImageStyleEvent):void
 		{  			
			Logger.debug("onImageStyleChange() setting imageStyle to: " + event.imageStyle,this);
			var selectedArr:IList = diagramManager.diagramModel.selectedObjects;	
			var commands:Array = [];
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDImageModel)
				{
					var sdImageModel:SDImageModel = SDImageModel(obj);
					var newState:SDImageModel =  CopyUtil.clone(sdImageModel) as SDImageModel;
					newState.styleName = event.imageStyle;
					var symbolCmd:ChangeCommand = new ChangeCommand(sdImageModel, newState);
					commands.push(symbolCmd);
				}
			}
			execCommands(commands);
			settingsModel.defaultImageStyle = event.imageStyle; 		
				
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.sdObjects = diagramManager.diagramModel.selectedObjects;			
			dispatcher.dispatchEvent(rsoEvent);							
		}
		
		
		[Mediate(event="LineStyleEvent.LINE_STYLE_CHANGE")]
		public function onLineStyleChange(event:LineStyleEvent):void
		{  			
			var selectedArr:IList = diagramManager.diagramModel.selectedObjects;	
			var commands:Array = [];
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDLineModel)
				{
					var sdLineModel:SDLineModel = SDLineModel(obj);
					var newState:SDLineModel =  CopyUtil.clone(sdLineModel) as SDLineModel;
					newState.lineStyle = event.lineStyle;
					var symbolCmd:ChangeCommand = new ChangeCommand(sdLineModel, newState);
					commands.push(symbolCmd);
				}
			}
			execCommands(commands);			
			settingsModel.defaultLineStyle = event.lineStyle  
			
				
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.sdObjects = diagramManager.diagramModel.selectedObjects;			
			dispatcher.dispatchEvent(rsoEvent);							
		}
		
		
		[Mediate(event="LineStyleEvent.LINE_START_STYLE_CHANGE")]
		public function onLineStartStyleChange(event:LineStyleEvent):void
		{  			
			var selectedArr:IList = diagramManager.diagramModel.selectedObjects;	
			var commands:Array = [];
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDLineModel)
				{
					var sdLineModel:SDLineModel = SDLineModel(obj);
					var newState:SDLineModel =  CopyUtil.clone(sdLineModel) as SDLineModel;
					newState.startLineStyle = event.lineStyle;
					var symbolCmd:ChangeCommand = new ChangeCommand(sdLineModel, newState);
					commands.push(symbolCmd);
				}
			}
			execCommands(commands);
		  			
			settingsModel.defaultStartLineStyle = event.lineStyle  		
				
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.sdObjects = diagramManager.diagramModel.selectedObjects;			
			dispatcher.dispatchEvent(rsoEvent);				
		}
  		
  		[Mediate(event="LineStyleEvent.LINE_END_STYLE_CHANGE")]
  		public function onLineEndStyleChange(event:LineStyleEvent):void
  		{		
			var selectedArr:IList = diagramManager.diagramModel.selectedObjects;	
			var commands:Array = [];
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDLineModel)
				{
					var sdLineModel:SDLineModel = SDLineModel(obj);
					var newStateLine:SDLineModel =  CopyUtil.clone(sdLineModel) as SDLineModel;
					newStateLine.endLineStyle = event.lineStyle;
					var symbolCmd:ChangeCommand = new ChangeCommand(sdLineModel, newStateLine);
					commands.push(symbolCmd);
				}
			}
			execCommands(commands);	
  			  			
			settingsModel.defaultEndLineStyle = event.lineStyle  		
				
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.sdObjects = diagramManager.diagramModel.selectedObjects;			
			dispatcher.dispatchEvent(rsoEvent);				
		}
		
		
		[Mediate(event="LineStyleEvent.LINE_WEIGHT_CHANGE")]
		[Mediate(event="LineStyleEvent.SYMBOL_LINE_WEIGHT_CHANGE")]
  	public function onLineWeightChange(event:LineStyleEvent):void
  	{
			var selectedArr:IList = diagramManager.diagramModel.selectedObjects;	
			var commands:Array = [];
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDLineModel)
				{
					var sdLineModel:SDLineModel = SDLineModel(obj);
					var newStateLine:SDLineModel =  CopyUtil.clone(sdLineModel) as SDLineModel;
					newStateLine.lineWeight = event.lineWeight;
					var symbolCmd:ChangeCommand = new ChangeCommand(sdLineModel, newStateLine);
					commands.push(symbolCmd);
				}
				else if (obj is SDSymbolModel)
				{
					var sdSymbolModel:SDSymbolModel = SDSymbolModel(obj);
					var newState:SDSymbolModel =  CopyUtil.clone(sdSymbolModel) as SDSymbolModel;
					newState.lineWeight = event.lineWeight;
					symbolCmd = new ChangeCommand(sdSymbolModel, newState);
					commands.push(symbolCmd);
				}
			}
			execCommands(commands);	
  		
			if (event.type==LineStyleEvent.SYMBOL_LINE_WEIGHT_CHANGE)
			{
				settingsModel.defaultSymbolLineWeight = event.lineWeight
			}
			else
			{
				settingsModel.defaultLineWeight = event.lineWeight
			}

			
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.sdObjects = diagramManager.diagramModel.selectedObjects;			
			dispatcher.dispatchEvent(rsoEvent);			
		}
		
		[Mediate(event="PencilStyleEvent.PENCIL_LINE_WEIGHT_CHANGE")]
		public function onPencilLineWeightChange(event:PencilStyleEvent):void
		{
			var selectedArr:IList = diagramManager.diagramModel.selectedObjects;	
			var commands:Array = [];
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDPencilDrawingModel)
				{
					var sdPencilModel:SDPencilDrawingModel = SDPencilDrawingModel(obj);
					var newStateLine:SDPencilDrawingModel =  CopyUtil.clone(sdPencilModel) as SDPencilDrawingModel;
					newStateLine.lineWeight = event.lineWeight;
					var symbolCmd:ChangeCommand = new ChangeCommand(sdPencilModel, newStateLine);
					commands.push(symbolCmd);
				}
			}
			execCommands(commands);				
			settingsModel.defaultPencilLineWeight = event.lineWeight			
			
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.sdObjects = diagramManager.diagramModel.selectedObjects;			
			dispatcher.dispatchEvent(rsoEvent);			
		}
	}
}