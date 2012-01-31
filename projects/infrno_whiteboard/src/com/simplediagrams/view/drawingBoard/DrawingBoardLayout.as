package com.simplediagrams.view.drawingBoard
{
	import mx.core.ILayoutElement;
	
	import spark.layouts.supportClasses.LayoutBase;
	
	public class DrawingBoardLayout extends LayoutBase
	{
		public function DrawingBoardLayout()
		{
			super();
		}
		
		override public function measure():void
		{
			var count:uint = target.numElements;

		}
		
		override public function updateDisplayList(width:Number, height:Number):void
		{
			var count:uint = target.numElements;
			if(count == 0)
				return;
			var width:Number = target.getElementAt(0).getLayoutBoundsWidth();
			var height:Number = target.getElementAt(0).getLayoutBoundsHeight();
			for(var i:int = 0; i < count;i++)
			{
				var item:ILayoutElement = target.getElementAt(i);
				var x:Number = 0;
				var y:Number = 0;
				if(width < target.width)
					x = (target.width - width )/2;
				if(height < target.height)
					y = (target.height - height )/2;
				item.setLayoutBoundsPosition(x, y);
			}
			target.setContentSize(width, height);
		}
	}
}