package com.simplediagrams.model.tools
{
	import com.simplediagrams.events.CreateLineComponentEvent;
	import com.simplediagrams.events.RemoteSharedObjectEvent;
	import com.simplediagrams.model.ConnectionPoint;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.util.Logger;
	
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;

	public class LineTool extends ToolBase
	{
		public function LineTool()
		{
			super();
		}
		
		public var drag:Boolean = false;
		public var startPoint:Point;
		public var endPoint:Point;
		public var currentPoint:Point;
		
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
		
		private var _connectorPoints:Array;
		
		public function get connectorPoints():Array
		{
			return _connectorPoints;
		}
		
		public function set connectorPoints(value:Array):void
		{
			_connectorPoints = value;
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
			{
				_diagramModel.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
				_diagramModel.sdObjects.removeEventListener( CollectionEvent.COLLECTION_CHANGE, onCollectionChange );
			}
			_diagramModel = value;
			connectorPoints = [];
			onPropertyChange(null);
			if(_diagramModel)
			{
				_diagramModel.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
				_diagramModel.sdObjects.addEventListener( CollectionEvent.COLLECTION_CHANGE, onCollectionChange );	
			}
		}
		
		private function onCollectionChange(event:CollectionEvent):void
		{
			calculatePoints();
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
		
		public override  function onMouseDown(toolMouseInfo:ToolMouseInfo):void
		{
			drag = true;
			startPoint = new Point(toolMouseInfo.x, toolMouseInfo.y);
			endPoint = startPoint;
			currentPoint = startPoint;
			calculatePoints();
		}
		
		public override function onMouseUp(toolMouseInfo:ToolMouseInfo):void
		{
			if(drag)
			{
				endPoint = new Point(toolMouseInfo.x, toolMouseInfo.y);
				dispatchEvent(new Event(Event.CHANGE));
				drag = false;
				var line:SDLineModel = new SDLineModel;
				var evt:CreateLineComponentEvent = new CreateLineComponentEvent(CreateLineComponentEvent.CREATE, true);	
				line.startX = startPoint.x;
				line.startY = startPoint.y;
				line.endX = endPoint.x;
				line.endY = endPoint.y;
				line.bendX = (line.endX + line.startX)/2;
				line.bendY = (line.endY + line.startY)/2; 
				if(veryCloseTargetStart)
				{
					line.fromPoint = veryClosePointStart;
					line.fromObject = veryCloseTargetStart;
					veryCloseTargetStart = null;
				}
				if(veryCloseTargetEnd)
				{
					line.toPoint = veryClosePointEnd;
					line.toObject = veryCloseTargetEnd;
					veryCloseTargetEnd = null;
				}
				evt.line = line;
				if(line.startX != line.endX || line.startY != line.endY)
					dispatcher.dispatchEvent(evt);
				startPoint = null;
				endPoint = null;
				
				Logger.info("onMouseUp", this);
				var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.DISPATCH_LINE_CONNECTIONS);	
				rsoEvent.sdObjects.addItem(line);
				dispatcher.dispatchEvent(rsoEvent);   
			}
		}
		
		public override function onMouseMove(toolMouseInfo:ToolMouseInfo):void
		{
			currentPoint = new Point(toolMouseInfo.x, toolMouseInfo.y);
			if(drag)
			{
				endPoint = new Point(toolMouseInfo.x, toolMouseInfo.y);
				dispatchEvent(new Event(Event.CHANGE));
			}
			calculatePoints();
		}
		
		public var veryClosePointStart:ConnectionPoint;
		public var veryClosePointEnd:ConnectionPoint;
		public var veryCloseTargetStart:SDObjectModel;
		public var veryCloseTargetEnd:SDObjectModel;
		
		private function calculatePoints():void
		{
			if(_diagramModel == null)
			{
				_connectorPoints = [];
			}
			if(currentPoint)
			{
				var start:Point
				if(startPoint != null)
					start = new Point(startPoint.x * scaleX,startPoint.y * scaleY);
				else
					start =  new Point(currentPoint.x * scaleX,currentPoint.y * scaleY);
				var end:Point = new Point(currentPoint.x * scaleX,currentPoint.y * scaleY);
				var resultConnectorPoints:Array = [];
				veryCloseTargetStart = null;
				veryCloseTargetEnd = null;
				for each(var sdObject:SDObjectModel in diagramModel.sdObjects)
				{
					if(sdObject.connectionPoints.length > 0)
					{
						var matrix:Matrix = new Matrix();
						matrix.scale(sdObject.width, sdObject.height);
						matrix.rotate(sdObject.rotation * Math.PI / 180);
						matrix.translate(sdObject.x, sdObject.y);
						var points:Array = sdObject.connectionPoints;
						var isClose:Boolean = false;
						var point:ConnectionPoint;
						var transformedPoint:Point;
						for each(point in points)
						{
							transformedPoint = matrix.transformPoint(new Point(point.x, point.y));
							transformedPoint.x *= scaleX;
							transformedPoint.y *= scaleY;
							
							var closeStart:Boolean = (Math.abs(transformedPoint.x - start.x) < 100) && (Math.abs(transformedPoint.y - start.y) < 100 );
							var closeEnd:Boolean = (Math.abs(transformedPoint.x - end.x) < 100) && (Math.abs(transformedPoint.y - end.y) < 100 );
							if(closeStart || closeEnd)
								isClose = true;
						}
						if(isClose)
						{
							for each(point in points)
							{
								transformedPoint = matrix.transformPoint(new Point(point.x, point.y));
								transformedPoint.x *= scaleX;
								transformedPoint.y *= scaleY;
								
								var connectorPoint:ConnectorPoint = new ConnectorPoint();
								connectorPoint.x = transformedPoint.x;
								connectorPoint.y = transformedPoint.y;
								resultConnectorPoints.push(connectorPoint);
								var veryCloseStart:Boolean = (Math.abs(transformedPoint.x - start.x) < 5) && (Math.abs(transformedPoint.y - start.y) < 5 );
								var veryCloseEnd:Boolean = (Math.abs(transformedPoint.x - end.x) < 5) && (Math.abs(transformedPoint.y - end.y) < 5 );
								if(veryCloseStart || veryCloseEnd)
								{
									connectorPoint.isClose = true;
								}
								if(veryCloseStart)
								{
									veryCloseTargetStart = sdObject;
									veryClosePointStart = point;
								}
								if(veryCloseEnd)
								{
									veryCloseTargetEnd = sdObject;
									veryClosePointEnd = point;
								}
							}	
						}
					}
				}
				_connectorPoints = resultConnectorPoints;				
				Logger.info("calculatePoints", this);
			}
			else
			{
				_connectorPoints = [];
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public override function deactivateTool():void
		{
			currentPoint = null;
			startPoint = null;
			endPoint = null;
		}
	}
}