package com.infrno.multiplayer.controller
{
	import com.infrno.multiplayer.model.DataProxy;
	import com.infrno.multiplayer.model.DeviceProxy;
	import com.infrno.multiplayer.model.events.VideoPresenseEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class AudioVideoControlCommand extends Command
	{
		[Inject]
		public var event			:VideoPresenseEvent;
		
		[Inject]
		public var dataProxy		:DataProxy;
		
		[Inject]
		public var deviceProxy		:DeviceProxy;
		
		override public function execute():void
		{
			trace(event.type);
			switch(event.type){
				case VideoPresenseEvent.AUDIO_LEVEL:
					if(deviceProxy.mic)
						deviceProxy.mic.gain = event.value;
					break;
				case VideoPresenseEvent.AUDIO_MUTED:
					dataProxy.pubishing_audio = false;
					
					if(dataProxy.ns)
						dataProxy.ns.attachAudio(null);
					break;
				case VideoPresenseEvent.AUDIO_UNMUTED:
					dataProxy.pubishing_audio = true;
					
					if(dataProxy.ns)
						dataProxy.ns.attachAudio(deviceProxy.mic);
					break;
				case VideoPresenseEvent.VIDEO_MUTED:
					dataProxy.pubishing_video = false;
					
					if(dataProxy.ns)
						dataProxy.ns.attachCamera(null);
					break;
				case VideoPresenseEvent.VIDEO_UNMUTED:
					dataProxy.pubishing_video = true;
					
					if(dataProxy.ns)
						dataProxy.ns.attachCamera(deviceProxy.camera);
					break;
			}
		}
	}
}