package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.services.PeerService;
	
	import org.robotlegs.mvcs.Command;
	
	public class ConnectPeerServerCommand extends Command
	{
		[Inject]
		public var dataProxy:DataProxy;
		
		[Inject]
		public var peerService:PeerService;
		
		override public function execute():void
		{
			trace("ConnectPeerServerCommand.execute() dataProxy.peer_enabled:"+dataProxy.peer_enabled);

			if(dataProxy.peer_enabled)
				peerService.connect();
		}
	}
}