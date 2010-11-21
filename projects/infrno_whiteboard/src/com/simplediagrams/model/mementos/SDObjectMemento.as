package com.simplediagrams.model.mementos
{
	public class SDObjectMemento implements ITransformMemento
	{
		
		private var _sdID:String = ""
		private var _x:Number
		private var _y:Number
		private var _height:Number
		private var _width:Number
		private var _rotation:Number
		private var _depth:int
		private var _color:Number
		
		public function SDObjectMemento()
		{
		}

		
		public function get sdID():String
		{
			return _sdID;
		}
		
		public function set sdID(value:String):void
		{
			_sdID = value;
		}
		
		public function get color():Number
		{
			return _color;
		}

		public function set color(value:Number):void
		{
			_color = value;
		}

		public function get depth():int
		{
			return _depth;
		}

		public function set depth(value:int):void
		{
			_depth = value;
		}

		public function get rotation():Number
		{
			return _rotation;
		}

		public function set rotation(value:Number):void
		{
			_rotation = value;
		}

		public function get width():Number
		{
			return _width;
		}

		public function set width(value:Number):void
		{
			_width = value;
		}

		public function get height():Number
		{
			return _height;
		}

		public function set height(value:Number):void
		{
			_height = value;
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
		}

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
		}
		
		public function cloneBaseProperties(memento:SDObjectMemento):SDObjectMemento
		{
			memento.x = _x
			memento.y = _y
			memento.width = _width
			memento.height = _height
			memento.color = _color
			memento.depth = _depth
			memento.rotation = _rotation
			return memento
		}

	}
}