package com.inferno.multiplayer.controller
{
	import com.inferno.multiplayer.services.MSService;
	import com.inferno.multiplayer.services.PeerService;
	
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