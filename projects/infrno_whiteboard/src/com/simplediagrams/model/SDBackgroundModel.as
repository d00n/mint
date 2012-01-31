package com.simplediagrams.model
{
	import flash.display.Bitmap;
	import flash.utils.ByteArray;
	
	import mx.graphics.BitmapFillMode;
	
	[Bindable]
	[RemoteClass]
	public class SDBackgroundModel implements IResourceLink
	{
		public var libraryName:String;	
		public var symbolName:String;		
		public var tintColor:Number = 0x000000;
		public var tintAlpha:Number = 0;
			
		//the following are used for bitmap backgrounds
		public var fillMode:String = BitmapFillMode.REPEAT
		
		
		public function SDBackgroundModel(libraryName:String = "", symbolName:String = "", fillMode:String = BitmapFillMode.REPEAT)
		{
			this.libraryName = libraryName;
			this.symbolName = symbolName;
		}
		
	}
}