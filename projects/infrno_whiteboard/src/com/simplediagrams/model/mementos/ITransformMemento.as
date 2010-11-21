package com.simplediagrams.model.mementos
{
	public interface ITransformMemento
	{
		function get sdID():String
		function set sdID(value:String):void
		function get color():Number		
		function set color(value:Number):void
		function get depth():int
		function set depth(value:int):void
		function get rotation():Number
		function set rotation(value:Number):void
		function get width():Number
		function set width(value:Number):void
		function get height():Number
		function set height(value:Number):void
		function get y():Number
		function set y(value:Number):void
		function get x():Number
		function set x(value:Number):void
		
	}
}