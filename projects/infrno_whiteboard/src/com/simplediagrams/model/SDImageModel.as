package com.simplediagrams.model
{
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;

	[Bindable]
	[RemoteClass]
	public class SDImageModel extends SDObjectModel implements IResourceLink
	{
		
		public static const STYLE_NONE:String = "none";
		public static const STYLE_BORDER:String = "border";
		public static const STYLE_TAPE:String = "tape";
		public static const STYLE_BORDER_AND_TAPE:String = "photoStyle";

		private var _imageData:ByteArray
		private var _styleName:String = STYLE_NONE;
		public var libraryName:String;
		public var symbolName:String;
    
		[Transient]
		public var origWidth:int
		[Transient]
		public var origHeight:int
    
		private var _imageURL:String = "";
		
		public function SDImageModel()
		{
			super();
//			this.width = 350
//			this.height = 250
		}
		public function get imageData():ByteArray
		{
			return _imageData;
		}

		public function set imageData(v:ByteArray):void
		{
			_imageData = v;
		}
		
		public function get imageURL():String{
			return _imageURL;			
		}
		
		public function set imageURL(value:String):void{
			_imageURL = value;		
		}
		
		private function loadProgress(event:ProgressEvent):void
		{   
			// TODO loading bar in the image frame for extra credit
			var percentLoaded:Number = Math.round((event.bytesLoaded/event.bytesTotal) * 100);
			trace("SDImageModel Loading: "+percentLoaded+"%");
		}
		
		public function loadComplete(event:Event):void
		{
			trace("SDImageModel Complete");
			// TODO: ....and where's Johnny?
			//			addChild(loader);
		}

		
		public function get styleName():String
		{
			return _styleName;
		}

		public function set styleName(v:String):void
		{
			_styleName = v;
		}
		
	}
}