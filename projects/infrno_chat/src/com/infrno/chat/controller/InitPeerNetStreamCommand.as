package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.NetStreamMS;
	import com.infrno.chat.services.NetStreamPeer;
	import com.infrno.chat.services.PeerService;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
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
			var netStream:NetStream;
			
			trace("InitPeerNetStreamCommand.execute() dataProxy.use_peer_connection: "+dataProxy.use_peer_connection);
			trace("InitPeerNetStreamCommand.execute() dataProxy.peer_capable: "+dataProxy.peer_capable);
			trace("InitPeerNetStreamCommand.execute() userInfoVO.nearID: "+userInfoVO.nearID);
			trace("InitPeerNetStreamCommand.execute() userInfoVO.suid: "+userInfoVO.suid);
			
			if (userInfoVO.netStream == null)
				trace("InitPeerNetStreamCommand.execute() userInfoVO.netStream is null");
			else
				trace("InitPeerNetStreamCommand.execute() userInfoVO.netStream is a: "+Class(getDefinitionByName(getQualifiedClassName(userInfoVO.netStream))));

			
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
				netStream = peerService.getNewNetStream(userInfoVO.nearID);
				netStream.play(userInfoVO.suid.toString());
				userInfoVO.set_netStream(netStream, handleNetStatus_NetStreamPeer);
				
				dispatchVpEvent = true;
			} else if(!dataProxy.use_peer_connection && 
					!(userInfoVO.netStream is NetStreamMS) )
			{
				trace("InitPeerNetStreamCommand.execute() setting up and playing from the server connection");
				netStream = msService.getNewNetStream();
				userInfoVO.set_netStream(netStream, handleNetStatus_NetStreamMS);
				userInfoVO.netStream.play(userInfoVO.suid.toString(),-1);
				dispatchVpEvent = true;
			}
			
			if (dispatchVpEvent) {
				trace("InitPeerNetStreamCommand.execute() dispatching VideoPresenceEvent.SETUP_PEER_VIDEOPRESENCE_COMPONENT");
				// Mediated by VideosGroupMediator.setupPeerVideoPresenceComponent
				var vpEvent:VideoPresenceEvent= new VideoPresenceEvent(VideoPresenceEvent.SETUP_PEER_VIDEOPRESENCE_COMPONENT);
				vpEvent.userInfoVO = userInfoVO;
				dispatch(vpEvent);	
			} else {
				trace("InitPeerNetStreamCommand.execute() NOT dispatching VideoPresenceEvent.SETUP_PEER_VIDEOPRESENCE_COMPONENT");
			}
		}
		
		private function handleNetStatus_NetStreamPeer(e:NetStatusEvent):void
		{
			trace("InitPeerNetStreamCommand.handleNetStatus_NetStreamPeer() e.info.code="+e.info.code);
			var msg:String = "InitPeerNetStreamCommand.handleNetStatus_NetStreamPeer e.info.code="+ e.info.code;
			msService.sendLogMessageToServer(msg);
		}
		
		private function handleNetStatus_NetStreamMS(e:NetStatusEvent):void
		{
			trace("InitPeerNetStreamCommand.handleNetStatus_NetStreamMS() e.info.code="+e.info.code);
			var msg:String = "InitPeerNetStreamCommand.handleNetStatus_NetStreamMS e.info.code="+ e.info.code;
			msService.sendLogMessageToServer(msg);
		}
	}
}