package com.simplediagrams.controllers
{
	
	import com.simplediagrams.commands.CutCommand;
	import com.simplediagrams.commands.PasteCommand;
	import com.simplediagrams.events.*;
	import com.simplediagrams.model.*;
	import com.simplediagrams.util.Logger;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardTransferMode;
	import flash.events.Event;
	
	import mx.core.FlexGlobals;
	import mx.core.UITextField;
	
	import org.swizframework.controller.AbstractController;
	
	import spark.components.TextArea;

	public class ClipboardController extends AbstractController
	{
		
		[Inject]
		public var diagramModel:DiagramModel;
		
		[Inject]
		public var libraryManager:LibraryManager;
		
		[Inject]
		public var undoRedoManager:UndoRedoManager;

		[Autowire(bean="remoteSharedObjectController")]
		public var remoteSharedObjectController:RemoteSharedObjectController
			
		
		private var _copyArr:Array = []
		
		private var _startCopyX:Number
		private var _startCopyY:Number
		
		public function ClipboardController()
		{
			
			//FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown)
			FlexGlobals.topLevelApplication.addEventListener(Event.CUT, onCutEvent)
			FlexGlobals.topLevelApplication.addEventListener(Event.COPY, onCopy)
			FlexGlobals.topLevelApplication.addEventListener(Event.PASTE, onPaste)
								
		}
		
		
//		[Mediate(event="CutEvent.CUT")]
		public function onCutEvent(event:Event):void
		{
			//make sure user isn't working in TextArea
			if (event.target == TextArea) return
			
			if (diagramModel.selectedArray.length>=1)
			{
				var cmd:CutCommand = new CutCommand(diagramModel)
				cmd.execute()
				undoRedoManager.push(cmd)
					
				//remoteSharedObjectController.dispatchUpdate_CutEvent(cmd);	
				var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.CUT);	
				rsoEvent.cutCommand = cmd;
				dispatcher.dispatchEvent(rsoEvent);
			}
			else
			{
				Logger.warn("No models selected.", this)
			}
			_startCopyX = FlexGlobals.topLevelApplication.stage.mouseX
			_startCopyY = FlexGlobals.topLevelApplication.stage.mouseY			
		}	
		
		
//		[Mediate(event="CopyEvent.COPY")]
		public function onCopy(event:Event):void
		{		
			//make sure user isn't working in TextArea
			if (event.target == TextArea) return
			
			if (diagramModel.selectedArray.length>=1)
			{
				//make clones and put them on the clipboard
				var clonesArr:Array = []
				for each (var sdObjectModel:SDObjectModel in diagramModel.selectedArray)
				{
					var clone:SDObjectModel = sdObjectModel.clone()
					clonesArr.push(clone) 
				}
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
		public function onPaste(event:Event):void
		{
			
			//make sure user isn't working in TextArea
			if (event.target == UITextField) return
				
			
			var sdObjects:Object =  Clipboard.generalClipboard.getData("com.simplediagrams.sdObjects", ClipboardTransferMode.ORIGINAL_ONLY)
			var clonesArr:Array = []
			
			if (sdObjects is Array == false)
			{
				Logger.warn("sdObjects was supposed to be an array, but instead it's : " + sdObjects, this)
				return
			}
			
			//we have to clone again here to make sure each pasted sdObjectModel is unique
			//each time objects pasted, they should have a blank sdID so they're unique when added by DiagramManager
			
			for each (var sdObjectModel:SDObjectModel in sdObjects)
			{
				var clone:SDObjectModel = sdObjectModel.clone()
				clone.sdID = ""
				clonesArr.push(clone) 
			}
							
			diagramModel.clearSelection()
				
			if (clonesArr.length>0)
			{
				var cmd:PasteCommand = new PasteCommand(diagramModel, libraryManager)
				cmd.pastedObjectsArr = clonesArr as Array
				cmd.execute()
				undoRedoManager.push(cmd)				
			}
			else
			{
				Logger.warn("the pasted clones array was empty!", this)
			}
			
		}		
	
				
	}
}