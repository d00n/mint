package com.infrno.so.model
{
	import com.infrno.so.model.events.NetConnectionEvent;
	import com.infrno.so.model.events.SOUpdateEvent;
	import com.infrno.so.services.ConnectorService;
	
	import flash.events.SyncEvent;
	import flash.net.SharedObject;
	
	import org.robotlegs.mvcs.Actor;
	
	public class SharedObjectProxy extends Actor
	{
		[Inject]
		public var connectorService			:ConnectorService;
		
		private var _so			:SharedObject;
		
		public function SharedObjectProxy()
		{
			super();
//			eventDispatcher.addEventListener(NetConnectionEvent.NETCONNECTION_CONNECTED,initSharedObject);
		}
		
		public function get so():SharedObject
		{
			return _so;
		}
		
		public function initSharedObject():void
		{
			_so = SharedObject.getRemote("updater",connectorService.nc.uri,true);
			_so.addEventListener(SyncEvent.SYNC,handleSync);
			_so.connect(connectorService.nc);
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