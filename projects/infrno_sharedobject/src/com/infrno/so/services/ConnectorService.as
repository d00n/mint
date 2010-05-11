package com.infrno.so.services
{
	import com.infrno.so.model.events.SOUpdateEvent;
	
	import flash.events.NetStatusEvent;
	import flash.events.SyncEvent;
	import flash.net.NetConnection;
	import flash.net.SharedObject;
	
	import org.robotlegs.mvcs.Actor;
	
	public class ConnectorService extends Actor
	{
		private var _nc			:NetConnection;
		private var _so			:SharedObject;
		
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
		
		public function get so():SharedObject
		{
			return _so;
		}
		
		private function handleNetStatus(e:NetStatusEvent):void
		{
			trace(e.info.code);
			switch (e.info.code){
				case "NetConnection.Connect.Success":
					setupSO();
					break;
			}
		}
			
		private function setupSO():void
		{
			_so = SharedObject.getRemote("updater",_nc.uri,true);
			_so.addEventListener(SyncEvent.SYNC,handleSync);
			_so.connect(_nc);
		}
		
		private function handleSync(e:SyncEvent):void
		{
//			trace("so synced");
			
			//clear
			//success
			//reject
			//change
			//delete
			
			for(var i:String in e.changeList){
//				trace(e.changeList[i].code);
				switch(e.changeList[i].code){
					case "change":
						dispatch(new SOUpdateEvent(SOUpdateEvent.PROPERTY_UPDATE,{"prop":e.changeList[i].name,"value":_so.data[e.changeList[i].name]}));
						break;
					case "clear":
						_so.setProperty("hello","world");
						break;
				}
			}
		}
	}
}