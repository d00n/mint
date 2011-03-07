package com.infrno.chat.model
{
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Actor;
	
	public class StatsProxy extends Actor
	{
		// needs to become an array
		public var serverStatsVO_array:Array;
		
		// needs to become a two-dimensional array
		public var peerStatsVO_array:Array;		
		

		
		private var _timer:Timer;
		private var foo:int = 0;
		public static const NUMBER_OF_DATA_RECORDS_TO_KEEP:int = 20;
		public var seconds_between_stat_collection:int = 1;
		
		public function StatsProxy() {
		}
		
		public function init():void {
			trace('StatsProxy.init()');
			peerStatsVO_array = new Array();	
			serverStatsVO_array = new Array();
			
			_timer = new Timer(seconds_between_stat_collection * 1000);
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
		
		// deprecated
		public function submitPeerStats(peerStatsRecord:Object) : void {
			trace('StatsProxy.submitPeerStats() remote_suid:'+peerStatsRecord.remote_suid+', srtt:'+peerStatsRecord.srtt );
			
			if (peerStatsVO_array[peerStatsRecord.remote_suid] == null) {
				peerStatsVO_array[peerStatsRecord.remote_suid] = new StatsVO();
			}
			
			var peerStatsVO:StatsVO = peerStatsVO_array[peerStatsRecord.remote_suid];
			
			// Using suid as the key and a field smells. hrmmm..
			peerStatsVO.suid = peerStatsRecord.remote_suid;
			
//			foo++;
//			var dummySrtt:Number = 50+ Math.round(Math.random()*50);
//			if (foo > 10) {
//				foo = 0;
//				dummySrtt= 150;
//			}
//			peerStatsRecord.srtt = dummySrtt; 
	
			peerStatsVO.data_AC.addItem(peerStatsRecord);		
			
			if (peerStatsVO.data_AC.length > NUMBER_OF_DATA_RECORDS_TO_KEEP) {
				peerStatsVO.data_AC.removeItemAt(0);
			}
			
			var statsEvent:StatsEvent = new StatsEvent(StatsEvent.DISPLAY_PEER_STATS);
			statsEvent.statsRecord = peerStatsRecord;
			dispatch(statsEvent);
		}
		


		
	}
}