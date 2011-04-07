package com.infrno.chat.services
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.ChatEvent;
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.PeerEvent;
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.vo.UserInfoVO;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Capabilities;
	
	import org.robotlegs.mvcs.Actor;
	
	//	Services Should Implement an Interface
	//	By creating service classes that implement interfaces, it makes it trivial to switch them out at 
	//	runtime for testing or providing access to additional services to the end users of the application.	
	public class MSService extends Actor // implements INetService
	{
		[Inject]
		public var dataProxy:DataProxy;
		
		[Inject]
		public var deviceProxy:DeviceProxy;
		
		private var _published:Boolean;	
		private var _netConnection:NetConnection;
		private var _netStream:NetStream;
		private var _netConnection_client:Object;
		
		public function MSService()
		{
			trace("MSService constructor");
			super();
			setupClient();
			setupNetConnection();
		}		
		
		private function setupClient():void
		{
			trace("MSService.setupClient()");
			
			_netConnection_client = new Object();
			
			_netConnection_client.initUser = function(userInfoVO:Object):void
			{
				trace("MSService: _nc_client.initUser() userInfoVO.suid:" + userInfoVO.suid);
				dataProxy.local_userInfoVO.update(userInfoVO);
			}
			
			_netConnection_client.chatToUser = function(msgIn:String, dieRoll:Boolean):void {
				dispatch(new ChatEvent(ChatEvent.RECEIVE_CHAT,msgIn,dieRoll));
			}
			
			_netConnection_client.collectClientStats = function():void {
				dispatch(new StatsEvent(StatsEvent.COLLECT_CLIENT_STATS));
			}
				
			_netConnection_client.receiveClientStats = function(clientStats:Object):void {
				var statsEvent:StatsEvent = new StatsEvent(StatsEvent.RECEIVE_CLIENT_STATS);
				statsEvent.inbound_clientStats = clientStats;
				dispatch(statsEvent);
			}
				
			_netConnection_client.receiveServerStats = function(serverStats:Object):void {
				var statsEvent:StatsEvent = new StatsEvent(StatsEvent.RECEIVE_SERVER_STATS);
				statsEvent.inbound_serverStats = serverStats;
				dispatch(statsEvent);
			}
				
			_netConnection_client.usePeerConnection = function(use_peer_connection:Boolean):void {
				trace("MSService.setupClient() _nc_client.usePeerConnection() use_peer_connection:"+use_peer_connection);
				if(use_peer_connection){
					dispatch(new PeerEvent(PeerEvent.PEER_ENABLE_VIDEO));
				} else {
					dispatch(new PeerEvent(PeerEvent.PEER_DISABLE_VIDEO));
				}
			}
				
			_netConnection_client.updateUsers = updateUsers;
		}
		
		private function setupNetConnection():void
		{
			trace("MSService.setupNetConnection()");
			
			_netConnection = new NetConnection();
			_netConnection.client = _netConnection_client;
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
		}
		
		public function chatToServer(msgIn:String, targetUsers:Array=null):void
		{
			trace("MSService.chatToServer() sending this chat to the server: "+msgIn);
			_netConnection.call("chatToServer",null,msgIn,targetUsers);
		}
		
		public function connect():void
		{
			var connection_uri:String = dataProxy.media_server +":"+ dataProxy.media_port +"/"+ dataProxy.media_app +"/"+ dataProxy.room_id;
			
			trace("MSService.connect() connection_uri="+connection_uri);
			
			trace("MSService.connect() dataProxy params:" 
				+ dataProxy.room_name 
				+":"+ dataProxy.local_userInfoVO.user_name 
				+":"+ dataProxy.room_id 
				+":"+ dataProxy.auth_key);
			
//			dispatch(new MSEvent(MSEvent.NETCONNECTION_CONNECTING));
			
			_netConnection.connect(connection_uri, 
				dataProxy.local_userInfoVO, 
				dataProxy.auth_key,
				dataProxy.room_id,
				dataProxy.room_name, 
				dataProxy.media_app,
				DataProxy.VERSION,
				Capabilities.serverString);
		}
		
		public function get netConnection():NetConnection
		{
			return _netConnection;
		}
		
		public function get netStream():NetStream
		{
			return _netStream;
		}
		
		public function getNewNetStream():NetStreamMS
		{
			trace("MSService.getNewNetStream()");

			var ns_client:Object = new Object();
			
			// TODO useful QoS data?
			ns_client.onPlayStatus = onPlayStatus;
			ns_client.onMetaData = onMetaData;
			
			var ns:NetStreamMS = new NetStreamMS(_netConnection);
			ns.client = ns_client;
			ns.addEventListener(NetStatusEvent.NET_STATUS,function(e:NetStatusEvent):void{}); //provided to avoid runtime error
			return ns;
		}
		
		public function onPlayStatus(e:Object):void {
			trace("MSService.onPlayStatus() e:" + e.toString());			
		}
		
		public function onMetaData(e:Object):void {
			trace("MSService.onMetaData() e:" + e.toString());			
		}
		
		public function sendClientStats(clientStats:Object):void
		{
			_netConnection.call("receiveClientStats",null,clientStats);
		}
		
//		public function sendClientPeerStats(peerStats:Object):void
//		{
//			_netConnection.call("receiveClientPeerStats",null,peerStats);
//		}		
		
		public function updatePublishStream():void
		{
			trace("MSService.updatePublishStream()");

			// TODO write test around this, then flip the if blocks to eliminate the negation 
			if(!dataProxy.use_peer_connection){
				if(!_published){
					trace("MSService.updatePublishStream() ### publishing local server stream with dataProxy.local_userInfoVO.suid: "+dataProxy.local_userInfoVO.suid.toString());
					
					if(dataProxy.pubishing_audio)
						_netStream.attachAudio(deviceProxy.mic);
					
					if(dataProxy.pubishing_video)
						_netStream.attachCamera(deviceProxy.camera);
					
					_netStream.publish(dataProxy.local_userInfoVO.suid.toString());
					
					dataProxy.ns = _netStream;
				} else {
					trace("MSService.updatePublishStream() ### already publishing local server stream");
				}
			} else {
				trace("MSService.updatePublishStream() ### closing server publish stream");
				_netStream.close();
			}
		}
		
		public function updateUserInfo():void
		{
			trace("MSService.updateUserInfo() dataProxy.local_userInfoVO.suid="+dataProxy.local_userInfoVO.suid);
			_netConnection.call("updateUserInfo",null,dataProxy.local_userInfoVO);
		}
		
		private function updateUsers(userInfoVOs:Object):void
		{
			trace("MSService.updateUsers()");
			
			// TODO: don't delete what hasn't changed.			
			//removing data
			for(var n:String in dataProxy.userInfoVO_array)
			{
				trace("MSService.updateUsers() looking to delete n="+n);
				if(userInfoVOs[n] == null)
					delete dataProxy.userInfoVO_array[n];
			}
			
			//adding/updating info
			for(var m:String in userInfoVOs){
				trace("MSService.updateUsers() looking to add m="+m);				
				var userInfoVO:UserInfoVO = dataProxy.userInfoVO_array[m];				
				
				if(userInfoVO == null){
					trace("MSService.updateUsers() creating new UserInfoVO for m="+m);				
					dataProxy.userInfoVO_array[m] = new UserInfoVO(userInfoVOs[m]);
				} else {
					trace("MSService.updateUsers() updating UserInfoVO for m="+m);						
					userInfoVO.update(userInfoVOs[m]);
				}
			}
			
			trace("MSService.updateUsers() dispatching MSEvent.USERS_OBJ_UPDATE)");	
			var msEvent:MSEvent = new MSEvent(MSEvent.USERS_OBJ_UPDATE);
			msEvent.userInfoVO_array = dataProxy.userInfoVO_array;
			msEvent.local_userInfoVO = dataProxy.local_userInfoVO;
			dispatch(msEvent);
		}
		
		private function setupNetStream():void
		{
			_netStream = new NetStream(_netConnection);
			_netStream.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
		}
		
		public function netStatusHandler(e:NetStatusEvent):void
		{
			trace("MSService.netStatusHandler() e.info.code: "+e.info.code);
			switch(e.info.code){
				
				// TODO MSEvent.NETCONNECTION_DISCONNECTED is not mediated
				case "NetConnection.Connect.Closed":
					dispatch(new MSEvent(MSEvent.NETCONNECTION_DISCONNECTED));
					break;
				case "NetConnection.Connect.Rejected":
					dispatch(new MSEvent(MSEvent.NETCONNECTION_DISCONNECTED));
					break;
				case "NetConnection.Connect.Success":
					setupNetStream();
					updateUserInfo();
					dispatch(new MSEvent(MSEvent.NETCONNECTION_CONNECTED));
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
	}
}
