package com.infrno.chat.controller
{
	import com.infrno.chat.model.events.LogEvent;
	import com.infrno.chat.services.MSService;
	
	import org.robotlegs.mvcs.Command;
	
	public class SendLogMessageCommand extends Command
	{
		[Inject]
		public var event:LogEvent;
		
		[Inject]
		public var msService:MSService;
		
		override public function execute():void
		{
//			var msg:String = event.location +", "+ event.peer +", "+ event.message;
//			msService.sendLogMessageToServer(msg);
		}
		
	}
}