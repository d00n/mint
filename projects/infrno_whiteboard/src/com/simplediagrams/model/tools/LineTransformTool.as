package com.simplediagrams.model.tools
{
	import com.simplediagrams.events.LineTransformEvent;
	import com.simplediagrams.events.RemoteSharedObjectEvent;
	import com.simplediagrams.model.ConnectionPoint;
	import com.simplediagrams.model.CopyUtil;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.SDComponents.SDSymbol;
	
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.events.PropertyChangeEvent;

	public class LineTransformTool extends ToolBase
	{
		public function LineTransformTool()
		{
			super();
		}
		
		public override function activateTool():void
		{
			controlPoints = null;
		}
		
		public override function deactivateTool():void
		{
			line = null;
			controlPoints = null;
		}
		
		private var _controlPoints:Array;

		[Bindable(event="change")]
		public function get controlPoints():Array
		{
			return _controlPoints;
		}

		public function set controlPoints(value:Array):void
		{
			if( _controlPoints !== value)
			{
				_controlPoints = value;
				dispatchEvent(new Event("change"));
			}
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

		
		private var _line:SDLineModel;
		private var _backUp:SDLineModel;

		public function get line():SDLineModel
		{
			return _line;
		}

		public function set line(value:SDLineModel):void
		{
			if(_line)
				_line.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
			_line = value;
			if(_line)
				_line.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
			calculatePoints();
		}
		
		private function onPropertyChange(event:Event):void
		{
			if(!internalChanges)
				calculatePoints();
		}

		private var _diagramModel:DiagramModel;

		public function get diagramModel():DiagramModel
		{
			return _diagramModel;
		}

		public function set diagramModel(value:DiagramModel):void
		{
			_diagramModel = value;
		}

		
		private var _scaleX:Number;
		
		
		public function get scaleX():Number
		{
			return _scaleX;
		}
		
		private var _scaleY:Number;
		
		public function get scaleY():Number
		{
			return _scaleY;
		}
		
		public function setScale(scaleX:Number, scaleY:Number):void
		{
			_scaleX = scaleX;
			_scaleY = scaleY;
			calculatePoints();
		}
		
		private var currentDragRole:uint = 0;		
		private var startDragPoint:Point;
		private var currentDragPoint:Point;
		
		public override function onMouseDown(toolMouseInfo:ToolMouseInfo):void
		{
			if(toolMouseInfo.target != null)
			{
				startDragPoint = new Point( toolMouseInfo.x,  toolMouseInfo.y);
				currentDragPoint = startDragPoint;
				if(toolMouseInfo.target is SDLineModel)
					currentDragRole = LineHandleRoles.MOVE;
				else
					currentDragRole = uint(toolMouseInfo.target);
				_backUp = CopyUtil.clone(line) as SDLineModel;
			}
		}
		
		private var internalChanges:Boolean = false;
		
		public override function onMouseMove(toolMouseInfo:ToolMouseInfo):void
		{
			if(currentDragRole != 0)
			{
				currentDragPoint = new Point( toolMouseInfo.x,  toolMouseInfo.y);
				internalChanges = true;
				var deltaX:Number = currentDragPoint.x - startDragPoint.x;
				var deltaY:Number = currentDragPoint.y - startDragPoint.y;
				switch(currentDragRole)
				{
					case LineHandleRoles.MOVE: 
						_line.startX = _backUp.startX + deltaX;
						_line.startY = _backUp.startY + deltaY;
						_line.endX = _backUp.endX + deltaX;
						_line.endY = _backUp.endY + deltaY;
						_line.bendX = _backUp.bendX + deltaX;
						_line.bendY = _backUp.bendY + deltaY;
						break;
					case LineHandleRoles.START: 
						_line.startX = _backUp.startX + deltaX;
						_line.startY = _backUp.startY + deltaY;
						break;
					case LineHandleRoles.BEND: 
						_line.bendX = _backUp.bendX + deltaX;
						_line.bendY = _backUp.bendY + deltaY;
						break;
					case LineHandleRoles.END: 
						_line.endX = _backUp.endX +  deltaX;
						_line.endY = _backUp.endY + deltaY;
						break;
				}
				internalChanges = false;
				calculatePoints();
			}
		}
		
		
		public override function onMouseUp(toolMouseInfo:ToolMouseInfo):void
		{
			if(currentDragRole != 0)
			{
				if(veryCloseTargetStart)
				{
					_line.fromObject = null;
					_line.fromPoint = veryClosePointStart;
					_line.fromObject = veryCloseTargetStart;
				}
				else
				{
					_line.fromObject = null;
				}
				if(veryCloseTargetEnd)
				{
					_line.toObject = null;
					_line.toPoint = veryClosePointEnd;
					_line.toObject = veryCloseTargetEnd;
				}
				else
				{
					_line.toObject = null;
				}
				var hasChanges:Boolean = _line.startX != _backUp.startX || _line.startY != _backUp.startY;
				hasChanges ||= _line.endX != _backUp.endX || _line.endY != _backUp.endY;
				hasChanges ||= _line.bendX != _backUp.bendX || _line.bendY != _backUp.bendY;
				hasChanges ||= _line.fromObject != _backUp.fromObject || _line.fromPoint != _backUp.fromPoint;
				hasChanges ||= _line.toObject != _backUp.toObject || _line.toPoint != _backUp.toPoint;
				if(hasChanges)
				{
					var event:LineTransformEvent = new LineTransformEvent(LineTransformEvent.TRANSFORM_LINE);
					event.oldState = _backUp;
					event.newState = _line;
					dispatcher.dispatchEvent(event);
				}
				currentDragRole = 0;
				calculatePoints();
				Logger.info("onMouseUp", this);
			}
		}
		
		public var veryClosePointStart:ConnectionPoint;
		public var veryClosePointEnd:ConnectionPoint;
		public var veryCloseTargetStart:SDObjectModel;
		public var veryCloseTargetEnd:SDObjectModel;
		
		private function calculatePoints():void
		{
			if(_line)
			{
				var start:Point = new Point(_line.startX * scaleX,_line.startY * scaleY);
				var end:Point = new Point(_line.endX * scaleX,_line.endY * scaleY);
				var bend:Point = new Point(_line.bendX * scaleX,_line.bendY * scaleY);
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
				controlPoints = [start, bend, end];
			}
			else
			{
				_connectorPoints = [];
				controlPoints = null;
			}
		}
	}
}