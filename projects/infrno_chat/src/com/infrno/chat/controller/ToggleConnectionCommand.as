package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.events.PeerEvent;
	import com.infrno.chat.services.MSService;
	
	import org.robotlegs.mvcs.Command;
	
	public class ToggleConnectionCommand extends Command
	{
		override public function execute():void
		{
			[Inject]
			public var event:PeerEvent;
			
			[Inject]
			public var dataProxy:DataProxy;
			
			[Inject]
			public var msService:MSService;
			
			override public function execute():void
			{
				trace("ToggleConnectionCommand.execute() event.type:" +event.type);

				dataProxy.local_userInfoVO.report_connection_status = !(dataProxy.local_userInfoVO.peer_connection_status == event.type);

				if(dataProxy.peer_enabled){
					dataProxy.local_userInfoVO.peer_connection_status = event.type;
				} else {
					dataProxy.local_userInfoVO.peer_connection_status = PeerEvent.PEER_NETCONNECTION_DISCONNECTED; //force server connection
				}
				
				msService.sendUserInfoToServer();
			}
		}
	}
}