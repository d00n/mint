package com.infrno.setup.model.events
{
	import flash.events.Event;
	
	public class DeviceEvent extends Event
	{
		public static const CAMERA_CHANGED:String			= "camera_changed";
		public static const MIC_CHANGED:String				= "mic_changed";
		
		public static const CAMERA_ACTIVITY:String			= "camera_activity";
		public static const MIC_ACTIVITY:String				= "mic_activity";
		public static const MIC_LEVEL:String				= "mic_level";
		
		private var _value		:Object;
		
		public function DeviceEvent(type:String, value:Object=null)
		{
			super(type);
			_value = value;
		}
		
		public function get value():Object
		{
			return _value;
		}
	}
}