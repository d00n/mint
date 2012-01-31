package com.simplediagrams.business
{
	import avmplus.getQualifiedClassName;
	
	import com.simplediagrams.model.ConnectionPoint;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDBackgroundModel;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDPencilDrawingModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.model.SDTextAreaModel;
	
	import flash.utils.Dictionary;

	public class DiagramExporter
	{
		public function DiagramExporter()
		{
			dictionaryWriters[getQualifiedClassName(SDBackgroundModel)] = writeBackground;
			dictionaryWriters[getQualifiedClassName(SDLineModel)] = writeLine;
			dictionaryWriters[getQualifiedClassName(SDSymbolModel)] = writeSymbol;
			dictionaryWriters[getQualifiedClassName(SDPencilDrawingModel)] = writePencilDrawing;
			dictionaryWriters[getQualifiedClassName(SDTextAreaModel)] = writeTextArea;
			dictionaryWriters[getQualifiedClassName(SDImageModel)] = writeImage;
		}
		
		private var dictionaryWriters:Dictionary = new Dictionary();
		
		protected function cdata(theURL:String):XML
		{
			var x:XML = new XML("<![CDATA[" + theURL + "]]>");
			return x;
		}
		
		private function writeBackground(background:SDBackgroundModel):XML
		{
				var xml:XML = <background>
								<libraryName>{background.libraryName}</libraryName>
								<symbolName>{background.symbolName}</symbolName>
								<fillMode>{background.fillMode}</fillMode>
								<tintColor>{background.tintColor}</tintColor>
								<tintAlpha>{background.tintAlpha}</tintAlpha>
							  </background>;
				return xml;
		}
		
		private function writeObject(item:SDObjectModel, xml:XML):void
		{
			xml.@id = item.id;
			xml.x = item.x;
			xml.y = item.y;
			xml.height = item.height;
			xml.width = item.width;
			xml.rotation = item.rotation;
			xml.color = item.color;
			xml.colorizable = item.colorizable.toString();
			xml.depth = item.depth;
			if(item.connectionPoints.length > 0)
			{
				var connectionPoints:XML = <connectionPoints/>;
				for each(var connectionPoint:ConnectionPoint in item.connectionPoints)
				{
					var cPointXML:XML = <connectionPoint/>;
					cPointXML.id = connectionPoint.id;
					cPointXML.x = connectionPoint.x;
					cPointXML.y = connectionPoint.y;
					connectionPoints.appendChild(cPointXML);
				}
				xml.appendChild(connectionPoints);
			}
		}
			
		private function writeLine(lm:SDLineModel):XML
		{
			var xml:XML = <line></line>;
			xml.startX = lm.startX
			xml.startY = lm.startY
			xml.endX = lm.endX
			xml.endY = lm.endY
			xml.bendX = lm.bendX
			xml.bendY = lm.bendY
			xml.lineWeight = lm.lineWeight
			xml.startLineStyle = lm.startLineStyle
			xml.endLineStyle = lm.endLineStyle
			xml.lineStyle = lm.lineStyle
			if(lm.fromObject)
			{
				xml.fromObject = lm.fromObject.id;
				xml.fromPoint = lm.fromPoint.id;
			}
			if(lm.toObject)
			{
				xml.toObject = lm.toObject.id;
				xml.toPoint = lm.toPoint.id;
			}
			return xml;
		}
			
		private function writeSymbol(item:SDSymbolModel):XML
		{
			var xml:XML = <symbol></symbol>;
			xml.text = <text>{cdata(item.text)}</text>;
			xml.libraryName = item.libraryName;
			xml.symbolName = item.symbolName;
			xml.textAlign = item.textAlign;
			xml.fontWeight = item.fontWeight;		
			xml.textPosition = item.textPosition;	
			xml.fontSize = item.fontSize;	
			xml.fontFamily = item.fontFamily;
			xml.lineWeight = item.lineWeight;
			return xml;
		}
			
		private function writePencilDrawing(item:SDPencilDrawingModel):XML
		{
			var xml:XML = <pencilDrawing></pencilDrawing>;
			xml.linePath = <linePath>{cdata(item.linePath)}</linePath>;
			xml.lineWeight = item.lineWeight;	
			return xml;
		}
			
		private function writeTextArea(item:SDTextAreaModel):XML
		{
			var xml:XML = <textArea></textArea>;
			xml.styleName = item.styleName;										
			xml.text = <text>{cdata(item.text)}</text>;
			xml.fontWeight = item.fontWeight;
			xml.fontSize = item.fontSize;
			xml.textAlign = item.textAlign;
			xml.fontFamily = item.fontFamily;
			xml.backgroundColor = item.backgroundColor
			xml.showTape = item.showTape.toString()
			return xml;
		}
			
		private function writeImage(item:SDImageModel):XML
		{
			var xml:XML = <image></image>;
			if(item.libraryName)
			{
				xml.libraryName = item.libraryName;
				xml.symbolName = item.symbolName;
			}
			xml.styleName = item.styleName;
			return xml;
		}
			
			
		public function writeDiagram(diagram:DiagramModel, version:String):XML
		{
			var xml:XML = <diagram></diagram>;
			xml.width = diagram.width;
			xml.height = diagram.height;	
			xml.name = diagram.name;
			xml.description = diagram.description;
			var backgroundXML:XML = writeBackground(diagram.background);
			xml.appendChild(backgroundXML);
			var elementsXML:XML = <elements></elements>;
			for each(var item:SDObjectModel in diagram.sdObjects)
			{
				var writer:Function = dictionaryWriters[getQualifiedClassName(item)];
				var itemXml:XML = writer(item);
				writeObject(item, itemXml);
				elementsXML.appendChild(itemXml);
			}
			xml.appendChild(elementsXML);
			var rootXml:XML = <sdxml version="1.5"><version>{version}</version><diagrams></diagrams></sdxml>;
			rootXml.diagrams.appendChild(xml);
			return rootXml;
		}		
		
	}
}