package com.simplediagrams.view.SDComponents.lineEndings
{
	import spark.primitives.Graphic;

	public class LineEnding extends Graphic
	{
		public function LineEnding()
		{
		}
		
		private var _lineWeight:Number = 1;

		public function get lineWeight():Number
		{
			return _lineWeight;
		}

		public function set lineWeight(value:Number):void
		{
			_lineWeight = value;
			invalidateProperties();
		}

		private var _lineColor:Number = 0; 

		public function get lineColor():Number
		{
			return _lineColor;
		}

		public function set lineColor(value:Number):void
		{
			_lineColor = value;
			invalidateProperties();
		}

	}
}