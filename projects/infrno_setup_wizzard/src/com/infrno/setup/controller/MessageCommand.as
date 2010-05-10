package com.infrno.setup.controller
{
	import com.infrno.setup.model.events.MessageEvent;
	
	import mx.controls.Alert;
	
	import org.robotlegs.mvcs.Command;
	
	public class MessageCommand extends Command
	{
		[Inject]
		public var event		:MessageEvent;
		
		override public function execute():void
		{
			Alert.show(event.message, event.type, mx.controls.Alert.OK);
		}
	}
}