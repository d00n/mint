package com.simplediagrams.controllers
{
		
	import com.simplediagrams.events.AnnotationToolEvent;
	import com.simplediagrams.model.AnnotationToolModel;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.dialogs.DefaultIndexCardPropsDialog;
	import com.simplediagrams.view.dialogs.DefaultStickyNotePropsDialog;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import org.swizframework.controller.AbstractController;
	
	public class AnnotationController extends AbstractController 
	{
		[Inject]
		public var dialogsController:DialogsController
		
		
		public function AnnotationController()
		{
		}
		
		[Mediate(event="AnnotationToolEvent.EDIT_DEFAULT_PROPERTIES")]
		public function onEditDefaultProps(event:AnnotationToolEvent):void
		{
			//show dialog based on type
			if (event.annotationType == AnnotationToolModel.STICKY_NOTE_TOOL)
			{
				var dialog:DisplayObject = dialogsController.showDefaultStickyNotePropsDialog() as DisplayObject
				
			}
			else if (event.annotationType == AnnotationToolModel.INDEX_CARD)
			{
				dialog = dialogsController.showDefaultIndexCardPropsDialog() as DisplayObject
			}
			dialog.addEventListener(Event.CANCEL, onCancelDialog)
			dialog.addEventListener("OK", onDoneDialog)
			
		}

		
		protected function onDoneDialog(event:Event):void
		{			
			event.target.removeEventListener(Event.CANCEL, onCancelDialog)
			event.target.removeEventListener("OK", onDoneDialog)
			dialogsController.removeDialog()
				
			var evt:AnnotationToolEvent = new AnnotationToolEvent(AnnotationToolEvent.DEFAULT_PROPERTIES_EDITED)					
			if (event.target is DefaultStickyNotePropsDialog)
			{
				evt.annotationType = AnnotationToolModel.STICKY_NOTE_TOOL
			}
			else if (event.target is DefaultIndexCardPropsDialog)
			{
				evt.annotationType = AnnotationToolModel.INDEX_CARD
			}
			dispatcher.dispatchEvent(evt)				
				
		}
		
		protected function onCancelDialog(event:Event):void
		{			
			event.target.removeEventListener(Event.CANCEL, onCancelDialog)
			event.target.removeEventListener("OK", onDoneDialog)
			dialogsController.removeDialog()
		}
		
		
	}
}