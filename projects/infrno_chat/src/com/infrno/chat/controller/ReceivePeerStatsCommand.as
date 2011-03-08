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
			var client_peerStats:Object = event.peerStats;
			
			// header record: the client suid and peerStatsVO_array
			var client_suid:String = client_peerStats.client_suid;
			var client_peerStatsVO_array:Array = statsProxy.client_array[client_suid] as Array;
			if (client_peerStatsVO_array == null) {
				client_peerStatsVO_array = new Array();
				statsProxy.client_array[client_suid] = client_peerStatsVO_array;
			}
			
			// client peers
			var peerStatsVO:StatsVO;
			var client_peerStatsRecord:Object;
			var client_peerStatsRecord_array:Array =	client_peerStats.peerStatsRecord_array as Array;			
			for (var remote_suid:String in client_peerStatsRecord_array) {
				client_peerStatsRecord = client_peerStatsRecord_array[remote_suid];
				
				peerStatsVO = client_peerStatsVO_array[client_peerStatsRecord.suid];
				if (peerStatsVO == null) {
					peerStatsVO = new StatsVO();
					client_peerStatsVO_array[client_peerStatsRecord.suid] = peerStatsVO;
				}
				
				peerStatsVO.data_AC.addItem(client_peerStatsRecord);
				
				if (peerStatsVO.data_AC.length > StatsProxy.NUMBER_OF_DATA_RECORDS_TO_KEEP) {
					peerStatsVO.data_AC.removeItemAt(0);
				}
			}
			
			// Delete client peers, missing from inbound stats collection
			for (var remote_suid:String in client_peerStatsVO_array) {
				if (client_peerStatsRecord_array[remote_suid] == null){
					client_peerStatsVO_array[remote_suid] == null;
				}
			}			


			var statsEvent:StatsEvent = new StatsEvent(StatsEvent.DISPLAY_PEER_STATS);
			statsEvent.suid = client_suid;
			dispatch(statsEvent);
		}			

	}
}