package com.infrno.chat.model
{
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.robotlegs.mvcs.Actor;
	
	public class StatsProxy extends Actor
	{
		public var peerStatsVO_array:Array;		
		public var serverStatsVO:StatsVO;
		
		private var _timer:Timer;
		private const SECONDS_BETWEEN_STAT_COLLECTION:int = 1;
		private var foo:int = 0;
		public static const NUMBER_OF_DATA_RECORDS_TO_KEEP:int = 20;
		
		public function StatsProxy() {
		}
		
		public function init():void {
			trace('StatsProxy.init()');
			peerStatsVO_array = new Array();	
			serverStatsVO = new StatsVO();
			
			_timer = new Timer(SECONDS_BETWEEN_STAT_COLLECTION * 1000);
			_timer.addEventListener(TimerEvent.TIMER, collectStats);
			_timer.start();
		}
		
		public function collectStats(event:TimerEvent):void {
			trace('StatsProxy.collectStats()');
			dispatch(new StatsEvent(StatsEvent.COLLECT_PEER_STATS));
      dispatch(new StatsEvent(StatsEvent.COLLECT_SERVER_STATS));
		}
		
//		public function initPeerStatsVO(suid:String):void {
//			// We could clobber old data, but having historical data could be useful
//			if (peerStatsVO_array[suid] == null) {
//				peerStatsVO_array[suid] = new PeerStatsVO();
//			}
//		}
		
		public function submitPeerStats(peerStatsRecord:Object) : void {
			trace('StatsProxy.submitPeerStats() suid:'+peerStatsRecord.suid+', srtt:'+peerStatsRecord.srtt );
			
			if (peerStatsVO_array[peerStatsRecord.suid] == null) {
				peerStatsVO_array[peerStatsRecord.suid] = new StatsVO();
			}
			
			var peerStatsVO:StatsVO = peerStatsVO_array[peerStatsRecord.suid];
			
			// Using suid as the key and a field smells. hrmmm..
			peerStatsVO.suid = peerStatsRecord.suid;
			
//			foo++;
//			var dummySrtt:Number = 50+ Math.round(Math.random()*50);
//			if (foo > 10) {
//				foo = 0;
//				dummySrtt= 150;
//			}
//			peerStatsRecord.srtt = dummySrtt; 
	
			peerStatsVO.data_array.addItem(peerStatsRecord);		
			
			if (peerStatsVO.data_array.length > NUMBER_OF_DATA_RECORDS_TO_KEEP) {
				peerStatsVO.data_array.removeItemAt(0);
			}
			
			var videoPresenceEvent:VideoPresenceEvent = new VideoPresenceEvent(VideoPresenceEvent.DISPLAY_PEER_STATS);
			videoPresenceEvent.statsVO = peerStatsVO;
			dispatch(videoPresenceEvent);
		}
		
		public function submitServerStats(server_stats:Object) : void {
			trace('StatsProxy.submitServerStats() suid:'+server_stats.suid);
			
			// Setting this on init would be nice..
			serverStatsVO.suid = server_stats.suid;
			
			var newDataRecord:Object = new Object();
			
			// TODO: Iterate over everything in server_stats
			newDataRecord.currentBytesPerSecond = server_stats.currentBytesPerSecond;
			
			serverStatsVO.data_array.addItem(newDataRecord);		
			
			if (serverStatsVO.data_array.length > NUMBER_OF_DATA_RECORDS_TO_KEEP) {
				serverStatsVO.data_array.removeItemAt(0);
			}
			
			var videoPresenceEvent:VideoPresenceEvent = new VideoPresenceEvent(VideoPresenceEvent.DISPLAY_SERVER_STATS);
			videoPresenceEvent.statsVO = serverStatsVO;
			dispatch(videoPresenceEvent);
		}		

		
	}
}