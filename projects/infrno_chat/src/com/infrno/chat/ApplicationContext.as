package com.infrno.chat
{
	import com.infrno.chat.controller.*;
	import com.infrno.chat.model.*;
	import com.infrno.chat.model.events.*;
	import com.infrno.chat.services.*;
	import com.infrno.chat.view.components.*;
	import com.infrno.chat.view.mediators.*;
	
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
			//Controller
			commandMap.mapEvent(ChatEvent.SEND_CHAT,SendChatCommand);

			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE, InitLocalVarsCommand);
			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE, ContextMenuSetupCommand);
			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE, ConnectMediaServerCommand);
			
			commandMap.mapEvent(MSEvent.GET_USER_STATS, ReportUserStatsCommand);
			commandMap.mapEvent(MSEvent.NETCONNECTION_CONNECTED,ConnectPeerServerCommand);
			commandMap.mapEvent(MSEvent.USERS_OBJ_UPDATE,ContextMenuSetupCommand);
			
			commandMap.mapEvent(PeerEvent.PEER_DISABLE_VIDEO,VideoSourceCommand);
			commandMap.mapEvent(PeerEvent.PEER_ENABLE_VIDEO,VideoSourceCommand);
			commandMap.mapEvent(PeerEvent.PEER_NETCONNECTION_CONNECTED,ReportPeerConnectionStatusCommand);
			commandMap.mapEvent(PeerEvent.PEER_NETCONNECTION_DISCONNECTED,ReportPeerConnectionStatusCommand);
			
			commandMap.mapEvent(VideoPresenceEvent.AUDIO_LEVEL,AudioVideoControlCommand);
			commandMap.mapEvent(VideoPresenceEvent.AUDIO_MUTED,AudioVideoControlCommand);
			commandMap.mapEvent(VideoPresenceEvent.AUDIO_UNMUTED,AudioVideoControlCommand);
			commandMap.mapEvent(VideoPresenceEvent.VIDEO_MUTED,AudioVideoControlCommand);
			commandMap.mapEvent(VideoPresenceEvent.VIDEO_UNMUTED,AudioVideoControlCommand);
			commandMap.mapEvent(VideoPresenceEvent.SETUP_PEER_NETSTREAM,SetupPeerNetStreamCommand);

			commandMap.mapEvent(SettingsEvent.SHOW_SETTINGS,SettingsCommand);			
			
			//Model
			// mapSingleton provides 1 instance of the requested class for N injections.
			injector.mapSingleton(DataProxy);
			injector.mapSingleton(DeviceProxy);
			
			//Services
			injector.mapSingleton(MSService);
			injector.mapSingleton(PeerService);
			
			//View
			mediatorMap.mapView(Chat,ChatMediator);
			mediatorMap.mapView(Videos,VideosMediator);
			
//			mediatorMap.mapView(ControlButtons,ControlButtonsMediator);
			
			//Startup Commencing
//			dispatchEvent(new ContextEvent(ContextEvent.STARTUP, StartupCommand));

			//Startup Complete
			super.startup();
		}
	}
}