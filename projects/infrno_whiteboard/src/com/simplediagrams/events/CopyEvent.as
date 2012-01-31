package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class CopyEvent extends Event
	{
		public static const COPY:String = "copyEvent"
		public static const COPY_DIAGRAM_TO_CLIPBOARD:String = "copyDiagramToClipboard"
			
		public function CopyEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}