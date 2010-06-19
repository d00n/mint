package com.infrno.load_manager
{
	import com.infrno.load_manager.controller.*;
	import com.infrno.load_manager.model.events.EventConstants;
	import com.infrno.load_manager.view.components.*;
	import com.infrno.load_manager.view.mediators.*;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	
	import org.robotlegs.base.ContextEvent;
	import org.robotlegs.mvcs.Context;
	
	public class ApplicationContext extends Context
	{
		public function ApplicationContext()
		{
			super();
			var a:DisplayObject;
		}
		
		override public function startup():void
		{
			commandMap.mapEvent(EventConstants.DISPLAY_MANAGER_LOADED,LoadWizzardCommand);
			commandMap.mapEvent(EventConstants.WIZZARD_COMPLETE,LoadChatCommand);
			
			mediatorMap.mapView(DisplayManager,DisplayManagerMediator);
			mediatorMap.mapView(Wizzard,WizzardMediator);
			
			//startup done
			super.startup();
		}
	}
}