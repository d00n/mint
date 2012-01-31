package com.simplediagrams.view.SDComponents
{
	
	import com.simplediagrams.errors.SymbolNotFoundError;
	import com.simplediagrams.events.EditSDComponentTextEvent;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.model.libraries.ImageShape;
	import com.simplediagrams.model.libraries.LibraryItem;
	import com.simplediagrams.model.libraries.SWFShape;
	import com.simplediagrams.model.libraries.VectorShape;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.components.ShapePath;
	
	import flash.display.AVM1Movie;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.BitmapFilterType;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.SWFLoader;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.managers.SystemManager;
	
	import spark.components.Group;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.RichEditableText;
	import spark.components.TextArea;
	import spark.primitives.BitmapImage;
	import spark.primitives.Graphic;
	import spark.primitives.Path;
	
	[Bindable]
	public class SDSymbol extends SDBase implements ISDComponent
	{	
		
		public static const STATE_DISPLAY_IMG:String = "displayIMG";
		public static const STATE_DISPLAY_SWF:String = "displaySWF";
		public static const STATE_DISPLAY_PATH:String = "displayPath";

				
		[SkinPart(required="true")]		
		public var shapeGroup:Group;
		
		[SkinPart(required="true")]		
		public var shapePath:ShapePath;
		
		[SkinPart(required="true")]		
		public var imgCustomSymbol:BitmapImage		
		
		[SkinPart(required="true")]		
		public var symbolHitArea:Graphic	
		
		[SkinPart(required="true")]
		public var swfLoader:SWFLoader
		
		[SkinPart(required="true")]
		public var avm1Holder:Group
				
		
		[SkinPart(required="true")]		
		public var retSymbolText:RichEditableText		
		
		public var symbolChanged:Boolean;
		
		public var pathData:String;
		public var color:Number
		public var text:String
		public var fontSize:Number 
		public var fontWeight:String 
		public var textAlign:String 
		public var textYPos:int		
		public var fontFamily:String
		public var maintainAspectRatio:Boolean = false //only for SWF objects
		
		public var textAreaEnabled:Boolean = false
		
		public var symbolGroup:Group 
		public var customSymbolSource:Object
		public var swfPath:String
		
		public var lineWeight:Number = .1
		
		private var _model:SDSymbolModel
		
		public var libraryManager:LibraryManager;
		
		public function SDSymbol()
		{
			super();
			this.setStyle("skinClass",Class(SDSymbolSkin))
		}
		
		private var libraryItem:LibraryItem;
		
		public function set objectModel(objectModel:SDObjectModel):void
		{      
			if(_model == objectModel)
				return;
			if(_model)
				_model.removeEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
			_model = SDSymbolModel(objectModel)
			
			fontWeight = _model.fontWeight
			fontFamily = _model.fontFamily
			text = _model.text
			textAlign = _model.textAlign
			fontSize = _model.fontSize
			lineWeight = _model.lineWeight
			
			color = _model.color
			
			x = _model.x;
			y = _model.y;
			width = _model.width
			height = _model.height
			rotation = _model.rotation
			depth = _model.depth;
			maintainAspectRatio = _model.maintainAspectRatio
			
			if (ApplicationModel.testMode)
			{
				toolTip = _model.id.toString();
			}
			
			_model.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
			
			libraryItem = libraryManager.getLibraryItem(_model.libraryName, _model.symbolName);
			if(libraryItem == null)
			{
				libraryItem = libraryManager.getDefaultShape();
			}
			if (libraryItem is ImageShape)
			{
				customSymbolSource = libraryManager.getAssetData(libraryItem, (libraryItem as ImageShape).path); 
			}
			if (libraryItem is SWFShape)
			{
				swfPath = LibraryManager.getAssetPath(libraryItem, (libraryItem as SWFShape).path);
			}
			if (libraryItem is VectorShape)
			{					
				pathData = (libraryItem as VectorShape).path;
				color = _model.color;
				lineWeight = _model.lineWeight
			}		
			
			
			
			symbolChanged = true;
		    invalidateSkinState()
			invalidateProperties();
		}
	
		
		public override function get objectModel():SDObjectModel
		{
			return _model;
		}
		
		public function getTextYPosition():Number
		{
			var textYPos:Number = 5
			if (_model==null) return textYPos
			
			switch (_model.textPosition)
			{
				
				case SDSymbolModel.TEXT_POSITION_ABOVE:					
					if (retSymbolText)
					{
						textYPos = - (retSymbolText.height + 5)
					}	
					break
				
				
				case SDSymbolModel.TEXT_POSITION_TOP:
					textYPos = 5
					break
				
				case SDSymbolModel.TEXT_POSITION_MIDDLE:	
					if (retSymbolText)
					{
						textYPos = (_model.height / 2) - (retSymbolText.height / 2)
					}
					break
				
				case SDSymbolModel.TEXT_POSITION_BOTTOM:
					textYPos = height - (fontSize + 10)
					break
				
				case SDSymbolModel.TEXT_POSITION_BELOW:
					textYPos = height + 5 
					break
				
				default:
					Logger.error("unrecognized textPosition: " + _model.textPosition, this)
					
			}
			return textYPos
		}
		
		
		override protected function onModelChange(event:PropertyChangeEvent):void
		{
			super.onModelChange(event)				
			switch(event.property)
			{
				
				case "x":
				case "y":
				case "width":
				case "height":
					this.textYPos = getTextYPosition()
					break
				
				case "fontWeight":
					fontWeight = event.newValue as String	
					break
				
				case "lineWeight":
					lineWeight = _model.lineWeight;
					break
				
				case "color": 
					color = _model.color
					//I don't think I've ever written something this ugly...
					if (swfLoader && libraryItem && libraryItem is SWFShape)
					{						
						colorSWF()
					}
					break	
				
				case "text": 						
					text = event.newValue as String						
					break	
				
				
				case "maintainAspectRatio": 						
					maintainAspectRatio = event.newValue as Boolean						
					break	
				
				case "textAlign": 						
					textAlign = event.newValue as String						
					break	
				
				case "fontSize": 						
					fontSize = event.newValue as int		
					this.textYPos = getTextYPosition()
					break	
				
				
				case "fontFamily": 						
					fontFamily = event.newValue as String		
					break	
				
				case "textPosition": 						
					this.textYPos = getTextYPosition()
					break	
			}
		}
		
		protected function colorSWF():void
		{
			try
			{
				var loadedObj:Object = swfLoader.content		
					
				//check for swfs exported as AVM1Movie (e.g. from Illustrator CS5)
				if (loadedObj is AVM1Movie)
				{
					
					var m:AVM1Movie = loadedObj as AVM1Movie					
					var cf:ColorTransform = m.transform.colorTransform
					cf.color = color
					m.transform.colorTransform = cf
					return
				}
				
				//assuming swf is DisplayObject
				var t:DisplayObject = loadedObj.getChildAt(0);	
				if (t is flash.display.AVM1Movie)
				{
					
				}
				else
				{
					try
					{
						(t as Object).setColor(_model.color)
					}
					catch(error:Error)
					{
						//if there's no setColor() method, just colorize directly
						try
						{
							
							var loadedObj:Object = swfLoader.content					
							var t:DisplayObject = loadedObj.getChildAt(0);
							var cf:ColorTransform = t.transform.colorTransform
							cf.color = color
							t.transform.colorTransform = cf
						}
						catch(error:Error)
						{
							Logger.error("Couldn't set swf color. Error: " + error,this)
						}
					}
				}				
			}
			catch(error:Error)
			{
				Logger.error("Coudn't set swf color. Error: " + error, this)
			}
			
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);		 					
			if (instance==retSymbolText)
			{								
				textYPos = getTextYPosition();
				retSymbolText.addEventListener(FlexEvent.UPDATE_COMPLETE, onTextAreaChange)
				retSymbolText.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)
				retSymbolText.addEventListener(FocusEvent.FOCUS_OUT, onTextAreaFocusOut)
			}
			if(instance==swfLoader)
			{
				swfLoader.addEventListener(Event.COMPLETE, onSWFLoaded)				
			}			
		}
		
		protected function onSWFLoaded(event:Event):void
		{
			/*Some symbols are not meant to be colored by current color chip when first dropped. 
			  Check flag here and only set to current color if needed */
			if (_model.startWithDefaultColor==false)
			{
				colorSWF()
			}
		}
		
		protected function onTextAreaChange(event:Event):void
		{
			textYPos = getTextYPosition();
		}
		
		protected function onTextAreaFocusOut(event:FocusEvent):void
		{
			textAreaEnabled = false
			_model.text = retSymbolText.text
		}
			
		
		public function onDoubleClick():void
		{
			this.textAreaEnabled = true
			this.retSymbolText.selectAll()
			this.retSymbolText.setFocus()
		}
		
		
		public function onMouseDown(event:MouseEvent):void
		{
			if (this.textAreaEnabled)
			{
				//don't propagate mouse events because ObjectHandles will pick them up. If you want to click and drag over text you won't be able to.
				event.stopPropagation()
			}			
		}
		
		public override function destroy():void
		{
			super.destroy()				
			retSymbolText.removeEventListener(FlexEvent.UPDATE_COMPLETE, onTextAreaChange)
			retSymbolText.removeEventListener(FocusEvent.FOCUS_OUT, onTextAreaFocusOut)
			retSymbolText.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)			
			swfLoader.removeEventListener(Event.COMPLETE, onSWFLoaded)
			_model = null
		}
		
		
		override protected function getCurrentSkinState():String 
		{
			if (libraryItem is ImageShape)
			{
				return STATE_DISPLAY_IMG
			}
			if (libraryItem is SWFShape)
			{
				return STATE_DISPLAY_SWF
			}
			if (libraryItem is VectorShape)
			{					
				return STATE_DISPLAY_PATH
			}		
			return null
		}
		
	}
}