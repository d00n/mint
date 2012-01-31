package com.simplediagrams.model.libraries
{
	public class LibraryItem
	{
		public function LibraryItem()
		{
		}
		
		public var libraryName:String; 	//universal name of library, usuall reverse domain name (com.simplediagrams...) or UUID
		public var name:String;   		//universal name of shape, usually camelcaps name or UUID
		public var displayName:String;
		public var width:Number = 50;
		public var height:Number = 50;
		public var scaleGridLeft:Number = NaN;
		public var scaleGridTop:Number = NaN;
		public var scaleGridRight:Number = NaN;
		public var scaleGridBottom:Number = NaN;
	}
}