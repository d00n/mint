package com.infrno.setup
{
	import com.infrno.setup.controller.*;
	import com.infrno.setup.model.DataProxy;
	import com.infrno.setup.model.DeviceProxy;
	import com.infrno.setup.model.events.MessageEvent;
	import com.infrno.setup.model.events.SettingsEvent;
	import com.infrno.setup.services.NetConnectionService;
	import com.infrno.setup.services.StratusConnectionService;
	import com.infrno.setup.view.components.*;
	import com.infrno.setup.view.mediators.*;
	
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
			//controller setup
//			commandMap.mapEvent(GenericEvent.SHOW_VIDEO,ToggleVideoCommand);

			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE, InitLocalVarsCommand);
			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE,ContextMenuSetupCommand);
			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE,TestNetworkCommand);
			
			commandMap.mapEvent(SettingsEvent.SHOW_CAMERA_SETTINGS,SettingsCommand);
			commandMap.mapEvent(SettingsEvent.SHOW_MIC_SETTINGS,SettingsCommand);
			commandMap.mapEvent(SettingsEvent.SHOW_SAVE_SETTINGS,SettingsCommand);
			
			commandMap.mapEvent(MessageEvent.ERROR,MessageCommand);
			commandMap.mapEvent(MessageEvent.INFORMATIVE,MessageCommand);
			commandMap.mapEvent(MessageEvent.WARNING,MessageCommand);
			
			//Model
			injector.mapSingleton(DataProxy);
			injector.mapSingleton(DeviceProxy);
			
			//Services
			injector.mapSingleton(NetConnectionService);
			injector.mapSingleton(StratusConnectionService);
			
			//view setup
			mediatorMap.mapView(TabSelection,TabSelectionMediator);
			mediatorMap.mapView(VideoHolder,VideoHolderMediator);
			mediatorMap.mapView(MicrophoneMeter, MicrophoneMeterMediator);
			
			//Startup complete
			super.startup();
		}
	}
}