package com.simplediagrams.model
{
	import flash.display.Bitmap;
	import flash.utils.ByteArray;
	
	import mx.graphics.BitmapFillMode;
	
	[Bindable]
	public class SDBackgroundModel extends SDObjectModel
	{
		
		public var libraryName:String	
		public var backgroundName:String
		public var isCustom:Boolean = false
		public var displayName:String
		public var fillMode:String = BitmapFillMode.SCALE
		public var thumbnailDataClass:Class
		public var imageDataClass:Class
		public var isTileOnly:Boolean = false
		
		public var tintColor:Number = 0x000000
		public var tintAlpha:Number = 0
		
		public function SDBackgroundModel(bgName:String, bp:Class, thumbnail:Class, tileOnly:Boolean=false, defaultFillMode:String=BitmapFillMode.REPEAT)
		{
			isTileOnly = tileOnly
			backgroundName = bgName
			displayName = bgName
			imageDataClass = bp
			thumbnailDataClass = thumbnail
			if (isTileOnly)
			{
				fillMode = BitmapFillMode.REPEAT
			}
			else
			{
				fillMode = defaultFillMode
			}
		}
	}
}