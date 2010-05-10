package com.inferno.multiplayer.model.events
{
	import flash.events.Event;
	
	public class MSEvent extends Event
	{
		public static const GET_USER_STATS				:String		= "get_user_stats";

		public static const NETCONNECTION_CONNECTED		:String		= "netconnection_connected";
		public static const NETCONNECTION_CONNECTING	:String		= "netconnection_connecting";
		public static const NETCONNECTION_DISCONNECTED	:String		= "netconnection_disconnected";

		public static const USERS_OBJ_UPDATE			:String		= "users_obj_update";
		
		private var _message							:String;
		
		public function MSEvent(type:String, message:String = null)
		{
			super(type);
			_message = message;
		}
		
		public function get message():String
		{
			return _message;
		}
	}
}