package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class GridEvent extends Event
	{
		public static const SHOW_GRID:String = "gridEvent_ShowGrid";
		public static const CELL_WIDTH:String = "gridEvent_CellWidth";
		public static const ALPHA:String = "gridEvent_Alpha";
		
		public var show_grid:Boolean = false;
		public var cell_width:Number = 10;
		public var alpha:Number = 1;
					
			public function GridEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
			{
				super(type, bubbles, cancelable);
			}
			
	}
}