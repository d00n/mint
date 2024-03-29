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
		
		override public function execute():void
		{
			trace("ReportPeerConnectionCommand.execute() event.type:"+event.type);
			trace("ReportPeerConnectionCommand.execute() dataProxy.peer_capable:"+dataProxy.peer_capable);
			trace("ReportPeerConnectionCommand.execute() dataProxy.peer_enabled:"+dataProxy.peer_enabled);
			
			// TODO unwind this
			dataProxy.local_userInfoVO.report_connection_status = !(dataProxy.peer_capable == (event.type == PeerEvent.PEER_NETCONNECTION_CONNECTED));
			
			trace("ReportPeerConnectionCommand.execute() dataProxy.local_userInfoVO.report_connection_status:"+dataProxy.local_userInfoVO.report_connection_status);
			
			if(dataProxy.peer_enabled){
				dataProxy.local_userInfoVO.nearID = event.value;
				dataProxy.local_userInfoVO.peer_connection_status = event.type;
				
				// TODO
				// So peer_capable is defined here as we successfully established a peer connection
				// What about subsequent, failed attempts? Isn't this a per-user attribute?
				dataProxy.peer_capable = event.type == PeerEvent.PEER_NETCONNECTION_CONNECTED;				
				
				trace("ReportPeerConnectionCommand.execute() peer_enabled=true, dataProxy.local_userInfoVO.nearID:"+dataProxy.local_userInfoVO.nearID);
				trace("ReportPeerConnectionCommand.execute() peer_enabled=true, dataProxy.local_userInfoVO.peer_connection_status:"+dataProxy.local_userInfoVO.peer_connection_status);
				trace("ReportPeerConnectionCommand.execute() peer_enabled=true, dataProxy.peer_capable:"+dataProxy.peer_capable);				
			} else {
				//force server connection
				dataProxy.local_userInfoVO.peer_connection_status = PeerEvent.PEER_NETCONNECTION_DISCONNECTED; 
				trace("ReportPeerConnectionCommand.execute() peer_enabled=false, dataProxy.local_userInfoVO.peer_connection_status:"+dataProxy.local_userInfoVO.peer_connection_status);				
			}
			
			// TODO rename this command
			// If it's purpose is to cause the connection to switch, reporting that switch is secondary
			// .. and this update here is what causes a connection switch:
			msService.sendUserInfoToServer();
			// AND it mediates PeerEvent.PEER_NETCONNECTION_CONNECTED
		}
	}
}