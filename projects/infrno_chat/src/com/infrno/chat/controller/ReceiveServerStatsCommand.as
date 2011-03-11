package com.infrno.chat.controller
{
	import com.infrno.chat.model.StatsProxy;
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	
	import org.robotlegs.mvcs.Command;
	
	public class ReceiveServerStatsCommand extends Command
	{
		[Inject]
		public var event:StatsEvent;
		
		[Inject]
		public var statsProxy:StatsProxy;
		
		override public function execute():void{
			var serverStats:Object = event.serverStats;
			
			var client_suid:String;
			for (client_suid in serverStats) {
				var server_clientStatsVO:StatsVO = statsProxy.server_clientStatsVO_array[client_suid];
				if (server_clientStatsVO == null) {
					server_clientStatsVO = new StatsVO();
					statsProxy.server_clientStatsVO_array[client_suid] = server_clientStatsVO;
				}
				
				server_clientStatsVO.data_AC.addItem(serverStats[client_suid]);		
				if (server_clientStatsVO.data_AC.length > StatsProxy.NUMBER_OF_DATA_RECORDS_TO_KEEP) {
					server_clientStatsVO.data_AC.removeItemAt(0);
				}
			}
			
			var statsEvent:StatsEvent = new StatsEvent(StatsEvent.DISPLAY_SERVER_STATS);
			statsEvent.server_clientStatsVO_array = statsProxy.server_clientStatsVO_array;
			dispatch(statsEvent);
		}	
	}
}