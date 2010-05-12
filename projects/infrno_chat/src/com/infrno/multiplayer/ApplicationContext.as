package com.infrno.multiplayer
{
	import com.infrno.multiplayer.controller.*;
	import com.infrno.multiplayer.model.*;
	import com.infrno.multiplayer.model.events.*;
	import com.infrno.multiplayer.services.*;
	import com.infrno.multiplayer.view.components.*;
	import com.infrno.multiplayer.view.mediators.*;
	
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

//			commandMap.mapEvent(ContextEvent.STARTUP, StartupCommand);
			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE, InitLocalVarsCommand);
			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE, ContextMenuSetupCommand);
			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE, ConnectMediaServerCommand);
			
			commandMap.mapEvent(MSEvent.GET_USER_STATS, ReportStatsCommand);
			commandMap.mapEvent(MSEvent.NETCONNECTION_CONNECTED,ConnectPeerServerCommand);
			
			commandMap.mapEvent(PeerEvent.PEER_DISABLE_VIDEO,VideoSourceCommand);
			commandMap.mapEvent(PeerEvent.PEER_ENABLE_VIDEO,VideoSourceCommand);
			commandMap.mapEvent(PeerEvent.PEER_NETCONNECTION_CONNECTED,PeerConnectionStatusCommand);
			commandMap.mapEvent(PeerEvent.PEER_NETCONNECTION_DISCONNECTED,PeerConnectionStatusCommand);
			
			commandMap.mapEvent(VideoPresenseEvent.AUDIO_LEVEL,AudioVideoControlCommand);
			commandMap.mapEvent(VideoPresenseEvent.AUDIO_MUTED,AudioVideoControlCommand);
			commandMap.mapEvent(VideoPresenseEvent.AUDIO_UNMUTED,AudioVideoControlCommand);
			commandMap.mapEvent(VideoPresenseEvent.VIDEO_MUTED,AudioVideoControlCommand);
			commandMap.mapEvent(VideoPresenseEvent.VIDEO_UNMUTED,AudioVideoControlCommand);
			
			
			//Model
			injector.mapSingleton(DataProxy);
			injector.mapSingleton(DeviceProxy);
			
			//Services
			injector.mapSingleton(MSService);
			injector.mapSingleton(PeerService);
			
			//View
			mediatorMap.mapView(Chat,ChatMediator);
			mediatorMap.mapView(Videos,VideosMediator);
			
			mediatorMap.mapView(ControlButtons,ControlButtonsMediator);
			mediatorMap.mapView(WhiteBoard,WhiteBoardMediator);
			
			//Startup Commencing
//			dispatchEvent(new ContextEvent(ContextEvent.STARTUP, StartupCommand));

			//Startup Complete
			super.startup();
		}
	}
}