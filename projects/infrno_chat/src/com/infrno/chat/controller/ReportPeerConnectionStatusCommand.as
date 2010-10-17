package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.events.PeerEvent;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.PeerService;
	
	import org.robotlegs.mvcs.Command;
	
	public class ReportPeerConnectionStatusCommand extends Command
	{
		[Inject]
		public var event			:PeerEvent;
		
		[Inject]
		public var dataProxy		:DataProxy;
		
		[Inject]
		public var msService		:MSService;
		
		override public function execute():void
		{
			dataProxy.userInfoVO.report_connection_status = !(dataProxy.peer_capable == (event.type == PeerEvent.PEER_NETCONNECTION_CONNECTED));
			
			if(dataProxy.peer_enabled){
				dataProxy.userInfoVO.nearID = event.value;
				dataProxy.userInfoVO.peer_connection_status = event.type;
				dataProxy.peer_capable = event.type == PeerEvent.PEER_NETCONNECTION_CONNECTED;
			} else {
				dataProxy.userInfoVO.peer_connection_status = PeerEvent.PEER_NETCONNECTION_DISCONNECTED; //force server connection
			}
			
			var user_stats:Object 				= new Object();
			user_stats.application_name			= dataProxy.media_app;
			user_stats.user_name				= dataProxy.userInfoVO.user_name;
			user_stats.user_id					= dataProxy.userInfoVO.user_id;
			user_stats.peer_connection_status	= dataProxy.userInfoVO.peer_connection_status;
			
			msService.reportPeerConnectionStatus(user_stats);
		}
	}
}