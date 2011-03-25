package com.infrno.chat.controller
{
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.view.mediators.StatsGroupMediator;
	
	import org.robotlegs.mvcs.Command;
	
	public class HideStatsGroupCommand extends Command
	{
		[Inject]
		public var event:StatsEvent;
		
		[Inject]
		public var statsGroupMediator:StatsGroupMediator;
		
		override public function execute( ) : void
		{
			statsGroupMediator.unmapListeners();			
		}
	}
}