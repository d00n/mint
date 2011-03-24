package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.SettingsEvent;
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.StatsVO;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.NetStreamMS;
	import com.infrno.chat.services.NetStreamPeer;
	import com.infrno.chat.view.components.Sparkline;
	import com.infrno.chat.view.components.VideoPresence;
	import com.infrno.chat.view.components.VideosGroup;
	
	import flash.display.DisplayObject;
	
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
		
		private var _local_videoPresence:VideoPresence;
		
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
						trace("VideosGroupMediator.removeStaleVideos() videoPresence.name="+videoPresence.name);
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
				
		private function getVideoPresenceByName(name:String): VideoPresence{
			var videoPresence:VideoPresence;
			var dataProviderLength:int = videosGroup.videosGroup_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
				videoPresence = videosGroup.videosGroup_list.dataProvider.getItemAt(i) as VideoPresence;
				if (videoPresence.name == name) {
					return videoPresence;
				}
			}
			return null;
		}
		
		private function onVideoPresenceCreationComplete(e:FlexEvent):void{
			var videoPresence:VideoPresence = e.target as VideoPresence;
			if(videoPresence.is_local){
				setupLocalVideoPresenceComponent(videoPresence);
			} else {
				setupPeerVideoPresenceNetStream(videoPresence);
			}
		}
		
		private function addNewVideos(userInfoVO_array:Array, local_userInfoVO:UserInfoVO):void {
			
			// What field in userInfoVO defines 'name' here?
			// Answer: suid
			for(var name:String in userInfoVO_array){
				var userInfoVO:UserInfoVO = userInfoVO_array[name];
				
				var videoPresence:VideoPresence = getVideoPresenceByName(name);
				if(videoPresence == null){
					trace("VideosGroupMediator.addNewVideos() adding new VideoPresence for name="+name);
					
					videoPresence = new VideoPresence();
					videosGroup.videosGroup_list.dataProvider.addItem(videoPresence);
					
					videoPresence.userInfoVO = userInfoVO;
					
					// TODO this smells. Pick one and stick with it.
					videoPresence.name = userInfoVO.suid.toString();
					
					// TODO push this comparison into the is_local attribute
					if (userInfoVO.suid == local_userInfoVO.suid) {
						videoPresence.is_local = true;
						_local_videoPresence = videoPresence;
					} else {
						videoPresence.is_local = false;
					}
					
					videoPresence.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
						{
							trace("VideosGroupMediator.updateVideos() VideoPresence FlexEvent.CREATION_COMPLETE event listener")
							
							var videoPresence:VideoPresence = e.target as VideoPresence;
							if(videoPresence.is_local){
								setupLocalVideoPresenceComponent(videoPresence);
							} else {
								setupPeerVideoPresenceNetStream(videoPresence);
							}
						});
					
				} else {
					trace("VideosGroupMediator.updateVideos() found existing VideoPresence for name="+name);
					
					// videoPresence is assigned, and not null.
					// why are we fetching this again? 
//					videoPresence = getElementbyName(videos.videos_holder, userInfoVO.suid.toString());
					
					if(!videoPresence.isInitialized()) {
						// what about the rest of the collection?
						return;
					}
							
					videoPresence.is_local = userInfoVO.suid == local_userInfoVO.suid;
					
					if(userInfoVO.suid == local_userInfoVO.suid){
						setupLocalVideoPresenceComponent(videoPresence);
					} else {
						setupPeerVideoPresenceNetStream(videoPresence);
					}					
				}				
			}
		}
		
		private function setupLocalVideoPresenceComponent(videoPresence:VideoPresence):void
		{
			trace("VideosGroupMediator.setupLocalVideoPresenceComponent()");
			videoPresence.is_local = true;
			videoPresence.camera = deviceProxy.camera;
			videoPresence.audio_level.value = deviceProxy.mic.gain;
//			videoPresence.audioLevel = deviceProxy.mic.gain;
			videoPresence.toggleAudio();
			videoPresence.toggleVideo();
		}
		
		private function setupPeerVideoPresenceNetStream(videoPresence:VideoPresence):void
		{
			trace("VideosGroupMediator.setupPeerVideoPresenceNetStream() videoPresence.userInfoVO.suid:"+videoPresence.userInfoVO.suid);			
			var vpEvent:VideoPresenceEvent = new VideoPresenceEvent(VideoPresenceEvent.SETUP_PEER_NETSTREAM);
			vpEvent.userInfoVO = videoPresence.userInfoVO;
			dispatch(vpEvent);			
		}
		
		private function setupPeerVideoPresenceComponent(vpEvent:VideoPresenceEvent):void
		{
			trace("VideosGroupMediator.setupPeerVideoPresenceComponent()");
			var userInfoVO:UserInfoVO = vpEvent.userInfoVO;
			var videoPresence:VideoPresence = getVideoPresenceByName(userInfoVO.suid.toString());			
			videoPresence.netstream = userInfoVO.netStream;
			videoPresence.toggleAudio();
			videoPresence.toggleVideo();
			
			try{
				videoPresence.audio_level.value = userInfoVO.netStream.soundTransform.volume*100
			} catch(e:Object){
				trace("VideosGroupMediator.setupPeerVideoPresenceComponent() setting videoPresence.audio_level.value threw an error: " + e.toString());
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
				
				var videoPresence:VideoPresence = getVideoPresenceByName(peer_suid);		
				
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
					videoPresence.sparkline.lineStrokeColor = Sparkline.GREEN; 
				} else {
					videoPresence.sparkline.lineStrokeColor = Sparkline.RED;
				}
			}			
		}
		
		private function displayServerStats(statsEvent:StatsEvent):void
		{
			if (_local_videoPresence == null)
				return;
			
			var serverStatsVO:StatsVO = statsEvent.server_clientStatsVO_array[_local_videoPresence.name];
			var videoPresence:VideoPresence = getVideoPresenceByName(_local_videoPresence.name);
			
			if (videoPresence == null || videoPresence.sparkline == null) {
				trace("VideosGroupMediator.displayServerStats()  videoPresence or videoPresence.sparkline is null !!!!!!!!!!!!!!!!!!");
				return;
			}
			
			videoPresence.sparkline.statsVO = serverStatsVO;
			videoPresence.sparkline.yFieldName = 'PingRoundTripTime';
			videoPresence.sparkline.lastValuePrefix = "Ping";
			var last_value:int = serverStatsVO.lastDataRecord[videoPresence.sparkline.yFieldName];
			videoPresence.sparkline.lastValue_label = videoPresence.sparkline.lastValuePrefix +": "+ last_value;
			
			if (last_value < Sparkline.MAX_SRTT) {
				videoPresence.sparkline.lineStrokeColor = Sparkline.GREEN; 
			} else {
				videoPresence.sparkline.lineStrokeColor = Sparkline.RED;
			}
			
		}		
		
	}
}
