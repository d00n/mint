package com.infrno.chat.model
{
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.PeerStatsVO;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.robotlegs.mvcs.Actor;
	
	public class StatsProxy extends Actor
	{
		public var peerStatsVO_array:Array;		
		public var serverStatsVO_array:Array;
		private var _timer:Timer;
		
		public function StatsProxy() {
		}
		
		public function init():void {
			trace('StatsProxy.init()');
			peerStatsVO_array = new Array();	
			serverStatsVO_array = new Array();
			
			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, collectStats);
			_timer.start();
		}
		
		public function collectStats(event:TimerEvent):void {
			trace('StatsProxy.collectStats()');
			dispatch(new StatsEvent(StatsEvent.COLLECT_PEER_STATS));
			
			// TODO: mediate this
      //dispatch(new StatsEvent(StatsEvent.COLLECT_SERVER_STATS));
		}
		
//		public function initPeerStatsVO(suid:String):void {
//			// We could clobber old data, but having historical data could be useful
//			if (peerStatsVO_array[suid] == null) {
//				peerStatsVO_array[suid] = new PeerStatsVO();
//			}
//		}
		
		public function submitPeerStats(peer_stats:Object) : void {
			trace('StatsProxy.submitPeerStats() suid:'+peer_stats.suid+', srtt:'+peer_stats.srtt );
			
			if (peerStatsVO_array[peer_stats.suid] == null) {
				peerStatsVO_array[peer_stats.suid] = new PeerStatsVO();
			}
			
			var peerStatsVO:PeerStatsVO = peerStatsVO_array[peer_stats.suid];
			
			// Using suid as the key and a field smells. hrmmm..
			peerStatsVO.suid = peer_stats.suid;
			
			var newDataRecord:Object = new Object();
			var dummySrtt:Number = 50+ Math.round(Math.random()*50);
			newDataRecord.srtt = dummySrtt; // peer_stats.srtt
			
			peerStatsVO.data_array.addItem(newDataRecord);		
			
			var videoPresenceEvent:VideoPresenceEvent = new VideoPresenceEvent(VideoPresenceEvent.DISPLAY_PEER_STATS);
			videoPresenceEvent.peerStatsVO = peerStatsVO;
			dispatch(videoPresenceEvent);
		}
		
	}
}