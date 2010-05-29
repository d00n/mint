package com.infrno.load_manager.view.mediators
{
	import com.infrno.load_manager.model.events.EventConstants;
	import com.infrno.load_manager.view.components.Wizzard;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class WizzardMediator extends Mediator
	{
		[Inject]
		public var wizzard			:Wizzard;
		
		public function WizzardMediator()
		{
			super();
		}
		
		override public function onRegister():void
		{
			wizzard.addEventListener(MouseEvent.CLICK,closeWizzard);
		}
		
		private function closeWizzard(e:MouseEvent):void
		{
			if(e.target != wizzard.close_btn)
				return;
			trace("WizzardMediator.closeWizzard() hit me");
			dispatch(new Event(EventConstants.WIZZARD_COMPLETE));
		}
		
	}
}