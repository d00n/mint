package com.infrno.load_manager
{
	import com.infrno.load_manager.controller.LoadWizzardCommand;
	
	import flash.display.DisplayObjectContainer;
	
	import org.robotlegs.base.ContextEvent;
	import org.robotlegs.mvcs.Context;
	
	public class ApplicationContext extends Context
	{
		public function ApplicationContext()
		{
			super();
		}
		
		override public function startup():void
		{
			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE,LoadWizzardCommand);
			
			//startup done
			super.startup();
		}
	}
}