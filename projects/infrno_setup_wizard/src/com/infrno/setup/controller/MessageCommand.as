package com.infrno.setup.controller
{
	import com.infrno.setup.model.events.MessageEvent;
	
	import flash.display.Sprite;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;
	
	import org.robotlegs.mvcs.Command;
	
	public class MessageCommand extends Command
	{
		[Inject]
		public var event		:MessageEvent;
		
		override public function execute():void
		{
			Alert.show(event.message, event.type, mx.controls.Alert.OK, contextView.parent as Sprite);
		}
	}
}