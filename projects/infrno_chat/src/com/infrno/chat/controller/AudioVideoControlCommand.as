package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.VideoPresenseEvent;
	
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
			trace("AudioVideoControlCommand.execute() " +event.type);
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
					
					trace( "audio unmuted." )
					if(dataProxy.ns)
					{
						trace( "attaching mic." )
						if( deviceProxy.mic == null ) 
						{
							trace( "deviceProxy.mic is null" )
						}
						
						dataProxy.ns.attachAudio(deviceProxy.mic);
					}
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