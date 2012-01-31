package com.simplediagrams.model.tools
{
	import com.simplediagrams.events.TextAreaCreatedEvent;

	public class TextTool extends ToolBase
	{
		public function TextTool()
		{
			super();
		}
		
		public override function onMouseClick(toolMouseInfo:ToolMouseInfo):void
		{
			var textAreaEvent:TextAreaCreatedEvent = new TextAreaCreatedEvent(TextAreaCreatedEvent.CREATED, true);      					
			textAreaEvent.dropX = toolMouseInfo.x; 
			textAreaEvent.dropY = toolMouseInfo.y;
			dispatcher.dispatchEvent(textAreaEvent);	
		}
	}
}