package com.infrno.setup.model
{
    import com.infrno.setup.model.events.DeviceEvent;
    
    import flash.events.ActivityEvent;
    import flash.events.StatusEvent;
    import flash.events.TimerEvent;
    import flash.media.Camera;
    import flash.media.Microphone;
    import flash.media.SoundCodec;
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
//			trace("Device Proxy v 0.5.1");
			camera_array = Camera.names;
			mic_array = Microphone.names;
			
            initTimers();
            initDevices();
        }
        
        private function initTimers():void
        {
        	_mic_level_timer = new Timer(50);
        	_mic_level_timer.addEventListener(TimerEvent.TIMER,function(e:TimerEvent):void{
        		mic_level = _mic.activityLevel;
				dispatch(new DeviceEvent(DeviceEvent.MIC_LEVEL,_mic.activityLevel));
        	});
        }
        public function get microphoneLevel( ) : int
        {
        	if( null == _mic ) 
        	{
        		return 0;
        	}
        	
        	return _mic.activityLevel;
        }
        private function initDevices():void //camera/mic init
		{ 
			initMic();
			initCam();
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
				
//				trace("setting camera width: "+_camera_width);
//				trace("setting camera height: "+_camera_height);
//				trace("setting camera fps: "+_camera_fps);
				
//				_camera.setKeyFrameInterval(30); //original 48.. default is 15
				_camera.setKeyFrameInterval(12); //original 48.. default is 15
				_camera.setMotionLevel(0);
//				_camera.setLoopback(true);
				_camera.addEventListener(StatusEvent.STATUS, function(evt:StatusEvent):void{
					trace(evt.code);
					if(evt.code=="Camera.Muted"){
						trace("no access to the camera");
						camera_active=false;
					}
				})
				
				_camera.addEventListener(ActivityEvent.ACTIVITY, function(evt:ActivityEvent):void{
					trace("camera active: "+evt.activating)
					camera_active=evt.activating;
					dispatch(new DeviceEvent(DeviceEvent.CAMERA_ACTIVITY,evt.activating));
				})
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
			
			_mic.codec = SoundCodec.SPEEX;
			_mic.framesPerPacket = 1;
			_mic.setLoopBack(true);
	
//			_mic.setSilenceLevel(0);
			_mic.rate=11;
			_mic.setUseEchoSuppression(true);
			_mic.addEventListener(ActivityEvent.ACTIVITY, function(evt:ActivityEvent):void{
//				trace(evt.toString());
				if(evt.activating){
					mic_active = evt.activating;
					dispatch(new DeviceEvent(DeviceEvent.MIC_ACTIVITY,evt.activating));
				}
			});
			_mic.addEventListener(StatusEvent.STATUS, function(evt:StatusEvent):void{
				trace(evt.code);
				if(evt.code=="Microphone.Muted"){
					trace("no access to the mic");
					mic_active = false;
				}
			});
			
			if(_mic!=null){
				_mic_level_timer.start();
			} else {
				_mic_level_timer.reset();
			}
			
			return _mic;
		}
		
		//public methods
		public function get camera():Camera
        {
        	return _camera;
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
