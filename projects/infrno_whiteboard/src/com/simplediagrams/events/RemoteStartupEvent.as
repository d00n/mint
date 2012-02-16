package com.simplediagrams.events
{
	import com.simplediagrams.business.RemoteLibraryDelegate;
	
	import flash.events.Event;

	public class RemoteStartupEvent extends Event
	{
		public static const CONNECT_LOGGER:String = "rle_connectLogger";
		public static const DISCONNECT_LOGGER:String = "rle_disconnectLogger";
		public static const COMPLETE:String = "rle_complete";
		public static const STATUS:String = "rle_Status";
		public static const ERROR:String = "rle_Error";
		public var status:String;
		public var error:String;
		
		public function RemoteStartupEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}