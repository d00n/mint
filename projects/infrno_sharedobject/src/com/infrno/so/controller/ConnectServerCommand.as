package com.infrno.so.controller
{
	import com.infrno.so.services.ConnectorService;
	
	import org.robotlegs.mvcs.Command;
	
	public class ConnectServerCommand extends Command
	{
		[Inject]
		public var connectorService		:ConnectorService;
		
		override public function execute():void
		{
			connectorService.connect();
		}
	}
}