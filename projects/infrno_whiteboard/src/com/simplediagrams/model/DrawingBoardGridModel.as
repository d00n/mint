package com.simplediagrams.model
{
	import com.simplediagrams.util.Logger;
	
	[Bindable]
	public class DrawingBoardGridModel
	{
		protected var _gridInterval:Number 	= 50;		
		protected var _gridColor:uint 			= 0;
		protected var _gridThickness:Number = 0;
		protected var _gridAlpha:Number 		= 1;
		protected var _showGrid:Boolean	 		= false;
			
		public function DrawingBoardGridModel()
		{
			Logger.debug("DrawingBoardGridModel() constructor")
		}
		
		
		public function get gridInterval():Number		{
			return _gridInterval;
		}		
		public function set gridInterval(v:Number):void		{
			_gridInterval = v;
		}
		
		public function get gridColor():uint		{
			return _gridColor;
		}		
		public function set gridColor(v:uint):void		{
			_gridColor = v;
		}
		
		public function get gridThickness():Number		{
			return _gridThickness;
		}		
		public function set gridThickness(v:Number):void		{
			_gridThickness = v;
		}
		
		public function get gridAlpha():Number		{
			return _gridAlpha;
		}		
		public function set gridAlpha(v:Number):void		{
			_gridAlpha = v;
		}		
		
		public function get showGrid():Boolean		{
			return _showGrid;
		}		
		public function set showGrid(v:Boolean):void		{
			_showGrid = v;
		}
	}
}