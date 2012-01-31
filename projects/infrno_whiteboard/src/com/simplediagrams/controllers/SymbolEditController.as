package com.simplediagrams.controllers
{
	
	import com.simplediagrams.events.EditSDComponentTextEvent;
	import com.simplediagrams.model.*;
	import com.simplediagrams.util.Logger;
	
	import flash.events.MouseEvent;
	
	import mx.controls.TextArea;
	
	import org.swizframework.controller.AbstractController;
			
	public class SymbolEditController extends AbstractController
	{
		
		[Inject]
		public var diagramManager:DiagramManager;
		
		
		public function SymbolEditController()
		{
			
		}
				
		[Mediate(event='EditSDComponentTextEvent.START_EDIT')]
		public function onEditSymbolTextEvent(event:EditSDComponentTextEvent):void
		{			
			var model:SDSymbolModel = event.sdObjectModel as SDSymbolModel					
		}
		
		protected function onMouseClick(event:MouseEvent):void
		{
			Logger.debug("onMouseClick",this)
		}
		
	}
}