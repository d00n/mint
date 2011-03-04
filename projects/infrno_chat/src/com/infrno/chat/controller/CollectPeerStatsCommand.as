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
			for(var suid:String in dataProxy.userInfoVO_array){
				trace("CollectPeerStatsCommand.execute() suid:"+suid);		
				var peer_userInfoVO:UserInfoVO = dataProxy.userInfoVO_array[suid];
				
				if (dataProxy.local_userInfoVO.suid.toString() == suid) {
					trace("CollectPeerStatsCommand.execute() skipping local user");	
				} else if (peer_userInfoVO == null) {
					trace("CollectPeerStatsCommand.execute() peer_userInfoVO is null");	
				} else if (peer_userInfoVO.netStream == null) {
					trace("CollectPeerStatsCommand.execute() peer_userInfoVO.netStream is null");	
				} else {
					var peer_stats:Object = new Object();
					var netStream:NetStream = peer_userInfoVO.netStream; 
					var netStreamInfo:NetStreamInfo = netStream.info;
					
	//				peer_stats.application_name				= dataProxy.media_app;
					peer_stats.suid										= suid;
					peer_stats.room_name							= dataProxy.room_name;
					peer_stats.room_id								= dataProxy.room_id;
					peer_stats.local_user_name				= dataProxy.local_userInfoVO.user_name;
					peer_stats.local_user_id					= dataProxy.local_userInfoVO.user_id;
					peer_stats.peer_user_name					= peer_userInfoVO.user_name;
					peer_stats.peer_user_id						= peer_userInfoVO.user_id;
					
					
					// netStreamInfo.videoLossRate is in the docs, but does not compile
					//peer_stats.videoLossRate 				= netStreamInfo.videoLossRate
					peer_stats.audioLossRate 					= netStreamInfo.audioLossRate;
					peer_stats.srtt 									= netStreamInfo.SRTT;
					peer_stats.droppedFrames 					= netStreamInfo.droppedFrames;
	
					peer_stats.currentBytesPerSecond 	= netStreamInfo.currentBytesPerSecond.toFixed();
					peer_stats.audioBytesPerSecond 		= netStreamInfo.audioBytesPerSecond.toFixed();
					peer_stats.videoBytesPerSecond 		= netStreamInfo.videoBytesPerSecond.toFixed();					
					peer_stats.dataBytesPerSecond 		= netStreamInfo.dataBytesPerSecond.toFixed();
					peer_stats.maxBytesPerSecond 			= netStreamInfo.maxBytesPerSecond.toFixed();


					// Don't care about these
//					peer_stats.byteCount 							= netStreamInfo.byteCount;
//					peer_stats.dataByteCount 					= netStreamInfo.dataByteCount;
//					peer_stats.videoByteCount					= netStreamInfo.videoByteCount;
//					peer_stats.audioByteCount					= netStreamInfo.audioByteCount;
					
					
					statsProxy.submitPeerStats(peer_stats);
					msService.sendPeerStats(peer_stats);	
				}
			}
		}
	}
	}