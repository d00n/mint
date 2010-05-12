package com.infrno.so.model.events
{
	import flash.events.Event;
	
	public class SOUpdateEvent extends Event
	{
		public static const PROPERTY_UPDATE		:String = "so_property_update";
		
		private var _value						:Object;
		
		public function SOUpdateEvent(type:String, value:Object=null)
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