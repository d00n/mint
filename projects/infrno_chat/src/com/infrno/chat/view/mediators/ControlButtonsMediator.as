package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.PeerEvent;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.view.components.ControlButtons;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Mediator;
	
	// not used
	public class ControlButtonsMediator extends Mediator
	{
		[Inject]
		public var dataProxy:DataProxy;
		
		[Inject]
		public var msService:MSService;
		
		[Inject]
		public var controlButtons:ControlButtons;
		
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,MSEvent.USERS_OBJ_UPDATE,updateVideoSource);
			
			controlButtons.addEventListener("peer_stream",switchToPeer);
			controlButtons.addEventListener("report_stats",reportStats);
			controlButtons.addEventListener("wowza_stream",switchToWowza);
		}
		
		private function switchToPeer(e:Event):void
		{
			dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_CONNECTED));
		}
		
		private function reportStats(e:Event):void
		{
			msService.getUserStats();
		}
		
		private function switchToWowza(e:Event):void
		{
			dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_DISCONNECTED));
		}
		
		private function updateVideoSource(e:MSEvent):void
		{
			controlButtons.connected_to.text = "peer connected: "+dataProxy.use_peer_connection;
		}
	}
}