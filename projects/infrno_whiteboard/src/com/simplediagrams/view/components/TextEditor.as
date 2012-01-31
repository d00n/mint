package com.simplediagrams.view.components
{
	import com.simplediagrams.events.CopyEvent;
	import com.simplediagrams.events.CutEvent;
	import com.simplediagrams.events.EditSDComponentTextEvent;
	import com.simplediagrams.events.PasteEvent;
	
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	
	import flashx.textLayout.formats.TextAlign;
	
	import spark.components.TextArea;
	import spark.components.supportClasses.SkinnableComponent;

	public class TextEditor extends SkinnableComponent
	{
		
		[SkinPart(required="true")]
		public var textArea:TextArea;
		
		[Bindable]
		public var fontFamily:String = "Arial";
		
		[Bindable]
		public var currText:String = "";
			
		[Bindable]
		public var textAlign:String = TextAlign.LEFT
		
		public function TextEditor()
		{
			super()
			this.setStyle("skinClass",Class(TextEditorSkin))
		}
		
		override protected function partAdded(partName:String, instance:Object):void 
		{
			super.partAdded(partName, instance);
			if (instance == textArea) 
			{
				textArea.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut)
			}
		}
	
		override protected function partRemoved(partName:String, instance:Object):void 
		{
			super.partRemoved(partName, instance);
			if (instance == textArea) 
			{				
				textArea.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut)
			}
		}
		
		[Mediate(event="EditSDComponentTextEvent.START_EDIT")]
		public function startEdit(event:EditSDComponentTextEvent):void
		{
			this.focusManager.setFocus(textArea)
		}
	
		
		protected function onFocusOut(event:FocusEvent):void
		{
			var evt:EditSDComponentTextEvent = new EditSDComponentTextEvent(EditSDComponentTextEvent.COMPLETE_EDIT, true)
			evt.finalText = textArea.text
			dispatchEvent(evt)
		}
		
	}
}