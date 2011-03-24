package com.infrno.chat.model.events
{
	import com.infrno.chat.model.vo.StatsVO;
	
	import flash.events.Event;

	public class StatsEvent extends Event
	{
		public static const COLLECT_CLIENT_STATS:String					= "se_collect_client_stats";
		public static const RECEIVE_CLIENT_STATS:String					= "se_receive_client_stats";
		public static const RECEIVE_SERVER_STATS:String					= "se_receive_server_stats";
		
		public static const DISPLAY_SERVER_STATS:String					= "se_display_server_stats";
		public static const DISPLAY_CLIENT_STATS:String					= "se_display_client_stats";
		
		public static const NEW_CLIENT_BLOCK:String							= "se_new_client_block";
		public static const DELETE_PEER_STATS:String						= "se_delete_peer_stats";
		

		
		// Used to receive clientStat records as constructed in CollectClientStatsCommand
		public var inbound_clientStats:Object;
		
		// Used to receive clientStat records as constructed on the server in UserManager.collectServerStats() 
		public var inbound_serverStats:Object;
		
		
		public var client_suid:String;
		public var client_serverStatsVO:StatsVO;		
		public var client_peerStatsVO_array:Array;
		public var server_clientStatsVO_array:Array;
		public var serverStatsVO:StatsVO;
		
		public function StatsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}