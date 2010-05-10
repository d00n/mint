package com.inferno.multiplayer.controller
{
	import com.inferno.multiplayer.model.DataProxy;
	import com.inferno.multiplayer.model.events.MSEvent;
	import com.inferno.multiplayer.model.events.PeerEvent;
	import com.inferno.multiplayer.services.MSService;
	import com.inferno.multiplayer.services.PeerService;
	import com.inferno.multiplayer.view.components.ControlButtons;
	
	import org.robotlegs.mvcs.Command;
	
	public class VideoSourceCommand extends Command
	{
		[Inject]
		public var event			:PeerEvent;
		
		[Inject]
		public var dataProxy		:DataProxy;
		
		[Inject]
		public var msService		:MSService;

		[Inject]
		public var peerService		:PeerService;
		
		override public function execute():void
		{
			dataProxy.use_peer_connection = event.type == PeerEvent.PEER_ENABLE_VIDEO && dataProxy.peer_enabled;
			
			msService.updatePublishStream();
			peerService.updatePublishStream();
			
			dispatch(new MSEvent(MSEvent.USERS_OBJ_UPDATE));
		}
	}
}