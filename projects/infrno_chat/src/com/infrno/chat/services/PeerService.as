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
		private var _ns_outgoing:NetStreamPeer;		
		private var _nc_client:Object;
		
		public function PeerService()
		{
			super();
			setupNetConnectionClient();
			setupNetConnection();
		}
		
		public function connect():void
		{
			trace("PeerService.connect() connecting to peer server: "+dataProxy.peer_server);
			dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_CONNECTING));
			_netConnection.connect(dataProxy.peer_server+"/"+dataProxy.peer_server_key);
		}
		
		public function get netStream():NetStream
		{
			return _ns_outgoing;
		}
		
		public function getNewNetStream(streamType:String = NetStream.DIRECT_CONNECTIONS):NetStreamPeer
		{
			var ns:NetStreamPeer = new NetStreamPeer(_netConnection,streamType);
			return ns;
		}
		
		public function updatePublishStream():void
		{
			if(!_netConnection.connected)
				return;
			
			// TODO write test around this, then flip the if blocks to eliminate the negation 
			if(dataProxy.use_peer_connection){
				if(!_published){
					trace("PeerService.updatePublishStream() >>> publishing my peer stream with name: "+dataProxy.local_userInfoVO.suid.toString());
					
					setupOutgoingNetStream();
					
					if(dataProxy.pubishing_audio)
						_ns_outgoing.attachAudio(deviceProxy.mic);
					
					if(dataProxy.pubishing_video)
						_ns_outgoing.attachCamera(deviceProxy.camera);
					
					_ns_outgoing.publish(dataProxy.local_userInfoVO.suid.toString());
					
					dataProxy.ns = _ns_outgoing;
				} else {
					trace("PeerService.updatePublishStream() >>> already publishing my peer stream");
				}
			} else {
				trace("PeerService.updatePublishStream() >>> closing peer publish stream");
				if(_ns_outgoing)
					_ns_outgoing.close();
			}
		}
		
		/**
		 * Private methods
		 */
		
		private function handleNetStatus(e:NetStatusEvent):void
		{
			trace("PeerService.handleNetStatus() Peer: "+e.info.code);
			// TODO Report these
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
					trace("PeerService.handleNetStatus() someone disconnected from me");
					//their farID = e.info.stream.farID;
					//dataProxy.users_collection has a reference for this
					break;
				
			}
		}
		
		private function handleOutgoingNetStatus(e:NetStatusEvent):void
		{
			trace("PeerService.handleOutgoingNetStatus() event: "+e.info.code);
			switch(e.info.code){
				case "NetStream.Play.Start":
					trace("PeerService.handleOutgoingNetStatus() someone connected to me and is playing my stream");
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
		
		private function setupNetConnectionClient():void
		{
			_nc_client = new Object();
		}
		
		private function setupNetConnection():void
		{
			_netConnection = new NetConnection();
			_netConnection.client = _nc_client;
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS,handleNetStatus);
		}
		
		private function setupOutgoingNetStream():void
		{
			if(_ns_outgoing){
				if(_ns_outgoing.hasEventListener(NetStatusEvent.NET_STATUS))
					_ns_outgoing.removeEventListener(NetStatusEvent.NET_STATUS,handleOutgoingNetStatus);
				_ns_outgoing.close();
				_ns_outgoing = null;
			}
			
			_ns_outgoing = getNewNetStream();
			_ns_outgoing.addEventListener(NetStatusEvent.NET_STATUS,handleOutgoingNetStatus);
			
			var c:Object = new Object();
			c.onPeerConnect = function(caller:NetStream):Boolean
			{
				trace("PeerService.setupOutgoingNetStream() #### Caller connecting to listener stream: " + caller.farID);
				//				trace("opposite_user._nearID: "+opposite_user._nearID);
				//				return opposite_user._nearID==caller.farID;
				return true;
			}
			_ns_outgoing.client = c;
		}
	}
}
