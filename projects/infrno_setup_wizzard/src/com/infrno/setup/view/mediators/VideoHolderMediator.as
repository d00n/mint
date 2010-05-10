package com.infrno.setup.view.mediators
{
	import com.infrno.setup.model.DeviceProxy;
	import com.infrno.setup.model.events.DeviceEvent;
	import com.infrno.setup.model.events.GenericEvent;
	import com.infrno.setup.view.components.VideoHolder;
	
	import flash.utils.setTimeout;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class VideoHolderMediator extends Mediator
	{
		[Inject]
		public var deviceProxy		:DeviceProxy;
		
		[Inject]
		public var videoHolder		:VideoHolder;
		
		public function VideoHolderMediator()
		{
			super();
		}
		
		override public function onRegister():void
		{
			videoHolder.addEventListener(GenericEvent.SHOW_VIDEO,toggleVideo);
			videoHolder.addEventListener(GenericEvent.HIDE_VIDEO,toggleVideo);
			
			eventMap.mapListener(eventDispatcher,DeviceEvent.CAMERA_ACTIVITY,camActive);
		}
		
		private function camActive(e:DeviceEvent):void
		{
//			trace("is the cam active? "+deviceProxy.camera_active.toString());
			videoHolder.video.visible = e.value;
		}
		
		private function toggleVideo(e:GenericEvent):void
		{
			dispatch(new GenericEvent(e.type));
			
			if(e.type != GenericEvent.HIDE_VIDEO){
				videoHolder.video.attachCamera(deviceProxy.camera);
				videoHolder.toggle_btn.label = "hide video";
			}else{
				videoHolder.video.attachCamera(null);
				videoHolder.toggle_btn.label = "show video";
			}
		}
	}
}