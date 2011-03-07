package com.infrno.chat.model.events
{
	import com.infrno.chat.model.vo.StatsVO;
	
	import flash.events.Event;
	
	public class StatsEvent extends Event
	{
		public static const COLLECT_SERVER_STATS:String					= "se_collect_server_stats";
		public static const COLLECT_PEER_STATS:String						= "se_collect_peer_stats";
		public static const RECEIVE_SERVER_STATS:String					= "se_receive_server_stats";
		public static const RECEIVE_PEER_STATS:String						= "se_receive_peer_stats";
		public static const DISPLAY_SERVER_STATS:String					= "se_display_server_stats";
		public static const DISPLAY_PEER_STATS:String						= "se_display_peer_stats";
		
		public var statsRecord:Object;
		public var statsVO:StatsVO;
		
		public function StatsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}