package com.infrno.setup.view.mediators
{
	import com.infrno.setup.model.DeviceProxy;
	import com.infrno.setup.model.events.DeviceEvent;
	import com.infrno.setup.model.events.GenericEvent;
	import com.infrno.setup.view.components.VideoHolder;
	
	import flash.media.Video;
	
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
			eventMap.mapListener(eventDispatcher,DeviceEvent.CAMERA_ACTIVITY,camActive);
			eventMap.mapListener(eventDispatcher,GenericEvent.REMOVE_VIDEO,handleRemoveVideo, null, false, 0, true );
			showVideo( null )
		}
		
		private function camActive(e:DeviceEvent):void
		{
			videoHolder.video.visible = e.value;
		}
		
		protected function showVideo( genericEvent:GenericEvent ) : void 
		{
			dispatch( new GenericEvent( GenericEvent.SHOW_VIDEO ) );
			videoHolder.video.attachCamera( deviceProxy.camera );
		}
		
		public function handleRemoveVideo( genericEvent:GenericEvent ) : void 
		{
			videoHolder.removeVideo( );
		}
	}
}