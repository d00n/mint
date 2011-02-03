package com.infrno.load_manager.controller
{
	import com.infrno.load_manager.model.events.EventConstants;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Command;
	
	public class LoadWizardCommand extends Command
	{
		override public function execute():void
		{
			trace("LoadWizardCommand.execute() supposed to try to load wizard");
			dispatch(new Event(EventConstants.LOAD_WIZARD));
		}
	}
}