package com.simplediagrams.controllers
{
	
	import com.simplediagrams.events.ChangeDepthEvent;
	import com.simplediagrams.events.CloseDiagramEvent;
	import com.simplediagrams.events.DrawingBoardEvent;
	import com.simplediagrams.events.ToolPanelEvent;
	import com.simplediagrams.model.*;
	import com.simplediagrams.model.tools.ToolBase;
	import com.simplediagrams.model.tools.Tools;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.SDComponents.SDBase;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.CursorManager;
	
	import org.swizframework.events.BeanEvent;
	

	public class ToolPanelController
	{
		[Dispatcher]
		public var dispatcher:IEventDispatcher;
		
		[Inject]
		public var diagramManager:DiagramManager;
		
		[Inject]
		public var toolsManager:ToolsManager;
		
		[Bindable]
		[Embed(source="assets/img/icons/zoom_out.png")]
		public var ZoomOutIcon:Class
		
		[Bindable]
		[Embed(source="assets/img/icons/zoom_in.png")]
		public var ZoomInIcon:Class
		
		[Bindable]
		[Embed(source="assets/img/icons/text_cursor.png")]
		public var TextCursorIcon:Class
		
		
		[Bindable]
		[Embed(source="assets/img/icons/line_cursor.png")]
		public var LineToolIcon:Class
		
		
		[Bindable]
		[Embed(source="assets/img/icons/pencil.png")]
		public var PencilIcon:Class
		
		protected var _suspendedToolType:String = Tools.POINTER_TOOL;
		
		public function ToolPanelController()
		{	
			FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown)
			FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_UP, onKeyUp)
		}
		
		[PostConstruct]
		public function onPostConstruct():void	
		{
			toolsManager.addEventListener(Event.CHANGE, onToolChange);
			onToolChange(null);
		}
		
		private var _oldTool:ToolBase;
		
		private function onToolChange(event:Event):void
		{
			if(_oldTool)
				dispatcher.dispatchEvent(new BeanEvent(BeanEvent.TEAR_DOWN_BEAN, _oldTool,"currentTool"));
			_oldTool = toolsManager.selectedToolImpl;
			if(_oldTool)
				dispatcher.dispatchEvent(new BeanEvent(BeanEvent.SET_UP_BEAN, _oldTool,"currentTool"));
		}
		
		protected function onKeyDown(event:KeyboardEvent):void
		{
			//If using zoom control, shift toggles between + and -
			if (toolsManager.selectedTool==Tools.ZOOM_TOOL)
			{
				if (event.keyCode == Keyboard.SHIFT)
				{
					Logger.debug("setting cursor to out...", this)
					CursorManager.removeAllCursors()
					CursorManager.setCursor(ZoomOutIcon)
				}
			}
		}
		
		protected function onKeyUp(event:KeyboardEvent):void
		{
			if (toolsManager.selectedTool==Tools.ZOOM_TOOL)
			{
				Logger.debug("setting cursor to in...", this)
				CursorManager.removeAllCursors()
				CursorManager.setCursor(ZoomInIcon)
			}
		}
		
		
		[Mediate(event="CloseDiagramEvent.DIAGRAM_CLOSED")]
		public function onDiagramClosed(event:CloseDiagramEvent):void
		{			
			CursorManager.removeAllCursors()
		}
		
		
		[Mediate(event="ToolPanelEvent.TOOL_SELECTED")]
		public function setTool(event:ToolPanelEvent):void
		{			
			CursorManager.removeAllCursors()
			
			//we may need to do some cleanup later on, or some other processing here in the time
			//between a tool being selected and the models and views learning about it.
			
			changeToolAction(event.toolTypeSelected)
					
		}
		
		
		[Mediate(event="PositionEvent.MOVE_BACKWARD")]
		[Mediate(event="PositionEvent.MOVE_FORWARD")]
		public function changePosition(event:PositionEvent):void
		{			
			//get current selection
			var selectedArr:Array = diagramModel.selectedArray;
			
			if (selectedArr.length==0)
			{
				Alert.show("No object selected.")
				return
			}
			
			if (selectedArr.length>1)
			{
				Alert.show("You must select exactly one object.")
				return
			}
						
			var sdObjectModel:SDObjectModel = selectedArr[0]
			var eventChangeDepth:ChangeDepthEvent
			switch(event.type)
			{
				case PositionEvent.MOVE_BACKWARD:
					eventChangeDepth = new ChangeDepthEvent(ChangeDepthEvent.MOVE_BACKWARD);
					eventChangeDepth.sdID = sdObjectModel.sdID;
					dispatcher.dispatchEvent(eventChangeDepth);
					break
				
				case PositionEvent.MOVE_FORWARD:
					eventChangeDepth = new ChangeDepthEvent(ChangeDepthEvent.MOVE_FORWARD);
					eventChangeDepth.sdID = sdObjectModel.sdID;
					dispatcher.dispatchEvent(eventChangeDepth);
					break
				
			}
		}
		
		[Mediate(event="ToolPanelEvent.SUSPEND_CURRENT_TOOL")]
		public function suspendCurrentTool(event:ToolPanelEvent):void
		{
			
			if (toolsManager.selectedTool == Tools.POINTER_TOOL) return
			CursorManager.removeAllCursors()
			this._suspendedToolType = toolsManager.selectedTool;
			changeToolAction(Tools.POINTER_TOOL)
		}
		
		[Mediate(event="DrawingBoardEvent.MOUSE_OVER")]
		public function resumeCurrentTool(event:DrawingBoardEvent):void
		{			
			if (this._suspendedToolType =="") return
			changeToolAction(this._suspendedToolType)
			this._suspendedToolType  = ""
		}
		
		
		protected function changeToolAction(toolType:String):void
		{
			switch (toolType)
			{
				case Tools.POINTER_TOOL:
					toolsManager.selectedTool = Tools.POINTER_TOOL
					break
				
				case Tools.PENCIL_TOOL:
					toolsManager.selectedTool = Tools.PENCIL_TOOL
					CursorManager.setCursor(PencilIcon,2, 0, -15)	
					diagramManager.diagramModel.selectedObjects.removeAll();	
					break
				
				case Tools.TEXT_TOOL:
					toolsManager.selectedTool = Tools.TEXT_TOOL
					CursorManager.setCursor(TextCursorIcon, 2, 0, 0)
					diagramManager.diagramModel.selectedObjects.removeAll();	
					break
				
				case Tools.LINE_TOOL:
					toolsManager.selectedTool = Tools.LINE_TOOL	
					CursorManager.setCursor(LineToolIcon, 2, -8, -8)
					diagramManager.diagramModel.selectedObjects.removeAll();	
					break
				
				case Tools.ZOOM_TOOL:
					toolsManager.selectedTool = Tools.ZOOM_TOOL	
					CursorManager.setCursor(ZoomInIcon)
					break
				
				default:
					Logger.warn("changeToolStatus() unrecognized tool type: " + toolType, this)
			}
		}
		
	}
}