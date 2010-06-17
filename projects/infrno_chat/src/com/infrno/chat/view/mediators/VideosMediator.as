package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.MSEvent;
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
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.components.Group;
	
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
		
		private function usersUpdated(e:MSEvent):void
		{
			removeVideos();
			updateVideos();
		}
		
		private function removeVideos():void
		{
			var element_num:int = videos.videos_holder.numElements;
			for(var i:int = 0; i<element_num; i++){
				try{
					var curr_element:VideoPresense = videos.videos_holder.getElementAt(i) as VideoPresense;
					//if the video isn't in the users collection remove it
					if(dataProxy.users_collection[curr_element.name] == null){
						videos.videos_holder.removeElement(curr_element as IVisualElement);
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
			
			for(var n:String in dataProxy.users_collection){
				var curr_info:UserInfoVO = dataProxy.users_collection[n];
				var video_presense:VideoPresense;
				
				//if the video presense doesn't exist add one
				if(videos.videos_holder.getChildByName(n) == null){
					video_presense = videos.videos_holder.addElement(new VideoPresense()) as VideoPresense;
					video_presense.data = curr_info;
					video_presense.name = curr_info.suid.toString();
				} else {
					video_presense = getElementbyName(videos.videos_holder,curr_info.suid.toString());
				}
				
				if(curr_info.suid == dataProxy.my_info.suid){
					trace("VideosMediator.updateVideos() this is my video.. so showing my camera");
					video_presense.is_local = true;
					video_presense.camera = deviceProxy.camera;
//					video_presense.audio_level.value = deviceProxy.mic.gain;
					video_presense.audioLevel = deviceProxy.mic.gain;
					video_presense.toggleAudio();
					video_presense.toggleVideo();
				} else {
					//update/create netstream to play from
					//start playing the suid
					video_presense.is_local = false;
					
					if(dataProxy.use_peer_connection && curr_info.nearID && dataProxy.peer_capable && !(curr_info.ns is NetStreamPeer) ){
						trace("VideosMediator.updateVideos() setting up and playing from the peer connection: "+curr_info.suid.toString());
						curr_info.ns = peerService.getNewNetStream(curr_info.nearID);
						curr_info.ns.play(curr_info.suid.toString());
						video_presense.netstream = curr_info.ns;
						video_presense.toggleAudio();
						video_presense.toggleVideo();
					} else if(!dataProxy.use_peer_connection && !(curr_info.ns is NetStreamMS) ){
						trace("VideosMediator.updateVideos() setting up and playing from the stream server");
						curr_info.ns = msService.getNewNetStream();
						curr_info.ns.play(curr_info.suid.toString(),-1);
						video_presense.netstream = curr_info.ns;
						video_presense.toggleAudio();
						video_presense.toggleVideo();
					}
					try{
						video_presense.audio_level.value = curr_info.ns.soundTransform.volume*100
					} catch(e:Object){
						//something didn't initialze
					}
				}
			}
		}
		
		private function getElementbyName(visible_element:Group,name:String):VideoPresense
		{
			var num_elements:int = visible_element.numElements;
			for(var i:int=0;i<num_elements;i++){
				var curr_element:VideoPresense = visible_element.getElementAt(i) as VideoPresense;
				if(curr_element.name == name){
					return curr_element;
				}
			}
			return null;
		}
		
	}
}
