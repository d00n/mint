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
			var serverRecord_or_clientSuid:String;
			for (serverRecord_or_clientSuid in serverStats) {
				if (serverRecord_or_clientSuid == 'server record') {				
					statsProxy.serverStatsVO.data_AC.addItem(serverStats['server record']);		
					if (statsProxy.serverStatsVO.data_AC.length > StatsProxy.NUMBER_OF_DATA_RECORDS_TO_KEEP) {
						statsProxy.serverStatsVO.data_AC.removeItemAt(0);
					}					
					 
				} else {
					client_suid = serverRecord_or_clientSuid;
				
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
			}
			
			for (client_suid in statsProxy.server_clientStatsVO_array) {
				if (serverStats[client_suid] == null){
					delete statsProxy.server_clientStatsVO_array[client_suid];
				}
			}
			
			var statsEvent:StatsEvent = new StatsEvent(StatsEvent.DISPLAY_SERVER_STATS);
			statsEvent.server_clientStatsVO_array = statsProxy.server_clientStatsVO_array;
			statsEvent.serverStatsVO = statsProxy.serverStatsVO;
			dispatch(statsEvent);
		}	
	}
}