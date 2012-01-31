package com.simplediagrams.business
{
	import com.simplediagrams.model.ConnectionPoint;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDBackgroundModel;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDPencilDrawingModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.model.SDTextAreaModel;
	import com.simplediagrams.view.SDComponents.SDImage;
	
	import flash.utils.Dictionary;

	public class DiagramImporter
	{
		public function DiagramImporter()
		{
			dictionaryReaders["background"] = readBackground;
			dictionaryReaders["line"] = readLine;
			dictionaryReaders["symbol"] = readSymbol;
			dictionaryReaders["pencilDrawing"] = readPencilDrawing;
			dictionaryReaders["textArea"] = readTextArea;
			dictionaryReaders["image"] = readImage;

		}
		
		private var dictionaryReaders:Dictionary = new Dictionary();
		
		private function readBackground(xml:XML):SDBackgroundModel
		{
			var background:SDBackgroundModel = new SDBackgroundModel();
			background.libraryName = xml.libraryName;
			background.symbolName = xml.symbolName;
			background.fillMode = xml.fillMode;
			background.tintAlpha = xml.tintAlpha;
			background.tintColor = xml.tintColor;
			return background;
		}
		
		private function readObject(item:SDObjectModel, xml:XML):void
		{
			item.id = xml.@id;
			item.x = xml.x;
			item.y = xml.y;
			item.height = xml.height;
			item.width = xml.width;
			item.rotation = xml.rotation;
			item.color = xml.color;
			item.colorizable = xml.colorizable.toString() == true
			item.depth = xml.depth;
			if(xml.connectionPoints != null)
			{
				var points:Array = [];
				for each(var connecionPointXml:XML in xml.connectionPoints.connectionPoint)
				{
					var connectionPoint:ConnectionPoint = new ConnectionPoint(connecionPointXml.id, connecionPointXml.x, connecionPointXml.y);
					points.push(connectionPoint);
				}
				item.connectionPoints = points;
			}
		}
		
		private function readLine(xml:XML):SDLineModel
		{
			var lm:SDLineModel = new SDLineModel();
			lm.startX = xml.startX;
			lm.startY = xml.startY;
			lm.endX = xml.endX;
			lm.endY = xml.endY;
			lm.bendX = xml.bendX;
			lm.bendY = xml.bendY;
			lm.lineWeight = xml.lineWeight;
			lm.startLineStyle = xml.startLineStyle;
			lm.endLineStyle = xml.endLineStyle;
			lm.lineStyle = xml.lineStyle
			return lm;
		}
		
		private function readSymbol(xml:XML):SDSymbolModel
		{
			var item:SDSymbolModel = new SDSymbolModel();
			item.text = xml.text;
			item.libraryName = xml.libraryName;
			item.symbolName = xml.symbolName;
			item.textAlign = xml.textAlign;
			item.fontWeight = xml.fontWeight;		
			item.textPosition = xml.textPosition;	
			item.fontSize = xml.fontSize;	
			item.fontFamily = xml.fontFamily;
			item.lineWeight = xml.lineWeight;
			return item;
		}
		
		private function readPencilDrawing(xml:XML):SDPencilDrawingModel
		{
			var item:SDPencilDrawingModel = new SDPencilDrawingModel();
			item.linePath = xml.linePath;
			item.lineWeight =  xml.lineWeight;
			return item;
		}
		
		private function readTextArea(xml:XML):SDTextAreaModel
		{
			var item:SDTextAreaModel = new SDTextAreaModel();
			item.styleName = xml.styleName;										
			item.text = xml.text;
			item.fontWeight = xml.fontWeight;
			item.fontSize = xml.fontSize;
			item.textAlign = xml.textAlign;
			item.fontFamily = xml.fontFamily;
			
			//we added the following to textAreas in 1.5.11, so it may not exist in diagram.xml
			var value:String = xml.backgroundColor
			if (value!=null&&value!="")
			{
				item.backgroundColor = uint(xml.backgroundColor)
			}
			var value:String = xml.showTape
			if (value!=null&&value!="")
			{
				item.showTape = xml.showTape=="true"
			}
			
			
			return item;
		}
		
		private function readImage(xml:XML):SDImageModel
		{
			var item:SDImageModel = new SDImageModel();
			if("libraryName" in xml)
			{
				item.libraryName = xml.libraryName;
				item.symbolName = xml.symbolName;
			}
			item.styleName = xml.styleName;
			return item;
		}
		
		
		public function readDiagram(fullXml:XML):DiagramModel
		{
			var xml:XML = fullXml.diagrams.diagram[0];
			var diagramModel:DiagramModel = new DiagramModel();
			diagramModel.width = xml.width;
			diagramModel.height = xml.height;	
			diagramModel.name = xml.name;
			diagramModel.description = xml.description;
			diagramModel.background = readBackground(xml.background[0]);
			for each(var itemXML:XML in xml.elements.*)
			{
				var reader:Function = dictionaryReaders[itemXML.name()];
				var item:SDObjectModel = reader(itemXML);
				readObject(item, itemXML);
				diagramModel.sdObjects.addItem(item);
			}
			for each (var lineXML:XML in xml.elements.line)
			{		
				var id:int = lineXML.@id;
				var sdLineModel:SDLineModel = diagramModel.getModelByID(id) as SDLineModel;							
				if("fromObject" in lineXML)
				{
					var from:SDObjectModel = diagramModel.getModelByID(lineXML.fromObject);
					sdLineModel.fromObject = from;
					sdLineModel.fromPoint = from.getConnectionPoint(lineXML.fromPoint);
				}
				if("toObject" in lineXML)
				{
					var to:SDObjectModel = diagramModel.getModelByID(lineXML.toObject);
					sdLineModel.toObject = to;
					sdLineModel.toPoint = to.getConnectionPoint(lineXML.toPoint);
				}
			}
			return diagramModel;
		}		
	}
}