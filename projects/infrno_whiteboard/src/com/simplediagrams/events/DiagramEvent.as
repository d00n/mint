package com.simplediagrams.events
{
	import com.simplediagrams.model.DiagramModel;
	
	import flash.events.Event;
	
	public class DiagramEvent extends Event
	{
		public function DiagramEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public var diagramModel:DiagramModel;
		
		public static const CHANGE_DIAGRAM_PROPERTIES:String = "com.simplediagrams.events.diagramEvent.CHANGE_DIAGRAM_PROPERTIES"
		public static const MOVE_SELECTION:String = "com.simplediagrams.events.diagramEvent.MOVE_SELECTION"
		public static const FIT_DIAGRAM_SIZE_TO_DEFAULT_BG_SIZE:String = "com.simplediagrams.events.diagramEvent.FIT_DIAGRAM_SIZE_TO_DEFAULT_BG_SIZE"
		public var x:Number = 0;
		public var y:Number = 0;
 
	}
}