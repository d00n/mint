package com.infrno.load_manager.view.mediators
{
	import com.infrno.load_manager.model.events.EventConstants;
	import com.infrno.load_manager.view.components.DisplayManager;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class DisplayManagerMediator extends Mediator
	{
		[Inject]
		public var displayManager		:DisplayManager;
		
		public function DisplayManagerMediator()
		{
			super();
		}
		
		override public function onRegister():void
		{
			eventDispatcher.addEventListener(EventConstants.LOAD_CHAT,loadChat);
			eventDispatcher.addEventListener(EventConstants.LOAD_WIZARD,loadWizard);
			
			dispatch(new Event(EventConstants.DISPLAY_MANAGER_LOADED));
		}
		
		private function loadChat(e:Event):void
		{
			displayManager.wizard = null;
			displayManager.currentState = "chat";
		}
		private function loadWizard(e:Event):void
		{
			displayManager.currentState = "wizard";
		}
	}
}