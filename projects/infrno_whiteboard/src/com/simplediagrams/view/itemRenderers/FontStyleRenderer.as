package com.simplediagrams.view.itemRenderers
{
	import mx.controls.Label;
	import mx.events.FlexEvent;
	
	public class FontStyleRenderer extends Label
	{
		public function FontStyleRenderer()
		{
			super();
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			setStyle("fontFamily",value.fontName);
			text = value.fontName;
			dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
	}
}