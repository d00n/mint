package com.simplediagrams.events
{
	import flash.events.Event;

	public class TransformEvent extends Event
	{
		public function TransformEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

		public var newTransforms:Array;
		public var oldTransforms:Array;
		public var backup:Array;

		public static const TRANSFORM:String = "TransformEvent.TRANSFORM";
	}
}