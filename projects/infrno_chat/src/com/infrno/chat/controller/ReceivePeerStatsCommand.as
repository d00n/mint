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
//			trace('ReceivePeerStatsCommand.execute()');
			var client_peerStatsRecord_array:Array =	 event.peerStats.peerStatsRecord_array as Array;
			
			if (client_peerStatsRecord_array.length == 0) {
				trace('ReceivePeerStatsCommand.execute() aborting because client_peerStatsRecord_array is empty');
				return;
			}
			
			// header record: the client suid and peerStatsVO_array
			var client_suid:String =  event.peerStats.client_suid;
			var client_peerStatsVO_array:Array = statsProxy.client_array[client_suid] as Array;
			if (client_peerStatsVO_array == null) {
				client_peerStatsVO_array = new Array();
				statsProxy.client_array[client_suid] = client_peerStatsVO_array;
			}

			// Delete client peers missing from inbound stats collection
			for (var peer_suid:String in client_peerStatsVO_array) {
				if (client_peerStatsRecord_array[peer_suid] == null){
					delete client_peerStatsVO_array[peer_suid];
					
//					var statsVO_to_remove:StatsVO = client_peerStatsVO_array[peer_suid] as StatsVO;
//					var remove_index:int = client_peerStatsVO_array.indexOf(statsVO_to_remove);
//					client_peerStatsVO_array.splice(remove_index, 1);

					
					// Let's try deleting on MSEvent.USERS_OBJ_UPDATE instead
//					var delete_statsEvent:StatsEvent = new StatsEvent(StatsEvent.DELETE_PEER_STATS);
//					delete_statsEvent.client_suid = client_suid;
//					delete_statsEvent.peer_suid = peer_suid;
//					dispatch(delete_statsEvent);
				}
			}			
			
			
			// client peers
			var client_peerStatsVO:StatsVO;
			var client_peerStatsRecord:Object;
			
			// Add new data records to each peerStatVO
			for (var peer_suid:String in client_peerStatsRecord_array) {
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
			
		
			var statsEvent:StatsEvent = new StatsEvent(StatsEvent.DISPLAY_PEER_STATS);
			statsEvent.client_suid = client_suid;
			statsEvent.client_peerStatsVO_array = client_peerStatsVO_array;
			dispatch(statsEvent);
		}			

	}
}