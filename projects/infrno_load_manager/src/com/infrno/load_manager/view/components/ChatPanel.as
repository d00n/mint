package com.infrno.load_manager.view.components
{
	import mx.containers.Panel;
	import mx.core.UIComponent;
	import mx.core.SpriteAsset;
	import mx.events.FlexEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class ChatPanel extends Panel
	{
		public function ChatPanel()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		// Expose the title bar property for draggin and dropping.
		[Bindable]
		public var myTitleBar:UIComponent;
		
		private function creationCompleteHandler(event:Event):void
		{
			myTitleBar = titleBar;			
		}
		
	}
}