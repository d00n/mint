package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.view.components.Sparkline;
	import com.infrno.chat.view.components.StatsBlock;
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

			// TODO map this after the relevant statBlock is ready
//			eventMap.mapListener(eventDispatcher,VideoPresenceEvent.DISPLAY_PEER_STATS,displayPeerStats);
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
					var statsBlock:StatsBlock = statsGroup.statsGroup_list.dataProvider.getItemAt(i) as StatsBlock;
					trace("StatsGroupMediator.removeDisconnectedStatBlocks() statsBlock.suid="+statsBlock.suid);
					
					//if the video isn't in the users collection remove it
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
				
				var statsBlock:StatsBlock = getStatsBlockBySuid(suid);
				if (statsBlock == null) {
					trace("StatsGroupMediator.addNewStatBlocks() adding new StatsBlock for suid:"+suid);
					statsBlock = new StatsBlock();
					statsBlock.suid = suid;
					statsBlock.user_name_label = userInfoVO.user_name;
					statsGroup.statsGroup_list.dataProvider.addItem(statsBlock);					
					
					statsBlock.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
					{
						trace("StatsGroupMediator.addNewStatBlocks() StatsBlock FlexEvent.CREATION_COMPLETE event listener");						
						eventMap.mapListener(eventDispatcher,VideoPresenceEvent.DISPLAY_PEER_STATS,displayPeerStats);
					});
					
				} else {
					trace("StatsGroupMediator.addNewStatBlocks() found existing StatsBlock for suid:"+suid);					
				}				
			}
		}
		

		// TODO Move this event into StatsEvent
		private function displayPeerStats(vpEvent:VideoPresenceEvent):void
		{
			trace("StatsContainerMediator.displayPeerStats()");
			var peerStatsVO:StatsVO = vpEvent.statsVO;
			
			var statsBlock:StatsBlock = getStatsBlockBySuid(peerStatsVO.suid);
			if (statsBlock == null) {
				trace("StatsContainerMediator.displayPeerStats() null statsBlock !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
				return;
			}
							
			statsBlock.sparkline1.statsVO = peerStatsVO;		
			statsBlock.sparkline2.statsVO = peerStatsVO;		
			statsBlock.sparkline3.statsVO = peerStatsVO;		
		}
		
		private function getStatsBlockBySuid(suid:String): StatsBlock {
			trace("StatsGroupMediator.getStatsBySuid() suid="+suid)

			var statsBlock:StatsBlock;
			var dataProviderLength:int = statsGroup.statsGroup_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
				trace("StatsGroupMediator.getStatsBySuid() i="+i+", statsGroup.statsGroup_list.dataProvider.length="+dataProviderLength)
				statsBlock = statsGroup.statsGroup_list.dataProvider.getItemAt(i) as StatsBlock;
				trace("StatsGroupMediator.getStatsBySuid() statsBlock.suid="+statsBlock.suid)
				if (statsBlock.suid == suid) {
					return statsBlock;
				}
			}
			return null;
		}
	}
}