package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.SettingsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.NetStreamMS;
	import com.infrno.chat.services.NetStreamPeer;
	import com.infrno.chat.services.PeerService;
	import com.infrno.chat.view.components.VideoPresence;
	import com.infrno.chat.view.components.Videos;
	
	import flash.display.DisplayObject;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.logging.Log;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.components.Group;
	import spark.components.List;
	
	public class VideosMediator extends Mediator
	{
		[Inject]
		public var dataProxy:DataProxy;
		
		[Inject]
		public var deviceProxy:DeviceProxy;
		
		[Inject]
		public var msService:MSService;
		
		[Inject]
		public var peerService:PeerService;
		
		[Inject]
		public var videos:Videos;
		
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,MSEvent.USERS_OBJ_UPDATE,usersUpdated);
			
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
		
		private function usersUpdated(e:MSEvent):void
		{
			removeVideos();
			updateVideos();
		}
		
		private function removeVideos():void
		{
			trace("VideosMediator.removeVideos()");
//			var element_num:int = videos.videos_holder.numChildren;
			var dataProviderLength:int = videos.videos_holder.dataProvider.length;
			for(var i:int = 0; i<dataProviderLength; i++){
				trace("VideosMediator.removeVideos() i="+i);
				try{
					
//					var curr_element:VideoPresence = videos.videos_holder.getElementAt(i) as VideoPresence;
					var videoPresence:VideoPresence = videos.videos_holder.dataProvider.getItemAt(i) as VideoPresence;
					trace("VideosMediator.removeVideos() videoPresence.name="+videoPresence.name);
					
					//if the video isn't in the users collection remove it
					if(dataProxy.userInfoVO_array[videoPresence.name] == null){
//						videos.videos_holder.removeElement(videoPresence as IVisualElement);
						var vp_index:int = videos.videos_holder.dataProvider.getItemIndex(videoPresence);
						trace("VideosMediator.removeVideos() vp_index="+vp_index);
						videos.videos_holder.dataProvider.removeItemAt(vp_index);
					}
				}catch(e:Object){
					//out of range error I'm sure
					trace("VideosMediator.removeVideos() " +e.toString());
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
		
//		private function getElementbyName(visible_element:spark.components.List, name:String):VideoPresence
//		{
//			var num_elements:int = visible_element.numChildren;
//			for(var i:int=0;i<num_elements;i++){
//				var curr_element:VideoPresence = visible_element.getChildAt(i) as VideoPresence;
//				if(curr_element.name == name){
//					return curr_element;
//				}
//			}
//			return null;
//		}		
		
		private function onVideoPresenceCreationComplete(e:FlexEvent):void
		{
			trace("VideosMediator.onVideoPresenceCreationComplete")
			
			var curr_presence:VideoPresence = e.target as VideoPresence;
			if(curr_presence.is_local){
				setupMyPresenceComponent(curr_presence);
			} else {
				setupOtherPresenceComponent(curr_presence);
			}
		}
		
		private function updateVideos():void
		{
			trace("VideosMediator.updateVideos()");
			
			for(var name:String in dataProxy.userInfoVO_array){
				trace("VideosMediator.updateVideos() name="+name);
				var userInfo:UserInfoVO = dataProxy.userInfoVO_array[name];
				
				//if the video presence doesn't exist add one
//				if(videos.videos_holder.getChildByName(name) == null){
				var videoPresence:VideoPresence = getVideoPresenceByName(name);
				if(videoPresence == null){
					trace("VideosMediator.updateVideos() adding new VideoPresence for name="+name);
					
//					videoPresence = videos.videos_holder.addElement(new VideoPresence()) as VideoPresence;
					videoPresence = new VideoPresence();
					videos.videos_holder.dataProvider.addItem(videoPresence);
					
					videoPresence.data = userInfo;
					videoPresence.name = userInfo.suid.toString();
					
					videoPresence.is_local = userInfo.suid == dataProxy.my_info.suid;
					
					videoPresence.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
						{
							trace("VideosMediator.updateVideos() VideoPresence FlexEvent.CREATION_COMPLETE event listener")
							
							var curr_presence:VideoPresence = e.target as VideoPresence;
							if(curr_presence.is_local){
								setupMyPresenceComponent(curr_presence);
							} else {
								setupOtherPresenceComponent(curr_presence);
							}
						});
					
				} else {
					trace("VideosMediator.updateVideos() found existing VideoPresence for name="+name);
					
					// videoPresence is assigned, and not null.
					// why are we fetching this again? 
//					videoPresence = getElementbyName(videos.videos_holder, userInfo.suid.toString());
					
					if(!videoPresence.isInitialized()) {
						// what about the rest of the collection?
						return;
					}
							
					videoPresence.is_local = userInfo.suid == dataProxy.my_info.suid;
					
					if(userInfo.suid == dataProxy.my_info.suid){
						setupMyPresenceComponent(videoPresence);
					} else {
						setupOtherPresenceComponent(videoPresence);
					}
					
				}
				
//				if(userInfo.suid == dataProxy.my_info.suid){
//					trace("VideosMediator.updateVideos() this is my video.. so showing my camera");
//					videoPresence.is_local = true;
//					videoPresence.camera = deviceProxy.camera;
////					videoPresence.audio_level.value = deviceProxy.mic.gain;
//					videoPresence.audioLevel = deviceProxy.mic.gain;
//					videoPresence.toggleAudio();
//					videoPresence.toggleVideo();
//				} else {
//					//update/create netstream to play from
//					//start playing the suid
//					videoPresence.is_local = false;
//					
//					if(dataProxy.use_peer_connection && userInfo.nearID && dataProxy.peer_capable && !(userInfo.ns is NetStreamPeer) ){
//						trace("VideosMediator.updateVideos() setting up and playing from the peer connection: "+userInfo.suid.toString());
//						userInfo.ns = peerService.getNewNetStream(userInfo.nearID);
//						userInfo.ns.play(userInfo.suid.toString());
//						videoPresence.netstream = userInfo.ns;
//						videoPresence.toggleAudio();
//						videoPresence.toggleVideo();
//					} else if(!dataProxy.use_peer_connection && !(userInfo.ns is NetStreamMS) ){
//						trace("VideosMediator.updateVideos() setting up and playing from the stream server");
//						userInfo.ns = msService.getNewNetStream();
//						userInfo.ns.play(userInfo.suid.toString(),-1);
//						videoPresence.netstream = userInfo.ns;
//						videoPresence.toggleAudio();
//						videoPresence.toggleVideo();
//					}
//					try{
//						videoPresence.audio_level.value = userInfo.ns.soundTransform.volume*100
//					} catch(e:Object){
//						//something didn't initialze
//					}
//				}
			}
		}
		
		private function setupMyPresenceComponent(videoPresence:VideoPresence):void
		{
			trace("VideosMediator.setupMyPresenceComponent()");
			videoPresence.is_local = true;
			videoPresence.camera = deviceProxy.camera;
			videoPresence.audio_level.value = deviceProxy.mic.gain;
//			videoPresence.audioLevel = deviceProxy.mic.gain;
			videoPresence.toggleAudio();
			videoPresence.toggleVideo();
		}
		
		private function setupOtherPresenceComponent(videoPresence:VideoPresence):void
		{
			trace("VideosMediator.setupOtherPresenceComponent()");
			var userInfo:UserInfoVO = videoPresence.data;
			
			if(dataProxy.use_peer_connection && userInfo.nearID && dataProxy.peer_capable && !(userInfo.ns is NetStreamPeer) ){
				trace("VideosMediator.setupOtherPresenceComponent() setting up and playing from the peer connection: "+userInfo.suid.toString());
				userInfo.ns = peerService.getNewNetStream(userInfo.nearID);
				userInfo.ns.play(userInfo.suid.toString());
				videoPresence.netstream = userInfo.ns;
				videoPresence.toggleAudio();
				videoPresence.toggleVideo();
			} else if(!dataProxy.use_peer_connection && !(userInfo.ns is NetStreamMS) ){
				trace("VideosMediator.setupOtherPresenceComponent() setting up and playing from the stream server");
				userInfo.ns = msService.getNewNetStream();
				userInfo.ns.play(userInfo.suid.toString(),-1);
				videoPresence.netstream = userInfo.ns;
				videoPresence.toggleAudio();
				videoPresence.toggleVideo();
			}
			
			try{
				videoPresence.audio_level.value = userInfo.ns.soundTransform.volume*100
			} catch(e:Object){
				trace("VideosMediator.setupOtherPresenceComponent() setting videoPresence.audio_level.value threw an error: " + e.toString());
			}
		}
		

		
	}
}
