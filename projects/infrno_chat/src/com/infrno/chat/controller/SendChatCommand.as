package com.infrno.chat.controller
{
	import com.infrno.chat.model.events.ChatEvent;
	import com.infrno.chat.services.MSService;
	
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