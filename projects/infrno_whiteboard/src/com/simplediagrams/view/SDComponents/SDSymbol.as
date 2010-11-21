package com.simplediagrams.view.SDComponents
{
	
	import com.simplediagrams.errors.SymbolNotFoundError;
	import com.simplediagrams.events.EditSymbolTextEvent;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.util.Logger;
	
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.ByteArray;
	
	import mx.controls.Image;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Label;
	import spark.primitives.Graphic;



	[SkinState("normal")]
	[SkinState("customSymbol")]
	[Bindable]
	public class SDSymbol extends SDBase implements ISDComponent
	{	
		
		
		[SkinPart(required="true")]		
		public var imgLibrarySymbol:Image		
		
		[SkinPart(required="true")]		
		public var imgCustomSymbol:Image		
		
		[SkinPart(required="true")]		
		public var symbolHitArea:Graphic		
		
		[SkinPart(required="true")]		
		public var lblSymbolText:Label		
		
		public var color:Number
		public var text:String
		public var fontSize:Number 
		public var fontWeight:String 
		public var textAlign:String 
		public var textYPos:int		
		public var fontFamily:String
		
		
		public var librarySymbolSource:Object
		public var customSymbolSource:Object
		
		private var _model:SDSymbolModel
			
		public function SDSymbol()
		{
			super();
			this.setStyle("skinClass",Class(SDSymbolSkin))
		}
			
		public function set objectModel(objectModel:SDObjectModel):void
		{       
            _model = SDSymbolModel(objectModel)
            
			fontWeight = _model.fontWeight
			fontFamily = _model.fontFamily
			text = _model.text
			textAlign = _model.textAlign
			fontSize = _model.fontSize
			textYPos = getTextYPosition();
			
			color = _model.color
			x = _model.x;
			y = _model.y;
			width = _model.width
			height = _model.height
			rotation = _model.rotation
			depth = _model.depth;	
			
			if (ApplicationModel.testMode)
			{
				toolTip = _model.sdID
			}
			
            _model.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
        	
			
			if (_model.isCustom)
			{
				//if this is a customLibrary object, the image will just pick up the imageData property
				customSymbolSource = _model.imageData
			}
			else
			{					
				var symbolClass:Class = LibraryManager.getSymbolClass(_model.libraryName + "." + _model.symbolName)
				librarySymbolSource = new objectModel.symbolClass()
			}
            
			
			if (_model.colorizable) setSymbolColor(_model.color)
							
			this.invalidateSkinState()
		}
		
		
		override protected function getCurrentSkinState():String 
		{
			if (_model.isCustom) return "customSymbol"
			return "normal"			
		}
		
		public override function get objectModel():SDObjectModel
		{
			return _model
		}
		
		public function getTextYPosition():Number
		{
			var textYPos:Number = 5
			if (_model==null) return textYPos
				
			switch (_model.textPosition)
			{
				
				case SDObjectModel.TEXT_POSITION_ABOVE:
					if (lblSymbolText)
					{
						textYPos = - (lblSymbolText.height + 5)
					}	
					break
				
				
				case SDObjectModel.TEXT_POSITION_TOP:
					textYPos = 5
					break
				
				case SDObjectModel.TEXT_POSITION_MIDDLE:	
					if (lblSymbolText)
					{
						textYPos = (_model.height / 2) - (lblSymbolText.height / 2)
					}
					break
				
				case SDObjectModel.TEXT_POSITION_BOTTOM:
					textYPos = height - (fontSize + 10)
					break
				
				case SDObjectModel.TEXT_POSITION_BELOW:
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
					this.fontWeight = event.newValue as String	
					break
				
				case "color": 		
					if (_model.colorizable) setSymbolColor(event.newValue as Number);	
					color = event.newValue as Number
					invalidateSkinState()
					break	
				
				case "text": 						
					text = event.newValue as String						
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
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);		 
			if (instance == imgLibrarySymbol && _model.colorizable)
			{
				setSymbolColor(_model.color)	
			}
			if (instance == symbolHitArea)
			{
				//symbolHitArea.addEventListener(MouseEvent.DOUBLE_CLICK, onSymbolDoubleClick)
			}
			if (instance == lblSymbolText)
			{
				lblSymbolText.addEventListener(FlexEvent.UPDATE_COMPLETE, onLabelChange)
			}
		}
		
		protected function onLabelChange(event:Event):void
		{
			lblSymbolText.y = getTextYPosition()
		}
				
       
       	protected function setSymbolColor(color:Number):void
       	{
			
       		var newFiltersArr:Array = []
       		       		
       		var matrix:Array = new Array();
       		
       		var red:Number = color>>16;
      		var grnBlu:Number = color-(red<<16);
        	var grn:Number = grnBlu>>8;
        	var blu:Number = grnBlu-(grn<<8);
       		
            matrix = matrix.concat([0, 0, 0, 0, red]); // red
            matrix = matrix.concat([0, 0, 0, 0, grn]); // green
            matrix = matrix.concat([0, 0, 0, 0, blu]); // blue
            matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
            
       		var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
       		
       		newFiltersArr.push(filter)
       		
       		filters = newFiltersArr
       		
       		this.invalidateSkinState()
       	}
       
		
		public function onSymbolDoubleClick(event:MouseEvent):void
		{
			var editSymbolTextEvent:EditSymbolTextEvent = new EditSymbolTextEvent(EditSymbolTextEvent.EDIT_SYMBOL_TEXT, true)
			editSymbolTextEvent.sdSymbolModel = this._model		
			dispatchEvent(editSymbolTextEvent)
		}
		
		
		public override function destroy():void
		{
			super.destroy()
			symbolHitArea.removeEventListener(MouseEvent.DOUBLE_CLICK, onSymbolDoubleClick)
			_model = null
		}
		
		
		/*
		public function get imageSource():Object
		{
			if (_model.isCustom)
			{
				return _model.imageData
			}
			else
			{
				return getStyle('symbol')
			}
			return null		
		}
		*/
	
		
		
		
	}
}