package com.simplediagrams.events
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	public class TestInvoke extends Event
	{
		public static const INVOKE:String = "testInvoke"
		
		public var arguments:Array
		
		public function TestInvoke(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable)
		}
	}
}