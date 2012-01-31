package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class ExportDiagramUserRequestEvent extends Event
	{				
		public static const EXPORT_DIAGRAM:String = "exportDiagramUserRequest"
		public static const DESTINATION_YAMMER:String ="exportToYammer"
		public static const DESTINATION_BASECAMP:String = "exportToBasecamp"
		public static const DESTINATION_FILE:String = "exportToFile"
		public static const DESTINATION_CLIPBOARD:String = "exportToClipboard"
			
		public var destination:String
				
		public function ExportDiagramUserRequestEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}