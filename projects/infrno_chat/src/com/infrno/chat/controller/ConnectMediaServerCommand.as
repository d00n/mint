package com.infrno.chat.controller
{
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.PeerService;
	
	import org.robotlegs.mvcs.Command;
	
	public class ConnectMediaServerCommand extends Command
	{
		[Inject]
		public var msService:MSService;
		
		override public function execute():void
		{
			msService.connect();
		}
	}
}