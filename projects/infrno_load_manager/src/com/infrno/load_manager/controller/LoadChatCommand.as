package com.infrno.load_manager.controller
{
	import com.infrno.load_manager.model.events.EventConstants;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Command;
	
	public class LoadChatCommand extends Command
	{
		override public function execute():void
		{
			dispatch(new Event(EventConstants.LOAD_CHAT));
		}
	}
}