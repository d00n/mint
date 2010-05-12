package com.infrno.multiplayer.model.vo
{
	import com.infrno.multiplayer.model.events.PeerEvent;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;

	public class UserInfoVO
	{
//		public var peer_capable				:Boolean;
		public var suid						:int;
		
		public var peer_connection_status	:String;
		public var uname					:String;
		public var nearID					:String;

		private var _ns						:NetStream;
		
		public function UserInfoVO(infoObj:Object=null)
		{
//			peer_capable = infoObj.peer_capable;
			peer_connection_status = PeerEvent.PEER_NETCONNECTION_CONNECTING;
			suid = infoObj.suid;
			uname = infoObj.uname;
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
					this[i] = info[i];
			}
		}
		
		private function handleNetStatus(e:NetStatusEvent):void
		{
			trace(uname+": "+e.info.code);
		}
	}
}