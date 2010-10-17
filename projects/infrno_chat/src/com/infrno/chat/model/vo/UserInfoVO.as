package com.infrno.chat.model.vo
{
	import com.infrno.chat.model.events.PeerEvent;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;

	public class UserInfoVO
	{
//		public var peer_capable				:Boolean;
		public var report_connection_status	:Boolean;

		public var suid						:int;
		
		public var peer_connection_status	:String;
		public var user_name				:String;
		public var user_id					:String;
		public var nearID					:String;

		private var _ns						:NetStream;
		
		public function UserInfoVO(userInfoObj:Object=null)
		{
//			peer_capable = userInfoObj.peer_capable;
			peer_connection_status = PeerEvent.PEER_NETCONNECTION_CONNECTING;
			suid = userInfoObj.suid;
			user_id = userInfoObj.user_id;
			user_name = userInfoObj.user_name;
		}
		
		public function get ns():NetStream
		{
			return _ns;
		}
		
		public function set ns(ns_in:NetStream):void
		{
			if(_ns && _ns.hasEventListener(NetStatusEvent.NET_STATUS)){
				_ns.close();
				_ns.removeEventListener(NetStatusEvent.NET_STATUS,handleNetStatus);
				_ns = null;
			}
			_ns = ns_in;
			_ns.addEventListener(NetStatusEvent.NET_STATUS,handleNetStatus);
		}
		
		public function updateInfo(info:Object):void
		{
			for(var i:String in info){
				if(info[i]!=null)
				{
					this[i] = info[i];
					trace("UserInfoVO.updateInfo()" +i+" = "+info[i]);
				}
			}
		}
		
		private function handleNetStatus(e:NetStatusEvent):void
		{
			trace("UserInfoVO.handleNetStatus() user_name=" +user_name+" : "+e.info.code);
		}
	}
}