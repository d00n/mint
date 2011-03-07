package com.infrno.chat.controller
{
	import com.infrno.chat.model.StatsProxy;
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	
	import org.robotlegs.mvcs.Command;
	
	public class ReceiveServerStatsCommand extends Command
	{
		[Inject]
		public var event:StatsEvent;
		
		[Inject]
		public var statsProxy:StatsProxy;
		
		override public function execute():void{
			trace('ReceiveServerStatsCommand.execute()');
			
			var serverStatsVO:StatsVO = event.statsRecord as StatsVO;
			
			// Setting this on init would be nice..
			statsProxy.serverStatsVO.suid = event.statsRecord.suid;
			
			statsProxy.serverStatsVO.data_AC.addItem(event.statsRecord);		
			
			if (statsProxy.serverStatsVO.data_AC.length > StatsProxy.NUMBER_OF_DATA_RECORDS_TO_KEEP) {
				statsProxy.serverStatsVO.data_AC.removeItemAt(0);
			}
			
			var videoPresenceEvent:VideoPresenceEvent = new VideoPresenceEvent(VideoPresenceEvent.DISPLAY_SERVER_STATS);
			videoPresenceEvent.statsVO = serverStatsVO;
			dispatch(videoPresenceEvent);
		}	
	}
}