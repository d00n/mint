package com.infrno.chat.services
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.ChatEvent;
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.PeerEvent;
	import com.infrno.chat.model.vo.UserInfoVO;
	
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Actor;
	
	public class MSService extends Actor
	{
		[Inject]
		public var dataProxy		:DataProxy;
		
		[Inject]
		public var deviceProxy		:DeviceProxy;
		
		private var _publishing		:Boolean;
		
		private var _nc				:NetConnection;
		private var _ns				:NetStream;
		private var _nc_client		:Object;
		
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
			trace("MSService.connect() connecting to media server: "
				+dataProxy.media_server+"/"+dataProxy.room_id);
			
			trace("MSService.connect() dataProxy params available:" 
				+ dataProxy.room_name 
				+":"+ dataProxy.user_name 
				+":"+ dataProxy.room_id 
				+":"+ dataProxy.auth_key);
		
			dispatch(new MSEvent(MSEvent.NETCONNECTION_CONNECTING));
			_nc.connect(dataProxy.media_server+"/"+dataProxy.room_id, 
				dataProxy.my_info, 
				dataProxy.auth_key,
				dataProxy.room_id,
				dataProxy.room_name, 
				dataProxy.user_name);
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
			var ns:NetStreamMS = new NetStreamMS(_nc);
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
			trace("MSService.reportUserStats()");
			_nc.call("reportUserStats",null,statsIn);
		}
		
		public function updatePublishStream():void
		{
			if(!dataProxy.use_peer_connection){
				if(!_publishing){
					trace("MSService.updatePublishStream() ### publishing my server stream with name: "+dataProxy.my_info.suid.toString());
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
			_nc.call("updateUserInfo",null,dataProxy.my_info);
		}
		
		/**
		 * Private methods
		 */
		
		private function netStatusHandler(e:NetStatusEvent):void
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
		
		private function setupClient():void
		{
			_nc_client = new Object();
			_nc_client.initUser = function(user_info:Object):void
			{
//				dataProxy.my_info = new UserInfoVO(user_info);
				dataProxy.my_info.updateInfo(user_info);
			}
			_nc_client.chatToUser = function(msgIn:String):void
			{
				dispatch(new ChatEvent(ChatEvent.RECEIVE_CHAT,msgIn));
			}
			_nc_client.getUserStats = function():void
			{
				dispatch(new MSEvent(MSEvent.GET_USER_STATS));
			}
			_nc_client.usePeerConnection = function(usePeer:Boolean):void
			{
				if(usePeer){
					dispatch(new PeerEvent(PeerEvent.PEER_ENABLE_VIDEO));
				} else {
					dispatch(new PeerEvent(PeerEvent.PEER_DISABLE_VIDEO));
				}
			}
			_nc_client.updateUsers = updateUsers;
		}
		
		private function updateUsers(users_obj:Object):void
		{
			trace("MSService.updateUsers() users object has been updated");
			
			//removing data
			for(var n:String in dataProxy.users_collection)
			{
				if(users_obj[n] == null)
					delete dataProxy.users_collection[n];
			}
			
			//adding/updating info
			for(var i:String in users_obj){
				if(dataProxy.users_collection[i] == null){
					dataProxy.users_collection[i] = new UserInfoVO(users_obj[i]);
				} else {
					dataProxy.users_collection[i].updateInfo(users_obj[i]);
				}
			}
			
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
