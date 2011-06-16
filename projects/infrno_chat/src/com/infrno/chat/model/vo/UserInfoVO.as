package com.infrno.chat.model.vo
{
	import com.infrno.chat.model.events.LogEvent;
	import com.infrno.chat.model.events.PeerEvent;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;

	public class UserInfoVO
	{
		
//		public var peer_capable				:Boolean;
		public var report_connection_status:Boolean;
		
		public var suid:int;		
		public var peer_connection_status:String;
		public var user_name:String;
		public var user_id:String;
		public var nearID:String;
		
		private var _netStream:NetStream;
		
		public function UserInfoVO(infoObj:Object=null)
		{
			for(var i:String in infoObj){
				if(infoObj[i]!=null) 
					trace("UserInfoVO constructor infoObj["+i+"]=" +infoObj[i]);
			}

//			peer_capable = infoObj.peer_capable;
			
			// TODO use updateObject() for initialization
			// Smells: Setting a value from an event const?
			peer_connection_status = PeerEvent.PEER_NETCONNECTION_CONNECTING;
			
			suid = infoObj.suid;
			user_id = infoObj.user_id;
			user_name = infoObj.user_name;
		}
		
		public function get netStream():NetStream
		{
			return _netStream;
		}
		
		public function set netStream(value:NetStream):void
		{
			if (_netStream == null) {
				trace("UserInfoVO.netStream: _netStream is null");
			} else {
				trace("UserInfoVO.netStream: _netStream is not null");
				trace("UserInfoVO.netStream: _netStream.hasEventListener(NetStatusEvent.NET_STATUS)="+_netStream.hasEventListener(NetStatusEvent.NET_STATUS));
			}		
				
			// InitPeerNetStreamCommand passes a new NetStream to this setter
			// This may be how stale peer connections are closed (unpublished?)
			if(_netStream && _netStream.hasEventListener(NetStatusEvent.NET_STATUS)){
				_netStream.close();
				_netStream.removeEventListener(NetStatusEvent.NET_STATUS,handleNetStatus);
				_netStream = null;
			}
			
			_netStream = value;
			_netStream.addEventListener(NetStatusEvent.NET_STATUS,handleNetStatus);
		}
		
		public function update(infoObj:Object):void
		{
			for(var i:String in infoObj){
				if(infoObj[i]!=null) {
					trace("UserInfoVO.updateInfo infoObj["+i+"]=" +infoObj[i]);
					this[i] = infoObj[i];
				}
			}
		}
		
		private function handleNetStatus(e:NetStatusEvent):void
		{
			trace("UserInfoVO.handleNetStatus() user_name=" +user_name+" : "+e.info.code);
			
			// TODO XXX log this to the server
			
//			var msg:String = "UserInfoVO.handleNetStatus() local="+user_name+" e.info.code=" +e.info.code;
//			dispatch(new LogEvent(LogEvent.SEND_TO_SERVER, "UserInfoVO.handleNetStatus()", "tbd", e.info.code));
		}
	}
}