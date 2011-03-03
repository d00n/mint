package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	import com.infrno.chat.view.components.Sparkline;
	import com.infrno.chat.view.components.StatsGroup;
	import com.infrno.chat.view.components.StatsBlock;
	
	import org.robotlegs.mvcs.Mediator;

	public class StatsGroupMediator extends Mediator
	{
		[Inject]
		public var statsGroup:StatsGroup;
	
		
		public function StatsGroupMediator()
		{
		}
		
		override public function onRegister():void{
			eventMap.mapListener(eventDispatcher,VideoPresenceEvent.DISPLAY_PEER_STATS,displayPeerStats);
		}
		
		// TODO Move this event into StatsEvent
		private function displayPeerStats(vpEvent:VideoPresenceEvent):void
		{
			trace("StatsContainerMediator.displayPeerStats()");
			var peerStatsVO:StatsVO = vpEvent.statsVO;
			
			var statsBlock:StatsBlock = getStatsBlockBySuid(peerStatsVO.suid);
			if (statsBlock == null) {
				statsBlock = new StatsBlock();
				statsBlock.suid = peerStatsVO.suid;
				statsBlock.peerStatsVO = peerStatsVO;
				statsGroup.statsGroup_list.dataProvider.addItem(statsBlock);
			}
			
//			var _sparkline:Sparkline;
//			for (var i:int=0; i<statsGroup.sparklines_AC.length; i++) {
//				_sparkline = statsGroup.sparklines_AC.getItemAt(i) as Sparkline;
//				_sparkline.statsVO = peerStatsVO;		
//			}		
			
			statsBlock.sparkline1.statsVO = peerStatsVO;		
			statsBlock.sparkline2.statsVO = peerStatsVO;		
			statsBlock.sparkline3.statsVO = peerStatsVO;		
		}
		
		private function getStatsBlockBySuid(suid:int): StatsBlock {
			trace("StatsGroupMediator.getStatsBySuid suid="+suid)

			var statsBlock:StatsBlock;
			var dataProviderLength:int = statsGroup.statsGroup_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
				trace("StatsGroupMediator.getStatsBlockBySuid i="+i+", statsGroup.statsGroup_list.dataProvider.length="+dataProviderLength)
				statsBlock = statsGroup.statsGroup_list.dataProvider.getItemAt(i) as StatsBlock;
				trace("StatsGroupMediator.getStatsBySuid statsBlock.suid="+statsBlock.suid)
				if (statsBlock.suid == suid) {
					return statsBlock;
				}
			}
			return null;
		}
	}
}