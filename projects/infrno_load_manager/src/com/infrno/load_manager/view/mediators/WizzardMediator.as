package com.infrno.load_manager.view.mediators
{
	import com.infrno.load_manager.model.events.EventConstants;
	import com.infrno.load_manager.view.components.Wizzard;
	
	import flash.events.Event;
	
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
			wizzard.addEventListener( EventConstants.WIZZARD_CLOSE, closeWizzard );
		}
		
		public function closeWizzard( event:Event ) : void
		{
			trace( "WizzardMediator.closeWizzard( )" );
			dispatch( new Event( EventConstants.WIZZARD_COMPLETE ) );
		}
		
	}
}