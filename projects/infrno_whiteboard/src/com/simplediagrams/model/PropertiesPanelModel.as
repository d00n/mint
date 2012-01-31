package com.simplediagrams.model
{
	import com.simplediagrams.model.libraries.LibraryItem;
	import com.simplediagrams.model.libraries.SWFShape;
	import com.simplediagrams.view.SDComponents.SDImage;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.Font;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.CollectionEvent;
	
	public class PropertiesPanelModel extends EventDispatcher
	{
		
		public static const PROPERTIES_NONE:String = "none"
		public static const PROPERTIES_TEXT:String  = "propertiesText"
		public static const PROPERTIES_LINE:String  = "propertiesLine";
		public static const PROPERTIES_SYMBOL:String  = "propertiesSymbol";
		public static const PROPERTIES_IMAGE:String  = "propertiesImage";
		public static const PROPERTIES_PENCIL:String  = "propertiesPencil";
		
		public static const SELECTION_CHANGED:String  = "selectionChange";

		[Inject]
		public var libraryManager:LibraryManager
		
		[Bindable]
		public var viewing:String = PROPERTIES_NONE;
		
		[Bindable]
		public var allHaveBackground:Boolean = false;
		
		[Bindable]
		public var allObjectsAreSWFItems:Boolean = false;
		
		[Bindable("selectionChange")]
		public var imageStyle:String = "";
		
		[Bindable("selectionChange")]
		public var fontSize:String = "";
		
		[Bindable("selectionChange")]
		public var fontWeight:String = "";
		
		[Bindable("selectionChange")]
		public var fontFamily:String = "";
		
		[Bindable("selectionChange")]
		public var textAlign:String = "";
		
		[Bindable("selectionChange")]
		public var textPosition:String = "";
		
		[Bindable("selectionChange")]
		public var lineWeight:String = "";
		
		[Bindable("selectionChange")]
		public var backgroundColor:uint = 0x000000;
		
		[Bindable("selectionChange")]
		public var showLineWeight:Boolean = true;
			
		private var _diagramModel:DiagramModel;
		
		
		
		public function PropertiesPanelModel()
		{
			
		}
		
		
		[Inject(source='diagramManager.diagramModel',bind='true')]
		public function get diagramModel():DiagramModel
		{
			return _diagramModel;
		}
		
		public function set diagramModel(value:DiagramModel):void
		{
			if(_diagramModel)
			{
				_diagramModel.selectedObjects.removeEventListener( CollectionEvent.COLLECTION_CHANGE, onCollectionChange );
			}
			_diagramModel = value;
			setPropertiesPanel();
			if(_diagramModel)
			{
				_diagramModel.selectedObjects.addEventListener( CollectionEvent.COLLECTION_CHANGE, onCollectionChange );	
			}
		}
		
		
		private function onCollectionChange(event:Event):void
		{
			setPropertiesPanel();
		}

		protected function setPropertiesPanel():void
		{
			if(diagramModel == null)
			{
				viewing = PropertiesPanelModel.PROPERTIES_NONE;
				return
			}
			var selectedArr:ArrayCollection = diagramModel.selectedObjects;	
	
			if (selectedArr.length==0) 
			{  				
				viewing = PropertiesPanelModel.PROPERTIES_NONE;  
				return;
			}
			
			var allText:Boolean = true
			var allLines:Boolean = true  
			var allSymbols:Boolean = true  	
			var allImages:Boolean = true 
			var allPencilDrawings:Boolean = true
				
			allHaveBackground = false
			allObjectsAreSWFItems = true
			for each (var obj:Object in selectedArr)
			{
				if (obj is SDTextAreaModel == false)
				{
					allText = false;
				}
				if (obj is SDLineModel == false)
				{
					allLines = false;
				}
				if (obj is SDSymbolModel == false)
				{
					allSymbols = false;
				}
				if (obj is SDImageModel == false)
				{
					allImages = false;
				}
				if (obj is SDPencilDrawingModel == false)
				{
					allPencilDrawings = false;
				}
				if (obj is SDSymbolModel)
				{
					var sd:SDSymbolModel = SDSymbolModel(obj)
					var libItem:LibraryItem = libraryManager.getLibraryItem(sd.libraryName, sd.symbolName)
					if (!(libItem is SWFShape))
					{
						allObjectsAreSWFItems = false
					}
				}
			}	
			
			
			
			if (allText)
			{
				allHaveBackground = true
				var allSameBackgroundColor:Boolean = true
				backgroundColor = SDTextAreaModel(selectedArr[0]).backgroundColor
				for each (obj in selectedArr)
				{
					if (SDTextAreaModel(obj).styleName==SDTextAreaModel.NO_BACKGROUND)
					{
						allHaveBackground=false						
						allSameBackgroundColor = false
						break
					}
					if (backgroundColor != SDTextAreaModel(obj).backgroundColor)
					{
						allSameBackgroundColor = false
					}
				}							
				if (allSameBackgroundColor && obj)
				{
					backgroundColor = SDTextAreaModel(obj).backgroundColor
				}
				else
				{
					backgroundColor = 0xFFFFFF
				}
				fillTextProperties();
				viewing = PropertiesPanelModel.PROPERTIES_TEXT;
				
			}
			else if (allLines)
			{
				viewing = PropertiesPanelModel.PROPERTIES_LINE
			}
			else if (allPencilDrawings)
			{
				viewing = PropertiesPanelModel.PROPERTIES_PENCIL
			}
			else if (allSymbols)		
			{
				//if all symbols are swf symbols, hide the line weight control				
				fillSymbolProperties();
				viewing = PropertiesPanelModel.PROPERTIES_SYMBOL;
				showLineWeight = !allObjectsAreSWFItems
			}
			else if (allImages)
			{
				fillImageProperties();
				viewing = PropertiesPanelModel.PROPERTIES_IMAGE;
			}
			else
			{
				viewing = PropertiesPanelModel.PROPERTIES_NONE; 
			} 	
			dispatchEvent(new Event("selectionChange"));
		}
		
		private function fillImageProperties():void
		{
			imageStyle = getSameValue(function(sdObject:SDImageModel):String{return sdObject.styleName;}, "") as String;
		}
		
		private function fillSymbolProperties():void
		{
			fontFamily = getSameValue(function(sdObject:SDSymbolModel):String{return sdObject.fontFamily;}, "");
			textAlign = getSameValue(function(sdObject:SDSymbolModel):String{return sdObject.textAlign;}, "");
			textPosition = getSameValue(function(sdObject:SDSymbolModel):String{return sdObject.textPosition;}, "");
			fontSize = getSameValue(function(sdObject:SDSymbolModel):String{return sdObject.fontSize.toString();}, "");
			fontWeight = getSameValue(function(sdObject:SDSymbolModel):String{return sdObject.fontWeight;}, "");	
			lineWeight =  getSameValue(function(sdObject:SDSymbolModel):String{return sdObject.lineWeight.toString();}, "");
		}
		
		private function fillTextProperties():void
		{
			fontFamily = getSameValue(function(sdObject:SDTextAreaModel):String{return sdObject.fontFamily;}, "");
			textAlign = getSameValue(function(sdObject:SDTextAreaModel):String{return sdObject.textAlign;}, "");
			fontSize = getSameValue(function(sdObject:SDTextAreaModel):String{return sdObject.fontSize.toString();}, "");
			fontWeight = getSameValue(function(sdObject:SDTextAreaModel):String{return sdObject.fontWeight;}, "");
		}
		
		private function getSameValue(func:Function, emptyValue:String):String	
		{
			var count:int = diagramModel.selectedObjects.length;
			if(count == 0)
				return emptyValue;
			var firstValue:String = func(diagramModel.selectedObjects.getItemAt(0));
			if(count == 1)
				return firstValue;
			for(var i:int = 1; i < count;i++)
			{
				var currentValue:Object = func(diagramModel.selectedObjects.getItemAt(i));
				if(currentValue != firstValue)
					return emptyValue;
			}
			return firstValue;
		}
		
	
		
	}
}