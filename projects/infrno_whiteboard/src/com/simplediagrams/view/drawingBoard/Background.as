package com.simplediagrams.view.drawingBoard
{
	import com.simplediagrams.events.LoadDiagramEvent;
	import com.simplediagrams.events.PropertiesEvent;
	import com.simplediagrams.events.StyleEvent;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.SDBackgroundModel;
	import com.simplediagrams.model.libraries.ImageBackground;
	import com.simplediagrams.model.libraries.ImageShape;
	import com.simplediagrams.model.libraries.Library;
	import com.simplediagrams.model.libraries.LibraryItem;
	import com.simplediagrams.model.libraries.SWFBackground;
	import com.simplediagrams.model.libraries.VectorShape;
	import com.simplediagrams.util.Logger;
	
	import flash.events.Event;
	
	import mx.core.BitmapAsset;
	import mx.events.PropertyChangeEvent;
	import mx.graphics.BitmapFillMode;
	import mx.styles.StyleManager;
	
	import spark.components.supportClasses.SkinnableComponent;

	[Bindable]
	public class Background extends SkinnableComponent 
	{		
		
		private var _diagramModel:DiagramModel
		
		[Inject]
		public var libraryManager:LibraryManager;

		public var backgroundSWF:Object; //use this when background is swf
		
		public var backgroundImage:Object; //use this when background is bitmap
		
		public var fillMode:String = BitmapFillMode.SCALE;
		public var tintColor:Number = 0x000000
		public var tintAlpha:Number = 0;
		
		[Inject(source='diagramManager.diagramModel',bind='true')]
		public function get diagramModel():DiagramModel
		{
			return _diagramModel;
		}

		public function set diagramModel(value:DiagramModel):void
		{
			if(_diagramModel)
			{
				diagramModel.removeEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
			}
			_diagramModel = value;
			if(_diagramModel)
			{
				_diagramModel.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
			}
			invalidateProperties();
		}
		
		public function Background()
		{
			super();						
		}
						
		protected function onModelChange(event:PropertyChangeEvent):void
		{
			invalidateProperties();
		}
		
		protected override function commitProperties():void
		{
			super.commitProperties();
			if (diagramModel==null || diagramModel.background==null || libraryManager == null) return;
			var bgModel:SDBackgroundModel = SDBackgroundModel(diagramModel.background)
			var resource:LibraryItem = libraryManager.getLibraryItem(bgModel.libraryName, bgModel.symbolName);
			if (resource is ImageBackground)
			{
				backgroundImage = libraryManager.getAssetData(resource, (resource as ImageBackground).path);
				backgroundSWF = null
			}
			else if (resource is SWFBackground)
			{
				backgroundSWF = libraryManager.getAssetData(resource, (resource as SWFBackground).path);
				backgroundImage = null
			}
			fillMode = bgModel.fillMode				
			tintAlpha = bgModel.tintAlpha
			tintColor = bgModel.tintColor				
		}
	}
}