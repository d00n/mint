package com.inferno.multiplayer.view.mediators
{
	import com.inferno.multiplayer.model.DataProxy;
	import com.inferno.multiplayer.model.events.MSEvent;
	import com.inferno.multiplayer.model.events.PeerEvent;
	import com.inferno.multiplayer.services.MSService;
	import com.inferno.multiplayer.view.components.ControlButtons;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class ControlButtonsMediator extends Mediator
	{
		[Inject]
		public var dataProxy		:DataProxy;
		
		[Inject]
		public var msService		:MSService;
		
		[Inject]
		public var controlButtons	:ControlButtons;
		
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