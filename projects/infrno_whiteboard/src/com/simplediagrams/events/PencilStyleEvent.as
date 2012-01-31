package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class PencilStyleEvent extends Event
	{
		
		public static const PENCIL_LINE_WEIGHT_CHANGE:String = "pencilLineWeightChange"
		
		public var lineWeight:int
		
		public function PencilStyleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}