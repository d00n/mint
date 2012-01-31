package com.simplediagrams.model
{
	[Bindable]	
	[RemoteClass]
	public class SDPencilDrawingModel extends SDObjectModel
	{
		public var linePath:String = "";
		public var lineWeight:Number = 1;
		
		public function SDPencilDrawingModel()
		{
		}
	}
}