package com.infrno.so.controller
{
	import com.infrno.so.model.events.BoxUpdateEvent;
	import com.infrno.so.services.ConnectorService;
	
	import org.robotlegs.mvcs.Command;
	
	public class UpdateSOCommand extends Command
	{
		[Inject]
		public var event				:BoxUpdateEvent;
		
		[Inject]
		public var connector_service	:ConnectorService;
		
		override public function execute():void
		{
			trace("box updated");
			var info_obj:Object = {};
			info_obj.x = event.value.x;
			info_obj.y = event.value.y;
			connector_service.so.setProperty(event.value.id,info_obj);
		}
	}
}