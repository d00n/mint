package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.SettingsEvent;
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
		
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,MSEvent.USERS_OBJ_UPDATE,usersUpdated);
			eventMap.mapListener(eventDispatcher,VideoPresenceEvent.SETUP_PEER_VIDEOPRESENCE_COMPONENT,setupPeerVideoPresenceComponent);
			
			// TODO map these after the sparklines are ready
			// ..or figure out where to create sparklines better/earlier
			eventMap.mapListener(eventDispatcher,VideoPresenceEvent.DISPLAY_PEER_STATS,displayPeerStats);
			eventMap.mapListener(eventDispatcher,VideoPresenceEvent.DISPLAY_SERVER_STATS,displayServerStats);
			
			videosGroup.addEventListener(SettingsEvent.SHOW_SETTINGS,handleShowSettings);
			videosGroup.addEventListener(VideoPresenceEvent.AUDIO_LEVEL,dispatchEventInSystem);
			videosGroup.addEventListener(VideoPresenceEvent.AUDIO_MUTED,dispatchEventInSystem);
			videosGroup.addEventListener(VideoPresenceEvent.AUDIO_UNMUTED,dispatchEventInSystem);
			videosGroup.addEventListener(VideoPresenceEvent.VIDEO_MUTED,dispatchEventInSystem);
			videosGroup.addEventListener(VideoPresenceEvent.VIDEO_UNMUTED,dispatchEventInSystem);
		}
		
		private function dispatchEventInSystem(e:VideoPresenceEvent):void
		{
			dispatch(new VideoPresenceEvent(e.type,e.bubbles,e.value));
		}
		
		public function handleShowSettings( settingsEvent:SettingsEvent ):void
		{
			dispatch( new SettingsEvent( settingsEvent.type ) );
		}
		
		private function usersUpdated(msEvent:MSEvent):void
		{
			removeVideos(msEvent.userInfoVO_array, msEvent.local_userInfoVO);
			updateVideos(msEvent.userInfoVO_array, msEvent.local_userInfoVO);
		}
		
		private function removeVideos(userInfoVO_array:Array, local_userInfoVO:UserInfoVO):void
		{
			trace("VideosGroupMediator.removeVideos()");
			var dataProviderLength:int = videosGroup.videosGroup_list.dataProvider.length;
			for(var i:int = 0; i<dataProviderLength; i++){
				trace("VideosGroupMediator.removeVideos() i="+i);
				try{					
					var videoPresence:VideoPresence = videosGroup.videosGroup_list.dataProvider.getItemAt(i) as VideoPresence;
					trace("VideosGroupMediator.removeVideos() videoPresence.name="+videoPresence.name);
					
					//if the video isn't in the users collection remove it
					if(userInfoVO_array[videoPresence.name] == null){
						var vp_index:int = videosGroup.videosGroup_list.dataProvider.getItemIndex(videoPresence);
						trace("VideosGroupMediator.removeVideos() vp_index="+vp_index);
						videosGroup.videosGroup_list.dataProvider.removeItemAt(vp_index);
					}
				}catch(e:Object){
					//out of range error I'm sure
					// TODO Make sure we don't get out of range errors
					// Things work just fine, but how does this state occur?
					trace("VideosGroupMediator.removeVideos() error:" +e.toString());
				}
			}
		}
		
		private function getVideoPresenceByName(name:String): VideoPresence{
			trace("VideosGroupMediator.getVideoPresenceByName name="+name)
			var videoPresence:VideoPresence;
			var dataProviderLength:int = videosGroup.videosGroup_list.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
				trace("VideosGroupMediator.getVideoPresenceByName i="+i+", videos.videos_holder.dataProvider.length="+dataProviderLength)
				videoPresence = videosGroup.videosGroup_list.dataProvider.getItemAt(i) as VideoPresence;
				trace("VideosGroupMediator.getVideoPresenceByName videoPresence.name="+videoPresence.name)
				if (videoPresence.name == name) {
					return videoPresence;
				}
			}
			return null;
		}
		
		private function onVideoPresenceCreationComplete(e:FlexEvent):void
		{
			trace("VideosGroupMediator.onVideoPresenceCreationComplete")
			
			var videoPresence:VideoPresence = e.target as VideoPresence;
			if(videoPresence.is_local){
				setupLocalVideoPresenceComponent(videoPresence);
			} else {
				setupPeerVideoPresenceNetStream(videoPresence);
			}
		}
		
		private function updateVideos(userInfoVO_array:Array, local_userInfoVO:UserInfoVO):void
		{
			trace("VideosGroupMediator.updateVideos()");
			
			// What field in userInfoVO defines 'name' here?
			// Answer: suid
			for(var name:String in userInfoVO_array){
				trace("VideosGroupMediator.updateVideos() name="+name);
				var userInfoVO:UserInfoVO = userInfoVO_array[name];
				
				var videoPresence:VideoPresence = getVideoPresenceByName(name);
				if(videoPresence == null){
					trace("VideosGroupMediator.updateVideos() adding new VideoPresence for name="+name);
					
					videoPresence = new VideoPresence();
					videosGroup.videosGroup_list.dataProvider.addItem(videoPresence);
					
					videoPresence.userInfoVO = userInfoVO;
					
					// TODO this smells. Pick one and stick with it.
					videoPresence.name = userInfoVO.suid.toString();
					
					// TODO push this comparison into the is_local attribute
					if (userInfoVO.suid == local_userInfoVO.suid)
						videoPresence.is_local = true;
					else
						videoPresence.is_local = false;
					
					// Instantiating these here causes the backwards/outside container render bug
//					var sparkline:Sparkline = new Sparkline();
//					videoPresence.sparkline = sparkline;
//					videoPresence.borderContainer.addElement(sparkline);
					
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
		
		private function displayPeerStats(vpEvent:VideoPresenceEvent):void
		{
			trace("VideosGroupMediator.displayPeerStats()");
			var peerStatsVO:StatsVO = vpEvent.statsVO;
			var videoPresence:VideoPresence = getVideoPresenceByName(peerStatsVO.suid.toString());		
			
			if (videoPresence.sparkline == null) {
				trace("VideosGroupMediator.displayPeerStats() videoPresence.sparkline is null !!!!!!!!!!!!!!!!!!");
				return;
			}
			
			videoPresence.sparkline.statsVO = peerStatsVO;
			videoPresence.sparkline.yFieldName = 'srtt';
			var last_ping_value:int = peerStatsVO.data_array[peerStatsVO.data_array.length-1].srtt;
//			videoPresence.sparkline.lastValue_label = last_ping_value.toString();
			videoPresence.sparkline.toolTip = "Ping (peer)";
			
			if (last_ping_value < Sparkline.MAX_SRTT) {
				videoPresence.sparkline.lineStrokeColor = Sparkline.GREEN; 
			} else {
				videoPresence.sparkline.lineStrokeColor = Sparkline.RED;
			}
			
		}
		
		private function displayServerStats(vpEvent:VideoPresenceEvent):void
		{
			trace("VideosGroupMediator.displayServerStats()");
			var serverStatsVO:StatsVO = vpEvent.statsVO;
			var videoPresence:VideoPresence = getVideoPresenceByName(serverStatsVO.suid.toString());
			
			if (videoPresence.sparkline == null) {
				trace("VideosGroupMediator.displayServerStats() videoPresence.sparkline is null !!!!!!!!!!!!!!!!!!");
				return;
			}
			
			videoPresence.sparkline.statsVO = serverStatsVO;
			videoPresence.sparkline.yFieldName = 'currentBytesPerSecond';
			var currentBytesPerSecond:int = serverStatsVO.data_array[serverStatsVO.data_array.length-1].currentBytesPerSecond;
//			videoPresence.sparkline.lastValue_label = currentBytesPerSecond.toString();
			videoPresence.sparkline.toolTip = "Bytes/second (server)";
			
			if (currentBytesPerSecond < Sparkline.MAX_CURRENT_BYTES_PER_SECOND) {
				videoPresence.sparkline.lineStrokeColor = Sparkline.GREEN; 
			} else {
				videoPresence.sparkline.lineStrokeColor = Sparkline.RED;
			}
			
		}		
		
	}
}
