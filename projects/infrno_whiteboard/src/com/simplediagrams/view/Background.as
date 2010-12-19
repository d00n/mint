package com.simplediagrams.view
{
	import com.simplediagrams.events.LoadDiagramEvent;
	import com.simplediagrams.events.PropertiesEvent;
	import com.simplediagrams.events.StyleEvent;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.DiagramStyleManager;
	import com.simplediagrams.model.SDBackgroundModel;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.skins.backgroundSkins.*;
	
	import flash.events.Event;
	
	import mx.core.BitmapAsset;
	import mx.events.PropertyChangeEvent;
	import mx.graphics.BitmapFillMode;
	import mx.styles.StyleManager;
	
	import spark.components.supportClasses.SkinnableComponent;


	[SkinState("normal")]
	[SkinState("blank")]
	[Bindable]
	public class Background extends SkinnableComponent 
	{		
		
		[Inject]
		public var diagramModel:DiagramModel
		
		[Inject]
		public var diagramStyleManager:DiagramStyleManager
		
		public var backgroundImageData:BitmapAsset
		public var fillMode:String = BitmapFillMode.SCALE;
		public var tintColor:Number = 0x000000
		public var tintAlpha:Number = 0;
		
		[PostConstruct]
		public function onPostConstruct():void
		{			
			diagramModel.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
			var ImageBitmapAsset:Class = SDBackgroundModel(diagramModel.currSDBackgroundModel).imageDataClass
			backgroundImageData = new ImageBitmapAsset()
			this.invalidateSkinState()
		}
		
		[PreDestroy]
		public function onPreDestroy():void
		{			
			diagramModel.removeEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
		}
		
		override protected function getCurrentSkinState():String 
		{
			if (SDBackgroundModel(diagramModel.currSDBackgroundModel).backgroundName=="Blank")
			{
				return "blank"
			}
			return "normal"		
		}
		
		public function Background()
		{
			super();						
		}
						
		protected function onModelChange(event:PropertyChangeEvent):void
		{
			if( event.property == "currSDBackgroundModel" && diagramModel && diagramModel.currSDBackgroundModel)
			{
				var bgModel:SDBackgroundModel = SDBackgroundModel(diagramModel.currSDBackgroundModel)
				var ImageBitmapAsset:Class = bgModel.imageDataClass
				fillMode = bgModel.fillMode
				tintAlpha = bgModel.tintAlpha
				tintColor = bgModel.tintColor
				backgroundImageData = new ImageBitmapAsset()				
			}
			this.invalidateSkinState()
		}
	
		
		
	}
}