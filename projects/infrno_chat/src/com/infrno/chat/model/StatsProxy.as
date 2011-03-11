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
		public var server_clientStatsVO_array:Array;
		public var client_serverStatsVO_array:Array;
		public var peer_array:Array;
		
		public static const NUMBER_OF_DATA_RECORDS_TO_KEEP:int = 60;
		
		public function StatsProxy() {
		}
		
		public function init():void {
			trace('StatsProxy.init()');
			peer_array = new Array();	
			client_serverStatsVO_array = new Array();
			server_clientStatsVO_array = new Array();	
		}		
	}
}