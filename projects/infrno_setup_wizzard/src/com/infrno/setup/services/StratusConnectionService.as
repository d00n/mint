package com.infrno.setup.services
{
	import com.infrno.setup.model.events.StratusConnectionEvent;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	import org.robotlegs.mvcs.Actor;
	
	public class StratusConnectionService extends Actor
	{
		private var _nc				:NetConnection;
		private var _nc_client		:Object;
		
		public function StratusConnectionService()
		{
			super();
			setupNetConnectionClient();
			setupNetConnection();
		}
		
		public function call(method:String,returnFunction:Function,... params):void
		{
			params.unshift(method,returnFunction);
			_nc.call.apply(params);
		}
		
		public function close():void
		{
			_nc.close();
		}
		
		public function connect(uri:String,... params):void
		{
			dispatch(new StratusConnectionEvent(StratusConnectionEvent.STRATUSCONNECTION_CONNECTING));
			
			params.unshift(uri);
			_nc.connect.apply(this,params);
		}
		
		/**
		 * Private methods
		 */
		
		private function handleNetStatus(e:NetStatusEvent):void
		{
//			trace(e.info.code);
			switch (e.info.code){
				case "NetConnection.Connect.Success":
					dispatch(new StratusConnectionEvent(StratusConnectionEvent.STRATUSCONNECTION_CONNECTED));
					break;
				case "NetConnection.Connect.Rejected":
				case "NetConnection.Connect.Failed":
					dispatch(new StratusConnectionEvent(StratusConnectionEvent.STRATUSCONNECTION_DISCONNECTED));
					break;
			}
		}
		
		private function setupNetConnection():void
		{
			_nc = new NetConnection();
			_nc.client = _nc_client;
			
			_nc.addEventListener(NetStatusEvent.NET_STATUS,handleNetStatus);
		}
		
		private function setupNetConnectionClient():void
		{
			_nc_client = new Object();
		}
	}
}