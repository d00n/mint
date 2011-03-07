package com.infrno.chat.controller
{
	import com.infrno.chat.model.StatsProxy;
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	
	import org.robotlegs.mvcs.Command;
	
	public class ReceivePeerStatsCommand extends Command
	{
		[Inject]
		public var event:StatsEvent;
		
		[Inject]
		public var statsProxy:StatsProxy;
		
		override public function execute():void{
			trace('ReceivePeerStatsCommand.execute()');
			
			var peerStatsRecord:Object = event.statsRecord;
			
			if (statsProxy.peerStatsVO_array[peerStatsRecord.remote_suid] == null) {
				statsProxy.peerStatsVO_array[peerStatsRecord.remote_suid] = new StatsVO();
			}
			
			var peerStatsVO:StatsVO = statsProxy.peerStatsVO_array[peerStatsRecord.remote_suid];
			
			// Using suid as the key and a field smells. hrmmm..
			peerStatsVO.suid = peerStatsRecord.remote_suid;
			
			peerStatsVO.data_AC.addItem(peerStatsRecord);		
			
			if (peerStatsVO.data_AC.length > StatsProxy.NUMBER_OF_DATA_RECORDS_TO_KEEP) {
				peerStatsVO.data_AC.removeItemAt(0);
			}
			
			var statsEvent:StatsEvent = new StatsEvent(StatsEvent.DISPLAY_PEER_STATS);
			statsEvent.statsVO = peerStatsVO;
			dispatch(statsEvent);
		}			

	}
}