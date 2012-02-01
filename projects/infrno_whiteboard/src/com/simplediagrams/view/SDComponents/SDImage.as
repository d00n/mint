package com.simplediagrams.view.SDComponents
{
	
	import com.simplediagrams.events.LoadImageEvent;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.libraries.ImageShape;
	import com.simplediagrams.model.libraries.LibraryItem;
	import com.simplediagrams.util.Logger;
	
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Image;

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
		
		protected var changeImageCMI:ContextMenuItem
		
		public function SDImage()
		{
			super();
			this.setStyle("skinClass", Class(SDImageSkin))
				
			changeImageCMI = new ContextMenuItem("Change image", false, true)
			changeImageCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onChangeImage);
//			contextMenu.items.unshift(changeImageCMI)
		}
		
		public var libraryManager:LibraryManager;
		
		
		
		protected function onImageLoaded(event:Event):void
		{
		}
	
		protected function onChangeImage(event:ContextMenuEvent):void
		{
			onAddImageClick()
			
			/*
			var evt:ChangeImageEvent = new ChangeImageEvent(ChangeImageEvent.CHANGE_IMAGE, true);
			evt.sdID = this.sdID
			dispatchEvent(eventChangeDepth);
			*/
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
			Logger.debug("SDImage set objectModel(): " + objectModel, this)         
			_model = SDImageModel(objectModel)
			
			//redraw();
			x = _model.x;
			y = _model.y;         
			this.width = _model.width
			this.height = _model.height  
			this.rotation = _model.rotation
			depth = _model.depth;
			if( _model.symbolName)
			{
				var libItem:ImageShape = libraryManager.getLibraryItem(_model.libraryName, _model.symbolName) as ImageShape;
				this.imageData = libraryManager.getAssetData(libItem, libItem.path) as ByteArray;
			}
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
			invalidateProperties()
					
			switch(event.property)
			{    
				case "styleName":
					Logger.debug("imageData changed", this)
					imageStyle = _model.styleName
					this.invalidateSkinState()
					break
//				case "imageURL":
//					Logger.debug("imageURL changed", this)
//					if (imageSource == null){
//						imageSource = _model.imageURL
//						this.invalidateProperties()
//					}								
			}
			
		}        
		
		override protected function commitProperties():void
		{
			super.commitProperties()
			if(_model.libraryName && _model.symbolName)
			{
				var libItem:ImageShape = libraryManager.getLibraryItem(_model.libraryName, _model.symbolName) as ImageShape;
				this.imageData = libraryManager.getAssetData(libItem, libItem.path) as ByteArray;
			}			
			else
			{
				this.imageData = null
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
			
			changeImageCMI.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onChangeImage);
			super.destroy()
			_model = null
		}
		
		
		
		
		
	}
}