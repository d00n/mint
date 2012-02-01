package com.simplediagrams.view.components
{
	import com.simplediagrams.view.itemRenderers.FontStyleRenderer;
	
	import flash.text.Font;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.ComboBox;
	import mx.core.ClassFactory;
	import mx.events.DropdownEvent;
	import mx.events.FlexEvent;
	
	public class FontStyleList extends ComboBox
	{	
		
		private var fontList:ArrayCollection;
		
		public function FontStyleList()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, listCreated);
			
		}
		private function listCreated(e:FlexEvent):void{
			fontList = new ArrayCollection(Font.enumerateFonts(true));
			labelField = "fontName";
			setStyle("fontSize",15);
			dataProvider = fontList;
			itemRenderer = new ClassFactory(FontStyleRenderer);
			dropdown.variableRowHeight = true;
		}
	}
}
