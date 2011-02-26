package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.StatsProxy;
	import com.infrno.chat.model.events.PeerEvent;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.PeerService;
	
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.system.Capabilities;
	
	import org.robotlegs.mvcs.Command;
	
	public class CollectServerStatsCommand extends Command
	{
		[Inject]
		public var dataProxy:DataProxy;
		
		[Inject]
		public var statsProxy:StatsProxy;
		
		[Inject]
		public var msService:MSService;
		
		[Inject]
		public var peerService:PeerService;
		
		override public function execute():void
		{			
			if (msService == null) {
				trace("CollectServerStatsCommand.execute() msService is null");	
			} else if (msService.netStream == null) {
				trace("CollectServerStatsCommand.execute() msService.netStream is null");	
			} else {
				var server_stats:Object = new Object();
				var curr_ns:NetStream = msService.netStream;				
				var ns_info:NetStreamInfo = curr_ns.info;

				server_stats.application_name				= dataProxy.media_app;
				server_stats.room_name							= dataProxy.room_name;
				server_stats.room_id								= dataProxy.room_id;
				server_stats.user_name							= dataProxy.local_userInfoVO.user_name;
				server_stats.user_id								= dataProxy.local_userInfoVO.user_id;
				
				server_stats.wowza_protocol					= msService.netConnection.protocol;
				server_stats.capabilities						= Capabilities.serverString;
				
				//			try{
				//				user_stats.videoLossRate 		= ns_info.videoLossRate;
				//			} catch (e:Object){
				//				//no value for this
				//				user_stats.videoLossRate		= 0;
				//			}
				
				server_stats.audioBytesPerSecond 		= int(ns_info.audioBytesPerSecond);
				server_stats.videoBytesPerSecond 		= int(ns_info.videoBytesPerSecond);
				server_stats.dataBytesPerSecond 		= int(ns_info.dataBytesPerSecond);
				
				server_stats.currentBytesPerSecond 	= int(ns_info.currentBytesPerSecond);
				server_stats.maxBytesPerSecond 			= int(ns_info.maxBytesPerSecond);
				server_stats.byteCount 							= ns_info.byteCount;
				server_stats.dataByteCount 					= ns_info.dataByteCount;
				server_stats.videoByteCount					= ns_info.videoByteCount;
				
				server_stats.audioLossRate 					= ns_info.audioLossRate;
				server_stats.droppedFrames 					= ns_info.droppedFrames;
				
				statsProxy.submitServerStats(server_stats);
				msService.reportUserStats(server_stats);
			}
			
		}
	}
}