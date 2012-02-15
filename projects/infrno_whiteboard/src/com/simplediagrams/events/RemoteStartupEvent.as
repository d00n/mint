package com.simplediagrams.events
{
	import com.simplediagrams.business.RemoteLibraryDelegate;
	
	import flash.events.Event;

	public class RemoteStartupEvent extends Event
	{
		public static const CONNECT_LOGGER:String = "rle_connectLogger";
		public static const DISCONNECT_LOGGER:String = "rle_disconnectLogger";
		public static const STATUS:String = "rle_Status";
		public var status:String;
		
		public function RemoteStartupEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}