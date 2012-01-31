package com.simplediagrams.model
{
	public class PathSegment
	{
		public function PathSegment(type:int, x:Number, y:Number)
		{
			this.type = type;
			this.x = x;
			this.y = y;
		}
		
		public static const MOVE:int = 0;
		public static const DRAW:int = 1;

		
		public var x:Number;
		public var y:Number;
		public var type:int = MOVE;
		
	}
}