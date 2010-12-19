package com.simplediagrams.view.SDComponents
{
	
	import com.simplediagrams.events.LoadImageEvent;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.util.Logger;
	
	import flash.utils.ByteArray;
	
	import mx.controls.Image
	import mx.events.PropertyChangeEvent;

	[SkinState("normal")]
	[SkinState("border")]
	[SkinState("tape")]
	[SkinState("photoStyle")]
	[Bindable]	
	public class SDImage extends SDBase implements ISDComponent
	{	
					
		private var _model:SDImageModel
		
		public var imageData:ByteArray		
		
		[SkinPart(required="true")]		
		public var imageHolder:Image;
		
		public var imageStyle:String
		public var tapeVisible:Boolean
		public var borderVisible:Boolean
		
		public function SDImage()
		{
			super();
			this.setStyle("skinClass", Class(SDImageSkin))
		}
		
		protected function onImageLoaded(event:Event):void
		{
			_model.origWidth = imageHolder.width
			_model.origHeight = imageHolder.height
		}
	
		public function onAddImageClick():void
		{
			Logger.debug("onAddImageClick()", this)
			var evt:LoadImageEvent = new LoadImageEvent(LoadImageEvent.BROWSE_FOR_IMAGE, true)
			evt.model = _model
			dispatchEvent(evt)
		}
		
		public function set objectModel(objectModel:SDObjectModel):void
		{
			Logger.debug("set model() model: " + objectModel, this)         
            _model = SDImageModel(objectModel)
            
            //redraw();
            x = _model.x;
            y = _model.y;         
			this.width = _model.width
			this.height = _model.height  
			this.rotation = _model.rotation
			this.imageData = _model.imageData
			this.depth = _model.depth;
            imageStyle = _model.styleName
            _model.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
        			
			this.invalidateSkinState()
			
		}
		

		
		public override function get objectModel():SDObjectModel
		{
			return _model
		}
				
		
        override protected function onModelChange(event:PropertyChangeEvent):void
		{
			super.onModelChange(event)
				
			switch(event.property)
			{    
				
				case "imageData":
					Logger.debug("imageData changed", this)
					imageData = _model.imageData
					this.invalidateProperties()
					break
				
				case "styleName":
					Logger.debug("imageData changed", this)
					imageStyle = _model.styleName
					this.invalidateSkinState()
					break
							
			}
			
			
		}        
       
		override protected function getCurrentSkinState():String 
		{
			if (imageStyle=="none") return "normal"
			return imageStyle
			
		}
		
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance)
	       		
			if (instance == imageHolder)
       		{
       			imageHolder.addEventListener(Event.COMPLETE, onImageLoaded)
       		}
	       	
	    }
        
        																	
		public override function destroy():void
		{
			super.destroy()
			_model = null
		}
		
		
		
		
		
	}
}