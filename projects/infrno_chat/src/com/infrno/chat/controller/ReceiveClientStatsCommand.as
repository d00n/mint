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
			
			var clientStats:Object = event.clientStats;
			var client_suid:String = clientStats.client_suid;
			
			var client_serverStatsVO:StatsVO = statsProxy.serverStatsVO_array[client_suid];
			if (client_serverStatsVO == null) {
				client_serverStatsVO = new StatsVO();
				statsProxy.serverStatsVO_array[client_suid] = client_serverStatsVO;
			}
			
			// Hrmmmm..
			client_serverStatsVO.suid = client_suid;
			
			client_serverStatsVO.data_AC.addItem(clientStats.serverStatsRecord);		
			
			if (client_serverStatsVO.data_AC.length > StatsProxy.NUMBER_OF_DATA_RECORDS_TO_KEEP) {
				client_serverStatsVO.data_AC.removeItemAt(0);
			}
			
			var client_peerStatsRecord_array:Array =	 clientStats.peerStatsRecord_array as Array;
			
//			if (client_peerStatsRecord_array.length == 0) {
//				trace('ReceivePeerStatsCommand.execute() aborting because client_peerStatsRecord_array is empty');
//				return;
//			}
			
			var client_peerStatsVO_array:Array = statsProxy.client_array[client_suid] as Array;
			if (client_peerStatsVO_array == null) {
				client_peerStatsVO_array = new Array();
				statsProxy.client_array[client_suid] = client_peerStatsVO_array;
			}

			
			// Delete client peers in local collection missing from inbound collection
			var peer_suid:String;
			for (peer_suid in client_peerStatsVO_array) {
				if (client_peerStatsRecord_array[peer_suid] == null){
					delete client_peerStatsVO_array[peer_suid];
					
					// We currently delete on MSEvent.USERS_OBJ_UPDATE, but that fires way to often. 
					// StatsEvent.DELETE_PEER_STATS is better, but we don't yet handle clientBlock adds
//					var delete_statsEvent:StatsEvent = new StatsEvent(StatsEvent.DELETE_PEER_STATS);
//					delete_statsEvent.client_suid = client_suid;
//					delete_statsEvent.peer_suid = peer_suid;
//					dispatch(delete_statsEvent);
				}
			}			
			
			
			
			// Add new data records to each peerStatVO
			var client_peerStatsVO:StatsVO;
			var client_peerStatsRecord:Object;
			for (peer_suid in client_peerStatsRecord_array) {
				client_peerStatsRecord = client_peerStatsRecord_array[peer_suid];
				
				client_peerStatsVO = client_peerStatsVO_array[client_peerStatsRecord.remote_suid];
				if (client_peerStatsVO == null) {
					client_peerStatsVO = new StatsVO();
					client_peerStatsVO_array[client_peerStatsRecord.remote_suid] = client_peerStatsVO;
				}
				
				client_peerStatsVO.data_AC.addItem(client_peerStatsRecord);
				
				if (client_peerStatsVO.data_AC.length > StatsProxy.NUMBER_OF_DATA_RECORDS_TO_KEEP) {
					client_peerStatsVO.data_AC.removeItemAt(0);
				}
			}
			
//			trace('ReceiveClientStatsCommand.execute() client_suid:'+client_suid+' peer_suid:'+peer_suid);
			
		
			var statsEvent:StatsEvent = new StatsEvent(StatsEvent.DISPLAY_CLIENT_STATS);
			statsEvent.client_suid = client_suid;
			statsEvent.clientStats = clientStats;
			statsEvent.client_serverStatsVO = client_serverStatsVO;
			statsEvent.client_peerStatsVO_array = client_peerStatsVO_array;
			dispatch(statsEvent);
		}		
	}
}