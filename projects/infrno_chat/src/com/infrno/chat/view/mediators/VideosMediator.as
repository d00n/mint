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
	import com.infrno.chat.view.components.Videos;
	
	import flash.display.DisplayObject;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.logging.Log;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.components.List;
	
	public class VideosMediator extends Mediator
	{
		// TODO: I don't think Mediators should depend on Models. 
		[Inject]
		public var deviceProxy:DeviceProxy;
		
		[Inject]
		public var videos:Videos;
		
		public const GREEN:String 											= "0x5DFC0A";  
		public const RED:String 												= "0xFF0000";  
		public const YELLOW:String											= "0xFFFF00";
		public const MAX_SRTT:int												= 100;
		public const MAX_CURRENT_BYTES_PER_SECOND:int		= 170000;
			
		
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,MSEvent.USERS_OBJ_UPDATE,usersUpdated);
			eventMap.mapListener(eventDispatcher,VideoPresenceEvent.SETUP_PEER_VIDEOPRESENCE_COMPONENT,setupPeerVideoPresenceComponent);
			eventMap.mapListener(eventDispatcher,VideoPresenceEvent.DISPLAY_PEER_STATS,displayPeerStats);
			eventMap.mapListener(eventDispatcher,VideoPresenceEvent.DISPLAY_SERVER_STATS,displayServerStats);
			
			videos.addEventListener(SettingsEvent.SHOW_SETTINGS,handleShowSettings);
			videos.addEventListener(VideoPresenceEvent.AUDIO_LEVEL,dispatchEventInSystem);
			videos.addEventListener(VideoPresenceEvent.AUDIO_MUTED,dispatchEventInSystem);
			videos.addEventListener(VideoPresenceEvent.AUDIO_UNMUTED,dispatchEventInSystem);
			videos.addEventListener(VideoPresenceEvent.VIDEO_MUTED,dispatchEventInSystem);
			videos.addEventListener(VideoPresenceEvent.VIDEO_UNMUTED,dispatchEventInSystem);
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
			trace("VideosMediator.removeVideos()");
			var dataProviderLength:int = videos.videos_holder.dataProvider.length;
			for(var i:int = 0; i<dataProviderLength; i++){
				trace("VideosMediator.removeVideos() i="+i);
				try{
					
					var videoPresence:VideoPresence = videos.videos_holder.dataProvider.getItemAt(i) as VideoPresence;
					trace("VideosMediator.removeVideos() videoPresence.name="+videoPresence.name);
					
					//if the video isn't in the users collection remove it
					if(userInfoVO_array[videoPresence.name] == null){
						var vp_index:int = videos.videos_holder.dataProvider.getItemIndex(videoPresence);
						trace("VideosMediator.removeVideos() vp_index="+vp_index);
						videos.videos_holder.dataProvider.removeItemAt(vp_index);
					}
				}catch(e:Object){
					//out of range error I'm sure
					// TODO Make sure we don't get out of range errors
					// Things work just fine, but how does this state occur?
					trace("VideosMediator.removeVideos() error:" +e.toString());
				}
			}
		}
		
		private function getVideoPresenceByName(name:String): VideoPresence{
			trace("VideosMediator.getVideoPresenceByName name="+name)
			var videoPresence:VideoPresence;
			var dataProviderLength:int = videos.videos_holder.dataProvider.length;
			for(var i:int = 0; i < dataProviderLength; i++){
				trace("VideosMediator.getVideoPresenceByName i="+i+", videos.videos_holder.dataProvider.length="+dataProviderLength)
				videoPresence = videos.videos_holder.dataProvider.getItemAt(i) as VideoPresence;
				trace("VideosMediator.getVideoPresenceByName videoPresence.name="+videoPresence.name)
				if (videoPresence.name == name) {
					return videoPresence;
				}
			}
			return null;
		}
		
		private function onVideoPresenceCreationComplete(e:FlexEvent):void
		{
			trace("VideosMediator.onVideoPresenceCreationComplete")
			
			var videoPresence:VideoPresence = e.target as VideoPresence;
			if(videoPresence.is_local){
				setupLocalVideoPresenceComponent(videoPresence);
			} else {
				setupPeerVideoPresenceNetStream(videoPresence);
			}
		}
		
		private function updateVideos(userInfoVO_array:Array, local_userInfoVO:UserInfoVO):void
		{
			trace("VideosMediator.updateVideos()");
			
			// What field in userInfoVO defines 'name' here?
			// Answer: suid
			for(var name:String in userInfoVO_array){
				trace("VideosMediator.updateVideos() name="+name);
				var userInfoVO:UserInfoVO = userInfoVO_array[name];
				
				var videoPresence:VideoPresence = getVideoPresenceByName(name);
				if(videoPresence == null){
					trace("VideosMediator.updateVideos() adding new VideoPresence for name="+name);
					
					videoPresence = new VideoPresence();
					videos.videos_holder.dataProvider.addItem(videoPresence);
					
					videoPresence.userInfoVO = userInfoVO;
					
					// TODO this smells. Pick one and stick with it.
					videoPresence.name = userInfoVO.suid.toString();
					
					// TODO push this comparison into the is_local attribute
					if (userInfoVO.suid == local_userInfoVO.suid)
						videoPresence.is_local = true;
					else
						videoPresence.is_local = false;
					
					videoPresence.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
						{
							trace("VideosMediator.updateVideos() VideoPresence FlexEvent.CREATION_COMPLETE event listener")
							
							var videoPresence:VideoPresence = e.target as VideoPresence;
							if(videoPresence.is_local){
								setupLocalVideoPresenceComponent(videoPresence);
							} else {
								setupPeerVideoPresenceNetStream(videoPresence);
							}
						});
					
				} else {
					trace("VideosMediator.updateVideos() found existing VideoPresence for name="+name);
					
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
			trace("VideosMediator.setupLocalVideoPresenceComponent()");
			videoPresence.is_local = true;
			videoPresence.camera = deviceProxy.camera;
			videoPresence.audio_level.value = deviceProxy.mic.gain;
//			videoPresence.audioLevel = deviceProxy.mic.gain;
			videoPresence.toggleAudio();
			videoPresence.toggleVideo();
		}
		
		private function setupPeerVideoPresenceNetStream(videoPresence:VideoPresence):void
		{
			trace("VideosMediator.setupPeerVideoPresenceNetStream() videoPresence.userInfoVO.suid:"+videoPresence.userInfoVO.suid);			
			var vpEvent:VideoPresenceEvent = new VideoPresenceEvent(VideoPresenceEvent.SETUP_PEER_NETSTREAM);
			vpEvent.userInfoVO = videoPresence.userInfoVO;
			dispatch(vpEvent);			
		}
		
		private function setupPeerVideoPresenceComponent(vpEvent:VideoPresenceEvent):void
		{
			trace("VideosMediator.setupPeerVideoPresenceComponent()");
			var userInfoVO:UserInfoVO = vpEvent.userInfoVO;
			var videoPresence:VideoPresence = getVideoPresenceByName(userInfoVO.suid.toString());			
			videoPresence.netstream = userInfoVO.netStream;
			videoPresence.toggleAudio();
			videoPresence.toggleVideo();
			
			try{
				videoPresence.audio_level.value = userInfoVO.netStream.soundTransform.volume*100
			} catch(e:Object){
				trace("VideosMediator.setupPeerVideoPresenceComponent() setting videoPresence.audio_level.value threw an error: " + e.toString());
			}
		}
		
		private function displayPeerStats(vpEvent:VideoPresenceEvent):void
		{
			trace("VideosMediator.displayPeerStats()");
			var peerStatsVO:StatsVO = vpEvent.statsVO;
			var videoPresence:VideoPresence = getVideoPresenceByName(peerStatsVO.suid.toString());		
			
			videoPresence.sparkline.statsVO = peerStatsVO;
			videoPresence.sparkline.yFieldName = 'currentBytesPerSecond';
			var last_ping_value:int = peerStatsVO.data_array[peerStatsVO.data_array.length-1].srtt;
			videoPresence.sparkline.lastValue_label = last_ping_value.toString();
			videoPresence.sparkline.toolTip = "bps";
			
			if (last_ping_value < MAX_SRTT) {
				videoPresence.sparkline.line_stroke_color = GREEN; 
			} else {
				videoPresence.sparkline.line_stroke_color = RED;
			}
			
		}
		
		private function displayServerStats(vpEvent:VideoPresenceEvent):void
		{
			trace("VideosMediator.displayPeerStats()");
			var serverStatsVO:StatsVO = vpEvent.statsVO;
			var videoPresence:VideoPresence = getVideoPresenceByName(serverStatsVO.suid.toString());		
			
			videoPresence.sparkline.statsVO = serverStatsVO;
			videoPresence.sparkline.yFieldName = 'currentBytesPerSecond';
			var currentBytesPerSecond:int = serverStatsVO.data_array[serverStatsVO.data_array.length-1].currentBytesPerSecond;
			videoPresence.sparkline.lastValue_label = currentBytesPerSecond.toString();
			videoPresence.sparkline.toolTip = "Bytes per second";
			
			if (currentBytesPerSecond < MAX_CURRENT_BYTES_PER_SECOND) {
				videoPresence.sparkline.line_stroke_color = GREEN; 
			} else {
				videoPresence.sparkline.line_stroke_color = RED;
			}
			
		}		
		
	}
}
