package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.PeerService;
	import com.infrno.chat.view.components.ClientStatsBlock;
	import com.infrno.chat.view.components.Client_PeerStatsBlock;
	import com.infrno.chat.view.components.ServerStatsBlock;
	import com.infrno.chat.view.components.Server_ClientStatsBlock;
	import com.infrno.chat.view.components.Sparkline;
	import com.infrno.chat.view.components.StatsGroup;
	
	import flash.events.Event;
	
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
			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_CLIENT_STATS,displayClientStats);
			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_CLIENT_STATS,displayPeerStats);
			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_SERVER_STATS,displayServerStats);

			// this gets called a *lot*, far too broad for our needs
			eventMap.mapListener(eventDispatcher,MSEvent.USERS_OBJ_UPDATE,usersUpdated);	
			
			// this is more efficent, but does not handle adding clientBlocks yet
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
//			trace("StatsGroupMediator.removeStaleClientStatBlocks()");
			var dataProviderLength:int = statsGroup.clientStatsBlock_list.dataProvider.length;
			for(var i:int = 0; i<dataProviderLength; i++){
//				trace("StatsGroupMediator.removeClientStatBlocks() i="+i);
				try{					
					var clientStatsBlock:ClientStatsBlock = statsGroup.clientStatsBlock_list.dataProvider.getItemAt(i) as ClientStatsBlock;
//					trace("StatsGroupMediator.removeStaleClientStatBlocks() statsBlock.client_suid="+statsBlock.client_suid);
					
					if(userInfoVO_array[clientStatsBlock.client_suid] == null){
						var statsGroup_index:int = statsGroup.clientStatsBlock_list.dataProvider.getItemIndex(clientStatsBlock);
						trace("StatsGroupMediator.removeStaleClientStatBlocks() clientStatsBlock.client_suid="+clientStatsBlock.client_suid);
						statsGroup.clientStatsBlock_list.dataProvider.removeItemAt(statsGroup_index);
					}
				}catch(e:Object){
					//out of range error I'm sure
					// TODO Make sure we don't get out of range errors
					// Things work just fine, but how does this state occur?
					trace("StatsGroupMediator.removeStaleClientStatBlocks() error:" +e.toString());
				}
			}
		}
		
		private function removeStalePeerStatBlocks(userInfoVO_array:Array):void {
			var statsGroup_list_dataProviderLength:int = statsGroup.clientStatsBlock_list.dataProvider.length;
			for(var i:int = 0; i<statsGroup_list_dataProviderLength; i++){
				try{					
					var clientStatsBlock:ClientStatsBlock = statsGroup.clientStatsBlock_list.dataProvider.getItemAt(i) as ClientStatsBlock;
					
					var peerBlock_list_dataProviderLength:int = clientStatsBlock.peerStatsBlock_list.dataProvider.length;
					for(var j:int = 0; j<peerBlock_list_dataProviderLength; j++){
						var peerStatsBlock:Client_PeerStatsBlock = clientStatsBlock.peerStatsBlock_list.dataProvider.getItemAt(j) as Client_PeerStatsBlock;
						
						if(userInfoVO_array[peerStatsBlock.peer_suid] == null){
							var peerStatsBlock_index:int = clientStatsBlock.peerStatsBlock_list.dataProvider.getItemIndex(peerStatsBlock);
							trace("StatsGroupMediator.removeStalePeerStatBlocks() removing peerStatsBlock.peer_suid="+peerStatsBlock.peer_suid);
							clientStatsBlock.peerStatsBlock_list.dataProvider.removeItemAt(peerStatsBlock_index);
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
					statsGroup.clientStatsBlock_list.dataProvider.addItem(clientStatsBlock);
					
					clientStatsBlock.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
					{
						trace("StatsGroupMediator.createNewClientStatsBlocks() ClientStatsBlock FlexEvent.CREATION_COMPLETE event listener")
					});
					
				} else {
					trace("StatsGroupMediator.createClientStatsBlocks() found existing ClientStatsBlock for suid:"+suid);					
				}				
			}
		}		

		private function displayServerStats(statsEvent:StatsEvent):void	{
			
			if (!statsGroup.serverStatsBlock.initialized)
				return;
			
			var server_clientStatsBlock:Server_ClientStatsBlock;
			var server_clientStatsVO:StatsVO;
			var server_clientStatsVO_array:Array = statsEvent.server_clientStatsVO_array;
			
			for (var  client_suid:String in server_clientStatsVO_array) {
				server_clientStatsVO = server_clientStatsVO_array[client_suid] as StatsVO;
				
				server_clientStatsBlock = getServer_ClientStatsBlock(client_suid);
				
				if (server_clientStatsBlock == null) {
					server_clientStatsBlock = new Server_ClientStatsBlock();
					server_clientStatsBlock.client_suid = client_suid;
					
					statsGroup.serverStatsBlock.clientStatsBlock_list.dataProvider.addItem(server_clientStatsBlock);
					
//					server_ClientStatsBlock.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
//					{
//						
//					});
				}
				
				server_clientStatsBlock.statsVO = server_clientStatsVO;
			}
			

//			
//			
//			var client_peerStatsVO:StatsVO;
//			var peerStatsBlock:Client_PeerStatsBlock;
//			var client_peerStatsVO_array:Array = statsEvent.client_peerStatsVO_array;
//			for (var peer_suid:String in client_peerStatsVO_array) {
//				client_peerStatsVO = client_peerStatsVO_array[peer_suid];		
//				
//				peerStatsBlock = getPeerStatsBlock(clientStatsBlock, peer_suid);
//				if (peerStatsBlock == null) {
//					trace("StatsGroupMediator.displayPeerStats() adding new PeerStatsBlock for peer_suid:"+peer_suid);
//					peerStatsBlock = new Client_PeerStatsBlock();
//					peerStatsBlock.peer_suid = peer_suid;
//					peerStatsBlock.user_name_label = "Peer: " + client_peerStatsVO.lastDataRecord.remote_user_name;
//					clientStatsBlock.peerStatsBlock_list.dataProvider.addItem(peerStatsBlock);							
//					
//					peerStatsBlock.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
//					{
//						trace("StatsGroupMediator.displayPeerStats() PeerStatsBlock FlexEvent.CREATION_COMPLETE event listener")
//						clientStatsBlock.peerStatsBlock_list.dataProvider.addItem(this);
//					});
//					
//					
//				} else {
//					//					trace("StatsGroupMediator.displayPeerStats() found existing PeerStatsBlock for peer_suid:"+peer_suid);					
//				}					
//				if (peerStatsBlock.initialized)
//					peerStatsBlock.peerStatsVO = client_peerStatsVO;	
//				else
//					trace("StatsGroupMediator.displayPeerStats() peerStatsBlock.initialized:"+peerStatsBlock.initialized);
//			}
		}
		private function displayClientStats(statsEvent:StatsEvent):void
		{
//			trace("StatsGroupMediator.displayServerStats()");
			
			// TODO This is the only reference of serverStatsVO.suid, should it be client_suid?
			var clientStatsBlock:ClientStatsBlock = getClientStatsBlock(statsEvent.client_suid);
			if (clientStatsBlock == null) {
				trace("StatsGroupMediator.displayServerStats() null clientStatsBlock !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
				return;
			}		

			clientStatsBlock.client_serverStatsVO 	= statsEvent.client_serverStatsVO;		
			clientStatsBlock.clientStats						= statsEvent.clientStats;		
		}		
		
		private function displayPeerStats(statsEvent:StatsEvent):void	{
//			trace("StatsGroupMediator.displayPeerStats()");
			
			var clientStats:Object = statsEvent.clientStats;
			
			var clientStatsBlock:ClientStatsBlock = getClientStatsBlock(statsEvent.client_suid);
			if (clientStatsBlock == null || clientStatsBlock.peerStatsBlock_list == null) {
				trace("StatsGroupMediator.displayPeerStats() null clientStatsBlock !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
				return;
			}		
			
			var client_peerStatsVO:StatsVO;
			var peerStatsBlock:Client_PeerStatsBlock;
			var client_peerStatsVO_array:Array = statsEvent.client_peerStatsVO_array;
			for (var peer_suid:String in client_peerStatsVO_array) {
				client_peerStatsVO = client_peerStatsVO_array[peer_suid];		
				
				peerStatsBlock = getPeerStatsBlock(clientStatsBlock, peer_suid);
				if (peerStatsBlock == null) {
					trace("StatsGroupMediator.displayPeerStats() adding new PeerStatsBlock for peer_suid:"+peer_suid);
					peerStatsBlock = new Client_PeerStatsBlock();
					peerStatsBlock.peer_suid = peer_suid;
					peerStatsBlock.user_name_label = "Peer: " + client_peerStatsVO.lastDataRecord.remote_user_name;
					clientStatsBlock.peerStatsBlock_list.dataProvider.addItem(peerStatsBlock);							
					
					peerStatsBlock.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
					{
						trace("StatsGroupMediator.displayPeerStats() PeerStatsBlock FlexEvent.CREATION_COMPLETE event listener")
						clientStatsBlock.peerStatsBlock_list.dataProvider.addItem(this);
					});
					
					
				} else {
//					trace("StatsGroupMediator.displayPeerStats() found existing PeerStatsBlock for peer_suid:"+peer_suid);					
				}					
				if (peerStatsBlock.initialized)
					peerStatsBlock.peerStatsVO = client_peerStatsVO;	
				else
					trace("StatsGroupMediator.displayPeerStats() peerStatsBlock.initialized:"+peerStatsBlock.initialized);
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
//			var peerStatsBlock_index:int = clientStatsBlock.peerStatsBlock_list.dataProvider.getItemIndex(peerStatsBlock);
//			trace("StatsGroupMediator.removePeerStatsBlock() peerStatsBlock_index="+peerStatsBlock_index);
//			clientStatsBlock.peerStatsBlock_list.dataProvider.removeItemAt(peerStatsBlock_index);
//		}	
	
		private function getServer_ClientStatsBlock(suid:String): Server_ClientStatsBlock {
			
			var statsBlock:Server_ClientStatsBlock;
			var dataProviderLength:int = statsGroup.serverStatsBlock.clientStatsBlock_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
				statsBlock = statsGroup.serverStatsBlock.clientStatsBlock_list.dataProvider.getItemAt(i) as Server_ClientStatsBlock;
				if (statsBlock != null && statsBlock.client_suid == suid) {
					return statsBlock;
				}
			}
			return null;
		}
		
		private function getPeerStatsBlock(clientStatsBlock:ClientStatsBlock, peer_suid:String): Client_PeerStatsBlock {
//			trace("StatsGroupMediator.getPeerStatsBlock() peer_suid="+peer_suid)
			
			var peerStatsBlock:Client_PeerStatsBlock;
			var dataProviderLength:int = clientStatsBlock.peerStatsBlock_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
//				trace("StatsGroupMediator.getPeerStatsBlock() i="+i+", statsGroup.statsGroup_list.dataProvider.length="+dataProviderLength);
				peerStatsBlock = clientStatsBlock.peerStatsBlock_list.dataProvider.getItemAt(i) as Client_PeerStatsBlock;
//				trace("StatsGroupMediator.getPeerStatsBlock() peerStatsBlock.peer_suid="+peerStatsBlock.peer_suid);
				if (peerStatsBlock != null && peerStatsBlock.peer_suid == peer_suid) {
					return peerStatsBlock;
				}
			}
			return null;
		}
		
		private function getClientStatsBlock(suid:String): ClientStatsBlock {
//			trace("StatsGroupMediator.getClientStatsBlock() suid="+suid)

			var clientStatsBlock:ClientStatsBlock;
			var dataProviderLength:int = statsGroup.clientStatsBlock_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
				clientStatsBlock = statsGroup.clientStatsBlock_list.dataProvider.getItemAt(i) as ClientStatsBlock;
				if (clientStatsBlock.client_suid == suid) {
					return clientStatsBlock;
				}
			}
			return null;
		}
	}
}