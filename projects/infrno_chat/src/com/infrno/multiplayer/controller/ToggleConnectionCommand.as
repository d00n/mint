package com.infrno.multiplayer.controller
{
	import com.infrno.multiplayer.model.DataProxy;
	import com.infrno.multiplayer.model.events.PeerEvent;
	import com.infrno.multiplayer.services.MSService;
	
	import org.robotlegs.mvcs.Command;
	
	public class ToggleConnectionCommand extends Command
	{
		override public function execute():void
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
					dataProxy.my_info.peer_connection_status = event.type;
				} else {
					dataProxy.my_info.peer_connection_status = PeerEvent.PEER_NETCONNECTION_DISCONNECTED; //force server connection
				}
				msService.updateUserInfo();
			}
		}
	}
}