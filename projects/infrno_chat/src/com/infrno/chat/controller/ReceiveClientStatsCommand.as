package com.infrno.chat.controller
{
	import com.infrno.chat.model.StatsProxy;
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Command;
	
	public class ReceiveClientStatsCommand extends Command
	{
		[Inject]
		public var event:StatsEvent;
		
		[Inject]
		public var statsProxy:StatsProxy;
		
		override public function execute():void{			
			var clientStats:Object = event.inbound_clientStats;
			var client_suid:String = clientStats.client_suid;
			
			var client_serverStatsVO:StatsVO = statsProxy.client_serverStatsVO_array[client_suid];
			if (client_serverStatsVO == null) {
				client_serverStatsVO = new StatsVO();
				statsProxy.client_serverStatsVO_array[client_suid] = client_serverStatsVO;
				
				var newClient_statsEvent:StatsEvent = new StatsEvent(StatsEvent.NEW_CLIENT_BLOCK);
				newClient_statsEvent.client_suid = client_suid;
				dispatch(newClient_statsEvent);
			}
			
			// Hrmmmm..
			client_serverStatsVO.suid = client_suid;
			
			client_serverStatsVO.data_AC.addItem(clientStats.serverStatsRecord);		
			
			if (client_serverStatsVO.data_AC.length > StatsProxy.NUMBER_OF_DATA_RECORDS_TO_KEEP) {
				client_serverStatsVO.data_AC.removeItemAt(0);
			}
			
			var peerStatsRecord_array:Array =	 clientStats.peerStatsRecord_array as Array;
			
//			if (client_peerStatsRecord_array.length == 0) {
//				trace('ReceivePeerStatsCommand.execute() aborting because client_peerStatsRecord_array is empty');
//				return;
//			}
			
			var peerStatsVO_array:Array = statsProxy.peer_array[client_suid] as Array;
			if (peerStatsVO_array == null) {
				peerStatsVO_array = new Array();
				statsProxy.peer_array[client_suid] = peerStatsVO_array;
				
				// TODO? Add client peer block event??				
			}

			
			// Delete client peers in local collection missing from inbound collection
			var peer_suid:String;
			for (peer_suid in peerStatsVO_array) {
				if (peerStatsRecord_array[peer_suid] == null){
					delete peerStatsVO_array[peer_suid];
					
					var delete_statsEvent:StatsEvent = new StatsEvent(StatsEvent.DELETE_PEER_STATS);
					delete_statsEvent.client_suid = peer_suid;
					dispatch(delete_statsEvent);
				}
			}			
			
			
			
			// Add new data records to each peerStatVO
			var peerStatsVO:StatsVO;
			var peerStatsRecord:Object;
			for (peer_suid in peerStatsRecord_array) {
				peerStatsRecord = peerStatsRecord_array[peer_suid];
				
				peerStatsVO = peerStatsVO_array[peerStatsRecord.remote_suid];
				if (peerStatsVO == null) {
					peerStatsVO = new StatsVO();
					peerStatsVO_array[peerStatsRecord.remote_suid] = peerStatsVO;
				}
				
				peerStatsVO.data_AC.addItem(peerStatsRecord);
				
				if (peerStatsVO.data_AC.length > StatsProxy.NUMBER_OF_DATA_RECORDS_TO_KEEP) {
					peerStatsVO.data_AC.removeItemAt(0);
				}
			}
			
//			trace('ReceiveClientStatsCommand.execute() client_suid:'+client_suid+' peer_suid:'+peer_suid);
			
		
			var displayClientStats_statsEvent:StatsEvent = new StatsEvent(StatsEvent.DISPLAY_CLIENT_STATS);
			displayClientStats_statsEvent.client_suid = client_suid;
			displayClientStats_statsEvent.inbound_clientStats = clientStats;
			displayClientStats_statsEvent.client_serverStatsVO = client_serverStatsVO;
			displayClientStats_statsEvent.client_peerStatsVO_array = peerStatsVO_array;
			dispatch(displayClientStats_statsEvent);
		}		
	}
}