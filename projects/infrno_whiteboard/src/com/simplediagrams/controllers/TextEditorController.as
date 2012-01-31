package com.simplediagrams.controllers
{
	import com.simplediagrams.events.EditSDComponentTextEvent;
	import com.simplediagrams.model.DiagramManager;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDTextAreaModel;
	import com.simplediagrams.model.TextEditorModel;
	
	import mx.core.FlexGlobals;
	
	import org.swizframework.controller.AbstractController;

	public class TextEditorController extends AbstractController
	{
		
		[Inject]
		public var textEditorModel:TextEditorModel
		
		[Inject]
		public var diagramManager:DiagramManager;
		
		
		public function TextEditorController()
		{
		}
		
		[Mediate(event="EditSDComponentTextEvent.START_EDIT")]
		public function startTextEdit(event:EditSDComponentTextEvent):void
		{
			/*
			var drawingBoard:DrawingBoard = FlexGlobals.topLevelApplication.appView.diagram.drawingBoard as DrawingBoard
			var screenWidth:Number = drawingBoard.width
			var screenHeight:Number = drawingBoard.height
			var scrollX:Number = drawingBoard.scrollingHolder.viewport.horizontalScrollPosition
			var scrollY:Number = drawingBoard.scrollingHolder.viewport.verticalScrollPosition
				
			textEditorModel.editComponent(event.sdObjectModel, diagramModel.scaleX, diagramModel.scaleY, screenWidth, screenHeight, scrollX, scrollY)		
			*/
		}
			
		[Mediate(event="EditSDComponentTextEvent.COMPLETE_EDIT")]
		public function completeTextEdit(event:EditSDComponentTextEvent):void
		{
			textEditorModel.completeEdit(event.finalText)
		}
	}
}