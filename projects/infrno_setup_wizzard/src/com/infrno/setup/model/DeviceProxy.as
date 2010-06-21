package com.infrno.setup.model
{
    import com.infrno.setup.model.events.DeviceEvent;
    import com.infrno.setup.model.events.GenericEvent;
    
    import flash.events.ActivityEvent;
    import flash.events.StatusEvent;
    import flash.events.TimerEvent;
    import flash.media.Camera;
    import flash.media.Microphone;
    import flash.media.SoundTransform;
    import flash.system.Security;
    import flash.system.SecurityPanel;
    import flash.utils.Timer;
    
    import org.robotlegs.mvcs.Actor;
    
    public class DeviceProxy extends Actor
    {
		public var camera_array:Array;
		public var mic_array:Array;
		
        public var camera_active:Boolean;
		public var mic_active:Boolean;
		
        public var cam_index:int;
        public var mic_index:int;
        public var mic_level:int;
        
        private var _camera:Camera;
        private var _mic:Microphone;
        private var _mic_level_timer:Timer;

        private var _camera_fps:uint=12;
        private var _camera_height:uint=240; //240
        private var _camera_quality:uint=85;
        private var _camera_width:uint=320;//320
        
        public function DeviceProxy() 
        {
			camera_array = Camera.names;
			mic_array = Microphone.names;
			
			initTimers();
			initMic();
			initCam();
        }
        
        private function initTimers():void
        {
        	_mic_level_timer = new Timer(50);
        	_mic_level_timer.addEventListener(TimerEvent.TIMER,function(e:TimerEvent):void{
        		mic_level = _mic.activityLevel;
				dispatch(new DeviceEvent(DeviceEvent.MIC_LEVEL,_mic.activityLevel));
        	});
        }
        
        private function releaseMic( ) : void 
        {
        	if( null == _mic ) 
			{
				return;
			} 
			
			_mic.setLoopBack( false );
			_mic.removeEventListener(ActivityEvent.ACTIVITY, handleMicActivity );
			_mic.removeEventListener(StatusEvent.STATUS, handleMicStatus );	
			_mic = null;
        }
        
        private function releaseCamera( ) : void 
        {
        	if( null == _camera ) 
        	{
        		return;
        	}
        	_camera.removeEventListener( StatusEvent.STATUS, handleCameraStatus );
			_camera.removeEventListener( ActivityEvent.ACTIVITY, handleCameraActivity );
			_camera = null;
        }
        
        private function initCam(nameIn:String=null):void 
		{
			camera_active = false;
			
        	_camera = Camera.getCamera(nameIn);
			if(_camera!=null){
				
				for(var i:String in camera_array){
					if(_camera.name == camera_array[i]){
						cam_index = int(i);
						break;
					}
				}
				
				updateCamQuality(_camera_quality);
				_camera.setMode(_camera_width,_camera_height,_camera_fps);
				_camera.setMotionLevel(0);
				
				_camera.addEventListener( StatusEvent.STATUS, handleCameraStatus, false, 0, true );
				_camera.addEventListener( ActivityEvent.ACTIVITY, handleCameraActivity, false, 0, true );
			}
		}
		
		private function handleCameraActivity(evt:ActivityEvent):void{
			trace("camera active: "+evt.activating)
			camera_active=evt.activating;
			dispatch(new DeviceEvent(DeviceEvent.CAMERA_ACTIVITY,evt.activating));
		}
		
		public function handleCameraStatus( evt:StatusEvent ) : void
		{
			trace(evt.code);
			if(evt.code=="Camera.Muted"){
				trace("no access to the camera");
				camera_active=false;
			}
		}
		
		private function initMic(micIn:int=-1):Microphone
		{
			_mic = Microphone.getMicrophone(micIn);
			
			for(var i:String in mic_array){
				if(_mic.name == mic_array[i]){
					mic_index = int(i);
					break;
				}
			}
			
			var mic_transform:SoundTransform = _mic.soundTransform;
			mic_transform.volume = 0;
			_mic.soundTransform = mic_transform;
			
			_mic.setLoopBack(true);
			_mic.setUseEchoSuppression(true);

			_mic.addEventListener(ActivityEvent.ACTIVITY, handleMicActivity, false, 0, true );
			_mic.addEventListener(StatusEvent.STATUS, handleMicStatus, false, 0, true );
			
			if(_mic!=null){
				_mic_level_timer.start();
			} else {
				_mic_level_timer.reset();
			}
			
			return _mic;
		}
		
		
		private function handleMicActivity( activityEvent:ActivityEvent ) : void
		{
			if( activityEvent.activating){
				mic_active = activityEvent.activating;
				dispatch(new DeviceEvent(DeviceEvent.MIC_ACTIVITY,activityEvent.activating));
			}
		}
		
		private function handleMicStatus( statusEvent:StatusEvent ) : void 
		{
			trace(statusEvent.code);
			if(statusEvent.code=="Microphone.Muted"){
				trace("no access to the mic");
				mic_active = false;
			}
		}
		
		//public methods
		public function get camera():Camera
        {
        	return _camera;
        }
        
        public function releaseResources( ) : void 
		{
			releaseMic( );
			releaseCamera( );
			_mic_level_timer.stop( );
			dispatch( new GenericEvent(GenericEvent.REMOVE_VIDEO, true, false ) );
		}
        
		public function setCamera(cam_index_in:String):void
        {
        	initCam(cam_index_in);
			dispatch(new DeviceEvent(DeviceEvent.CAMERA_CHANGED));
        }
        
		public function setMic(mic_index_in:int=-1,skip_notify:Boolean=false):Microphone
        {
        	if(!skip_notify)
				dispatch(new DeviceEvent(DeviceEvent.MIC_CHANGED));
        		
        	return initMic(mic_index_in);
        }
        
        public function get mic():Microphone
        {
        	return _mic;
        }
        
        public function updateCamMode(widthIn:int=320,heightIn:int=240,fps:int=12):void
        {
        	if(_camera_width != widthIn || _camera_height != heightIn || _camera_fps != fps){
	        	_camera_width = widthIn;
	        	_camera_height = heightIn;
	        	_camera_fps = fps;
	        	
	        	_camera.setMode(_camera_width,_camera_height,_camera_fps);
	        }
        }
        
		public function updateCamQuality(n_valIn:int):void{
//			trace("cam quality updated to: "+n_valIn);
			_camera_quality = n_valIn;
			_camera.setQuality(0,n_valIn);
		}
		
		public function showCamSettings():void
		{
			Security.showSettings(SecurityPanel.CAMERA);
		}
		
		public function showMicSettings():void
		{
			Security.showSettings(SecurityPanel.MICROPHONE);
		}
    }
}
