package com.infrno.setup.controller
{
	import com.infrno.setup.model.DataProxy;
	import com.infrno.setup.model.events.MessageEvent;
	import com.infrno.setup.model.events.NetConnectionEvent;
	import com.infrno.setup.model.events.StratusConnectionEvent;
	import com.infrno.setup.services.NetConnectionService;
	import com.infrno.setup.services.StratusConnectionService;
	
	import org.robotlegs.mvcs.Command;
	
	public class TestNetworkCommand extends Command
	{
		[Inject]
		public var dataProxy				:DataProxy;
		
		[Inject]
		public var netConnection			:NetConnectionService;
		
		[Inject]
		public var peerConnection			:StratusConnectionService;
		
		override public function execute():void
		{
			runServerConnectionTest();
		}
		
		private function runServerConnectionTest():void
		{
			netConnection.eventDispatcher.addEventListener(NetConnectionEvent.NETCONNECTION_CONNECTED,serverConnectionStatus);
			netConnection.eventDispatcher.addEventListener(NetConnectionEvent.NETCONNECTION_CONNECTING,serverConnectionStatus);
			netConnection.eventDispatcher.addEventListener(NetConnectionEvent.NETCONNECTION_DISCONNECTED,serverConnectionStatus);
			netConnection.connect(dataProxy.media_server);
		}
		
		private function runStratusConnectionTest():void
		{
			peerConnection.eventDispatcher.addEventListener(StratusConnectionEvent.STRATUSCONNECTION_CONNECTED,peerConnectionStatus);
			peerConnection.eventDispatcher.addEventListener(StratusConnectionEvent.STRATUSCONNECTION_CONNECTING,peerConnectionStatus);
			peerConnection.eventDispatcher.addEventListener(StratusConnectionEvent.STRATUSCONNECTION_DISCONNECTED,peerConnectionStatus);
			peerConnection.connect(dataProxy.peer_server+"/"+dataProxy.peer_server_key);
		}
		
		private function peerConnectionStatus(e:StratusConnectionEvent):void
		{
			trace("peer: "+e.type);
			var cleanup_listeners:Boolean;
			if(e.type == StratusConnectionEvent.STRATUSCONNECTION_CONNECTED){
				cleanup_listeners = true;
			} else if(e.type == StratusConnectionEvent.STRATUSCONNECTION_DISCONNECTED){
				dispatch(new MessageEvent(MessageEvent.WARNING,"Stratus connection failed.\nYour audio/video communication may be slightly delayed."));
				cleanup_listeners = true;
			}
			
			if(cleanup_listeners){
				peerConnection.eventDispatcher.removeEventListener(StratusConnectionEvent.STRATUSCONNECTION_CONNECTED,peerConnectionStatus);
				peerConnection.eventDispatcher.removeEventListener(StratusConnectionEvent.STRATUSCONNECTION_CONNECTING,peerConnectionStatus);
				peerConnection.eventDispatcher.removeEventListener(StratusConnectionEvent.STRATUSCONNECTION_DISCONNECTED,peerConnectionStatus);
				peerConnection.close();
			}
		}
		
		private function serverConnectionStatus(e:NetConnectionEvent):void
		{
			trace("server: "+e.type);
			var cleanup_listeners:Boolean;
			if(e.type == NetConnectionEvent.NETCONNECTION_CONNECTED){
				runStratusConnectionTest();
				cleanup_listeners = true;
			} else if(e.type == NetConnectionEvent.NETCONNECTION_DISCONNECTED){
				dispatch(new MessageEvent(MessageEvent.ERROR,"Server connection failed.\nPlease check your networks settings and try again."));
				cleanup_listeners = true;
			}
			
			if(cleanup_listeners){
				netConnection.eventDispatcher.removeEventListener(NetConnectionEvent.NETCONNECTION_CONNECTED,serverConnectionStatus);
				netConnection.eventDispatcher.removeEventListener(NetConnectionEvent.NETCONNECTION_CONNECTING,serverConnectionStatus);
				netConnection.eventDispatcher.removeEventListener(NetConnectionEvent.NETCONNECTION_DISCONNECTED,serverConnectionStatus);
				netConnection.close();
			}
		}
	}
}