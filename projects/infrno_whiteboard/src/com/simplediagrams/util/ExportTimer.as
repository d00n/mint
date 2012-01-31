package com.simplediagrams.util
{
	import flash.utils.Timer;
	
	public class ExportTimer extends Timer
	{
		public var sourceEventType:String
		
		public function ExportTimer(delay:Number, repeatCount:int=0)
		{
			super(delay, repeatCount);
		}
	}
}