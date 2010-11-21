package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class CloseDiagramEvent extends Event
	{
		
		public static const CLOSE_DIAGRAM:String = "closeDiagram"
		public static const DIAGRAM_CLOSED:String = "diagramClosed"

		public function CloseDiagramEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}