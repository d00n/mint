package com.infrno.so.model.events
{
	import flash.events.Event;
	
	public class BoxUpdateEvent extends Event
	{
		public static const PROPERTY_UPDATE		:String = "box_property_update";
		
		private var _value						:Object;
		
		public function BoxUpdateEvent(type:String, value:Object = null)
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