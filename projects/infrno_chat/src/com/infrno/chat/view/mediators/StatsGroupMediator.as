package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.PeerService;
	import com.infrno.chat.view.components.ClientStatsBlock;
	import com.infrno.chat.view.components.PeerStatsBlock;
	import com.infrno.chat.view.components.Sparkline;
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
//			eventMap.mapListener(eventDispatcher,StatsEvent.DELETE_PEER_STATS,removePeerStatsBlock);
		}
		
		private function usersUpdated(msEvent:MSEvent):void
		{
			updateStatGroup(msEvent.userInfoVO_array, msEvent.local_userInfoVO);
		}		
		
		private function updateStatGroup(userInfoVO_array:Array, local_userInfoVO:UserInfoVO):void
		{
			removeStalePeerStatBlocks(userInfoVO_array);			
			removeStaleClientStatBlocks(userInfoVO_array);			
			createNewClientStatsBlocks(userInfoVO_array);
		}
		
		private function removeStaleClientStatBlocks(userInfoVO_array:Array):void {
//			trace("StatsGroupMediator.removeClientStatBlocks()");
			var dataProviderLength:int = statsGroup.statsGroup_list.dataProvider.length;
			for(var i:int = 0; i<dataProviderLength; i++){
//				trace("StatsGroupMediator.removeClientStatBlocks() i="+i);
				try{					
					var clientStatsBlock:ClientStatsBlock = statsGroup.statsGroup_list.dataProvider.getItemAt(i) as ClientStatsBlock;
//					trace("StatsGroupMediator.removeClientStatBlocks() statsBlock.client_suid="+statsBlock.client_suid);
					
					if(userInfoVO_array[clientStatsBlock.client_suid] == null){
						var statsGroup_index:int = statsGroup.statsGroup_list.dataProvider.getItemIndex(clientStatsBlock);
						trace("StatsGroupMediator.removeClientStatBlocks() clientStatsBlock.client_suid="+clientStatsBlock.client_suid);
						statsGroup.statsGroup_list.dataProvider.removeItemAt(statsGroup_index);
					}
				}catch(e:Object){
					//out of range error I'm sure
					// TODO Make sure we don't get out of range errors
					// Things work just fine, but how does this state occur?
					trace("StatsGroupMediator.removeClientStatBlocks() error:" +e.toString());
				}
			}
		}
		
		private function removeStalePeerStatBlocks(userInfoVO_array:Array):void {
			var statsGroup_list_dataProviderLength:int = statsGroup.statsGroup_list.dataProvider.length;
			for(var i:int = 0; i<statsGroup_list_dataProviderLength; i++){
				try{					
					var clientStatsBlock:ClientStatsBlock = statsGroup.statsGroup_list.dataProvider.getItemAt(i) as ClientStatsBlock;
					
					var peerBlock_list_dataProviderLength:int = clientStatsBlock.peerBlock_list.dataProvider.length;
					for(var j:int = 0; j<peerBlock_list_dataProviderLength; j++){
						var peerStatsBlock:PeerStatsBlock = clientStatsBlock.peerBlock_list.dataProvider.getItemAt(j) as PeerStatsBlock;
						
						if(userInfoVO_array[peerStatsBlock.peer_suid] == null){
							var peerStatsBlock_index:int = clientStatsBlock.peerBlock_list.dataProvider.getItemIndex(peerStatsBlock);
							trace("StatsGroupMediator.removeStalePeerStatBlocks() removing peerStatsBlock.peer_suid="+peerStatsBlock.peer_suid);
							clientStatsBlock.peerBlock_list.dataProvider.removeItemAt(peerStatsBlock_index);
						}						
					}
				}catch(e:Object){
					trace("StatsGroupMediator.removeStalePeerStatBlocks() error:" +e.toString());
				}
			}
		}			
		
		private function createNewClientStatsBlocks(userInfoVO_array:Array):void{
			for(var suid:String in userInfoVO_array){
				trace("StatsGroupMediator.createClientStatsBlocks() suid:"+suid);
				var userInfoVO:UserInfoVO = userInfoVO_array[suid];
				
				var clientStatsBlock:ClientStatsBlock = getClientStatsBlock(suid);
				if (clientStatsBlock == null) {
					trace("StatsGroupMediator.createClientStatsBlocks() adding new ClientStatsBlock for suid:"+suid);
					clientStatsBlock = new ClientStatsBlock();
					clientStatsBlock.client_suid = suid;
					clientStatsBlock.user_name_label = "Client: " + userInfoVO.user_name;
					statsGroup.statsGroup_list.dataProvider.addItem(clientStatsBlock);
					
					clientStatsBlock.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
					{
						trace("StatsGroupMediator.createNewClientStatsBlocks() ClientStatsBlock FlexEvent.CREATION_COMPLETE event listener")
					});
					
				} else {
					trace("StatsGroupMediator.createClientStatsBlocks() found existing ClientStatsBlock for suid:"+suid);					
				}				
			}
		}		


		private function displayServerStats(statsEvent:StatsEvent):void
		{
//			trace("StatsGroupMediator.displayServerStats()");
			var serverStatsVO:StatsVO = statsEvent.statsVO;
			
			var statsBlock:ClientStatsBlock = getClientStatsBlock(serverStatsVO.suid);
			if (statsBlock == null) {
				trace("StatsGroupMediator.displayServerStats() null statsBlock !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
				return;
			}		
			
			statsBlock.droppedFrames_label = "Dropped frames: " + serverStatsVO.lastDataRecord.droppedFrames;
			statsBlock.serverStatsVO = serverStatsVO;		
		}		
		
		private function displayPeerStats(statsEvent:StatsEvent):void	{
//			trace("StatsGroupMediator.displayPeerStats()");
			
			var clientStatsBlock:ClientStatsBlock = getClientStatsBlock(statsEvent.client_suid);
			if (clientStatsBlock == null || clientStatsBlock.peerBlock_list == null) {
				trace("StatsGroupMediator.displayPeerStats() null clientStatsBlock !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
				return;
			}		
			
			var client_peerStatsVO:StatsVO;
			var peerStatsBlock:PeerStatsBlock;
			var client_peerStatsVO_array:Array = statsEvent.client_peerStatsVO_array;
			for (var peer_suid:String in client_peerStatsVO_array) {
				client_peerStatsVO = client_peerStatsVO_array[peer_suid];		
				
				peerStatsBlock = getPeerStatsBlock(clientStatsBlock, peer_suid);
				if (peerStatsBlock == null) {
					trace("StatsGroupMediator.displayPeerStats() adding new PeerStatsBlock for peer_suid:"+peer_suid);
					peerStatsBlock = new PeerStatsBlock();
					peerStatsBlock.peer_suid = peer_suid;
					peerStatsBlock.user_name_label = "Peer: " + client_peerStatsVO.lastDataRecord.remote_user_name;
					clientStatsBlock.peerBlock_list.dataProvider.addItem(peerStatsBlock);							
					
					peerStatsBlock.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
					{
						trace("StatsGroupMediator.displayPeerStats() PeerStatsBlock FlexEvent.CREATION_COMPLETE event listener")
					});
					
					
				} else {
//					trace("StatsGroupMediator.displayPeerStats() found existing PeerStatsBlock for peer_suid:"+peer_suid);					
				}					
				
				peerStatsBlock.peerStatsVO = client_peerStatsVO;				
			}
		}
		
//		private function removePeerStatsBlock(statsEvent:StatsEvent):void{
//			trace("StatsGroupMediator.removePeerStatsBlock()");
//			
//			var clientStatsBlock:ClientStatsBlock = getClientStatsBlock(statsEvent.client_suid);
//			if (clientStatsBlock == null) {
//				trace("StatsGroupMediator.removePeerStatsBlock() null clientStatsBlock !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//				return;
//			}		
//
//			var peerStatsBlock:PeerStatsBlock = getPeerStatsBlock(clientStatsBlock, statsEvent.peer_suid);
//			if (peerStatsBlock == null) {
//				trace("StatsGroupMediator.removePeerStatsBlock() null peerStatsBlock !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//				return;
//			}		
//			
//			var peerStatsBlock_index:int = clientStatsBlock.peerBlock_list.dataProvider.getItemIndex(peerStatsBlock);
//			trace("StatsGroupMediator.removePeerStatsBlock() peerStatsBlock_index="+peerStatsBlock_index);
//			clientStatsBlock.peerBlock_list.dataProvider.removeItemAt(peerStatsBlock_index);
//		}	
		
		private function getPeerStatsBlock(clientStatsBlock:ClientStatsBlock, peer_suid:String): PeerStatsBlock {
//			trace("StatsGroupMediator.getPeerStatsBlock() peer_suid="+peer_suid)
			
			var peerStatsBlock:PeerStatsBlock;
			var dataProviderLength:int = clientStatsBlock.peerBlock_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
//				trace("StatsGroupMediator.getPeerStatsBlock() i="+i+", statsGroup.statsGroup_list.dataProvider.length="+dataProviderLength);
				peerStatsBlock = clientStatsBlock.peerBlock_list.dataProvider.getItemAt(i) as PeerStatsBlock;
//				trace("StatsGroupMediator.getPeerStatsBlock() peerStatsBlock.peer_suid="+peerStatsBlock.peer_suid);
				if (peerStatsBlock.peer_suid == peer_suid) {
					return peerStatsBlock;
				}
			}
			return null;
		}
		
		private function getClientStatsBlock(suid:String): ClientStatsBlock {
//			trace("StatsGroupMediator.getClientStatsBlock() suid="+suid)

			var clientStatsBlock:ClientStatsBlock;
			var dataProviderLength:int = statsGroup.statsGroup_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
//				trace("StatsGroupMediator.getClientStatsBlock() i="+i+", statsGroup.statsGroup_list.dataProvider.length="+dataProviderLength)
				clientStatsBlock = statsGroup.statsGroup_list.dataProvider.getItemAt(i) as ClientStatsBlock;
//				trace("StatsGroupMediator.getClientStatsBlock() statsBlock.suid="+clientStatsBlock.client_suid)
				if (clientStatsBlock.client_suid == suid) {
					return clientStatsBlock;
				}
			}
			return null;
		}
	}
}