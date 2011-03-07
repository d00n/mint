package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.StatsEvent;
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
		
//		private var peerStatBlockConfig_AC:ArrayCollection = new ArrayCollection();
//		private var serverStatBlockConfig_AC:ArrayCollection = new ArrayCollection();

		public function StatsGroupMediator()
		{
		}
		
		override public function onRegister():void{
			eventMap.mapListener(eventDispatcher,MSEvent.USERS_OBJ_UPDATE,usersUpdated);
			
			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_SERVER_STATS,displayServerStats);
//			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_PEER_STATS,displayPeerStats);

			
//			peerStatBlockConfig_AC.addItem( {yFieldName:"srtt", labelPrefix:"SRTT", toolTip:"Specifies the Smooth Round Trip Time for the NetStream session. This value returns a valid value only for RTMFP streams and returns 0 for RTMP streams."} );
//			peerStatBlockConfig_AC.addItem( {yFieldName:"currentBytesPerSecond", labelPrefix:"Total", toolTip:"Specifies the rate at which the NetStream buffer is filled in bytes per second. The value is calculated as a smooth average for the total data received in the last second."} );
//			peerStatBlockConfig_AC.addItem( {yFieldName:"audioBytesPerSecond", labelPrefix:"Audio", toolTip:"Specifies the rate at which the NetStream audio buffer is filled in bytes per second. The value is calculated as a smooth average for the audio data received in the last second."} );
//			peerStatBlockConfig_AC.addItem( {yFieldName:"videoBytesPerSecond", labelPrefix:"Video", toolTip:"Specifies the rate at which the NetStream video buffer is filled in bytes per second. The value is calculated as a smooth average for the video data received in the last second."} );
//			peerStatBlockConfig_AC.addItem( {yFieldName:"dataBytesPerSecond", labelPrefix:"Data", toolTip:"Specifies the rate at which the NetStream data buffer is filled in bytes per second. The value is calculated as a smooth average for the data messages received in the last second."} );
//			peerStatBlockConfig_AC.addItem( {yFieldName:"audioLossRate", labelPrefix:"Audio loss rate", toolTip:"Specifies the audio loss for the NetStream session. This value returns a valid value only for RTMFP streams and would return 0 for RTMP streams. Loss rate is defined as the ratio of lost messages to total messages."} );
//			// Hack hack hack - The last item added doesn't get it's label displayed. So just tack an empty one on.
//			peerStatBlockConfig_AC.addItem( {yFieldName:"", labelPrefix:""} );
//			
//			serverStatBlockConfig_AC.addItem( {yFieldName:"currentBytesPerSecond", labelPrefix:"Current", toolTip:"Specifies the rate at which the NetStream buffer is filled in bytes per second. The value is calculated as a smooth average for the total data received in the last second."} );
//			serverStatBlockConfig_AC.addItem( {yFieldName:"maxBytesPerSecond", labelPrefix:"Max", toolTip:"Specifies the maximum rate at which the NetStream buffer is filled in bytes per second. This value provides information about the capacity of the client network based on the last messages received by the NetStream object. Depending on the size of the buffer specified in NetStream.bufferTime and the bandwidth available on the client, Flash Media Server fills the buffer in bursts. This property provides the maximum rate at which the client buffer is filled."} );
//			serverStatBlockConfig_AC.addItem( {yFieldName:"audioBytesPerSecond", labelPrefix:"Audio", toolTip:"Specifies the rate at which the NetStream audio buffer is filled in bytes per second. The value is calculated as a smooth average for the audio data received in the last second."} );
//			serverStatBlockConfig_AC.addItem( {yFieldName:"videoBytesPerSecond", labelPrefix:"Video", toolTip:"Specifies the rate at which the NetStream buffer is filled in bytes per second. The value is calculated as a smooth average for the total data received in the last second."} );
//			serverStatBlockConfig_AC.addItem( {yFieldName:"dataBytesPerSecond", labelPrefix:"Data", toolTip:"Specifies the maximum rate at which the NetStream buffer is filled in bytes per second. This value provides information about the capacity of the client network based on the last messages received by the NetStream object. Depending on the size of the buffer specified in NetStream.bufferTime and the bandwidth available on the client, Flash Media Server fills the buffer in bursts. This property provides the maximum rate at which the client buffer is filled."} );
//			serverStatBlockConfig_AC.addItem( {yFieldName:"audioLossRate", labelPrefix:"Audio loss rate", toolTip:"Specifies the audio loss for the NetStream session. This value returns a valid value only for RTMFP streams and would return 0 for RTMP streams. Loss rate is defined as the ratio of lost messages to total messages."} );			
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
//						statsBlock.removeEventListener(VideoPresenceEvent.DISPLAY_PEER_STATS,displayPeerStats);
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
//					statsBlock.config_AC = peerStatBlockConfig_AC;
					statsBlock.suid = suid;
					statsBlock.user_name_label = "User: " + userInfoVO.user_name;
					statsGroup.statsGroup_list.dataProvider.addItem(statsBlock);					
					
//					statsBlock.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
//					{
//						trace("StatsGroupMediator.addNewStatBlocks() StatsBlock FlexEvent.CREATION_COMPLETE event listener");						
//						eventMap.mapListener(eventDispatcher,VideoPresenceEvent.DISPLAY_PEER_STATS,displayPeerStats);
//					});
					
				} else {
					trace("StatsGroupMediator.addNewStatBlocks() found existing StatsBlock for suid:"+suid);					
				}				
			}
		}
		

		private function displayServerStats(statsEvent:StatsEvent):void
		{
			trace("StatsGroupMediator.displayServerStats()");
			var serverStatsVO:StatsVO = statsEvent.statsVO;
			
			var statsBlock:StatsBlock = getStatsBlockBySuid(serverStatsVO.suid);
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
			var peerStatsVO:StatsVO = statsEvent.statsVO;
			
			var statsBlock:StatsBlock = getStatsBlockBySuid(peerStatsVO.suid);
			if (statsBlock == null) {
				trace("StatsGroupMediator.displayPeerStats() null statsBlock !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
				return;
			}		
							
			statsBlock.droppedFrames_label = "Dropped frames: " + peerStatsVO.lastDataRecord.droppedFrames;
			statsBlock.peerStatsVO = peerStatsVO;		
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