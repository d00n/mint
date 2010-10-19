package com.infrno.chat.services
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.PeerEvent;
	
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.NetStream;
	import flash.utils.setTimeout;
	
	import org.robotlegs.mvcs.Actor;
	
	public class GroupService extends Actor
	{
		[Inject]
		public var dataProxy				:DataProxy;
		
		[Inject]
		public var deviceProxy				:DeviceProxy;
		
		private var _publishing				:Boolean;
		
		private var _group_spec				:GroupSpecifier;
		
		private var _nc						:NetConnection;
		private var _ng						:NetGroup;
		private var _ns						:NetStreamPeer;
		
		private var _outgoingPeerStream		:NetStream;
		
		private var _nc_client				:Object;
		
		public function GroupService()
		{
			super();
			setupNetConnectionClient();
			setupNetConnection();
		}
		
		public function connect():void
		{
			trace("connecting to group server: "+dataProxy.peer_server);
			dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_CONNECTING));
			_nc.connect(dataProxy.peer_server+"/"+dataProxy.peer_server_key);
		}
		
		public function getNewNetStream():NetStreamPeer
		{
			var ns:NetStreamPeer = new NetStreamPeer(_nc,_group_spec.groupspecWithAuthorizations());
			return ns;
		}
		
		public function updatePublishStream():void
		{
			if(_ng == null)
				return;
			
			if(dataProxy.use_peer_connection){
				if(!_publishing){
					trace(">>> publishing my group stream with name: "+dataProxy.my_info.suid.toString());
					setupNetStream();
					if(dataProxy.pubishing_audio)
						_ns.attachAudio(deviceProxy.mic);
					if(dataProxy.pubishing_video)
						_ns.attachCamera(deviceProxy.camera);
					_ns.publish(dataProxy.my_info.suid.toString());
					
					dataProxy.ns = _ns;
				} else {
					trace(">>> already publishing my group stream");
				}
			} else {
				trace(">>> closing group publish stream");
				if(_ns)
					_ns.close();
			}
		}
		
		/**
		 * Private methods
		 */
		
		private function handleNetGroupStatus(e:NetStatusEvent):void
		{
			trace("Peer group: "+e.info.code);
		}
		
		private function handleNetStatus(e:NetStatusEvent):void
		{
			trace("Group: "+e.info.code);
			switch(e.info.code){
				case "NetConnection.Connect.Success":
					//					dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_CONNECTED));
					setupNetGroup();
					break;
				case "NetGroup.Connect.Closed":
					setTimeout(function():void{setupNetGroup()},1000);
				case "NetConnection.Connect.Closed":
					dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_DISCONNECTED));
					break;
				case "NetConnection.Connect.Rejected":
				case "NetGroup.Connect.Rejected":
					dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_DISCONNECTED));
					break;
				case "NetGroup.Connect.Success":
					//					setupNetStream();
					dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_CONNECTED));
					break;
				case "NetStream.Publish.BadName":
					_publishing = false;
					updatePublishStream();
					break;
				case "NetStream.Publish.Start":
					_publishing = true;
					break;
				case "NetStream.Unpublish.Success":
					_publishing = false;
					break;
			}
		}
		
		private function setupNetConnectionClient():void
		{
			_nc_client = new Object();
		}
		
		private function setupNetConnection():void
		{
			_nc = new NetConnection();
			_nc.client = _nc_client;
			_nc.addEventListener(NetStatusEvent.NET_STATUS,handleNetStatus);
		}
		
		private function setupNetStream():void
		{
			if(_ns){
				if(_ns.hasEventListener(NetStatusEvent.NET_STATUS))
					_ns.removeEventListener(NetStatusEvent.NET_STATUS,handleNetStatus);
				_ns.close();
				_ns = null;
			}
			
			_ns = getNewNetStream();
			_ns.addEventListener(NetStatusEvent.NET_STATUS,handleNetStatus);
		}
		
		private function setupNetGroup():void
		{
			trace("setting up group: "+dataProxy.room_id);
			
			_group_spec = new GroupSpecifier("com.infrno.multiplayer:"+dataProxy.room_id);
			_group_spec.multicastEnabled = true;
			_group_spec.serverChannelEnabled = true;
			
			_ng = new NetGroup(_nc,_group_spec.groupspecWithAuthorizations());
			_ng.addEventListener(NetStatusEvent.NET_STATUS,handleNetGroupStatus);
		}
	}
}
