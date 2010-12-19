package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class RebuildDiagramEvent extends Event
	{
		public static const REBUILD_DIAGRAM_EVENT:String = "rebuildDiagramEvent"
		
		public function RebuildDiagramEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}