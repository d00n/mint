package com.simplediagrams.view.drawingBoard
{	
	
	import com.simplediagrams.model.DrawingBoardGridModel;
	import com.simplediagrams.view.skins.DrawingBoardSkinClass;
	
	import mx.events.ResizeEvent;
	import mx.managers.IFocusManagerComponent;
	
	import spark.components.Group;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.primitives.Graphic;
	
	[Bindable]
	public class DrawingBoardGrid extends SkinnableComponent implements IFocusManagerComponent 
	{
		[Inject]
		public var drawingBoardGridModel:DrawingBoardGridModel;
		
		[SkinPart(required="true")]
		public var gridHolder:Graphic;
			
			//Moved to DrawingBoardGridModel
//		public var gridInterval:Number = 50		
//		public var gridColor:uint = 0
//		public var gridThickness:Number = 0
//		public var gridAlpha:Number = 1
			
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
			gridHolder.graphics.lineStyle(drawingBoardGridModel.gridThickness, 
																		drawingBoardGridModel.gridColor, 
																		drawingBoardGridModel.gridAlpha);
			while (i < width-drawingBoardGridModel.gridInterval-2)
			{
				i +=drawingBoardGridModel.gridInterval;
				gridHolder.graphics.moveTo(i,0);
				gridHolder.graphics.lineTo(i,height);
			}
			while (j < height-drawingBoardGridModel.gridInterval-2)
			{
				j += drawingBoardGridModel.gridInterval;
				gridHolder.graphics.moveTo(0,j);
				gridHolder.graphics.lineTo(width,j);
			}     				   
		}
		
		override protected function commitProperties():void
		{
			drawGrid(null);
			super.commitProperties();
		} 
		
		
	}
}