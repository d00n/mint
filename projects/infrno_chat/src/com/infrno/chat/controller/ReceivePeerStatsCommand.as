package com.infrno.chat.controller
{
	import com.infrno.chat.model.StatsProxy;
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Command;
	
	public class ReceivePeerStatsCommand extends Command
	{
		[Inject]
		public var event:StatsEvent;
		
		[Inject]
		public var statsProxy:StatsProxy;
		
		override public function execute():void{
			trace('ReceivePeerStatsCommand.execute()');
			var incoming_peerStats:Object = event.peerStats;
			
			// header record: the incoming peer's suid and peerStatsVO_array
			var source_suid:String = incoming_peerStats.source_suid;
			var source_peerStatsVO_array:Array = statsProxy.peer_array[source_suid] as Array;
			if (source_peerStatsVO_array == null) {
				source_peerStatsVO_array = new Array();
				statsProxy.peer_array[source_suid] = source_peerStatsVO_array;
			}
			
			// detail rows
			var peerStatsVO:StatsVO;
			var incoming_peerStatsRecord:Object;
			var incoming_peerStatsRecord_array:Array =	incoming_peerStats.peerStatsRecord_array as Array;			
			for (var remote_suid:String in incoming_peerStatsRecord_array) {
				incoming_peerStatsRecord = incoming_peerStatsRecord_array[remote_suid];
				
				peerStatsVO = source_peerStatsVO_array[incoming_peerStatsRecord.suid];
				if (peerStatsVO == null) {
					peerStatsVO = new StatsVO();
					source_peerStatsVO_array[incoming_peerStatsRecord.suid] = peerStatsVO;
				}
				
				peerStatsVO.data_AC.addItem(incoming_peerStatsRecord);
				
				if (peerStatsVO.data_AC.length > StatsProxy.NUMBER_OF_DATA_RECORDS_TO_KEEP) {
					peerStatsVO.data_AC.removeItemAt(0);
				}
			}

			var statsEvent:StatsEvent = new StatsEvent(StatsEvent.DISPLAY_PEER_STATS);
			statsEvent.suid = source_suid;
			dispatch(statsEvent);
		}			

	}
}