package com.simplediagrams.model
{
	
	
	[Bindable]
	public class AnnotationToolModel
	{	
		
		public static const IMAGE_TOOL:String = "imageTool"
		public static const STICKY_NOTE_TOOL:String = "stickyNoteTool"
		public static const INDEX_CARD:String = "indexCard"
			
		
		public var toolTip:String = ""
		public var type:String = ""
		public var displayName:String = ""
		public var iconClass:Class
				
		
	}
}