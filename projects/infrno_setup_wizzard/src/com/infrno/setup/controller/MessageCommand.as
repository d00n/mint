package com.infrno.setup.controller
{
	import com.infrno.setup.model.events.MessageEvent;
	
	import mx.controls.Alert;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;
	
	import org.robotlegs.mvcs.Command;
	
	public class MessageCommand extends Command
	{
		[Inject]
		public var event		:MessageEvent;
		
		override public function execute():void
		{
			// the relevant manager (AlertManager?) needs to be linked
			// from this swf to the containing swf.
			// 'using adobe flex 4', page 188
			Alert.show(event.message, event.type, mx.controls.Alert.OK);
		}
	}
}