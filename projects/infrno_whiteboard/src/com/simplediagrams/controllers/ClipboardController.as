package com.simplediagrams.controllers
{
	
	import com.simplediagrams.commands.AddCommand;
	import com.simplediagrams.commands.CompositeCommand;
	import com.simplediagrams.commands.IUndoRedoCommand;
	import com.simplediagrams.commands.RemoveCommand;
	import com.simplediagrams.events.*;
	import com.simplediagrams.model.*;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.SDComponents.SDTextArea;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardTransferMode;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.core.UITextField;
	import mx.utils.UIDUtil;
	
	import org.swizframework.controller.AbstractController;
	
	import spark.components.TextArea;

	public class ClipboardController extends AbstractController
	{
		
		[Inject]
		public var diagramManager:DiagramManager;
		
		[Inject]
		public var libraryManager:LibraryManager;
		
		[Inject]
		public var undoRedoManager:UndoRedoManager;
		
		[Inject]
		public var textEditorModel:TextEditorModel;
		
		private var _copyArr:Array = []
		
		private var _startCopyX:Number
		private var _startCopyY:Number
		
		public function ClipboardController()
		{									
		}
		
		public var pasteOffsetX:Number = 30;
		public var pasteOffsetY:Number = 30;
		
		public var currentPasteOffsetX:Number = pasteOffsetX;
		public var currentPasteOffsetY:Number = pasteOffsetY;
		
		[Mediate(event="CutEvent.CUT")]
		public function onCutEvent(event:CutEvent):void
		{			
			if (textEditorModel.showEditField)
			{
				//don't do anything...this is a text edit
				return
			}
			
			if (diagramManager.diagramModel.selectedObjects.length>=1)
			{
				var clonesArr:Array = createSmartCopy(diagramManager.diagramModel.selectedObjects.source);
				currentPasteOffsetX = pasteOffsetX;
				currentPasteOffsetY = pasteOffsetY;
				Clipboard.generalClipboard.clear(); 				
				Clipboard.generalClipboard.setData("com.simplediagrams.sdObjects", clonesArr, false)
				var commands:Array = [];
				for each(var item:SDObjectModel in diagramManager.diagramModel.selectedObjects)
				{
					var removeCommand:RemoveCommand = new RemoveCommand(diagramManager.diagramModel, item);
					commands.push(removeCommand);
				}
				execCommands(commands);
			}
			else
			{
				Logger.warn("No models selected.", this)
			}
			_startCopyX = FlexGlobals.topLevelApplication.stage.mouseX
			_startCopyY = FlexGlobals.topLevelApplication.stage.mouseY			
		}	
		
		private function createSmartCopy(objects:Array):Array
		{
			var clonesArr:Array = [];
			var sdObjectModel:SDObjectModel;
			for each (sdObjectModel in objects)
			{
				var clone:SDObjectModel = CopyUtil.clone(sdObjectModel) as SDObjectModel;
				clone.id = -1;
				clonesArr.push(clone);
			}
			for(var i:int = 0;i < objects.length;i++)
			{
				sdObjectModel = objects[i];
				clone = clonesArr[i];
				if(sdObjectModel is SDLineModel)
				{
					var sdLine:SDLineModel = sdObjectModel as SDLineModel;
					var lineClone:SDLineModel = clone as SDLineModel;
					var index:int;
					if(sdLine.fromObject != null)
					{
						index = objects.indexOf(sdLine.fromObject) ;
						if(index != -1)
						{
							var fromClone:SDObjectModel = clonesArr[index];
							lineClone.fromPoint = fromClone.getConnectionPoint(sdLine.fromPoint.id);
							lineClone.fromObject = fromClone;
						}
						else
						{
							lineClone.fromPoint = null;
							lineClone.fromObject = null;
						}
					}
					if(sdLine.toObject != null)
					{
						index = objects.indexOf(sdLine.toObject) ;
						if(index != -1)
						{
							var toClone:SDObjectModel = clonesArr[index];
							lineClone.toPoint = toClone.getConnectionPoint(sdLine.toPoint.id);
							lineClone.toObject = toClone;
						}
						else
						{
							lineClone.toPoint = null;
							lineClone.toObject = null;
						}
					}
				}
			}
			return clonesArr;
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
		
		
		[Mediate(event="CopyEvent.COPY")]
		public function onCopy(event:CopyEvent):void
		{			
			if (textEditorModel.showEditField)
			{
				//don't do anything...this is a text edit
				return
			}
			
			if (diagramManager.diagramModel.selectedObjects.length>=1)
			{					
				currentPasteOffsetX = pasteOffsetX;
				currentPasteOffsetY = pasteOffsetY;
				//make clones and put them on the clipboard
				var clonesArr:Array = createSmartCopy(diagramManager.diagramModel.selectedObjects.source);
				Clipboard.generalClipboard.clear(); 				
				Clipboard.generalClipboard.setData("com.simplediagrams.sdObjects", clonesArr, false)					
			}
			else
			{
				Logger.warn("No models selected.", this)
			}
			_startCopyX = FlexGlobals.topLevelApplication.stage.mouseX
			_startCopyY = FlexGlobals.topLevelApplication.stage.mouseY
			
		}	
		
//		[Mediate(event="PasteEvent.PASTE")]
		[Mediate(event="Event.PASTE")]
		public function onPaste(event:Event):void
		{
		
			if (textEditorModel.showEditField)
			{
				//don't do anything...this is a text edit
				return
			}
			
			var sdObjects:Object =  Clipboard.generalClipboard.getData("com.simplediagrams.sdObjects", ClipboardTransferMode.ORIGINAL_ONLY)
			
			if (sdObjects is Array == false)
			{
				Logger.warn("sdObjects was supposed to be an array, but instead it's : " + sdObjects, this)
				return
			}
			
			var clonesArr:Array = createSmartCopy(sdObjects as Array);
			for each(var sdObjectModel:SDObjectModel in clonesArr)
			{
				var transform:TransformData = sdObjectModel.getTransform();
				var newTransform:TransformData = transform.clone();
				newTransform.x += currentPasteOffsetX;
				newTransform.y += currentPasteOffsetY;
				sdObjectModel.applyTransform(newTransform, transform, sdObjectModel);
			}
			currentPasteOffsetX += pasteOffsetX;
			currentPasteOffsetY += pasteOffsetY;
			//we have to clone again here to make sure each pasted sdObjectModel is unique
			//each time objects pasted, they should have a blank sdID so they're unique when added by DiagramManager
			var commands:Array = [];
			for each (sdObjectModel in clonesArr)
			{
				commands.push(new AddCommand(diagramManager.diagramModel, sdObjectModel));
			}
							
				
			if (clonesArr.length>0)
			{
				execCommands(commands);
			}
			else
			{
				Logger.warn("the pasted clones array was empty!", this)
			}
			diagramManager.diagramModel.select(clonesArr);
			
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.LIBRARY_ITEM_ADDED);	
			for each (sdObjectModel in clonesArr)
    		rsoEvent.sdObjects.addItem(sdObjectModel);
			dispatcher.dispatchEvent(rsoEvent);			

		}		
	
				
	}
}