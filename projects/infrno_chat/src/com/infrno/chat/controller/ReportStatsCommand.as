package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.events.PeerEvent;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.PeerService;
	
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.system.Capabilities;
	
	import org.robotlegs.mvcs.Command;
	
	public class ReportStatsCommand extends Command
	{
		[Inject]
		public var dataProxy		:DataProxy;
		
		[Inject]
		public var msService		:MSService;
		
		[Inject]
		public var peerService		:PeerService;
		
		override public function execute():void
		{
			var user_stats:Object = new Object();
//			var curr_ns:NetStream = dataProxy.my_info.peer_connection_status == PeerEvent.PEER_NETCONNECTION_CONNECTED?peerService.ns:msService.ns;
			var curr_ns:NetStream = dataProxy.use_peer_connection?peerService.ns:msService.ns;
			var ns_info:NetStreamInfo = curr_ns.info;
			
			user_stats.uname					= dataProxy.my_info.uname;
			user_stats.wowza_protocol			= msService.nc.protocol;
			user_stats.capabilities				= Capabilities.serverString;
			user_stats.audioLossRate 			= ns_info.audioLossRate;
			user_stats.droppedFrames 			= ns_info.droppedFrames;
			user_stats.SRTT 					= ns_info.SRTT;
//			try{
//				user_stats.videoLossRate 		= ns_info.videoLossRate;
//			} catch (e:Object){
//				//no value for this
//				user_stats.videoLossRate		= 0;
//			}
			user_stats.byteCount 				= ns_info.byteCount;
			
			user_stats.audioBytesPerSecond 		= int(ns_info.audioBytesPerSecond);
			user_stats.videoBytesPerSecond 		= int(ns_info.videoBytesPerSecond);
			user_stats.currentBytesPerSecond 	= int(ns_info.currentBytesPerSecond);
			user_stats.dataBytesPerSecond 		= int(ns_info.dataBytesPerSecond);
			user_stats.maxBytesPerSecond 		= int(ns_info.maxBytesPerSecond);
			
			msService.reportUserStats(user_stats);
			
		}
	}
}