package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.PeerService;
	import com.infrno.chat.view.components.PeerStatsBlock;
	import com.infrno.chat.view.components.Sparkline;
	import com.infrno.chat.view.components.ClientStatsBlock;
	import com.infrno.chat.view.components.StatsGroup;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.robotlegs.mvcs.Mediator;

	public class StatsGroupMediator extends Mediator
	{
		[Inject]
		public var statsGroup:StatsGroup;
		
		public function StatsGroupMediator()
		{
		}
		
		override public function onRegister():void{
			eventMap.mapListener(eventDispatcher,MSEvent.USERS_OBJ_UPDATE,usersUpdated);	
			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_SERVER_STATS,displayServerStats);
			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_PEER_STATS,displayPeerStats);
			eventMap.mapListener(eventDispatcher,StatsEvent.DELETE_PEER_STATS,removePeerStatsBlock);
		}
		
		private function usersUpdated(msEvent:MSEvent):void
		{
			updateStatGroup(msEvent.userInfoVO_array, msEvent.local_userInfoVO);
		}		
		
		private function updateStatGroup(userInfoVO_array:Array, local_userInfoVO:UserInfoVO):void
		{
			removeDisconnectedStatBlocks(userInfoVO_array);			
			addNewStatBlocks(userInfoVO_array);
		}
		
		private function removeDisconnectedStatBlocks(userInfoVO_array:Array):void
		{
			trace("StatsGroupMediator.removeDisconnectedStatBlocks()");
			var dataProviderLength:int = statsGroup.statsGroup_list.dataProvider.length;
			for(var i:int = 0; i<dataProviderLength; i++){
				trace("StatsGroupMediator.removeDisconnectedStatBlocks() i="+i);
				try{					
					var statsBlock:ClientStatsBlock = statsGroup.statsGroup_list.dataProvider.getItemAt(i) as ClientStatsBlock;
					trace("StatsGroupMediator.removeDisconnectedStatBlocks() statsBlock.suid="+statsBlock.suid);
					
					if(userInfoVO_array[statsBlock.suid] == null){
						var statsGroup_index:int = statsGroup.statsGroup_list.dataProvider.getItemIndex(statsBlock);
						trace("StatsGroupMediator.removeDisconnectedStatBlocks() statsGroup_index="+statsGroup_index);
						statsGroup.statsGroup_list.dataProvider.removeItemAt(statsGroup_index);
					}
				}catch(e:Object){
					//out of range error I'm sure
					// TODO Make sure we don't get out of range errors
					// Things work just fine, but how does this state occur?
					trace("StatsGroupMediator.removeDisconnectedStatBlocks() error:" +e.toString());
				}
			}
		}
		
		private function addNewStatBlocks(userInfoVO_array:Array):void{
			for(var suid:String in userInfoVO_array){
				trace("StatsGroupMediator.addNewStatBlocks() suid:"+suid);
				var userInfoVO:UserInfoVO = userInfoVO_array[suid];
				
				var statsBlock:ClientStatsBlock = getStatsBlockBySuid(suid);
				if (statsBlock == null) {
					trace("StatsGroupMediator.addNewStatBlocks() adding new StatsBlock for suid:"+suid);
					statsBlock = new ClientStatsBlock();
					statsBlock.suid = suid;
					statsBlock.user_name_label = "User: " + userInfoVO.user_name;
					statsGroup.statsGroup_list.dataProvider.addItem(statsBlock);										
				} else {
					trace("StatsGroupMediator.addNewStatBlocks() found existing StatsBlock for suid:"+suid);					
				}				
			}
		}
		

		private function displayServerStats(statsEvent:StatsEvent):void
		{
			trace("StatsGroupMediator.displayServerStats()");
			var serverStatsVO:StatsVO = statsEvent.statsVO;
			
			var statsBlock:ClientStatsBlock = getStatsBlockBySuid(serverStatsVO.suid);
			if (statsBlock == null) {
				trace("StatsGroupMediator.displayServerStats() null statsBlock !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
				return;
			}		
			
			statsBlock.droppedFrames_label = "Dropped frames: " + serverStatsVO.lastDataRecord.droppedFrames;
			statsBlock.serverStatsVO = serverStatsVO;		
		}		
		
		private function displayPeerStats(statsEvent:StatsEvent):void
		{
			trace("StatsGroupMediator.displayPeerStats()");
			
			var statsBlock:ClientStatsBlock = getStatsBlockBySuid(statsEvent.suid);
			if (statsBlock == null) {
				trace("StatsGroupMediator.displayPeerStats() null statsBlock !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
				return;
			}		
			
			var client_peerStatsRecord:Object;
			var client_peerStatsRecord_array:Array = statsEvent.client_peerStatsRecord_array;
			
			for (var remote_suid:String in client_peerStatsRecord_array) {
				client_peerStatsRecord = client_peerStatsRecord_array[remote_suid];
			}
		}
		
		private function removePeerStatsBlock(statsEvent:StatsEvent):void{
			trace("StatsGroupMediator.removePeerStatsBlock()");
			
			var statsBlock:ClientStatsBlock = getStatsBlockBySuid(statsEvent.client_suid);
			if (statsBlock == null) {
				trace("StatsGroupMediator.removePeerStatsBlock() null statsBlock !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
				return;
			}		

			var peerStatsBlock:PeerStatsBlock = getPeerStatsBlock(statsBlock, statsEvent.peer_suid);
			if (peerStatsBlock == null) {
				trace("StatsGroupMediator.removePeerStatsBlock() null peerStatsBlock !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
				return;
			}		
			
			var peerStatsBlock_index:int = statsBlock.peerBlock_list.dataProvider.getItemIndex(peerStatsBlock);
			trace("StatsGroupMediator.removePeerStatsBlock() peerStatsBlock_index="+peerStatsBlock_index);
			statsBlock.peerBlock_list.dataProvider.removeItemAt(peerStatsBlock_index);
		}	
		
		private function getPeerStatsBlock(statsBlock:ClientStatsBlock, peer_suid:String): PeerStatsBlock {
			trace("StatsGroupMediator.getPeerStatsBlock() peer_suid="+peer_suid)
			
			var peerStatsBlock:PeerStatsBlock;
			var dataProviderLength:int = statsBlock.peerBlock_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
				trace("StatsGroupMediator.getPeerStatsBlock() i="+i+", statsGroup.statsGroup_list.dataProvider.length="+dataProviderLength)
				peerStatsBlock = statsBlock.peerBlock_list.dataProvider.getItemAt(i) as PeerStatsBlock;
				trace("StatsGroupMediator.getPeerStatsBlock() peerStatsBlock.peer_suid="+peerStatsBlock.peer_suid)
				if (peerStatsBlock.peer_suid == peer_suid) {
					return peerStatsBlock;
				}
			}
			return null;
		}
		
		private function getStatsBlockBySuid(suid:String): ClientStatsBlock {
			trace("StatsGroupMediator.getStatsBySuid() suid="+suid)

			var clientStatsBlock:ClientStatsBlock;
			var dataProviderLength:int = statsGroup.statsGroup_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
				trace("StatsGroupMediator.getStatsBySuid() i="+i+", statsGroup.statsGroup_list.dataProvider.length="+dataProviderLength)
				clientStatsBlock = statsGroup.statsGroup_list.dataProvider.getItemAt(i) as ClientStatsBlock;
				trace("StatsGroupMediator.getStatsBySuid() statsBlock.suid="+clientStatsBlock.suid)
				if (clientStatsBlock.suid == suid) {
					return clientStatsBlock;
				}
			}
			return null;
		}
	}
}