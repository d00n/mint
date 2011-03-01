package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	import com.infrno.chat.view.components.Sparkline;
	import com.infrno.chat.view.components.StatsContainer;
	import com.infrno.chat.view.components.StatsGroup;
	
	import org.robotlegs.mvcs.Mediator;

	public class StatsContainerMediator extends Mediator
	{
		[Inject]
		public var statsContainer:StatsContainer;
	
		
		public function StatsContainerMediator()
		{
		}
		
		override public function onRegister():void{
			eventMap.mapListener(eventDispatcher,VideoPresenceEvent.DISPLAY_PEER_STATS,displayPeerStats);
		}
		
		// Move this event into StatsEvent
		private function displayPeerStats(vpEvent:VideoPresenceEvent):void
		{
			trace("StatsContainerMediator.displayPeerStats()");
			var peerStatsVO:StatsVO = vpEvent.statsVO;
			
			var statsGroup:StatsGroup = getStatsGroupBySuid(peerStatsVO.suid);
			if (statsGroup == null) {
				statsGroup = statsContainer.addStatsGroup(peerStatsVO);		
				statsGroup.createSparklines();
			}
			
			var _sparkline:Sparkline;
			for (var i:int=0; i<statsGroup.sparklines_AC.length; i++) {
				_sparkline = statsGroup.sparklines_AC.getItemAt(i) as Sparkline;
				_sparkline.statsVO = peerStatsVO;		
			}			
		}
		
		private function getStatsGroupBySuid(suid:int): StatsGroup {
			trace("StatsContainerMediator.getStatsBySuid suid="+suid)

			var statsGroup:StatsGroup;
			var dataProviderLength:int = statsContainer.statsGroups_holder.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
				trace("StatsContainerMediator.getStatsBySuid i="+i+", stats.holder.dataProvider.length="+dataProviderLength)
				statsGroup = statsContainer.statsGroups_holder.dataProvider.getItemAt(i) as StatsGroup;
				trace("StatsContainerMediator.getStatsBySuid statsGroup.suid="+statsGroup.suid)
				if (statsGroup.suid == suid) {
					return statsGroup;
				}
			}
			return null;
		}
	}
}