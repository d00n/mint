package com.inferno.multiplayer.controller
{
	import com.inferno.multiplayer.model.DataProxy;
	import com.inferno.multiplayer.services.PeerService;
	
	import org.robotlegs.mvcs.Command;
	
	public class ConnectPeerServerCommand extends Command
	{
		[Inject]
		public var dataProxy		:DataProxy;
		
		[Inject]
		public var peerService		:PeerService;
		
		override public function execute():void
		{
			if(dataProxy.peer_enabled)
				peerService.connect();
		}
	}
}