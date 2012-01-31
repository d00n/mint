package com.simplediagrams.controllers
{
	import com.simplediagrams.events.ToolPanelEvent;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.ToolsManager;
	import com.simplediagrams.model.tools.Tools;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.TextInput;
	import mx.core.FlexGlobals;
	
	import org.swizframework.controller.AbstractController;
	
	import spark.components.TextArea;
	
	public class KeyboardController extends AbstractController
	{
		public function KeyboardController()
		{
			FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown)
		}
		
		
		public function onKeyDown(event:KeyboardEvent):void
		{				
			if (event.target is TextArea || event.target is TextInput) return
				
			if ((ApplicationModel.isMac && event.commandKey) || (ApplicationModel.isWin && event.controlKey) || (ApplicationModel.isLinux && event.controlKey))
			{ 
				
				if (event.keyCode==Keyboard.P ) 
				{
					evt = new ToolPanelEvent(ToolPanelEvent.TOOL_SELECTED, true)
					evt.toolTypeSelected = Tools.POINTER_TOOL
					dispatcher.dispatchEvent(evt)
				}					
				else if (event.keyCode==Keyboard.B ) 
				{
					evt = new ToolPanelEvent(ToolPanelEvent.TOOL_SELECTED, true)
					evt.toolTypeSelected = Tools.PENCIL_TOOL
					dispatcher.dispatchEvent(evt)
				}					
				else if (event.keyCode==Keyboard.L) 
				{
					evt = new ToolPanelEvent(ToolPanelEvent.TOOL_SELECTED, true)
					evt.toolTypeSelected = Tools.LINE_TOOL
					dispatcher.dispatchEvent(evt)
				}
				else if (event.keyCode==Keyboard.T) 
				{
					var evt:ToolPanelEvent = new ToolPanelEvent(ToolPanelEvent.TOOL_SELECTED, true)
					evt.toolTypeSelected = Tools.TEXT_TOOL
					dispatcher.dispatchEvent(evt)
				}
			} 
			
		}
		
		
		
		
	}
}