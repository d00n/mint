package com.infrno.chat
{
	import com.infrno.chat.controller.*;
	import com.infrno.chat.model.*;
	import com.infrno.chat.model.events.*;
	import com.infrno.chat.services.*;
	import com.infrno.chat.view.components.*;
	import com.infrno.chat.view.mediators.*;
	
	import flash.display.DisplayObjectContainer;
	
	import mx.states.OverrideBase;
	
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
//			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE, ContextMenuSetupCommand);
			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE, ConnectMediaServerCommand);
						
			commandMap.mapEvent(MSEvent.NETCONNECTION_CONNECTED,ConnectPeerServerCommand);
			commandMap.mapEvent(MSEvent.NETCONNECTION_CONNECTED,InitStatsProxyCommand);
			
			// TODO: Why do we recreate the context menu on user update?
			// Is it p2p status? Can that be controlled with a bound var?
			commandMap.mapEvent(MSEvent.USERS_OBJ_UPDATE,ContextMenuSetupCommand);
					
			// These are exclusively fired in response to server commands
			commandMap.mapEvent(PeerEvent.PEER_DISABLE_VIDEO,VideoSourceCommand);
			commandMap.mapEvent(PeerEvent.PEER_ENABLE_VIDEO,VideoSourceCommand);
			
			commandMap.mapEvent(PeerEvent.PEER_NETCONNECTION_CONNECTED,ReportPeerConnectionCommand);
			commandMap.mapEvent(PeerEvent.PEER_NETCONNECTION_DISCONNECTED,ReportPeerConnectionCommand);
			
			commandMap.mapEvent(StatsEvent.COLLECT_CLIENT_STATS, CollectClientStatsCommand);
			commandMap.mapEvent(StatsEvent.RECEIVE_CLIENT_STATS, ReceiveClientStatsCommand);
			commandMap.mapEvent(StatsEvent.RECEIVE_SERVER_STATS, ReceiveServerStatsCommand);
			commandMap.mapEvent(StatsEvent.SHOW_NETWORK_GOD_MODE, ShowStatsGroupCommand);
			commandMap.mapEvent(StatsEvent.HIDE_NETWORK_GOD_MODE, HideStatsGroupCommand);
			
			commandMap.mapEvent(VideoPresenceEvent.AUDIO_LEVEL,AudioVideoControlCommand);
			commandMap.mapEvent(VideoPresenceEvent.AUDIO_MUTED,AudioVideoControlCommand);
			commandMap.mapEvent(VideoPresenceEvent.AUDIO_UNMUTED,AudioVideoControlCommand);
			commandMap.mapEvent(VideoPresenceEvent.VIDEO_MUTED,AudioVideoControlCommand);
			commandMap.mapEvent(VideoPresenceEvent.VIDEO_UNMUTED,AudioVideoControlCommand);
			
			commandMap.mapEvent(VideoPresenceEvent.SETUP_PEER_NETSTREAM,InitPeerNetStreamCommand);

			commandMap.mapEvent(SettingsEvent.SHOW_SETTINGS,ShowSettingsCommand);			
			
//			commandMap.mapEvent(LogEvent.SEND_TO_SERVER,SendLogMessageCommand);

			
			//Models
			// mapSingleton provides 1 instance of the requested class for N injections.
			injector.mapSingleton(DataProxy);
			injector.mapSingleton(DeviceProxy);
			injector.mapSingleton(StatsProxy);
			
			//Services
			injector.mapSingleton(MSService);
			injector.mapSingleton(PeerService);
			
			//Views
			mediatorMap.mapView(InfrnoChat,InfrnoChatMediator);
			mediatorMap.mapView(VideosGroup,VideosGroupMediator);
			mediatorMap.mapView(Chat,ChatMediator);
			mediatorMap.mapView(StatsGroup, StatsGroupMediator);

			
			//Startup Commencing
//			dispatchEvent(new ContextEvent(ContextEvent.STARTUP, StartupCommand));

			//Startup Complete
			super.startup();
		}
		
		override public function shutdown():void {
			//Controller
			commandMap.unmapEvent(ChatEvent.SEND_CHAT,SendChatCommand);
			
			commandMap.unmapEvent(ContextEvent.STARTUP_COMPLETE, InitLocalVarsCommand);
			//			commandMap.unmapEvent(ContextEvent.STARTUP_COMPLETE, ContextMenuSetupCommand);
			commandMap.unmapEvent(ContextEvent.STARTUP_COMPLETE, ConnectMediaServerCommand);
			
			commandMap.unmapEvent(MSEvent.NETCONNECTION_CONNECTED,ConnectPeerServerCommand);
			commandMap.unmapEvent(MSEvent.NETCONNECTION_CONNECTED,InitStatsProxyCommand);
			
			// TODO: Why do we recreate the context menu on user update?
			// Is it p2p status? Can that be controlled with a bound var?
			commandMap.unmapEvent(MSEvent.USERS_OBJ_UPDATE,ContextMenuSetupCommand);
			
			// These are exclusively fired in response to server commands
			commandMap.unmapEvent(PeerEvent.PEER_DISABLE_VIDEO,VideoSourceCommand);
			commandMap.unmapEvent(PeerEvent.PEER_ENABLE_VIDEO,VideoSourceCommand);
			
			commandMap.unmapEvent(PeerEvent.PEER_NETCONNECTION_CONNECTED,ReportPeerConnectionCommand);
			commandMap.unmapEvent(PeerEvent.PEER_NETCONNECTION_DISCONNECTED,ReportPeerConnectionCommand);
			
			commandMap.unmapEvent(StatsEvent.COLLECT_CLIENT_STATS, CollectClientStatsCommand);
			commandMap.unmapEvent(StatsEvent.RECEIVE_CLIENT_STATS, ReceiveClientStatsCommand);
			commandMap.unmapEvent(StatsEvent.RECEIVE_SERVER_STATS, ReceiveServerStatsCommand);
			commandMap.unmapEvent(StatsEvent.SHOW_NETWORK_GOD_MODE, ShowStatsGroupCommand);
			commandMap.unmapEvent(StatsEvent.HIDE_NETWORK_GOD_MODE, HideStatsGroupCommand);
			
			commandMap.unmapEvent(VideoPresenceEvent.AUDIO_LEVEL,AudioVideoControlCommand);
			commandMap.unmapEvent(VideoPresenceEvent.AUDIO_MUTED,AudioVideoControlCommand);
			commandMap.unmapEvent(VideoPresenceEvent.AUDIO_UNMUTED,AudioVideoControlCommand);
			commandMap.unmapEvent(VideoPresenceEvent.VIDEO_MUTED,AudioVideoControlCommand);
			commandMap.unmapEvent(VideoPresenceEvent.VIDEO_UNMUTED,AudioVideoControlCommand);
			
			commandMap.unmapEvent(VideoPresenceEvent.SETUP_PEER_NETSTREAM,InitPeerNetStreamCommand);
			
			commandMap.unmapEvent(SettingsEvent.SHOW_SETTINGS,ShowSettingsCommand);			
			
			//			commandMap.unmapEvent(LogEvent.SEND_TO_SERVER,SendLogMessageCommand);
			
			
			//Models
			injector.unmap(DataProxy);
			injector.unmap(DeviceProxy);
			injector.unmap(StatsProxy);
			
			//Services
			injector.unmap(MSService);
			injector.unmap(PeerService);
			
			//Views
			mediatorMap.unmapView(InfrnoChat);
			mediatorMap.unmapView(VideosGroup);
			mediatorMap.unmapView(Chat);
			mediatorMap.unmapView(StatsGroup);
			
			
			super.shutdown()
		}

	}
}