package com.infrno.chat.controller
{
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.view.components.StatsGroup;
	import com.infrno.chat.view.mediators.InfrnoChatMediator;
	import com.infrno.chat.view.mediators.StatsGroupMediator;
	
	import org.robotlegs.mvcs.Command;
	
	public class ShowStatsGroupCommand extends Command
	{
		[Inject]
		public var event:StatsEvent;
		
		[Inject]
		public var infrnoChatMediator:InfrnoChatMediator;
		
		override public function execute( ) : void
		{			
			infrnoChatMediator.addStatsGroup();
		}
	}
}