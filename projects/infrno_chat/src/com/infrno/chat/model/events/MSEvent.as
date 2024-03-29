package com.infrno.chat.model.events
{
	import com.infrno.chat.model.vo.UserInfoVO;
	
	import flash.events.Event;
	
	public class MSEvent extends Event
	{
		public static const NETCONNECTION_CONNECTED:String			= "mse_netconnection_connected";
		public static const NETCONNECTION_CONNECTING:String			= "mse_netconnection_connecting";
		public static const NETCONNECTION_DISCONNECTED:String		= "mse_netconnection_disconnected";
		

		// TODO break this into add/delete/change
		public static const USERS_OBJ_UPDATE:String							= "mse_users_obj_update";
		
		private var _message:String;
		
		public var userInfoVO_array:Array;
		public var local_userInfoVO:UserInfoVO;
		
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