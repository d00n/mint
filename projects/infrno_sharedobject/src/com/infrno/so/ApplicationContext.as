package com.infrno.so
{
	import com.infrno.so.controller.*;
	import com.infrno.so.model.*;
	import com.infrno.so.model.events.*;
	import com.infrno.so.services.ConnectorService;
	import com.infrno.so.view.components.Boxes;
	import com.infrno.so.view.mediators.BoxesMediator;
	
	import flash.display.DisplayObjectContainer;
	
	import org.robotlegs.base.ContextEvent;
	import org.robotlegs.mvcs.Context;
	
	public class ApplicationContext extends Context
	{
		public function ApplicationContext()
		{
			super();
		}
		
		override public function startup():void
		{
			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE,ConnectServerCommand);
			commandMap.mapEvent(BoxUpdateEvent.PROPERTY_UPDATE,UpdateSOCommand);
			commandMap.mapEvent(NetConnectionEvent.NETCONNECTION_CONNECTED,ConnectSOCommand);
			
			mediatorMap.mapView(Boxes,BoxesMediator);
			
			injector.mapSingleton(SharedObjectProxy);
			
			injector.mapSingleton(ConnectorService);
			super.startup();
		}
	}
}