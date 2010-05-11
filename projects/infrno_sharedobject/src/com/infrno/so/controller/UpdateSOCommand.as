package com.infrno.so.controller
{
	import com.infrno.so.model.SharedObjectProxy;
	import com.infrno.so.model.events.BoxUpdateEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class UpdateSOCommand extends Command
	{
		[Inject]
		public var event				:BoxUpdateEvent;
		
		[Inject]
		public var sharedObjectProxy	:SharedObjectProxy;
		
		override public function execute():void
		{
			trace("box updated");
			var info_obj:Object = {};
			info_obj.x = event.value.x;
			info_obj.y = event.value.y;
			sharedObjectProxy.so.setProperty(event.value.id,info_obj);
		}
	}
}