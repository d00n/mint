package com.infrno.multiplayer.controller
{
	import com.infrno.multiplayer.model.DataProxy;
	import com.infrno.multiplayer.model.events.MSEvent;
	import com.infrno.multiplayer.model.events.PeerEvent;
	import com.infrno.multiplayer.services.MSService;
	import com.infrno.multiplayer.services.PeerService;
	import com.infrno.multiplayer.view.components.ControlButtons;
	
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