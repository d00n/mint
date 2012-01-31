package com.simplediagrams.events
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	public class ApplicationEvent extends Event
	{
		public static const INIT_APP:String = "initApplication"
		public static const INIT_MENU:String = "initMenu"
		public static const QUIT:String = "quitApplication"
		
		public static const SHOW_MANAGE_LIBRARIES:String = "showManageLibraries";
		public static const HIDE_MANAGE_LIBRARIES:String = "hideManageLibraries";

		public static const SHOW_CREATE_LIBRARY:String = "showCreateLibrary";
		public static const HIDE_CREATE_LIBRARY:String = "hideCreateLibrary";
		
		public static const SHOW_IMPORT_DATABASE_PROMPT:String = "showImportDatabasePrompt";
		public static const HIDE_IMPORT_DATABASE_PROMPT:String = "hideImportDatabasePrompt";
		
		public function ApplicationEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}