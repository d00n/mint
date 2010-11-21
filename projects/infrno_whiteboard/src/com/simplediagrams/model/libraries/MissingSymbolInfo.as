package com.simplediagrams.model.libraries
{
	public class MissingSymbolInfo
	{
		public var symbolName:String
		public var libraryName:String
		public var libraryType:String 
		
		public function MissingSymbolInfo(libName:String, symName:String)
		{
			symbolName = symName
			libraryName = libName
		}
	}
}