package com.infrno.so.services
{
	import com.infrno.so.model.events.NetConnectionEvent;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	import org.robotlegs.mvcs.Actor;
	
	public class ConnectorService extends Actor
	{
		private var _nc			:NetConnection;
		
		public function ConnectorService()
		{
			super();
		}
		
		public function connect():void
		{
			_nc = new NetConnection();
			_nc.connect("rtmp://gearsandcogs.com/test");
			_nc.addEventListener(NetStatusEvent.NET_STATUS,handleNetStatus);
		}
		
		public function get nc():NetConnection
		{
			return _nc;
		}
		
		private function handleNetStatus(e:NetStatusEvent):void
		{
			trace(e.info.code);
			switch (e.info.code){
				case "NetConnection.Connect.Success":
					dispatch(new NetConnectionEvent(NetConnectionEvent.NETCONNECTION_CONNECTED));
					break;
			}
		}
	}
}