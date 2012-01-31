package com.simplediagrams.model
{
	
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.components.StickyNoteIcon;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	

	[Bindable]
	public class DefaultToolsManager  extends EventDispatcher
	{
					
		[Embed(source='assets/tool_shapes/default_tools.swf', symbol='PhotoTool')]
		public var PhotoToolIcon:Class;
		
			
		
		[Embed(source='assets/tool_shapes/default_tools.swf', symbol='IndexCard')]
		public var IndexCard:Class		
		
			
						
		public var annotToolsAC:ArrayCollection = new ArrayCollection()
					
		public function DefaultToolsManager()
		{			
			var annot:AnnotationToolModel = new AnnotationToolModel()
			annot.type = AnnotationToolModel.IMAGE_TOOL
			annot.toolTip = "Photo" 
			annot.displayName = "photo"
			annot.iconClass = PhotoToolIcon
			annotToolsAC.addItem(annot)
						
			annot = new AnnotationToolModel()
			annot.type = AnnotationToolModel.STICKY_NOTE_TOOL
			annot.toolTip = "Sticky Note" 
			annot.displayName = "stickyNote"
			annot.iconClass = StickyNoteIcon
			annotToolsAC.addItem(annot)
				
			annot = new AnnotationToolModel()
			annot.type = AnnotationToolModel.INDEX_CARD
			annot.toolTip = "Index Card" 
			annot.displayName = "indexCard"
			annot.iconClass = IndexCard
			annotToolsAC.addItem(annot)
								
			annotToolsAC.refresh()
			
		}
		
		
	}
}