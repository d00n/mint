package com.simplediagrams.events
{
	import com.simplediagrams.view.SDComponents.ISDComponent;
	
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	public class DiagramModelEvent extends Event
	{
		public static const SD_OBJECT_ADDED_TO_MODEL:String = "sdObjectAddedToModel"
		
		public var newSDComponent:ISDComponent
			
		public function DiagramModelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}