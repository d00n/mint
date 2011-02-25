package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.events.PeerEvent;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.PeerService;
	
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.system.Capabilities;
	
	import org.robotlegs.mvcs.Command;
	
	public class ReportPeerStatsCommand extends Command
	{
		[Inject]
		public var dataProxy:DataProxy;
		
		[Inject]
		public var msService:MSService;
		
		[Inject]
		public var peerService:PeerService;
		
		// mediates MSEvent.GENERATE_PEER_STATS
		override public function execute():void
		{
			for(var suid:String in dataProxy.userInfoVO_array){
				trace(">>>>>>>>>>>>  ReportPeerStatsCommand.execute() suid:"+suid);		
				
				if (dataProxy.local_userInfoVO.suid.toString() == suid)
					trace(">>>>>>>>>>>>  ReportPeerStatsCommand.execute() local_userInfoVO exists in userInfoVO_array");	
				
				var peer_userInfoVO:UserInfoVO = dataProxy.userInfoVO_array[suid];
				if (peer_userInfoVO == null) {
					trace(">>>>>>>>>>>>  ReportPeerStatsCommand.execute() peer_userInfoVO is null");	
				} else if (peer_userInfoVO.netStream == null) {
					trace(">>>>>>>>>>>>  ReportPeerStatsCommand.execute() peer_userInfoVO.netStream is null");	
				} else {
			
					var peer_stats:Object = new Object();
	
					var netStream:NetStream = peer_userInfoVO.netStream; 
					var netStreamInfo:NetStreamInfo = netStream.info;
					
	//				peer_stats.application_name				= dataProxy.media_app;
					peer_stats.room_name							= dataProxy.room_name;
					peer_stats.room_id								= dataProxy.room_id;
					peer_stats.local_user_name				= dataProxy.local_userInfoVO.user_name;
					peer_stats.local_user_id					= dataProxy.local_userInfoVO.user_id;
					peer_stats.peer_user_name					= peer_userInfoVO.user_name;
					peer_stats.peer_user_id						= peer_userInfoVO.user_id;
					
					
					// netStreamInfo.videoLossRate is in the docs, but does not compile
					//peer_stats.videoLossRate 				= netStreamInfo.videoLossRate
					peer_stats.audioLossRate 					= netStreamInfo.audioLossRate;
					peer_stats.SRTT 									= netStreamInfo.SRTT;
	
					// Why do some of these need casting? They're all Numbers
					peer_stats.audioBytesPerSecond 		= int(netStreamInfo.audioBytesPerSecond);
					peer_stats.videoBytesPerSecond 		= int(netStreamInfo.videoBytesPerSecond);
					peer_stats.dataBytesPerSecond 		= int(netStreamInfo.dataBytesPerSecond);
					
					peer_stats.currentBytesPerSecond 	= int(netStreamInfo.currentBytesPerSecond);
					peer_stats.maxBytesPerSecond 			= int(netStreamInfo.maxBytesPerSecond);
					peer_stats.byteCount 							= netStreamInfo.byteCount;
					peer_stats.dataByteCount 					= netStreamInfo.dataByteCount;
					peer_stats.videoByteCount					= netStreamInfo.videoByteCount;
					
					peer_stats.audioLossRate 					= netStreamInfo.audioLossRate;
					peer_stats.droppedFrames 					= netStreamInfo.droppedFrames;
					
					msService.sendPeerStats(peer_stats);	
				}
			}
		}
	}
	}