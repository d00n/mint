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
//			trace('ReceiveServerStatsCommand.execute()');
			
			var serverStatsRecord:Object = event.statsRecord;
			
			var serverStatsVO:StatsVO = statsProxy.serverStatsVO_array[serverStatsRecord.suid];
			if (serverStatsVO == null) {
				serverStatsVO = new StatsVO();
				statsProxy.serverStatsVO_array[serverStatsRecord.suid] = serverStatsVO;
			}
			
			// Hrmmmm..
			serverStatsVO.suid = serverStatsRecord.suid;
			
			serverStatsVO.data_AC.addItem(serverStatsRecord);		
			
			if (serverStatsVO.data_AC.length > StatsProxy.NUMBER_OF_DATA_RECORDS_TO_KEEP) {
				serverStatsVO.data_AC.removeItemAt(0);
			}
			
			var statsEvent:StatsEvent = new StatsEvent(StatsEvent.DISPLAY_SERVER_STATS);
			statsEvent.statsVO = serverStatsVO;
			dispatch(statsEvent);
		}	
	}
}