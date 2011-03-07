package com.infrno.chat.model.vo
{
	import com.infrno.chat.model.StatsProxy;
	import com.infrno.chat.model.events.PeerEvent;
	
	import mx.collections.ArrayCollection;
	
	public class StatsVO
	{
		public var suid:String;				
		
		[Bindable]
		public var data_AC:ArrayCollection = new ArrayCollection();
		
		private var _lastDataRecord:Object;
    
		public function StatsVO()
		{
			// Filling the data_array with empty objects makes the LineChart 
			// avoid the compression-like behavior while it fills from 0 to max
			for (var i:int = 0; i < StatsProxy.NUMBER_OF_DATA_RECORDS_TO_KEEP ; i++) 
				data_AC.addItem(new Object);
		}
		
		public function get lastDataRecord():Object {
			return data_AC.getItemAt(data_AC.length - 1);
		}
	}
}