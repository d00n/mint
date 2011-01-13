package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.MSEvent;
	import com.infrno.chat.model.events.SettingsEvent;
	import com.infrno.chat.model.events.VideoPresenseEvent;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.NetStreamMS;
	import com.infrno.chat.services.NetStreamPeer;
	import com.infrno.chat.services.PeerService;
	import com.infrno.chat.view.components.VideoPresense;
	import com.infrno.chat.view.components.Videos;
	
	import flash.display.DisplayObject;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.components.Group;
	import spark.components.List;
	
	public class VideosMediator extends Mediator
	{
		[Inject]
		public var dataProxy		:DataProxy;
		
		[Inject]
		public var deviceProxy		:DeviceProxy;
		
		[Inject]
		public var msService		:MSService;
		
		[Inject]
		public var peerService		:PeerService;
		
		[Inject]
		public var videos			:Videos;
		
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,MSEvent.USERS_OBJ_UPDATE,usersUpdated);
			
			videos.addEventListener(SettingsEvent.SHOW_SETTINGS,handleShowSettings);
			videos.addEventListener(VideoPresenseEvent.AUDIO_LEVEL,dispatchEventInSystem);
			videos.addEventListener(VideoPresenseEvent.AUDIO_MUTED,dispatchEventInSystem);
			videos.addEventListener(VideoPresenseEvent.AUDIO_UNMUTED,dispatchEventInSystem);
			videos.addEventListener(VideoPresenseEvent.VIDEO_MUTED,dispatchEventInSystem);
			videos.addEventListener(VideoPresenseEvent.VIDEO_UNMUTED,dispatchEventInSystem);
		}
		
		private function dispatchEventInSystem(e:VideoPresenseEvent):void
		{
			dispatch(new VideoPresenseEvent(e.type,e.bubbles,e.value));
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
			var element_num:int = videos.videos_holder.numChildren;
			for(var i:int = 0; i<element_num; i++){
				try{
					
//					var curr_element:VideoPresense = videos.videos_holder.getElementAt(i) as VideoPresense;
					var curr_element:VideoPresense = videos.videos_holder.getChildAt(i) as VideoPresense;
					
					
					//if the video isn't in the users collection remove it
					if(dataProxy.users_collection[curr_element.name] == null){
//						videos.videos_holder.removeElement(curr_element as IVisualElement);
						videos.videos_holder.removeChild(curr_element as VideoPresense);
					}
				}catch(e:Object){
					//out of range error I'm sure
					trace("VideosMediator.removeVideos() " +e.toString());
				}
			}
		}
		
		private function updateVideos():void
		{
			trace("VideosMediator.updateVideos() updating videos");
			
			for(var name:String in dataProxy.users_collection){
				var userInfo:UserInfoVO = dataProxy.users_collection[name];
				var video_presense:VideoPresense;
				
				//if the video presense doesn't exist add one
				if(videos.videos_holder.getChildByName(name) == null){
					
//					video_presense = videos.videos_holder.addElement(new VideoPresense()) as VideoPresense;
					video_presense = new VideoPresense();
					videos.videos_holder.dataProvider.addItem(video_presense);
					
					video_presense.data = userInfo;
					video_presense.name = userInfo.suid.toString();
					
					video_presense.is_local = userInfo.suid == dataProxy.my_info.suid;
					
					video_presense.addEventListener(FlexEvent.CREATION_COMPLETE,function(e:FlexEvent):void
					{
						var curr_presense:VideoPresense = e.target as VideoPresense;
						if(curr_presense.is_local){
							setupMyPresenseComponent(curr_presense);
						} else {
							setupOtherPresenseComponent(curr_presense);
						}
					});
					
				} else {
					video_presense = getElementbyName(videos.videos_holder, userInfo.suid.toString());
					if(!video_presense.isInitialized())
						return;

					video_presense.is_local = userInfo.suid == dataProxy.my_info.suid;
					
					if(userInfo.suid == dataProxy.my_info.suid){
						setupMyPresenseComponent(video_presense);
					} else {
						setupOtherPresenseComponent(video_presense);
					}
				}
				
//				if(userInfo.suid == dataProxy.my_info.suid){
//					trace("VideosMediator.updateVideos() this is my video.. so showing my camera");
//					video_presense.is_local = true;
//					video_presense.camera = deviceProxy.camera;
////					video_presense.audio_level.value = deviceProxy.mic.gain;
//					video_presense.audioLevel = deviceProxy.mic.gain;
//					video_presense.toggleAudio();
//					video_presense.toggleVideo();
//				} else {
//					//update/create netstream to play from
//					//start playing the suid
//					video_presense.is_local = false;
//					
//					if(dataProxy.use_peer_connection && userInfo.nearID && dataProxy.peer_capable && !(userInfo.ns is NetStreamPeer) ){
//						trace("VideosMediator.updateVideos() setting up and playing from the peer connection: "+userInfo.suid.toString());
//						userInfo.ns = peerService.getNewNetStream(userInfo.nearID);
//						userInfo.ns.play(userInfo.suid.toString());
//						video_presense.netstream = userInfo.ns;
//						video_presense.toggleAudio();
//						video_presense.toggleVideo();
//					} else if(!dataProxy.use_peer_connection && !(userInfo.ns is NetStreamMS) ){
//						trace("VideosMediator.updateVideos() setting up and playing from the stream server");
//						userInfo.ns = msService.getNewNetStream();
//						userInfo.ns.play(userInfo.suid.toString(),-1);
//						video_presense.netstream = userInfo.ns;
//						video_presense.toggleAudio();
//						video_presense.toggleVideo();
//					}
//					try{
//						video_presense.audio_level.value = userInfo.ns.soundTransform.volume*100
//					} catch(e:Object){
//						//something didn't initialze
//					}
//				}
			}
		}
		
		private function setupMyPresenseComponent(video_presense:VideoPresense):void
		{
			trace("VideosMediator.updateVideos() this is my video.. so showing my camera");
			video_presense.is_local = true;
			video_presense.camera = deviceProxy.camera;
			video_presense.audio_level.value = deviceProxy.mic.gain;
//			video_presense.audioLevel = deviceProxy.mic.gain;
			video_presense.toggleAudio();
			video_presense.toggleVideo();
		}
		
		private function setupOtherPresenseComponent(video_presense:VideoPresense):void
		{
			var userInfo:UserInfoVO = video_presense.data;
			
			if(dataProxy.use_peer_connection && userInfo.nearID && dataProxy.peer_capable && !(userInfo.ns is NetStreamPeer) ){
				trace("VideosMediator.updateVideos() setting up and playing from the peer connection: "+userInfo.suid.toString());
				userInfo.ns = peerService.getNewNetStream(userInfo.nearID);
				userInfo.ns.play(userInfo.suid.toString());
				video_presense.netstream = userInfo.ns;
				video_presense.toggleAudio();
				video_presense.toggleVideo();
			} else if(!dataProxy.use_peer_connection && !(userInfo.ns is NetStreamMS) ){
				trace("VideosMediator.updateVideos() setting up and playing from the stream server");
				userInfo.ns = msService.getNewNetStream();
				userInfo.ns.play(userInfo.suid.toString(),-1);
				video_presense.netstream = userInfo.ns;
				video_presense.toggleAudio();
				video_presense.toggleVideo();
			}
			try{
				video_presense.audio_level.value = userInfo.ns.soundTransform.volume*100
			} catch(e:Object){
				//something didn't initialze
			}
		}
		
		private function getElementbyName(visible_element:spark.components.List, name:String):VideoPresense
		{
			var num_elements:int = visible_element.numChildren;
			for(var i:int=0;i<num_elements;i++){
				var curr_element:VideoPresense = visible_element.getChildAt(i) as VideoPresense;
				if(curr_element.name == name){
					return curr_element;
				}
			}
			return null;
		}
		
	}
}
