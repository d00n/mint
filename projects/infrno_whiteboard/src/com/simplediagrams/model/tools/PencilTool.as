package com.simplediagrams.model.tools
{
	import com.simplediagrams.events.PencilDrawingEvent;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.PathSegment;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.effects.Move;
	import mx.events.PropertyChangeEvent;

	public class PencilTool extends ToolBase
	{
		public function PencilTool()
		{
			super();
		}
		
		public var drag:Boolean = false;
		public var segments:ArrayCollection = new ArrayCollection();
		
		private var _color:int = 0;
		
		[Inject(source='settingsModel.selectedColor',bind='true')]
		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			_color = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;

		private var _diagramModel:DiagramModel;
		
		[Inject(source='diagramManager.diagramModel',bind='true')]
		public function get diagramModel():DiagramModel
		{
			return _diagramModel;
		}
		
		public function set diagramModel(value:DiagramModel):void
		{
			if(_diagramModel)
				_diagramModel.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
			_diagramModel = value;
			onPropertyChange(null);
			if(_diagramModel)
				_diagramModel.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
		}
		
		private function onPropertyChange(event:Event):void
		{
			if(diagramModel)
			{
				scaleX = diagramModel.scaleX;
				scaleY = diagramModel.scaleY;
			}
			dispatchEvent(new Event(Event.CHANGE));
		}

		public function commitPath():void
		{			
			var len:int = segments.length;
			var i:int;
			var left:Number = Number.MAX_VALUE;
			var top:Number =  Number.MAX_VALUE;
			var right:Number = Number.MIN_VALUE;
			var bottom:Number = Number.MIN_VALUE;
			var segment:PathSegment;
			for (i = 0; i< len;i++)
			{
				segment = segments.getItemAt(i) as PathSegment;
				if(left > segment.x)
					left = segment.x;
				if(top > segment.y)
					top = segment.y;
				if(right < segment.x)
					right = segment.x;
				if(bottom < segment.y)
					bottom = segment.y;
			}
			for (i = 0; i< len;i++)
			{
				segment = segments.getItemAt(i) as PathSegment;
				segment.x = segment.x - left;
				segment.y = segment.y - top;
			}
			var path:String = "";
			for (i = 0; i< len;i++)
			{
				segment = segments.getItemAt(i) as PathSegment;
				var moveType:String = (segment.type == PathSegment.MOVE)?"M":"L";
				path += moveType + " " + segment.x.toString() + "," + segment.y.toString() + " ";
			}
			var evt:PencilDrawingEvent = new PencilDrawingEvent(PencilDrawingEvent.DRAWING_CREATED, true)
			evt.path = path;
			evt.color = _color;
			evt.initialX = left;
			evt.initialY = top;
			evt.width = right - left;
			evt.height = bottom - top;
			dispatcher.dispatchEvent(evt)
			segments.removeAll();
		}
		
		public override function activateTool():void
		{
			segments.removeAll();
		}
		
		public override  function deactivateTool():void
		{
			commitPath();
		}
		
		public override  function onMouseDown(toolMouseInfo:ToolMouseInfo):void
		{
			drag = true;
			segments.addItem(new PathSegment(PathSegment.MOVE,toolMouseInfo.x, toolMouseInfo.y));
		}
		
		public override function onMouseUp(toolMouseInfo:ToolMouseInfo):void
		{
			if(drag)
			{
				var lastSegment:PathSegment = segments.getItemAt(segments.length - 1) as PathSegment;
				if(lastSegment.x != toolMouseInfo.x || lastSegment.y != toolMouseInfo.y)
					segments.addItem(new PathSegment(PathSegment.DRAW,toolMouseInfo.x, toolMouseInfo.y));
				drag = false;
			}
		}
		
		public override function onMouseMove(toolMouseInfo:ToolMouseInfo):void
		{
			if(drag)
			{
				var lastSegment:PathSegment = segments.getItemAt(segments.length - 1) as PathSegment;
				if(lastSegment.x != toolMouseInfo.x || lastSegment.y != toolMouseInfo.y)
					segments.addItem(new PathSegment(PathSegment.DRAW,toolMouseInfo.x, toolMouseInfo.y));
			}
		}
	}
}