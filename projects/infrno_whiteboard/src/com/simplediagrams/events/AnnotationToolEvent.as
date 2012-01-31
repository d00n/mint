package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class AnnotationToolEvent extends Event
	{
		public static const EDIT_DEFAULT_PROPERTIES:String = "editAnnotationDefaultProperties"
		public static const DEFAULT_PROPERTIES_EDITED:String = "defaultPropertiesEdited"
		
		public var annotationType:String = ""
			
		public function AnnotationToolEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}