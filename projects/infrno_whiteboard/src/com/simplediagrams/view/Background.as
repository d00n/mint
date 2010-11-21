package com.simplediagrams.view
{
	import com.simplediagrams.events.LoadDiagramEvent;
	import com.simplediagrams.events.PropertiesEvent;
	import com.simplediagrams.events.StyleEvent;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.DiagramStyleManager;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.skins.backgroundSkins.*;
	
	import flash.events.Event;
	
	import mx.styles.StyleManager;
	
	;
	
	import spark.components.supportClasses.SkinnableComponent;


	[SkinState("normal")]
	[SkinState("disabled")]
	[Bindable]
	public class Background extends SkinnableComponent 
	{		
		
		[Inject]
		public var diagramModel:DiagramModel
		
		[Inject]
		public var diagramStyleManager:DiagramStyleManager
		
		public var fillColor:Number = 0xFFFFFF;
				
		public function Background()
		{
			super();				
			this.setStyle("skinClass",Class(ChalkboardSkin))			
		}
		
		[Mediate("PropertiesEvent.PROPERTIES_EDITED")]
		public function onDiagramPropertiesEdited(event:Event):void
		{
			fillColor = diagramModel.baseBackgroundColor			
		}
				
		[Mediate("LoadDiagramEvent.DIAGRAM_LOADED")]
		public function onDiagramLoaded(event:LoadDiagramEvent):void
		{
			fillColor = diagramModel.baseBackgroundColor
		}
				
		[PostConstruct]
		public function onPostConstruct():void
		{
			setBackgroundStyle(diagramStyleManager.currStyle)
		}			
		
		[Mediate(event="StyleEvent.STYLE_CHANGED")]
		public function onStyleChange(event:StyleEvent):void
		{
			setBackgroundStyle(event.styleName)
		}
		
		protected function setBackgroundStyle(styleName:String):void
		{
			switch(styleName)
			{
				case DiagramStyleManager.CHALKBOARD_STYLE:
					this.setStyle("skinClass",Class(ChalkboardSkin))
					break
				
				case DiagramStyleManager.WHITEBOARD_STYLE:
					this.setStyle("skinClass",Class(WhiteboardSkin))				
					break
										
				case DiagramStyleManager.BASIC_STYLE:
					Logger.debug("setting fill Color to : " + fillColor, this)				
					fillColor = diagramModel.baseBackgroundColor
					this.setStyle("skinClass",Class(BasicSkin))					
					break
					
			}
		}
	
		
		
	}
}