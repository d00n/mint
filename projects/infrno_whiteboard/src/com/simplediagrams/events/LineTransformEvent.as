package com.simplediagrams.events
{
	import com.simplediagrams.model.SDLineModel;
	
	import flash.events.Event;
	
	public class LineTransformEvent extends Event
	{		
		public var startX:Number
		public var startY:Number
		public var endX:Number
		public var endY:Number
		public var bendX:Number
		public var bendY:Number
		
		public var oldState:SDLineModel;
		public var newState:SDLineModel;
		
		public function LineTransformEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public static const TRANSFORM_LINE:String = "lineTransform";
	}
}