package com.simplediagrams.model.libraries
{
	public class LibraryInfo
	{
		public function LibraryInfo()
		{
		}
		public var name:String;
		public var displayName:String;
		public var type:String;
		public var custom:Boolean;
		[Bindable]
		public var enabled:Boolean = true;
	}
}