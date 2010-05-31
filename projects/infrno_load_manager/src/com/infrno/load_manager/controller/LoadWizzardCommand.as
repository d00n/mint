package com.infrno.load_manager.controller
{
	import com.infrno.load_manager.model.events.EventConstants;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Command;
	
	public class LoadWizzardCommand extends Command
	{
		override public function execute():void
		{
			trace("LoadWizzardCommand.execute() supposed to try to load wizzard");
			dispatch(new Event(EventConstants.LOAD_WIZZARD));
		}
	}
}