package com.infrno.chat.controller
{
	import com.infrno.chat.model.StatsProxy;
	import com.infrno.chat.model.events.PeerEvent;
	
	import org.robotlegs.mvcs.Command;
	
	// not used
	public class InitPeerStatsVOCommand extends Command
	{
		[Inject]
		public var statsProxy:StatsProxy;
		
		[Inject]
		public var peerEvent:PeerEvent;
		
		override public function execute():void
		{
			statsProxy.initPeerStatsVO(peerEvent.value);
		}
		
	}
}