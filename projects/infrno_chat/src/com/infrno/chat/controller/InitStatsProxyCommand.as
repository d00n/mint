package com.infrno.chat.controller
{
	import com.infrno.chat.model.StatsProxy;
	
	import org.robotlegs.mvcs.Command;
	
	public class InitStatsProxyCommand extends Command
	{
		[Inject]
		public var statsProxy:StatsProxy;
		
		override public function execute():void
		{
			statsProxy.init();
		}
	}
}