package com.simplediagrams.model.dao
{
	import flash.utils.ByteArray;

	
	[Table(name="custom_symbols")]
	public class CustomSymbolDAO extends DAO
	{
		
		protected var _libraryID:int
		
		protected var _symbolName:String = ""
		
		protected var _initialWidth:Number = 50;
		
		protected var _initialHeight:Number = 50;
			
		protected var _imageData:ByteArray;
							
		public function CustomSymbolDAO()
		{
		}
		
		
		[Column(name="library_id")]
		public function get libraryID():int
		{
			return _libraryID
		}
		
		public function set libraryID(value:int):void
		{
			_libraryID = value
		}
		
		
		
		
		[Column(name="symbol_name")]
		public function get symbolName():String
		{
			return _symbolName
		}
		
		public function set symbolName(value:String):void
		{
			_symbolName = value
		}
		
		
		[Column(name="initial_width")]
		public function get initialWidth():Number
		{
			return _initialWidth
		}
		
		public function set initialWidth(value:Number):void
		{
			_initialWidth = value
		}
		
		[Column(name="initial_height")]
		public function get initialHeight():Number
		{
			return _initialHeight
		}
		
		public function set initialHeight(value:Number):void
		{
			_initialHeight = value
		}
		
		
		
		[Column(name="image_data")]
		public function get imageData():ByteArray
		{
			return _imageData
		}
		
		public function set imageData(value:ByteArray):void
		{
			_imageData = value
		}
	}
}

