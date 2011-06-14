package com.infrno.chat.services
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.PeerEvent;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.setTimeout;
	
	import org.robotlegs.mvcs.Actor;
	
	//	Services Should Implement an Interface
	//	By creating service classes that implement interfaces, it makes it trivial to switch them out at 
	//	runtime for testing or providing access to additional services to the end users of the application.
	public class PeerService extends Actor // implements INetService
	{
		[Inject]
		public var dataProxy:DataProxy;
		
		[Inject]
		public var deviceProxy:DeviceProxy;
		
		private var _published:Boolean;		
		private var _netConnection:NetConnection;
		private var _netStream:NetStreamPeer;		
		private var _netConnection_client:Object;
		
		public function PeerService()
		{
			super();
			_netConnection_client = new Object();
			setupNetConnection();
		}
		
//		private function setupNetConnectionClient():void
//		{
//			_netConnection_client = new Object();
//		}
//		
		private function setupNetConnection():void
		{
			_netConnection = new NetConnection();
			_netConnection.client = _netConnection_client;
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS,handleNetStatus);
		}
				
		public function connect():void
		{
			trace("PeerService.connect() connecting to peer server: "+dataProxy.peer_server+"/"+dataProxy.peer_server_key);
			
			// Nobody mediates this
			dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_CONNECTING));
			
			_netConnection.connect(dataProxy.peer_server+"/"+dataProxy.peer_server_key);
		}
		
		public function get netStream():NetStream
		{
			return _netStream;
		}
		
		public function getNewNetStream(streamType:String = NetStream.DIRECT_CONNECTIONS):NetStreamPeer
		{
			var ns:NetStreamPeer = new NetStreamPeer(_netConnection,streamType);
			return ns;
		}
		
		public function updatePublishStream():void
		{
			trace("PeerService.updatePublishStream() _netConnection.connected:"+_netConnection.connected);
			
			if(!_netConnection.connected) {
				return;
			}
			
			// TODO write test around this, then flip the if blocks to eliminate the negation 
			if(dataProxy.use_peer_connection){
				if(!_published){
					trace("PeerService.updatePublishStream() publishing local peer stream with suid/name: "+dataProxy.local_userInfoVO.suid.toString());
					
					setupOutgoingNetStream();
					
					if(dataProxy.pubishing_audio)
						_netStream.attachAudio(deviceProxy.mic);
					
					if(dataProxy.pubishing_video)
						_netStream.attachCamera(deviceProxy.camera);
					
					_netStream.publish(dataProxy.local_userInfoVO.suid.toString());
					
					dataProxy.ns = _netStream;
				} else {
					trace("PeerService.updatePublishStream() local stream is already published");
				}
			} else {
				trace("PeerService.updatePublishStream() closing local peer stream. _published:"+_published);
				if(_netStream)
					_netStream.close();
			}
		}
		
		private function handleNetStatus(e:NetStatusEvent):void
		{
			trace("PeerService.handleNetStatus() "+e.info.code+" _netConnection.nearID:"+_netConnection.nearID);
			// TODO Report these to the server
			switch(e.info.code){
				case "NetConnection.Connect.Success":
					dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_CONNECTED,_netConnection.nearID));
					break;
				case "NetConnection.Connect.Closed":
					dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_DISCONNECTED));
					break;
				case "NetConnection.Connect.Rejected":
					dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_DISCONNECTED));
					break;
				case "NetStream.Connect.Closed":
					trace(">>>>>>>>> not sure if this ever gets hit >>>>>>>>> PeerService.handleNetStatus() NetStream.Connect.Closed");
					
					// TODO validate this:
					//dataProxy.users_collection has a reference for this
					break;				
			}
		}
		
		private function handleOutgoingNetStatus(e:NetStatusEvent):void
		{
			trace("PeerService.handleOutgoingNetStatus() event: "+e.info.code);
			switch(e.info.code){
				case "NetStream.Play.Start":
					break;
				case "NetStream.Publish.BadName":
					_published = false;
					updatePublishStream();
					break;
				case "NetStream.Publish.Start":
					_published = true;
					break;
				case "NetStream.Unpublish.Success":
					_published = false;
					break;
			}
		}
		
		private function setupOutgoingNetStream():void
		{
			trace("PeerService.setupOutgoingNetStream()");

			if(_netStream){
				if(_netStream.hasEventListener(NetStatusEvent.NET_STATUS))
					_netStream.removeEventListener(NetStatusEvent.NET_STATUS,handleOutgoingNetStatus);
				_netStream.close();
				_netStream = null;
			}
			
			_netStream = getNewNetStream();
			_netStream.addEventListener(NetStatusEvent.NET_STATUS,handleOutgoingNetStatus);
			
			var client:Object = new Object();
			client.onPeerConnect = function(netStream:NetStream):Boolean
			{
				trace("PeerService.setupOutgoingNetStream() client.onPeerConnect() netStream.farID: " + netStream.farID);
				return true;
			}
			_netStream.client = client;
		}
	}
}
