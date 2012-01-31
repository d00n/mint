package com.simplediagrams.model
{
	import com.simplediagrams.util.Logger;
	
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.events.PropertyChangeEvent;

	[Bindable]
	[RemoteClass]
	public class SDLineModel extends SDObjectModel
	{
		public static const LINE_ENDING_NONE:Number = 0;
		public static const LINE_ENDING_STOP:Number = 1;
		public static const LINE_ENDING_ARROW:Number = 2;
		public static const LINE_ENDING_SOLID_ARROW:Number = 3;
		public static const LINE_ENDING_CIRCLE:Number = 4;
		public static const LINE_ENDING_SOLID_CIRCLE:Number = 5;
		public static const LINE_ENDING_SOLID_DIAMOND:Number = 6;
		public static const LINE_ENDING_EMPTY_DIAMOND:Number = 7;
		public static const LINE_ENDING_HALF_CIRCLE:Number = 8;
		
		public static const TEXT_INSIDE_CURVE:String = "textInsideCurve"
		public static const TEXT_OUTSIDE_CURVE:String = "textOutsideCurve"
		public static const TEXT_FOLLOW_CURVE:String = "textFollowCurve"
		
		public static const LINE_STYLE_SOLID:uint = 0
		public static const LINE_STYLE_DASHED:uint = 1
		
		private var _startTarget:SDObjectModel;
		
		private var _endConnectionPoint:ConnectionPoint;
		
		private var _endTarget:SDObjectModel;

		protected var numStyles:int = 5;
		
		protected var _startX:Number = 0;
		protected var _startY:Number = 0;
		protected var _endX:Number = 100;
		protected var _endY:Number = 100;
		protected var _bendX:Number = 50;
		protected var _bendY:Number = 40;
		protected var _lineWeight:Number = 1;
		
		public var lineStyle:int = SDLineModel.LINE_STYLE_SOLID;
		public var startLineStyle:int = SDLineModel.LINE_ENDING_STOP	
		public var endLineStyle:int = SDLineModel.LINE_ENDING_ARROW
		public var textAlignStyle:String = TEXT_FOLLOW_CURVE;	
		
		public var text:String = "";
		public var fontSize:Number = 12;
		public var fontColor:Number = 0xFFFFFF;
		
		public function SDLineModel()
		{
			connectionPoints = [];
		}
		
		private var _startConnectionPoint:ConnectionPoint;

		
		public function get startX():Number
		{
			return _startX
		}
		
		public function set startX(value:Number):void
		{
			if (isNaN(value))
			{
				Logger.error("startX was passed NaN", this)
				value = 0
			}
			_startX = value
		}
		
		public function get startY():Number
		{
			return _startY
		}
		
		public function set startY(value:Number):void
		{
			if (isNaN(value))
			{
				Logger.error("startY was passed NaN", this)
				value = 0
			}
			_startY = value
		}
		
		
		
		
		public function get endX():Number
		{
			return _endX
		}
		
		public function set endX(value:Number):void
		{
			if (isNaN(value))
			{
				Logger.error("endX was passed NaN", this)
				value = 0
			}
			_endX = value
		}
		
		public function get endY():Number
		{
			return _endY
		}
		
		public function set endY(value:Number):void
		{
			if (isNaN(value))
			{
				Logger.error("endY was passed NaN", this)
				value = 0
			}
			_endY = value
		}
		
		
		
		public function get bendX():Number
		{
			return _bendX
		}
		
		public function set bendX(value:Number):void
		{
			if (isNaN(value))
			{
				Logger.error("endX was passed NaN", this)
				value = 0
			}
			_bendX = value
		}
		
		public function get bendY():Number
		{
			return _bendY
		}
		
		public function set bendY(value:Number):void
		{
			if (isNaN(value))
			{
				Logger.error("bendY was passed NaN", this)
				value = 0
			}
			_bendY = value
		}
		
		
		
		
		public function get lineWeight():Number
		{
			return _lineWeight
		}
		
		public function set lineWeight(value:Number):void
		{
			if (isNaN(value))
			{
				Logger.error("lineWeight was passed NaN", this)
				value = 0
			}
			_lineWeight = value
		}
		
		
		
		
		
		
		
		public function get fromPoint():ConnectionPoint
		{
			return _startConnectionPoint;
		}

		public function set fromPoint(value:ConnectionPoint):void
		{
			if(_startConnectionPoint != value)
			{
				_startConnectionPoint = value;
				onStartPropertyChange(null);
			}
		}

		public function get fromObject():SDObjectModel
		{
			return _startTarget;
		}

		public function set fromObject(value:SDObjectModel):void
		{
			if(_startTarget)
				_startTarget.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onStartPropertyChange);
			if(_startTarget != value)
			{
				_startTarget = value;
				onStartPropertyChange(null);
			}
			if(_startTarget)
				_startTarget.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onStartPropertyChange);
		}
		
		private function onStartPropertyChange(event:Event):void
		{
			if(_startTarget && fromPoint)
			{
				var matrix:Matrix = new Matrix();
				matrix.scale(_startTarget.width, _startTarget.height);
				matrix.rotate(_startTarget.rotation * Math.PI / 180);
				matrix.translate(_startTarget.x, _startTarget.y);
				var point:Point = matrix.transformPoint(new Point(fromPoint.x, fromPoint.y));
				startX = point.x;
				startY = point.y;
			}
		}
		
		
		private function onEndPropertyChange(event:Event):void
		{
			if(_endTarget && toPoint)
			{
				var matrix:Matrix = new Matrix();
				matrix.scale(_endTarget.width, _endTarget.height);
				matrix.rotate(_endTarget.rotation * Math.PI / 180);
				matrix.translate(_endTarget.x, _endTarget.y);
				var point:Point = matrix.transformPoint(new Point(toPoint.x, toPoint.y));
				endX = point.x;
				endY = point.y;
			}
		}

		public function get toPoint():ConnectionPoint
		{
			return _endConnectionPoint;
		}

		public function set toPoint(value:ConnectionPoint):void
		{
			if(_endConnectionPoint != value)
			{
				_endConnectionPoint = value;
				onEndPropertyChange(null);
			}
		}

		

		public function get toObject():SDObjectModel
		{
			return _endTarget;
		}

		public function set toObject(value:SDObjectModel):void
		{
			if(_endTarget)
				_endTarget.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onEndPropertyChange);
			if(_endTarget != value)
			{
				_endTarget = value;
				onEndPropertyChange(null);
			}
			if(_endTarget)
				_endTarget.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onEndPropertyChange);
		}

		
		public override function getTransform():TransformData
		{
			var left:Number;
			var right:Number;
			var bottom:Number;
			var top:Number;
			if(startX > endX)
			{
				left = endX;
				right = startX;
			}
			else
			{
				left = startX;
				right = endX;
			}
			if(startY > endY)
			{
				top = endY;
				bottom = startY;
			}
			else
			{
				top = startY;
				bottom = endY;
			}
			var controlX:Number  = bendX;
			var controlY:Number  = bendY;
			var t:Number;
			if(controlX < left || controlX > right)
			{
				t = (startX - bendX) / (startX- 2 * bendX + endX);
				controlX = startX * (1 - t) * (1 - t) + 2 * bendX *(1-t)* t + endX * t * t;
			}
			if(controlY < top || controlY > bottom)
			{
				t = (startY - bendY) / (startY- 2 * bendY + endY);
				controlY = startY * (1 - t) * (1 - t) + 2 * bendY *(1-t)* t + endY * t * t;
			}
			
			if(controlX < left)
				left = controlX;
			if(controlX > right)
				right = controlX;
			
			if(controlY < top)
				top = controlY;
			if(controlY > bottom)
				bottom = controlY;

			return new TransformData(left, top, right - left , bottom - top, 0);
		}
		
		public override function applyTransform(data:TransformData, originalTransform:TransformData, originalObject:SDObjectModel):void
		{
			var matrix:Matrix = new Matrix();
			matrix.rotate(data.rotation * Math.PI / 180);
			matrix.scale(data.width / originalTransform.width, data.height/originalTransform.height);
			matrix.translate(data.x, data.y);
			var originalLine:SDLineModel = originalObject as SDLineModel;
			if(fromObject == null)
			{
				var start:Point = matrix.transformPoint(new Point(originalLine.startX  - originalTransform.x, originalLine.startY - originalTransform.y));
				startX = start.x;
				startY = start.y;
			}
			if(toObject == null)
			{
				var end:Point = matrix.transformPoint(new Point(originalLine.endX  - originalTransform.x, originalLine.endY - originalTransform.y));
				endX = end.x;
				endY = end.y;
			}
			var bend:Point = matrix.transformPoint(new Point(originalLine.bendX  - originalTransform.x, originalLine.bendY - originalTransform.y));
			bendX = bend.x;
			bendY = bend.y;
		}
	}
}