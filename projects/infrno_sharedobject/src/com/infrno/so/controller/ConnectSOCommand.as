package com.infrno.so.controller
{
	import com.infrno.so.model.SharedObjectProxy;
	import com.infrno.so.model.events.NetConnectionEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class ConnectSOCommand extends Command
	{
		[Inject]
		public var event				:NetConnectionEvent;
		
		[Inject]
		public var sharedObjectProxy	:SharedObjectProxy;
		
		override public function execute():void
		{
			sharedObjectProxy.initSharedObject();
		}
	}
}