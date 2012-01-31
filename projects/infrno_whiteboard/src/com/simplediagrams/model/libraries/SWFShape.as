package com.simplediagrams.model.libraries
{
	public class SWFShape extends LibraryItem
	{
		public function SWFShape()
		{
			super();
		}
		
		//path to swf in library
		public var path:String;
		public var maintainAspectRatio:Boolean = false
		public var startWithShapeDefaultColor:Boolean = false
	}
}