package com.simplediagrams.model.mementos
{
	public class SDSymbolMemento extends SDObjectMemento
	{
		
		public var libraryName:String
		public var symbolName:String
		
		public var isCustom:Boolean
		public var textAlign:String
		public var text:String
		public var textPosition:String
		public var fontFamily:String
		public var fontSize:Number
		public var fontWeight:String
		
		
		public function SDSymbolMemento()
		{
		}
		
		public function clone():SDSymbolMemento
		{		
			var memento:SDSymbolMemento = new SDSymbolMemento()
			this.cloneBaseProperties(memento)
		
			//clone SDSymbolModel specific properties
			//...todo
				
			return memento

		}
		
		
	}
}