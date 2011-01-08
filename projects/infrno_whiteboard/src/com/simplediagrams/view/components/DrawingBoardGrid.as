package com.simplediagrams.view.components
{	
	
	import com.simplediagrams.view.skins.DrawingBoardSkinClass;
	
	import mx.events.ResizeEvent;
	import mx.managers.IFocusManagerComponent;
	
	import spark.components.Group;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.primitives.Graphic;
	
	public class DrawingBoardGrid extends SkinnableComponent implements IFocusManagerComponent 
	{
		
		[SkinPart(required="true")]
		public var gridHolder:Graphic;
			
		public var gridInterval:Number = 15
		
		public var gridColor:Number = 0xFFFFFF
		public var gridThickness:Number = 1
		public var gridAlpha:Number = 1
			
		public function DrawingBoardGrid()
		{
			super();
			this.setStyle("skinClass",Class(DrawingBoardSkinClass))
		}
		
		override protected function partAdded(partName:String, instance:Object):void 
		{
			super.partAdded(partName, instance);
			if (instance == gridHolder) 
			{
				gridHolder.addEventListener(ResizeEvent.RESIZE, drawGrid)
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void 
		{
			super.partRemoved(partName, instance);
			if (instance == gridHolder) 
			{				
				gridHolder.removeEventListener(ResizeEvent.RESIZE, drawGrid)
			}
		}
		
		
		protected function drawGrid(event:ResizeEvent):void
		{
			var i:int=0;
			var j:int=0;
			gridHolder.graphics.clear();
			gridHolder.graphics.lineStyle(gridThickness, gridColor, gridAlpha)
			while (i < width-gridInterval-2)
			{
				i +=gridInterval;
				gridHolder.graphics.moveTo(i,0);
				gridHolder.graphics.lineTo(i,height);
			}
			while (j < height-gridInterval-2)
			{
				j += gridInterval;
				gridHolder.graphics.moveTo(0,j);
				gridHolder.graphics.lineTo(width,j);
			}     				   
		}
		
		
	}
}