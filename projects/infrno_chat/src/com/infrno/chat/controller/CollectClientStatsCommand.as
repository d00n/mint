package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.StatsProxy;
	import com.infrno.chat.model.events.PeerEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.PeerService;
	
	import flash.display.Sprite;
	import flash.media.Microphone;
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.system.Capabilities;
	import flash.system.System;
	
	import mx.controls.Alert;
	
	import org.robotlegs.mvcs.Command;
	
	public class CollectClientStatsCommand extends Command
	{
		[Inject]
		public var dataProxy:DataProxy;
		
		[Inject]
		public var deviceProxy:DeviceProxy;
		
		[Inject]
		public var statsProxy:StatsProxy;
		
		[Inject]
		public var msService:MSService;
		
		[Inject]
		public var peerService:PeerService;
		
		override public function execute():void
		{
			var peerStatsRecord_array:Array = new Array();
			
			var peer_count:int = 0;
			
			for(var suid:String in dataProxy.userInfoVO_array){
//				trace("CollectClientStatsCommand.execute() suid:"+suid);		
				var peer_userInfoVO:UserInfoVO = dataProxy.userInfoVO_array[suid];
				
				if (dataProxy.local_userInfoVO.suid.toString() == suid) {
//					trace("CollectClientStatsCommand.execute() skipping local user");	
				} else if (peer_userInfoVO == null) {
					trace("CollectClientStatsCommand.execute() peer_userInfoVO is null");	
				} else if (peer_userInfoVO.netStream == null) {
					trace("CollectClientStatsCommand.execute() peer_userInfoVO.netStream is null");	
				} else if (msService.netConnection == null) {
					trace("CollectClientStatsCommand.execute() msService.netConnection is null");	
				} else {
					var peerStatsRecord:Object = new Object();
					var netStream:NetStream = peer_userInfoVO.netStream; 
					var netStreamInfo:NetStreamInfo;
					
					try {
						netStreamInfo = netStream.info;
					}catch(e:Object){
						trace("CollectClientStatsCommand.execute() netStream.info error:"+e.toString());
						return;
					}
					
//					var now:Date = new Date();
//					peerStatsRecord.time = now.getSeconds();
					
					peer_count++;
					
					// TODO strip remote_ prefix
					peerStatsRecord.remote_suid							= peer_userInfoVO.suid
					peerStatsRecord.remote_user_id					= peer_userInfoVO.user_id;
					peerStatsRecord.remote_user_name				= peer_userInfoVO.user_name;
					
					
					// netStreamInfo.videoLossRate is in the docs, but does not compile
					//peer_stats.videoLossRate 								= netStreamInfo.videoLossRate
					peerStatsRecord.audioLossRate 					= int(netStreamInfo.audioLossRate);
					peerStatsRecord.srtt 										= int(netStreamInfo.SRTT);
					peerStatsRecord.droppedFrames 					= int(netStreamInfo.droppedFrames);
	
					peerStatsRecord.currentBytesPerSecond 	= int(netStreamInfo.currentBytesPerSecond);
					peerStatsRecord.audioBytesPerSecond 		= int(netStreamInfo.audioBytesPerSecond);
					peerStatsRecord.videoBytesPerSecond 		= int(netStreamInfo.videoBytesPerSecond);					
					peerStatsRecord.dataBytesPerSecond 			= int(netStreamInfo.dataBytesPerSecond);
					peerStatsRecord.maxBytesPerSecond 			= int(netStreamInfo.maxBytesPerSecond);

					// Don't care about these
//					peer_stats.byteCount 							= netStreamInfo.byteCount;
//					peer_stats.dataByteCount 					= netStreamInfo.dataByteCount;
//					peer_stats.videoByteCount					= netStreamInfo.videoByteCount;
//					peer_stats.audioByteCount					= netStreamInfo.audioByteCount;
					
					peerStatsRecord_array[peerStatsRecord.remote_suid] = peerStatsRecord;
				}				
			}
			
			var clientStats:Object 						= new Object();
			
			clientStats.memory								= System.totalMemory;
			
			clientStats.client_suid						= dataProxy.local_userInfoVO.suid;
			clientStats.client_user_id				= dataProxy.local_userInfoVO.user_id;
			clientStats.client_user_name			= dataProxy.local_userInfoVO.user_name;
			clientStats.room_name							= dataProxy.room_name;
			clientStats.room_id								= dataProxy.room_id;
			
			clientStats.wowza_protocol				= msService.netConnection.protocol;
			clientStats.capabilities					= Capabilities.serverString;
			
			clientStats.mic_level							= deviceProxy.mic_level;
			clientStats.peer_enabled					= dataProxy.peer_enabled;
			clientStats.peer_capable					= dataProxy.peer_capable;
			clientStats.use_peer_connection		= dataProxy.use_peer_connection;
			clientStats.publishing_audio			= dataProxy.pubishing_audio;
			clientStats.publishing_video			= dataProxy.pubishing_video;
			clientStats.peer_count						= peer_count;
			
			clientStats.serverStatsRecord 		= getServerStats();
			clientStats.peerStatsRecord_array = peerStatsRecord_array;
			
			msService.sendClientStats(clientStats);	
			
//			msService.sendLogMessageToServer("System.totalMemory=" + System.totalMemory.toString());
			
//			if (deviceProxy.mic_level == -1 ) {
//				trace("CollectClientStatsCommand.execute() deviceProxy.mic_level == -1, deviceProxy.mic = " + deviceProxy.mic.toString());
////				msService.sendLogMessageToServer("deviceProxy.mic_level == -1");
//				dispatch(new VideoPresenceEvent(VideoPresenceEvent.SHOW_MIC_DISCONNECTED));				
//			}
			
		}
		
		private function getServerStats():Object {
			if (msService == null) {
				trace("CollectClientStatsCommand.getServerStats() msService is null");	
			} else if (msService.netStream == null) {
				trace("CollectClientStatsCommand.getServerStats() msService.netStream is null");	
			} else {
				var serverStats:Object = new Object();
				var netStream:NetStream = msService.netStream;				
				var netStreamInfo:NetStreamInfo;
				
				try {
					netStreamInfo = netStream.info;
				}catch(e:Object){
					trace("CollectClientStatsCommand.getServerStats() netStream.info error:"+e.toString());
					return serverStats;
				}
				
				// TODO Move header data elsewhere
				
				// netStreamInfo.videoLossRate is in the docs, but does not compile
				//server_stats.videoLossRate 				= netStreamInfo.videoLossRate
				serverStats.audioLossRate 					= netStreamInfo.audioLossRate;
				serverStats.droppedFrames 					= netStreamInfo.droppedFrames;
				
				serverStats.currentBytesPerSecond 	= int(netStreamInfo.currentBytesPerSecond);
				serverStats.audioBytesPerSecond 		= int(netStreamInfo.audioBytesPerSecond);
				serverStats.videoBytesPerSecond 		= int(netStreamInfo.videoBytesPerSecond);
				serverStats.dataBytesPerSecond 			= int(netStreamInfo.dataBytesPerSecond);				
				serverStats.maxBytesPerSecond 			= int(netStreamInfo.maxBytesPerSecond);				
			}
			return serverStats;
		}
	}
}