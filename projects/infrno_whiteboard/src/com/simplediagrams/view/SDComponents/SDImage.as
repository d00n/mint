package com.simplediagrams.view.SDComponents
{
	
	import com.google.analytics.debug.Alert;
	import com.simplediagrams.events.LoadImageEvent;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.libraries.ImageShape;
	import com.simplediagrams.model.libraries.LibraryItem;
	import com.simplediagrams.util.Logger;
	
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.controls.ProgressBar;
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
		public var imageSource:Object;
		
		[SkinPart(required="true")]		
		public var imageHolder:Image;
		
		[SkinPart(required="true")]		
		public var loading_pb:ProgressBar;
		
		public var imageStyle:String
		public var tapeVisible:Boolean
		public var borderVisible:Boolean
		
		protected var changeImageCMI:ContextMenuItem
		private static var MAX_INITIAL_IMAGE_WIDTH:int = 800;
		
		public function SDImage()
		{
			super();
			this.setStyle("skinClass", Class(SDImageSkin))
			
			//			changeImageCMI = new ContextMenuItem("Change image", false, true)
			//			changeImageCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onChangeImage);
			//			contextMenu.items.unshift(changeImageCMI)
		}
		
		public var libraryManager:LibraryManager;
		
		
		
		protected function onImageLoaded(event:Event):void
		{
			Logger.info("onImageLoaded() ",this)
				
			loading_pb.visible = false;
			
			_model.origWidth = imageHolder.width
			_model.origHeight = imageHolder.height
			
			// If so, use actual size, subject to max width
			if (_model.imageURL == null || _model.imageURL == '') {
				if (imageHolder.sourceWidth > MAX_INITIAL_IMAGE_WIDTH) {
					_model.width = MAX_INITIAL_IMAGE_WIDTH;
					var shrinkPercentage:Number = MAX_INITIAL_IMAGE_WIDTH / imageHolder.sourceWidth;
					_model.height = imageHolder.sourceHeight * shrinkPercentage;
				} else {
					_model.width = imageHolder.sourceWidth;
					_model.height = imageHolder.sourceHeight;		
				}
			}			
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
			isLocked = _model.isLocked;
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
			if (_model.imageURL != null && _model.imageURL.length != 0)
				this.imageSource = _model.imageURL;
			else
				this.imageSource = _model.imageData;			
			
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
				
				case "imageData":
					Logger.debug("imageData changed", this)
					imageSource = _model.imageData
					this.invalidateProperties()
					break
				case "imageURL":
					Logger.debug("imageURL changed", this)
					if (imageSource == null){
						imageSource = _model.imageURL
						this.invalidateProperties()
					}
					break
				case "styleName":
					Logger.debug("styleName changed", this)
					imageStyle = _model.styleName
					this.invalidateSkinState()
					break
				
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
			else if (_model.imageURL && _model.imageURL.length > 0)
			{
				callLater(setImageSource);
//				this.imageHolder.source = _model.imageURL;
			}
			else
			{
				this.imageData = null
			}
		}

		public function setImageSource():void{
			this.imageHolder.source = _model.imageURL;
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
				imageHolder.addEventListener(HTTPStatusEvent.HTTP_STATUS, onImageHttpStatus);
				imageHolder.addEventListener(Event.INIT, onImageEvent);
				imageHolder.addEventListener(IOErrorEvent.IO_ERROR, onImageIoError);
				imageHolder.addEventListener(Event.OPEN, onImageEvent);
				imageHolder.addEventListener(ProgressEvent.PROGRESS, onImageProgress);
				imageHolder.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onImageSecurityError);
				imageHolder.addEventListener(Event.UNLOAD, onImageEvent); 
			}	       	
		}
		
		protected function onImageHttpStatus(event:HTTPStatusEvent):void{
			Logger.info(event.toString(), this);
		}
		
		protected function onImageIoError(event:IOErrorEvent):void{
			Logger.info(event.toString(), this);
			mx.controls.Alert.show(event.toString(), "Image loading error");  
		}
		
		protected function onImageEvent(event:Event):void{
			Logger.info(event.toString(), this);
		}
		
		protected function onImageProgress(event:ProgressEvent):void{
//			Logger.info(event.toString(), this);
		}
		
		protected function onImageSecurityError(event:SecurityErrorEvent):void{
			Logger.info(event.toString(), this);
			mx.controls.Alert.show(event.toString(), "Image security error");  
		}
		
		
		public override function destroy():void
		{
			super.destroy()
			_model = null
		}
		
		
		
		
		
	}
}