package com.infrno.multiplayer.controller
{
	import com.infrno.multiplayer.model.DataProxy;
	import com.infrno.multiplayer.model.events.PeerEvent;
	import com.infrno.multiplayer.services.MSService;
	import com.infrno.multiplayer.services.PeerService;
	
	import org.robotlegs.mvcs.Command;
	
	public class PeerConnectionStatusCommand extends Command
	{
		[Inject]
		public var event			:PeerEvent;
		
		[Inject]
		public var dataProxy		:DataProxy;
		
		[Inject]
		public var msService		:MSService;
		
		override public function execute():void
		{
			if(dataProxy.peer_enabled){
				dataProxy.my_info.nearID = event.value;
				dataProxy.my_info.peer_connection_status = event.type;
				dataProxy.peer_capable = event.type == PeerEvent.PEER_NETCONNECTION_CONNECTED;
			} else {
				dataProxy.my_info.peer_connection_status = PeerEvent.PEER_NETCONNECTION_DISCONNECTED; //force server connection
			}
			msService.updateUserInfo();
		}
	}
}