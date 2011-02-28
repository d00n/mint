package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.events.PeerEvent;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.PeerService;
	
	import org.robotlegs.mvcs.Command;
	
	public class ReportPeerConnectionCommand extends Command
	{
		[Inject]
		public var event:PeerEvent;
		
		[Inject]
		public var dataProxy:DataProxy;
		
		[Inject]
		public var msService:MSService;
		
		// Mediates: 
		// PeerEvent.PEER_NETCONNECTION_CONNECTED  
		// PeerEvent.PEER_NETCONNECTION_DISCONNECTED
		override public function execute():void
		{
			// TODO unwind this
			dataProxy.local_userInfoVO.report_connection_status = !(dataProxy.peer_capable == (event.type == PeerEvent.PEER_NETCONNECTION_CONNECTED));
			
			if(dataProxy.peer_enabled){
				dataProxy.local_userInfoVO.nearID = event.value;
				dataProxy.local_userInfoVO.peer_connection_status = event.type;
				dataProxy.peer_capable = event.type == PeerEvent.PEER_NETCONNECTION_CONNECTED;
			} else {
				//force server connection
				dataProxy.local_userInfoVO.peer_connection_status = PeerEvent.PEER_NETCONNECTION_DISCONNECTED; 
			}
			msService.updateUserInfo();
		}
	}
}