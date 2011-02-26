package com.infrno.chat.model.vo
{
	import com.infrno.chat.model.events.PeerEvent;
	
	import mx.collections.ArrayCollection;
	
	public class PeerStatsVO
	{
		public var suid:int;		
		
		[Bindable]
		public var data_array:ArrayCollection = new ArrayCollection();
    
		public function PeerStatsVO()
		{
		}
	}
}