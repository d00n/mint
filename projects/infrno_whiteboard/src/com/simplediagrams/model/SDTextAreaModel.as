package com.simplediagrams.model
{
	import com.simplediagrams.events.RemoteSharedObjectEvent;
	
	[Bindable]
	[RemoteClass]
	public class SDTextAreaModel extends SDObjectModel
	{
		public static var NO_BACKGROUND:String = "noBackground"
		public static var STICKY_NOTE:String = "stickyNote"
		public static var PAPER_WITH_TAPE:String = "paperWithTape"
		public static var INDEX_CARD:String = "indexCard"
		
		public var styleName:String = SDTextAreaModel.NO_BACKGROUND
		private var _text:String = ""
		public var fontSize:Number = 12
		public var fontWeight:String = "normal";
		public var textAlign:String = "left";
		public var fontFamily:String = "Arial";
		public var backgroundColor:uint = 0x000000
		public var showTape:Boolean = true

		public function SDTextAreaModel()
		{
			super();
			this.width = 200;
			this.height = 150;
			allowRotation = false;
		}
		
		public function get text():String{
			return _text;
		}
		public function set text(value:String):void{
			_text = value;		
		}
	}
}