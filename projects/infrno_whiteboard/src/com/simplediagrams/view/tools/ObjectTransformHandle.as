package com.simplediagrams.view.tools
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import spark.core.SpriteVisualElement;
	
	public class ObjectTransformHandle extends SpriteVisualElement
	{
		
		protected var isOver:Boolean = false;
		
		public var role:uint = 0;
		
		public function ObjectTransformHandle()
		{
			super();
			addEventListener( MouseEvent.ROLL_OUT, onRollOut );
			addEventListener( MouseEvent.ROLL_OVER, onRollOver );
			redraw();
		}
		
		protected function onRollOut( event : MouseEvent ) : void
		{
			isOver = false;
			redraw();
		}
		protected function onRollOver( event:MouseEvent):void
		{
			isOver = true;
			redraw();
		}
		
		public function redraw() : void
		{
			graphics.clear();
			if( isOver )
			{
				graphics.lineStyle(1,0x3dff40);
				graphics.beginFill(0xc5ffc0     ,1);                            
			}
			else
			{
				graphics.lineStyle(1,0);
				graphics.beginFill(0xaaaaaa,1);
			}
			
			graphics.drawRect(-5,-5,10,10);
			graphics.endFill();
			
		}
	}
}
