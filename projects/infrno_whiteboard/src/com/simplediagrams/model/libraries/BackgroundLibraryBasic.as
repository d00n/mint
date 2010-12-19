package com.simplediagrams.model.libraries
{
	import com.simplediagrams.model.SDBackgroundModel;
	
	import flash.display.Bitmap;	
	import mx.graphics.BitmapFillMode;
	
	public class BackgroundLibraryBasic extends BackgroundsLibrary
	{
		
		[Bindable]
		[Embed(source='assets/backgrounds/blank.png')]
		public var Blank:Class
		
		[Bindable]
		[Embed(source='assets/backgrounds/chalkboard.png')]
		public var Chalkboard:Class
						
		[Bindable]
		[Embed(source='assets/backgrounds/whiteboard.png')]
		public var Whiteboard:Class
		
		
		[Bindable]
		[Embed(source='assets/backgrounds/graph_paper_tile.png')]
		public var GraphPaper:Class
		
		[Bindable]
		[Embed(source='assets/backgrounds/graph_paper_thumbnail.png')]
		public var GraphPaperThumbnail:Class
		
		
		[Bindable]
		[Embed(source='assets/backgrounds/napkin.png')]
		public var Napkin:Class
		
		[Bindable]
		[Embed(source='assets/backgrounds/napkin_thumbnail.png')]
		public var NapkinThumbnail:Class
		
		
		[Bindable]
		[Embed(source='assets/backgrounds/graph_paper_2_tile.png')]
		public var GraphPaper2:Class
		
		[Bindable]
		[Embed(source='assets/backgrounds/graph_paper_2_thumbnail.png')]
		public var GraphPaper2Thumbnail:Class
				
		[Bindable]
		[Embed(source='assets/backgrounds/notebook_paper.png')]
		public var NotebookPaper:Class
				
		[Bindable]
		[Embed(source='assets/backgrounds/notebook_paper_thumbnail.png')]
		public var NotebookPaperThumbnail:Class
		
		
		[Bindable]
		[Embed(source='assets/backgrounds/vanilla_paper.png')]
		public var VanillaPaper:Class
		
		[Bindable]
		[Embed(source='assets/backgrounds/vanilla_paper_thumbnail.png')]
		public var VanillaPaperThumbnail:Class
		
		
		
		public function BackgroundLibraryBasic()
		{
			this.isBackgroundsLibrary = true
			libraryName ="com.simplediagrams.backgroundLibrary.basic"
			displayName = "Basic"
			super()
		}
		
		override public function initShapes():void
		{			
			addLibraryItem( new SDBackgroundModel("Blank", Blank, Blank))
			addLibraryItem( new SDBackgroundModel("Chalkboard", Chalkboard, Chalkboard, false))
			addLibraryItem( new SDBackgroundModel("Whiteboard", Whiteboard, Whiteboard, false))
			addLibraryItem(new SDBackgroundModel("GraphPaper",  GraphPaper, GraphPaperThumbnail, true))
			addLibraryItem(new SDBackgroundModel("GraphPaper2",  GraphPaper2, GraphPaper2Thumbnail, true))
			addLibraryItem(new SDBackgroundModel("Napkin",  Napkin, NapkinThumbnail, false))
			addLibraryItem( new SDBackgroundModel("Notebook", NotebookPaper, NotebookPaperThumbnail))
			addLibraryItem( new SDBackgroundModel("Vanilla", VanillaPaper, VanillaPaperThumbnail))
			//addLibraryItem(new SDBackgroundModel("GraphPaper2",  GraphPaper2, GraphPaper2Thumbnail))
		}
		
	}
		
	
}