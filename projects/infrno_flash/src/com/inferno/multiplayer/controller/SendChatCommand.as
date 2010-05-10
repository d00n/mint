package com.inferno.multiplayer.controller
{
	import com.inferno.multiplayer.model.events.ChatEvent;
	import com.inferno.multiplayer.services.MSService;
	
	import org.robotlegs.mvcs.Command;
	
	public class SendChatCommand extends Command
	{
		[Inject]
		public var event:ChatEvent;
		
		[Inject]
		public var msService:MSService;
		
		override public function execute():void
		{
			msService.chatToServer(event.message);
		}
		
	}
}