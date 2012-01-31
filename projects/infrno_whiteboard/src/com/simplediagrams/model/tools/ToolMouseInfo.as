package com.simplediagrams.model.tools
{
	public class ToolMouseInfo
	{
		public function ToolMouseInfo(x:Number, y:Number, target:Object = null, shiftKey:Boolean = false, ctrlKey:Boolean = false)
		{
			this.x = x;
			this.y = y;
			this.target = target;
			this.shiftKey = shiftKey; 
			this.ctrlKey = ctrlKey;
		}
		
		public var target:Object;
		public var x:Number;
		public var y:Number;
		public var shiftKey:Boolean;
		public var ctrlKey:Boolean;
	}
}