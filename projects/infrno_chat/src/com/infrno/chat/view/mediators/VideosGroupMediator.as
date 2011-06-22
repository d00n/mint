package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.SettingsEvent;
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.NetStreamMS;
	import com.infrno.chat.services.NetStreamPeer;
	import com.infrno.chat.view.components.Sparkline;
	import com.infrno.chat.view.components.VideoPresence;
	import com.infrno.chat.view.components.VideosGroup;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.logging.Log;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.components.List;
	
	public class VideosGroupMediator extends Mediator
	{
		// TODO: I don't think Mediators should depend on Models. 
		[Inject]
		public var deviceProxy:DeviceProxy;
		
		[Inject]
		public var videosGroup:VideosGroup;	
		
		// Needed for logging to server, not sure yet if I like logging here
		[Inject]
		public var msService:MSService;
		
		private var _local_videoPresence:VideoPresence;
		
		private var _disconnectedMicAlert_is_visible:Boolean = false;
		
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,MSEvent.USERS_OBJ_UPDATE,usersUpdated);
			eventMap.mapListener(eventDispatcher,VideoPresenceEvent.SETUP_PEER_VIDEOPRESENCE_COMPONENT,setupPeerVideoPresenceComponent);
			
			// TODO map these after the sparklines are ready
			// ..or figure out where to create sparklines better/earlier
			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_CLIENT_STATS,displayPeerStats);
			eventMap.mapListener(eventDispatcher,StatsEvent.DISPLAY_SERVER_STATS,displayServerStats);
			
			videosGroup.addEventListener(SettingsEvent.SHOW_SETTINGS,handleShowSettings);
			videosGroup.addEventListener(VideoPresenceEvent.AUDIO_LEVEL,dispatchEventInSystem);
			videosGroup.addEventListener(VideoPresenceEvent.AUDIO_MUTED,dispatchEventInSystem);
			videosGroup.addEventListener(VideoPresenceEvent.AUDIO_UNMUTED,dispatchEventInSystem);
			videosGroup.addEventListener(VideoPresenceEvent.VIDEO_MUTED,dispatchEventInSystem);
			videosGroup.addEventListener(VideoPresenceEvent.VIDEO_UNMUTED,dispatchEventInSystem);
			
			eventMap.mapListener(eventDispatcher,VideoPresenceEvent.SHOW_NETWORK_GRAPHS,showNetworkGraphs);
			eventMap.mapListener(eventDispatcher,VideoPresenceEvent.HIDE_NETWORK_GRAPHS,hideNetworkGraphs);
			
			eventMap.mapListener(eventDispatcher,VideoPresenceEvent.SHOW_MIC_DISCONNECTED,handleUnhookedMic);
		}
		
		private function dispatchEventInSystem(e:VideoPresenceEvent):void
		{
			dispatch(new VideoPresenceEvent(e.type,e.bubbles,e.value));
		}
		
		public function handleShowSettings( settingsEvent:SettingsEvent ):void
		{
			dispatch( new SettingsEvent( settingsEvent.type ) );
		}
		
		private function showNetworkGraphs(e:VideoPresenceEvent):void
		{
			trace("showNetworkGraphs");
			var videoPresence:VideoPresence;
			var dataProviderLength:int = videosGroup.videosGroup_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
				videoPresence = videosGroup.videosGroup_list.dataProvider.getItemAt(i) as VideoPresence;
				videoPresence.sparkline.visible = true;
			}
		}		
		
		private function hideNetworkGraphs(e:VideoPresenceEvent):void
		{
			trace("hideNetworkGraphs");
			var videoPresence:VideoPresence;
			var dataProviderLength:int = videosGroup.videosGroup_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
				videoPresence = videosGroup.videosGroup_list.dataProvider.getItemAt(i) as VideoPresence;
				videoPresence.sparkline.visible = false;
			}
		}		
		
		private function handleUnhookedMic(e:VideoPresenceEvent):void
		{
			trace("showMicDisconnected");
//			dispatchEventInSystem(new VideoPresenceEvent(VideoPresenceEvent.AUDIO_UNMUTED,true));
//			
//			if (!_disconnectedMicAlert_is_visible) {
//				_disconnectedMicAlert_is_visible = true;
//				Alert.show("This is a bug, and it is nervous, because it feels my boots coming closer.\n\nYour microphone is now connected, and unmuted.\n\nAfter your game, do your duty! Report how often you saw this message to feedback@infrno.net.\n\nHoorah!", 
//					"Your microphone was disconnected.", mx.controls.Alert.OK, contextView.parent as Sprite, closeMicDisconnectAlert);
//			}
//			
//			_local_videoPresence.audioToggle_selected = false;
			
			if (_local_videoPresence.audioToggle_selected == false)
				msService.sendLogMessageToServer("deviceProxy.mic_level == -1");
		}			
		
		private function closeMicDisconnectAlert(e:Event):void{
			_disconnectedMicAlert_is_visible = false;
		}
		
		private function usersUpdated(msEvent:MSEvent):void
		{
			removeStaleVideos(msEvent.userInfoVO_array, msEvent.local_userInfoVO);
			addNewVideos(msEvent.userInfoVO_array, msEvent.local_userInfoVO);
		}
		
		private function removeStaleVideos(userInfoVO_array:Array, local_userInfoVO:UserInfoVO):void
		{
			var dataProviderLength:int = videosGroup.videosGroup_list.dataProvider.length;
			for(var i:int = 0; i<dataProviderLength; i++){
				try{					
					var videoPresence:VideoPresence = videosGroup.videosGroup_list.dataProvider.getItemAt(i) as VideoPresence;
					if(userInfoVO_array[videoPresence.name] == null){
						var vp_index:int = videosGroup.videosGroup_list.dataProvider.getItemIndex(videoPresence);
						trace("VideosGroupMediator.removeStaleVideos() removing videoPresence.name="+videoPresence.name);
						videosGroup.videosGroup_list.dataProvider.removeItemAt(vp_index);
					}
				}catch(e:Object){
					//out of range error I'm sure
					// TODO Make sure we don't get out of range errors
					// Things work just fine, but how does this state occur?
					trace("VideosGroupMediator.removeStaleVideos() error:" +e.toString());
				}
			}
		}
				
		// TODO rename to getVideoPresence()
		private function getVideoPresenceBySuid(suid:String): VideoPresence{
			var videoPresence:VideoPresence;
			var dataProviderLength:int = videosGroup.videosGroup_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
				videoPresence = videosGroup.videosGroup_list.dataProvider.getItemAt(i) as VideoPresence;
				if (videoPresence.name == suid) {
					return videoPresence;
				}
			}
			return null;
		}
		
//		private function onVideoPresenceCreationComplete(e:FlexEvent):void{
//			var videoPresence:VideoPresence = e.target as VideoPresence;
//			if(videoPresence.is_local){
//				setupLocalVideoPresenceComponent(videoPresence);
//			} else {
//				setupPeerVideoPresenceNetStream(videoPresence);
//			}
//		}
		
		private function addNewVideos(userInfoVO_array:Array, local_userInfoVO:UserInfoVO):void {
			
			for(var suid:String in userInfoVO_array){
				trace("VideosGroupMediator.addNewVideos() working with suid="+suid);
				var userInfoVO:UserInfoVO = userInfoVO_array[suid];
				
				var videoPresence:VideoPresence = getVideoPresenceBySuid(suid);
				
				if(videoPresence == null){
					trace("VideosGroupMediator.addNewVideos() adding new VideoPresence for suid="+suid);
					
					videoPresence = new VideoPresence();
					videosGroup.videosGroup_list.dataProvider.addItem(videoPresence);
					
					videoPresence.userInfoVO = userInfoVO;
					
					// TODO this smells. Pick one and stick with it.
					videoPresence.name = userInfoVO.suid.toString();
					
					if (userInfoVO.suid == local_userInfoVO.suid) {
						videoPresence.is_local = true;
						_local_videoPresence = videoPresence;
					} else {
						videoPresence.is_local = false;
					}
					
					// removing this prevents new peers from showing up.
					// flipping from p2p to server mode will bring them up
					// XXX 6/16 works w/o it locally, but not on staging
					videoPresence.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
						{
							trace("VideosGroupMediator.addNewVideos() VideoPresence FlexEvent.CREATION_COMPLETE event listener")
							
							var videoPresence:VideoPresence = e.target as VideoPresence;
							if(videoPresence.is_local){
								setupLocalVideoPresenceComponent(videoPresence);
							} else {
								setupPeerVideoPresenceNetStream(videoPresence);
							}
						});
					
				} else {
					trace("VideosGroupMediator.addNewVideos() found existing VideoPresence for suid="+suid);
					
					if(videoPresence.initialized) {	
						// TODO wtf? 
						// Without this code, the peer netstream does not work.
						if(videoPresence.is_local){
							trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>> VideosGroupMediator.addNewVideos() calling setupLocalVideoPresenceComponent() for suid="+ videoPresence.userInfoVO.suid);
							setupLocalVideoPresenceComponent(videoPresence);
						} else {
							trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>> VideosGroupMediator.addNewVideos() calling setupPeerVideoPresenceNetStream() for suid="+ videoPresence.userInfoVO.suid);
							setupPeerVideoPresenceNetStream(videoPresence);
						}					
					}
				}				
			}
			
			trace("VideosGroupMediator.addNewVideos() exiting");
		}
		
		private function setupLocalVideoPresenceComponent(videoPresence:VideoPresence):void
		{
			trace("VideosGroupMediator.setupLocalVideoPresenceComponent()");
			videoPresence.camera = deviceProxy.camera;

			videoPresence.audio_level_value = deviceProxy.mic.gain;
			
			videoPresence.playVideo();
			videoPresence.playAudio();
		}
		
		private function setupPeerVideoPresenceNetStream(videoPresence:VideoPresence):void
		{
			trace("VideosGroupMediator.setupPeerVideoPresenceNetStream() videoPresence.userInfoVO.suid:"+videoPresence.userInfoVO.suid);	
			
			// Mediated by InitPeerNetStreamCommand
			var vpEvent:VideoPresenceEvent = new VideoPresenceEvent(VideoPresenceEvent.SETUP_PEER_NETSTREAM);
			vpEvent.userInfoVO = videoPresence.userInfoVO;
			dispatch(vpEvent);			
		}
		
		private function setupPeerVideoPresenceComponent(vpEvent:VideoPresenceEvent):void
		{
			trace("VideosGroupMediator.setupPeerVideoPresenceComponent()");
			var userInfoVO:UserInfoVO = vpEvent.userInfoVO;
			var videoPresence:VideoPresence = getVideoPresenceBySuid(userInfoVO.suid.toString());			
			
			if (videoPresence.isInitialized()) {
				videoPresence.netstream = userInfoVO.netStream;
				videoPresence.audio_level_value = userInfoVO.netStream.soundTransform.volume*100
				videoPresence.playVideo();
				videoPresence.playAudio();			
			}
		}
		
		private function displayPeerStats(statsEvent:StatsEvent):void
		{
//			trace("VideosGroupMediator.displayPeerStats()");
			var peerStatsVO:StatsVO;
			var peerStatsRecord:Object;
			var peer_suid:String;
			for (peer_suid in statsEvent.client_peerStatsVO_array) {
				peerStatsVO = statsEvent.client_peerStatsVO_array[peer_suid];				
				
				var videoPresence:VideoPresence = getVideoPresenceBySuid(peer_suid);		
				
				if (videoPresence == null || videoPresence.sparkline == null) {
					trace("VideosGroupMediator.displayPeerStats() videoPresence or videoPresence.sparkline is null !!!!!!!!!!!!!!!!!!");
					return;
				}
				
				if (videoPresence.is_local) {
					return;
				}
				
				videoPresence.sparkline.statsVO = peerStatsVO;
				videoPresence.sparkline.yFieldName = 'srtt';
				videoPresence.sparkline.lastValuePrefix = "Ping";
				var last_value:int = peerStatsVO.lastDataRecord[videoPresence.sparkline.yFieldName];
				videoPresence.sparkline.lastValue_label = videoPresence.sparkline.lastValuePrefix +": "+ last_value;
				
				if (last_value < Sparkline.MAX_SRTT) {
//					videoPresence.sparkline.lineStrokeColor = Sparkline.GREEN; 
					videoPresence.sparkline.lastValue_label_id.setStyle("color", Sparkline.BLACK); 
				} else {
//					videoPresence.sparkline.lineStrokeColor = Sparkline.RED;
					videoPresence.sparkline.lastValue_label_id.setStyle("color", Sparkline.RED);
				}
			}			
		}
		
		private function displayServerStats(statsEvent:StatsEvent):void
		{
//			var videoPresence:VideoPresence = getVideoPresenceBySuid(_local_videoPresence.name);
			
			if (_local_videoPresence == null || _local_videoPresence.sparkline == null) {
				trace("VideosGroupMediator.displayServerStats()  _local_videoPresence or _local_videoPresence.sparkline is null !!!!!!!!!!!!!!!!!!");
				return;
			}
			
			// TODO change name to suid
			var serverStatsVO:StatsVO = statsEvent.server_clientStatsVO_array[_local_videoPresence.name];			
			
			_local_videoPresence.sparkline.statsVO = serverStatsVO;
			_local_videoPresence.sparkline.yFieldName = 'PingRoundTripTime';
			_local_videoPresence.sparkline.lastValuePrefix = "Ping";
			var last_value:int = serverStatsVO.lastDataRecord[_local_videoPresence.sparkline.yFieldName];
			_local_videoPresence.sparkline.lastValue_label = _local_videoPresence.sparkline.lastValuePrefix +": "+ last_value;
			
			/* TODO Something very strange is happening when lineStrokeColor is set below
			 When flipping between colors, it appears as if there are two graphs. 
			 One full of the high values, and the other full of low values. 
			 Furthermore, the graphs are slightly out of step with what god mode shows.
			Trends are accurate, but they're not showing precisely the same data. 
			Not sure how that's possible, since the Command receiving the data sends it to 
			both this mediator and StatsMediator. it's the same data....
			
			More: All graphs appear to be sharing one set of data for green/black, and appropriate data for red. Maybe.
			*/
			if (last_value < Sparkline.MAX_SRTT) {
//				_local_videoPresence.sparkline.lineStrokeColor = Sparkline.GREEN; 
				_local_videoPresence.sparkline.lastValue_label_id.setStyle("color", Sparkline.BLACK);
			} else {
//				_local_videoPresence.sparkline.lineStrokeColor = Sparkline.RED;
				_local_videoPresence.sparkline.lastValue_label_id.setStyle("color", Sparkline.RED);
			}
			
		}		
		
	}
}
