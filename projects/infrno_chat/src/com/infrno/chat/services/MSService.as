package com.infrno.chat.services
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.ChatEvent;
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.PeerEvent;
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
		private var _nc:NetConnection;
		private var _ns:NetStream;
		private var _nc_client:Object;
		
		public function MSService()
		{
			super();
			setupClient();
			setupNetConnection();
		}
		
		public function chatToServer(msgIn:String, targetUsers:Array=null):void
		{
			trace("MSService.chatToServer() sending this chat to the server: "+msgIn);
			_nc.call("chatToServer",null,msgIn,targetUsers);
		}
		
		public function connect():void
		{
			var connection_uri:String = dataProxy.media_server +":"+ dataProxy.media_port +"/"+ dataProxy.media_app +"/"+ dataProxy.room_id;
			
			trace("MSService.connect() connection_uri="+connection_uri);
			
			trace("MSService.connect() dataProxy params:" 
				+ dataProxy.room_name 
				+":"+ dataProxy.my_info.user_name 
				+":"+ dataProxy.room_id 
				+":"+ dataProxy.auth_key);
			
//			dispatch(new MSEvent(MSEvent.NETCONNECTION_CONNECTING));
			
			_nc.connect(connection_uri, 
				dataProxy.my_info, 
				dataProxy.auth_key,
				dataProxy.room_id,
				dataProxy.room_name, 
				dataProxy.media_app,
				DataProxy.VERSION,
				Capabilities.serverString);
		}
		
		public function get nc():NetConnection
		{
			return _nc;
		}
		
		public function get ns():NetStream
		{
			return _ns;
		}
		
		public function getNewNetStream():NetStreamMS
		{
			
			var ns_client:Object = new Object();
			ns_client.onPlayStatus = function(e:Object):void{};
			ns_client.onMetaData = function(e:Object):void{};
			
			var ns:NetStreamMS = new NetStreamMS(_nc);
			ns.client = ns_client;
			ns.addEventListener(NetStatusEvent.NET_STATUS,function(e:NetStatusEvent):void{}); //provided to avoid runtime error
			return ns;
		}
		
		public function getUserStats():void
		{
			trace("MSService.getUserStats()");
			_nc.call("getUserStats",null);
		}
		
		public function reportUserStats(statsIn:Object):void
		{
			//			trace("MSService.reportUserStats()");
			_nc.call("reportUserStats",null,statsIn);
		}
		
		public function updatePublishStream():void
		{
			// TODO write test around this, then flip the if blocks to eliminate the negation 
			if(!dataProxy.use_peer_connection){
				if(!_published){
					trace("MSService.updatePublishStream() ### publishing my server stream with dataProxy.my_info.suid: "+dataProxy.my_info.suid.toString());
					
					if(dataProxy.pubishing_audio)
						_ns.attachAudio(deviceProxy.mic);
					
					if(dataProxy.pubishing_video)
						_ns.attachCamera(deviceProxy.camera);
					
					_ns.publish(dataProxy.my_info.suid.toString());
					
					dataProxy.ns = _ns;
				} else {
					trace("MSService.updatePublishStream() ### already publishing my server stream");
				}
			} else {
				trace("MSService.updatePublishStream() ### closing server publish stream");
				_ns.close();
			}
		}
		
		public function updateUserInfo():void
		{
			trace("MSService.updateUserInfo() typeof(dataProxy.my_info)="+typeof(dataProxy.my_info));
			_nc.call("updateUserInfo",null,dataProxy.my_info);
		}
		
		/**
		 * Private methods
		 */
		
		public function netStatusHandler(e:NetStatusEvent):void
		{
			trace("MSService.netStatusHandler() Media: "+e.info.code);
			switch(e.info.code){
				
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
		
		private function setupClient():void
		{
			_nc_client = new Object();
			
			_nc_client.initUser = function(user_info:Object):void
				{
					//dataProxy.my_info = new UserInfoVO(user_info);
					trace("MSService:: _nc_client.initUser() user_info:" + user_info.toString());
					dataProxy.my_info.updateInfo(user_info);
				}
				
			_nc_client.chatToUser = function(msgIn:String):void {
					dispatch(new ChatEvent(ChatEvent.RECEIVE_CHAT,msgIn));
				}
				
			_nc_client.getUserStats = function():void {
					dispatch(new MSEvent(MSEvent.GET_USER_STATS));
				}
				
			_nc_client.usePeerConnection = function(usePeer:Boolean):void {
				if(usePeer){
					dispatch(new PeerEvent(PeerEvent.PEER_ENABLE_VIDEO));
				} else {
					dispatch(new PeerEvent(PeerEvent.PEER_DISABLE_VIDEO));
				}
			}
				
			_nc_client.updateUsers = updateUsers;
		}
		
		private function updateUsers(userInfoVO_array:Object):void
		{
			trace("MSService.updateUsers()");
			
			//removing data
			for(var n:String in dataProxy.userInfoVO_array)
			{
				trace("MSService.updateUsers() looking to delete n="+n);
				if(userInfoVO_array[n] == null)
					delete dataProxy.userInfoVO_array[n];
			}
			
			//adding/updating info
			for(var m:String in userInfoVO_array){
				trace("MSService.updateUsers() looking to add m="+m);				
				if(dataProxy.userInfoVO_array[m] == null){
					trace("MSService.updateUsers() creating new UserInfoVO for m="+m);				
					dataProxy.userInfoVO_array[m] = new UserInfoVO(userInfoVO_array[m]);
				} else {
					trace("MSService.updateUsers() updating UserInfoVO for m="+m);				
					dataProxy.userInfoVO_array[m].updateInfo(userInfoVO_array[m]);
				}
			}
			
			trace("MSService.updateUsers() dispatching MSEvent.USERS_OBJ_UPDATE)");	
			dispatch(new MSEvent(MSEvent.USERS_OBJ_UPDATE));
		}
		
		private function setupNetConnection():void
		{
			_nc = new NetConnection();
			_nc.client = _nc_client;
			_nc.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
		}
		
		private function setupNetStream():void
		{
			_ns = new NetStream(_nc);
			_ns.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
		}
	}
}
