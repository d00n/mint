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
		
		override public function execute():void
		{			
			trace("CollectServerStatsCommand.execute() dataProxy.local_userInfoVO.suid:"+dataProxy.local_userInfoVO.suid);		

			if (msService == null) {
				trace("CollectServerStatsCommand.execute() msService is null");	
			} else if (msService.netStream == null) {
				trace("CollectServerStatsCommand.execute() msService.netStream is null");	
			} else {
				var server_stats:Object = new Object();
				var netStream:NetStream = msService.netStream;				
				var netStreamInfo:NetStreamInfo;
				
				try {
					netStreamInfo = netStream.info;
				}catch(e:Object){
					trace("CollectServerStatsCommand.execute() netStream.info error:"+e.toString());
					return;
				}
				
				// TODO Move header data elsewhere
				server_stats.application_name				= dataProxy.media_app;
				server_stats.room_name							= dataProxy.room_name;
				server_stats.room_id								= dataProxy.room_id;

				server_stats.suid										= dataProxy.local_userInfoVO.suid;
				server_stats.user_id								= dataProxy.local_userInfoVO.user_id;
				server_stats.user_name							= dataProxy.local_userInfoVO.user_name;
				
				server_stats.wowza_protocol					= msService.netConnection.protocol;
				server_stats.capabilities						= Capabilities.serverString;
				
				// netStreamInfo.videoLossRate is in the docs, but does not compile
				//server_stats.videoLossRate 				= netStreamInfo.videoLossRate
				server_stats.audioLossRate 					= netStreamInfo.audioLossRate;
				server_stats.droppedFrames 					= netStreamInfo.droppedFrames;
				
				server_stats.currentBytesPerSecond 	= int(netStreamInfo.currentBytesPerSecond);
				server_stats.audioBytesPerSecond 		= int(netStreamInfo.audioBytesPerSecond);
				server_stats.videoBytesPerSecond 		= int(netStreamInfo.videoBytesPerSecond);
				server_stats.dataBytesPerSecond 		= int(netStreamInfo.dataBytesPerSecond);				
				server_stats.maxBytesPerSecond 			= int(netStreamInfo.maxBytesPerSecond);
				
				// Don't care about these
//				server_stats.byteCount 							= netStreamInfo.byteCount;
//				server_stats.dataByteCount 					= netStreamInfo.dataByteCount;
//				server_stats.videoByteCount					= netStreamInfo.videoByteCount;
				
				
//				statsProxy.displayServerStats(server_stats);
				msService.sendServerStats(server_stats);
			}
			
		}
	}
}