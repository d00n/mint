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
//			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_CLIENT_STATS,displayClientStats);
//			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_CLIENT_STATS,displayPeerStats);
//			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_SERVER_STATS,displayServerStats);

			// handle deletions
//			eventMap.mapListener(eventDispatcher,StatsEvent.DELETE_PEER_STATS,removeBlocksForSuid);	
			
			// ..then additions
//			eventMap.mapListener(eventDispatcher,StatsEvent.NEW_CLIENT_BLOCK,addClientStatBlock);	

		}

		
		public function mapListeners():void{
			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_CLIENT_STATS,displayClientStats);
			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_CLIENT_STATS,displayPeerStats);
			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_SERVER_STATS,displayServerStats);
			eventMap.mapListener(eventDispatcher,StatsEvent.DELETE_PEER_STATS,removeBlocksForSuid);	
			eventMap.mapListener(eventDispatcher,StatsEvent.NEW_CLIENT_BLOCK,addClientStatBlock);		
			statsGroup.visible = true;
		}
		
		public function unmapListeners():void{
			eventMap.unmapListener(eventDispatcher,StatsEvent.DISPLAY_CLIENT_STATS,displayClientStats);
			eventMap.unmapListener(eventDispatcher,StatsEvent.DISPLAY_CLIENT_STATS,displayPeerStats);
			eventMap.unmapListener(eventDispatcher,StatsEvent.DISPLAY_SERVER_STATS,displayServerStats);
			eventMap.unmapListener(eventDispatcher,StatsEvent.DELETE_PEER_STATS,removeBlocksForSuid);	
			eventMap.unmapListener(eventDispatcher,StatsEvent.NEW_CLIENT_BLOCK,addClientStatBlock);				
			statsGroup.visible = false;
		}
		
		private function removeBlocksForSuid(statsEvent:StatsEvent):void {	
			removeServer_ClientStatBlock(statsEvent.client_suid);			
			removeClientStatBlock(statsEvent.client_suid);			
			removeClient_PeerStatBlocks(statsEvent.client_suid);		
		}
		
		private function removeServer_ClientStatBlock(suid:String):void {
			if (!statsGroup.serverStatsBlock.initialized)
				return;
			
			var server_ClientStatsBlock:Server_ClientStatsBlock;
			var server_clientStatsBlock_list_dataProviderLength:int = statsGroup.serverStatsBlock.clientStatsBlock_list.dataProvider.length;
			for(var i:int = 0; i<server_clientStatsBlock_list_dataProviderLength; i++){
				try{					
					server_ClientStatsBlock = statsGroup.serverStatsBlock.clientStatsBlock_list.dataProvider.getItemAt(i) as Server_ClientStatsBlock;
					
					if(server_ClientStatsBlock.client_suid == suid){
						var server_ClientStatsBlock_index:int = statsGroup.serverStatsBlock.clientStatsBlock_list.dataProvider.getItemIndex(server_ClientStatsBlock);
						statsGroup.serverStatsBlock.clientStatsBlock_list.dataProvider.removeItemAt(server_ClientStatsBlock_index);
						return;
					}						
				}catch(e:Object){
					trace("StatsGroupMediator.removeServer_ClientStatBlock() error:" +e.toString());
				}
			}
		}		
		
		private function removeClientStatBlock(suid:String):void {
			var clientStatsBlock:ClientStatsBlock = getClientStatsBlock(suid);
			if(clientStatsBlock != null){
				var statsGroup_index:int = statsGroup.clientStatsBlock_list.dataProvider.getItemIndex(clientStatsBlock);
				trace("StatsGroupMediator.removeStaleClientStatBlock() clientStatsBlock.client_suid="+clientStatsBlock.client_suid);
				try{					
					statsGroup.clientStatsBlock_list.dataProvider.removeItemAt(statsGroup_index);
				}catch(e:Object){
					//out of range error I'm sure
					// TODO Make sure we don't get out of range errors
					// Things work just fine, but how does this state occur?
					trace("StatsGroupMediator.removeStaleClientStatBlock() error:" +e.toString());
				}
			}
		}		
		
		private function removeClient_PeerStatBlocks(suid:String):void {
			var statsGroup_list_dataProviderLength:int = statsGroup.clientStatsBlock_list.dataProvider.length;
			for(var i:int = 0; i<statsGroup_list_dataProviderLength; i++){
				try{					
					var clientStatsBlock:ClientStatsBlock = statsGroup.clientStatsBlock_list.dataProvider.getItemAt(i) as ClientStatsBlock;
					
					var peerBlock_list_dataProviderLength:int = clientStatsBlock.peerStatsBlock_list.dataProvider.length;
					for(var j:int = 0; j<peerBlock_list_dataProviderLength; j++){
						var peerStatsBlock:Client_PeerStatsBlock = clientStatsBlock.peerStatsBlock_list.dataProvider.getItemAt(j) as Client_PeerStatsBlock;
						
						if(peerStatsBlock.peer_suid == suid){
							var peerStatsBlock_index:int = clientStatsBlock.peerStatsBlock_list.dataProvider.getItemIndex(peerStatsBlock);
							trace("StatsGroupMediator.removeStalePeerStatBlocks() removing peerStatsBlock.peer_suid="+peerStatsBlock.peer_suid);
							clientStatsBlock.peerStatsBlock_list.dataProvider.removeItemAt(peerStatsBlock_index);
							return;
						}						
					}
				}catch(e:Object){
					trace("StatsGroupMediator.removeClient_PeerStatBlocks() error:" +e.toString());
				}
			}
		}	
		
//		private function removeStaleClientStatBlocks(userInfoVO_array:Array):void {
////			trace("StatsGroupMediator.removeStaleClientStatBlocks()");
//			var dataProviderLength:int = statsGroup.clientStatsBlock_list.dataProvider.length;
//			for(var i:int = 0; i<dataProviderLength; i++){
////				trace("StatsGroupMediator.removeClientStatBlocks() i="+i);
//				try{					
//					var clientStatsBlock:ClientStatsBlock = statsGroup.clientStatsBlock_list.dataProvider.getItemAt(i) as ClientStatsBlock;
////					trace("StatsGroupMediator.removeStaleClientStatBlocks() statsBlock.client_suid="+statsBlock.client_suid);
//					
//					if(userInfoVO_array[clientStatsBlock.client_suid] == null){
//						var statsGroup_index:int = statsGroup.clientStatsBlock_list.dataProvider.getItemIndex(clientStatsBlock);
//						trace("StatsGroupMediator.removeStaleClientStatBlocks() clientStatsBlock.client_suid="+clientStatsBlock.client_suid);
//						statsGroup.clientStatsBlock_list.dataProvider.removeItemAt(statsGroup_index);
//					}
//				}catch(e:Object){
//					//out of range error I'm sure
//					// TODO Make sure we don't get out of range errors
//					// Things work just fine, but how does this state occur?
//					trace("StatsGroupMediator.removeStaleClientStatBlocks() error:" +e.toString());
//				}
//			}
//		}
//		
		private function removeStaleClient_PeerStatBlocks(clientStatsBlock:ClientStatsBlock, userInfoVO_array:Array):void {

			for(var i:int = 0; i<clientStatsBlock.peerStatsBlock_list.dataProvider.length; i++){
				try{					
					var client_PeerStatsBlock:Client_PeerStatsBlock = clientStatsBlock.peerStatsBlock_list.dataProvider.getItemAt(i) as Client_PeerStatsBlock;
											
					if(userInfoVO_array[client_PeerStatsBlock.peer_suid] == null){
						var peerStatsBlock_index:int = clientStatsBlock.peerStatsBlock_list.dataProvider.getItemIndex(client_PeerStatsBlock.peer_suid);
						trace("StatsGroupMediator.removeStalePeerStatBlocks() removing client_PeerStatsBlock.peer_suid="+client_PeerStatsBlock.peer_suid);
						clientStatsBlock.peerStatsBlock_list.dataProvider.removeItemAt(peerStatsBlock_index);
					}						
				}catch(e:Object){
					trace("StatsGroupMediator.removeStalePeerStatBlocks() error:" +e.toString());
				}
			}
		}			
//		
//		private function removeStaleServer_ClientStatBlocks(userInfoVO_array:Array):void {
//			if (!statsGroup.serverStatsBlock.initialized)
//				return;
//			
//			var server_ClientStatsBlock:Server_ClientStatsBlock;
//			var server_clientStatsBlock_list_dataProviderLength:int = statsGroup.serverStatsBlock.clientStatsBlock_list.dataProvider.length;
//			for(var i:int = 0; i<server_clientStatsBlock_list_dataProviderLength; i++){
//				try{					
//					server_ClientStatsBlock = statsGroup.serverStatsBlock.clientStatsBlock_list.dataProvider.getItemAt(i) as Server_ClientStatsBlock;
//						
//					if(userInfoVO_array[server_ClientStatsBlock.client_suid] == null){
//						var server_ClientStatsBlock_index:int = statsGroup.serverStatsBlock.clientStatsBlock_list.dataProvider.getItemIndex(server_ClientStatsBlock);
//						statsGroup.serverStatsBlock.clientStatsBlock_list.dataProvider.removeItemAt(server_ClientStatsBlock_index);
//					}						
//				}catch(e:Object){
//					trace("StatsGroupMediator.removeStaleServer_ClientStatBlocks() error:" +e.toString());
//				}
//			}
//		}				
		
		private function addClientStatBlock(statsEvent:StatsEvent):void{
			
			var clientStatsBlock:ClientStatsBlock = getClientStatsBlock(statsEvent.client_suid);
			if (clientStatsBlock == null) {
				trace("StatsGroupMediator.addClientStatBlock() adding new ClientStatsBlock for suid:"+statsEvent.client_suid);
				clientStatsBlock = new ClientStatsBlock();
				clientStatsBlock.client_suid = statsEvent.client_suid;
				clientStatsBlock.user_name_label = "Client: xx" // + userInfoVO.user_name;
				statsGroup.clientStatsBlock_list.dataProvider.addItem(clientStatsBlock);
				
				clientStatsBlock.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
				{
					trace("StatsGroupMediator.addClientStatBlock() ClientStatsBlock FlexEvent.CREATION_COMPLETE event listener")
				});
				
			} else {
				trace("StatsGroupMediator.addClientStatBlock() found existing ClientStatsBlock for suid:"+statsEvent.client_suid);					
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
		
		private function displayServerStats(event:StatsEvent):void	{			
			if (!statsGroup.serverStatsBlock.initialized)
				return;
			
			statsGroup.serverStatsBlock.statsVO = event.serverStatsVO;
			
			
			var server_clientStatsBlock:Server_ClientStatsBlock;
			var server_clientStatsVO:StatsVO;
			var server_clientStatsVO_array:Array = event.server_clientStatsVO_array;
			
			for (var  client_suid:String in server_clientStatsVO_array) {
				server_clientStatsVO = server_clientStatsVO_array[client_suid] as StatsVO;
				
				server_clientStatsBlock = getServer_ClientStatsBlock(client_suid);
				
				if (server_clientStatsBlock == null) {
					server_clientStatsBlock = new Server_ClientStatsBlock();
					server_clientStatsBlock.client_suid = client_suid;
					statsGroup.serverStatsBlock.clientStatsBlock_list.dataProvider.addItem(server_clientStatsBlock);
				}
				
				server_clientStatsBlock.statsVO = server_clientStatsVO;
			}
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
			clientStatsBlock.user_name_label				= statsEvent.inbound_clientStats.client_user_name;
			clientStatsBlock.clientStats						= statsEvent.inbound_clientStats;		
		}		
		
		private function displayPeerStats(statsEvent:StatsEvent):void	{
//			trace("StatsGroupMediator.displayPeerStats()");
			
			var clientStats:Object = statsEvent.inbound_clientStats;
			
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
				
				peerStatsBlock = getClient_PeerStatsBlock(clientStatsBlock, peer_suid);
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
		
		private function getClient_PeerStatsBlock(clientStatsBlock:ClientStatsBlock, peer_suid:String): Client_PeerStatsBlock {
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