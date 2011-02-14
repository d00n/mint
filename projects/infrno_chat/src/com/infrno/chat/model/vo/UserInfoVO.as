package com.infrno.chat.model.vo
{
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
//			peer_capable = infoObj.peer_capable;
			peer_connection_status = PeerEvent.PEER_NETCONNECTION_CONNECTING;
			suid = infoObj.suid;
			user_id = infoObj.user_id;
			user_name = infoObj.user_name;
		}
		
		public function get ns():NetStream
		{
			return _netStream;
		}
		
		public function set ns(netStream:NetStream):void
		{
			if(_netStream && _netStream.hasEventListener(NetStatusEvent.NET_STATUS)){
				_netStream.close();
				_netStream.removeEventListener(NetStatusEvent.NET_STATUS,handleNetStatus);
				_netStream = null;
			}
			_netStream = netStream;
			_netStream.addEventListener(NetStatusEvent.NET_STATUS,handleNetStatus);
		}
		
		public function updateInfo(info:Object):void
		{
			for(var i:String in info){
				if(info[i]!=null) {
					trace("UserInfoVO.updateInfo info["+i+"]=" +info[i]);
					this[i] = info[i];
				}
			}
		}
		
		private function handleNetStatus(e:NetStatusEvent):void
		{
			trace("UserInfoVO.handleNetStatus() user_name=" +user_name+" : "+e.info.code);
		}
	}
}