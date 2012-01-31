package com.simplediagrams.model
{
	import com.simplediagrams.view.components.TextEditor;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mx.binding.utils.ChangeWatcher;
	
	[Bindable]
	public class TextEditorModel
	{
		
		public var showEditField:Boolean = false
		public var currText:String
		public var currComponent:SDObjectModel 
		
		public var editorWidth:Number = 300
		public var editorHeight:Number = 200
		public var editorX:Number = 0
		public var editorY:Number = 0
		public var editorTextAlign:String = TextAlign.LEFT
			
			
		public function TextEditorModel()
		{
		}
		
		public function getTextYPosition(sdObjectModel:SDSymbolModel):Number
		{
			var textYPos:Number = 5
			switch (sdObjectModel.textPosition)
			{
				case SDSymbolModel.TEXT_POSITION_ABOVE:
					textYPos = -20
					break
				
				case SDSymbolModel.TEXT_POSITION_TOP:
					textYPos = 5
					break
				
				case SDSymbolModel.TEXT_POSITION_MIDDLE:					
					textYPos = uint(sdObjectModel.height/2) - uint(sdObjectModel.fontSize / 2)
					break
				
				case SDSymbolModel.TEXT_POSITION_BOTTOM:
					textYPos = sdObjectModel.height - (sdObjectModel.fontSize + 10)
					break
				
				case SDSymbolModel.TEXT_POSITION_BELOW:
					textYPos = sdObjectModel.height + 5 
					break
					
			}
			return textYPos
			
		}
		
		public function editComponent(sdObjectModel:SDObjectModel, scaleX:Number, scaleY:Number, screenWidth:Number, screenHeight:Number, scrollX:Number, scrollY:Number):void
		{
			
			
			editorWidth = 300
			editorHeight = 200
			
			//first show edit field
			showEditField = true
			editorX = (sdObjectModel.x-scrollX) * scaleX 
			
			currComponent = sdObjectModel
				
			if (currComponent is SDTextAreaModel)
			{
				var tm:SDTextAreaModel = SDTextAreaModel(currComponent)
				editorY = (sdObjectModel.y-scrollY) * scaleY 					
				editorTextAlign = tm.textAlign
				currText = tm.text
			}
			else if (currComponent is SDSymbolModel)
			{
				var sdSymbolModel:SDSymbolModel = SDSymbolModel(currComponent)
				editorY = (sdSymbolModel.y + getTextYPosition(sdSymbolModel)-scrollY) * scaleY
				editorTextAlign = sdSymbolModel.textAlign
				currText = sdSymbolModel.text
			}
			
			//resize width so editor doesn't go off screen
			if (editorX + editorWidth > screenWidth)
			{
				var diff:Number = screenWidth - editorX - 15
				if (diff>sdObjectModel.width)
				{
					editorWidth = screenWidth - editorX - 15
				}
				else
				{
					editorWidth = sdObjectModel.width
				}
			}
		
							
			//then customize to component type
		}
			
		
		public function completeEdit(finalText:String):void
		{
			if (currComponent is SDTextAreaModel)
			{
				var tm:SDTextAreaModel = SDTextAreaModel(currComponent)
				tm.text = finalText		
			}
			else if (currComponent is SDSymbolModel)
			{
				var sdSymbolModel:SDSymbolModel = SDSymbolModel(currComponent)
				sdSymbolModel.text = finalText
				
			}
			
			currText = ""
			showEditField = false
			currComponent = null
		}
		
	}
}