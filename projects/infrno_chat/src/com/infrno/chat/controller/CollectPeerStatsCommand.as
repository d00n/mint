package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.StatsProxy;
	import com.infrno.chat.model.events.PeerEvent;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.PeerService;
	
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.system.Capabilities;
	
	import org.robotlegs.mvcs.Command;
	
	public class CollectPeerStatsCommand extends Command
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
			var peerStatsRecord_array:Array = new Array();
			
			for(var suid:String in dataProxy.userInfoVO_array){
//				trace("CollectPeerStatsCommand.execute() suid:"+suid);		
				var peer_userInfoVO:UserInfoVO = dataProxy.userInfoVO_array[suid];
				
				if (dataProxy.local_userInfoVO.suid.toString() == suid) {
//					trace("CollectPeerStatsCommand.execute() skipping local user");	
				} else if (peer_userInfoVO == null) {
					trace("CollectPeerStatsCommand.execute() peer_userInfoVO is null");	
				} else if (peer_userInfoVO.netStream == null) {
					trace("CollectPeerStatsCommand.execute() peer_userInfoVO.netStream is null");	
				} else {
					var peerStatsRecord:Object = new Object();
					var netStream:NetStream = peer_userInfoVO.netStream; 
					var netStreamInfo:NetStreamInfo;
					
					try {
						netStreamInfo = netStream.info;
					}catch(e:Object){
						trace("CollectPeerStatsCommand.execute() netStream.info error:"+e.toString());
						return;
					}
					
	//				peer_stats.application_name				= dataProxy.media_app;
					
					// TODO Move header data elsewhere
					peerStatsRecord.room_name								= dataProxy.room_name;
					peerStatsRecord.room_id									= dataProxy.room_id;

					peerStatsRecord.local_suid							= dataProxy.local_userInfoVO.suid;
					peerStatsRecord.local_user_id						= dataProxy.local_userInfoVO.user_id;
					peerStatsRecord.local_user_name					= dataProxy.local_userInfoVO.user_name;
					
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
					
					
//					statsProxy.submitPeerStats(peer_stats);
					
					peerStatsRecord_array[peerStatsRecord.remote_suid] = peerStatsRecord;
				}
				
				if (peerStatsRecord_array.length > 0) {
					var peerStats:Object 							= new Object();
					peerStats.client_suid							= dataProxy.local_userInfoVO.suid;
					peerStats.peerStatsRecord_array 	= peerStatsRecord_array;
					msService.sendPeerStats(peerStats);	
				}
			}
		}
	}
}