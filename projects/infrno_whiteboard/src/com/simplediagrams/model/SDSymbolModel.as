package com.simplediagrams.model
{
	[Bindable]
	[RemoteClass]
	public class SDSymbolModel extends SDObjectModel implements IResourceLink
	{	
		public static const TEXT_POSITION_ABOVE:String = "above"
		public static const TEXT_POSITION_TOP:String = "top"
		public static const TEXT_POSITION_MIDDLE:String = "middle"
		public static const TEXT_POSITION_BOTTOM:String = "bottom"
		public static const TEXT_POSITION_BELOW:String = "below"
			
		public var libraryName:String;	
		public var symbolName:String;
		public var fontWeight:String  = "normal";
		public var fontFamily:String  = "Arial";
		public var textAlign:String  = "left";
		public var fontSize:Number = 12;
		public var textPosition:String = TEXT_POSITION_TOP;
		public var text:String  = "";
		public var displayName:String; 
		public var lineWeight:Number = 1;
		public var isBitmap:Boolean = false;
		public var maintainAspectRatio:Boolean = true	//for swfs
		public var startWithDefaultColor:Boolean = false //for swfs
		
		public function SDSymbolModel(libraryName:String = "", symbolName:String="", displayName:String = "")
		{
			super();
			this.libraryName = libraryName;
			this.symbolName = symbolName;
			if(displayName == "")
				displayName = symbolName;
			this.displayName = symbolName;
		}
		
		
	}
}