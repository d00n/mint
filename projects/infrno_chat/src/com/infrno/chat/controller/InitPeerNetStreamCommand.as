package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.NetStreamMS;
	import com.infrno.chat.services.NetStreamPeer;
	import com.infrno.chat.services.PeerService;
	
	import flash.net.NetStream;
	
	import org.robotlegs.mvcs.Command;
	
	public class InitPeerNetStreamCommand extends Command
	{
		[Inject]
		public var event:VideoPresenceEvent;

		[Inject]
		public var dataProxy:DataProxy;
		
		[Inject]
		public var msService:MSService;
		
		[Inject]
		public var peerService:PeerService;		
		
		// TODO test me!
		override public function execute():void
		{
			var userInfoVO:UserInfoVO = event.userInfoVO;
			
			var dispatchVpEvent:Boolean = false;
			
			if(dataProxy.use_peer_connection && 
					userInfoVO.nearID && 
					dataProxy.peer_capable && 
					!(userInfoVO.netStream is NetStreamPeer) )
			{
				trace("InitPeerNetStreamCommand.execute() setting up and playing from the peer connection: "+userInfoVO.suid.toString());
				
				// rewriting for testability
//				userInfoVO.netStream = peerService.getNewNetStream(userInfoVO.nearID);
//				userInfoVO.netStream.play(userInfoVO.suid.toString());
				
				// becomes:
				var netStream:NetStream = peerService.getNewNetStream(userInfoVO.nearID);
				netStream.play(userInfoVO.suid.toString());
				userInfoVO.netStream = netStream;
				
				dispatchVpEvent = true;
			} else if(!dataProxy.use_peer_connection && 
					!(userInfoVO.netStream is NetStreamMS) )
			{
				trace("InitPeerNetStreamCommand.execute() setting up and playing from the stream server");
				userInfoVO.netStream = msService.getNewNetStream();
				userInfoVO.netStream.play(userInfoVO.suid.toString(),-1);
				dispatchVpEvent = true;
			}
			
			if (dispatchVpEvent) {
				var vpEvent:VideoPresenceEvent= new VideoPresenceEvent(VideoPresenceEvent.SETUP_PEER_VIDEOPRESENCE_COMPONENT);
				vpEvent.userInfoVO = userInfoVO;
				dispatch(vpEvent);	
			}
		}
	}
}