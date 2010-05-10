package com.inferno.multiplayer.controller
{
	import com.inferno.multiplayer.model.DataProxy;
	import com.inferno.multiplayer.model.events.PeerEvent;
	import com.inferno.multiplayer.services.MSService;
	import com.inferno.multiplayer.services.PeerService;
	
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
			user_stats.currentBytesPerSecond 	= ns_info.currentBytesPerSecond;
			user_stats.dataBytesPerSecond 		= ns_info.dataBytesPerSecond;
			user_stats.droppedFrames 			= ns_info.droppedFrames;
			user_stats.maxBytesPerSecond 		= ns_info.maxBytesPerSecond;
			user_stats.SRTT 					= ns_info.SRTT;
//			try{
//				user_stats.videoLossRate 		= ns_info.videoLossRate;
//			} catch (e:Object){
//				//no value for this
//				user_stats.videoLossRate		= 0;
//			}
			user_stats.byteCount 				= ns_info.byteCount;
			user_stats.audioBytesPerSecond 		= ns_info.audioBytesPerSecond;
			user_stats.videoBytesPerSecond 		= ns_info.videoBytesPerSecond;
			
			msService.reportUserStats(user_stats);
			
		}
	}
}