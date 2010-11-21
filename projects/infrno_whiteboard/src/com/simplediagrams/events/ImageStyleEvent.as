package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class ImageStyleEvent extends Event
	{
		public static const IMAGE_STYLE_CHANGE:String = "imageStyleChange"
		
		public var imageStyle:String
		
		public function ImageStyleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}