package com.simplediagrams.model
{
	[RemoteClass]
	public class ConnectionPoint
	{
		public function ConnectionPoint(id:int = 0, x:Number = 0, y:Number = 0)
		{
			this.id = id;
			this.x = x;
			this.y = y;
		}
		
		public var id:int;
		public var x:Number;
		public var y:Number;
	}
}