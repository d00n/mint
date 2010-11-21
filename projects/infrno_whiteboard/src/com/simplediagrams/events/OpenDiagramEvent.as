package com.simplediagrams.events
{
	import flash.events.Event;
//	import flash.filesystem.File;
	
	public class OpenDiagramEvent extends Event
	{
		public static const OPEN_DIAGRAM:String = "openDiagram"
		public static const DIAGRAM_OPENED:String = "diagramOpened"
		
//		public var openFile:File
			
		public function OpenDiagramEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}