package com.simplediagrams.model
{
	[Bindable]
	[RemoteClass]
	public class SDImageModel extends SDObjectModel implements IResourceLink
	{
		
		public static const STYLE_NONE:String = "none";
		public static const STYLE_BORDER:String = "border";
		public static const STYLE_TAPE:String = "tape";
		public static const STYLE_BORDER_AND_TAPE:String = "photoStyle";

		public var libraryName:String;
		public var symbolName:String;
		public var styleName:String = STYLE_BORDER_AND_TAPE;
		
		public function SDImageModel()
		{
			super();
			this.width = 350
			this.height = 250
		}
	}
}