package com.infrno.load_manager.controller
{
	import org.robotlegs.mvcs.Command;
	
	public class LoadWizzardCommand extends Command
	{
		override public function execute():void
		{
			trace("loaded fine");
		}
	}
}