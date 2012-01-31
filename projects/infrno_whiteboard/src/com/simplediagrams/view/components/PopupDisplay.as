package com.simplediagrams.view.components
{
	import flash.display.DisplayObject;
	
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;

	public class PopupDisplay
	{
		public function PopupDisplay()
		{
		}
		
		public var popup:Class;
		
		public var instance:IFlexDisplayObject;
		
		private var _display:Boolean = false;

		public var modal:Boolean = true;
		
		public function get display():Boolean
		{
			return _display;
		}

		public function set display(value:Boolean):void
		{
			if(_display)
			{
				PopUpManager.removePopUp(instance);
				instance = null;
			}
			_display = value;
			if(_display)
			{
				instance = new popup;
				PopUpManager.addPopUp(instance, FlexGlobals.topLevelApplication as DisplayObject, modal);
				PopUpManager.centerPopUp(instance);
			}
		}

	}
}