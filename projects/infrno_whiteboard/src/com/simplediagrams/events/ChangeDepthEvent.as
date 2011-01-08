package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class ChangeDepthEvent extends Event
	{
		
		public static const MOVE_TO_BACK:String = "cd_moveToBack"
		public static const MOVE_TO_FRONT:String = "cd_moveToFront"
		public static const MOVE_FORWARD:String = "cd_moveForward"
		public static const MOVE_BACKWARD:String = "cd_moveBackward"
			
		public static const OBJECT_MOVED:String = "cd_objectMoved"
		
		public var sdID:String;
		
		public function ChangeDepthEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}