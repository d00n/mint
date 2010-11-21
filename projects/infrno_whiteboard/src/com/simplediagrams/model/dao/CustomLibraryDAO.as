package com.simplediagrams.model.dao
{
	
	[Table(name="custom_libraries")]
	[Bindable]
	public class CustomLibraryDAO extends DAO
	{
		protected var _displayName:String	
		protected var _libraryName:String		
		protected var _description:String 
		protected var _showInPanel:Boolean 
		
		public function CustomLibraryDAO()
		{
		}
		
		
		
		[Column(name="library_name")]
		public function get libraryName():String
		{
			return _libraryName
		}
		
		public function set libraryName(value:String):void
		{
			_libraryName = value
		}
		
		[Column(name="display_name")]
		public function get displayName():String
		{
			return _displayName
		}
		
		public function set displayName(value:String):void
		{
			_displayName = value
		}
				
		public function get description():String
		{
			return _description
		}
		
		public function set description(value:String):void
		{
			_description = value
		}
		
		public function set showInPanel(value:Boolean):void
		{
			_showInPanel = value
		}
		
		public function get showInPanel():Boolean
		{
			return _showInPanel
		}
	}
}

