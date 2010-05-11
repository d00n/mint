package com.infrno.multiplayer.controller
{
	import com.infrno.multiplayer.services.MSService;
	import com.infrno.multiplayer.services.PeerService;
	
	import org.robotlegs.mvcs.Command;
	
	public class ConnectMediaServerCommand extends Command
	{
		[Inject]
		public var msService	:MSService;
		
		override public function execute():void
		{
			msService.connect();
		}
	}
}