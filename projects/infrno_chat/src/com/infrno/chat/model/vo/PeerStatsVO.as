package com.infrno.chat.model.vo
{
	import com.infrno.chat.model.events.PeerEvent;
	
	public class PeerStatsVO
	{
		public var suid:int;		
		
		[Bindable]
		public var srtt_array:Array = new Array();
    
		public function PeerStatsVO()
		{
		}
	}
}