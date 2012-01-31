package com.simplediagrams.model.tools
{
	import com.simplediagrams.events.SelectionEvent;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.TransformData;
	import com.simplediagrams.util.Logger;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class MarqueeTool extends ToolBase
	{
		public function MarqueeTool()
		{
			super();
		}
		
		private var _marqueeTansform:TransformData;
		
		
		[Bindable(event="change")]
		public function get marqueeTansform():TransformData
		{
			return _marqueeTansform;
		}
		
		public function set marqueeTansform(value:TransformData):void
		{
			if( _marqueeTansform !== value)
			{
				_marqueeTansform = value;
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		public override function activateTool():void
		{
			_marqueeTansform = null;
		}
		
		public override function deactivateTool():void
		{
			_marqueeTansform = null;
		}
		
		public var unscaledTransform:TransformData;
		
		private var scaleX:Number;
		
		private var scaleY:Number;
		
		public function setScale(scaleX:Number, scaleY:Number):void
		{
			this.scaleX = scaleX;
			this.scaleY = scaleY;
			if(unscaledTransform)
			{
				var tranformClone:TransformData = unscaledTransform.clone();
				tranformClone.scale(scaleX, scaleY);
				marqueeTansform = tranformClone;
			}
		}
		
		private var startDragPoint:Point;


		public override function onMouseDown(toolMouseInfo:ToolMouseInfo):void
		{
			if(toolMouseInfo.target == null)
			{
				startDragPoint = new Point( toolMouseInfo.x,  toolMouseInfo.y);
			}
		}
		
		private var internalChanges:Boolean = false;
		
		public override function onRollOut():void
		{
			
		}
		
		public override function onMouseMove(toolMouseInfo:ToolMouseInfo):void
		{
			if (toolMouseInfo==null)
			{
				Logger.error("toolMouseInfo was null", this)
				return 
			}			
			if(startDragPoint)
			{
				unscaledTransform = getDragTransformData(startDragPoint, toolMouseInfo );
				var tranformClone:TransformData = unscaledTransform.clone();
				tranformClone.scale(scaleX, scaleY);
				marqueeTansform = tranformClone;
			}
		}
		
		private function getDragTransformData(startDragPoint:Point, toolMouseInfo:ToolMouseInfo):TransformData
		{
			if (startDragPoint==null)
			{
				Logger.error("startDragPoint was null",this)
				return null
			}
			if (toolMouseInfo==null)
			{
				Logger.error("toolMouseInfo was null", this)
				return null
			}
			
			var top:Number;
			var left:Number;
			var right:Number;
			var bottom:Number;
			if(toolMouseInfo.y > startDragPoint.y)
			{
				top = startDragPoint.y;
				bottom = toolMouseInfo.y;
			} 
			else
			{
				top = toolMouseInfo.y;
				bottom = startDragPoint.y;
			}
			if(toolMouseInfo.x > startDragPoint.x)
			{
				left = startDragPoint.x;
				right = toolMouseInfo.x;
			}
			else
			{
				left = toolMouseInfo.x;
				right = startDragPoint.x;
			}
			return new TransformData(left, top, right - left, bottom - top);
		}
		
		public override function onMouseUp(toolMouseInfo:ToolMouseInfo):void
		{
			if(startDragPoint)
			{
				unscaledTransform = getDragTransformData(startDragPoint, toolMouseInfo );
				if (unscaledTransform==null)
				{
					return
				}
				startDragPoint = null;
				marqueeTansform = null;
				var selectionEvent:SelectionEvent = new SelectionEvent(SelectionEvent.SELECT_IN_RECT);
				selectionEvent.rect = new Rectangle(unscaledTransform.x, unscaledTransform.y, unscaledTransform.width, unscaledTransform.height);
				dispatcher.dispatchEvent(selectionEvent);
			}
		}

	}
}