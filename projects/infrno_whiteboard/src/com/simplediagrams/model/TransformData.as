package com.simplediagrams.model
{
	import flash.geom.Matrix;
	import flash.geom.Point;

	public class TransformData
	{
		public function TransformData(x:Number = 0, y:Number = 0, width:Number = 0, hegiht:Number = 0, rotation:Number = 0)
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = hegiht;
			this.rotation = rotation;
		}
		
		public var x:Number=0;
		public var y:Number=0;
		public var width:Number=0;
		public var height:Number=0;
		public var rotation:Number=0;
		
		public function scale(scaleX:Number, scaleY:Number):void
		{
			x *= scaleX;
			y *= scaleY;
			width *= scaleX;
			height *= scaleY;
		}
		
		public function clone():TransformData
		{
			var res:TransformData = new TransformData();
			res.x = x;
			res.y = y;
			res.rotation = rotation;
			res.width = width;
			res.height = height;
			return res;
		}
		
		public function getMatrix():Matrix
		{
			var matrix:Matrix = new Matrix();
			matrix.rotate(rotation * Math.PI/ 180);
			matrix.translate(x, y );
			return matrix;
		}
		
		public function get left():Number
		{
			if(rotation == 0)
				return x;
			else
			{
				var matrix:Matrix = getMatrix();
				var point:Point = new Point(0, 0);
				point = matrix.transformPoint(point);
				var minX:Number = point.x;
				point = new Point(width, 0);
				point = matrix.transformPoint(point);
				minX = Math.min(minX, point.x);
				point = new Point(0, height);
				point = matrix.transformPoint(point);
				minX = Math.min(minX, point.x);
				point = new Point(width, height);
				point = matrix.transformPoint(point);
				minX = Math.min(minX, point.x);
				return minX;
			}
		}

		public function get right():Number
		{
			if(rotation == 0)
				return x + width;
			else
			{
				var matrix:Matrix = getMatrix();
				var point:Point = new Point(0, 0);
				point = matrix.transformPoint(point);
				var minX:Number = point.x;
				point = new Point(width, 0);
				point = matrix.transformPoint(point);
				minX = Math.max(minX, point.x);
				point = new Point(0, height);
				point = matrix.transformPoint(point);
				minX = Math.max(minX, point.x);
				point = new Point(width, height);
				point = matrix.transformPoint(point);
				minX = Math.max(minX, point.x);
				return minX;
			}
		}

		public function get top():Number
		{
			if(rotation == 0)
				return y;
			else
			{
				var matrix:Matrix = getMatrix();
				var point:Point = new Point(0, 0);
				point = matrix.transformPoint(point);
				var res:Number = point.y;
				point = new Point(width, 0);
				point = matrix.transformPoint(point);
				res = Math.min(res, point.y);
				point = new Point(0, height);
				point = matrix.transformPoint(point);
				res = Math.min(res, point.y);
				point = new Point(width, height);
				point = matrix.transformPoint(point);
				res = Math.min(res, point.y);
				return res;
			}
		}

		public function get bottom():Number
		{
			if(rotation == 0)
				return y + height;
			else
			{
				var matrix:Matrix = getMatrix();
				var point:Point = new Point(0, 0);
				point = matrix.transformPoint(point);
				var res:Number = point.y;
				point = new Point(width, 0);
				point = matrix.transformPoint(point);
				res = Math.max(res, point.y);
				point = new Point(0, height);
				point = matrix.transformPoint(point);
				res = Math.max(res, point.y);
				point = new Point(width, height);
				point = matrix.transformPoint(point);
				res = Math.max(res, point.y);
				return res;
			}
		}
		
		public function get center():Number
		{
			if(rotation == 0)
				return x + width/2.0;
			else
				return (left + right)/2;	
		}
		
		public function get middle():Number
		{
			if(rotation == 0)
				return y + height/2.0;
			else
				return (top + bottom)/2;
		}
	}
}