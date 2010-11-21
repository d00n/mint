package com.simplediagrams.view.SDComponents
{
	
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.SDObjectModel;

	public interface ISDComponent
	{
		function set objectModel(objectModel:SDObjectModel):void
		function get objectModel():SDObjectModel;
		function get sdID():String;
		function set sdID(value:String):void;
		function destroy():void	
	}
}