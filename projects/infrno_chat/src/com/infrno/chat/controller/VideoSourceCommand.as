package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.PeerEvent;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.PeerService;
	import com.infrno.chat.view.components.ControlButtons;
	
	import org.robotlegs.mvcs.Command;
	
	// TODO: rename this. It's controlling peer connection usage, not just video
	public class VideoSourceCommand extends Command
	{
		[Inject]
		public var event:PeerEvent;
		
		[Inject]
		public var dataProxy:DataProxy;
		
		[Inject]
		public var msService:MSService;

		[Inject]
		public var peerService:PeerService;
		
		override public function execute():void
		{
			trace("VideoSourceCommand.execute() event.type:"+event.type);
			trace("VideoSourceCommand.execute() dataProxy.peer_enabled:"+dataProxy.peer_enabled);

			dataProxy.use_peer_connection = event.type == PeerEvent.PEER_ENABLE_VIDEO && dataProxy.peer_enabled;
			trace("VideoSourceCommand.execute() dataProxy.use_peer_connection:"+dataProxy.use_peer_connection);
			
			msService.updatePublishStream();
			peerService.updatePublishStream();
			
			trace("VideoSourceCommand.execute() dispatching MSEvent.USERS_OBJ_UPDATE)");	
			var msEvent:MSEvent = new MSEvent(MSEvent.USERS_OBJ_UPDATE);
			msEvent.userInfoVO_array = dataProxy.userInfoVO_array;
			msEvent.local_userInfoVO = dataProxy.local_userInfoVO;
			dispatch(msEvent);
		}
	}
}