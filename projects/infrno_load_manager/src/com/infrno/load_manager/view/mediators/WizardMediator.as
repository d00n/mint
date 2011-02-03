package com.infrno.load_manager.view.mediators
{
	import com.infrno.load_manager.model.events.EventConstants;
	import com.infrno.load_manager.view.components.Wizard;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class WizardMediator extends Mediator
	{
		[Inject]
		public var wizard			:Wizard;
		
		public function WizardMediator()
		{
			super();
		}
		
		override public function onRegister():void
		{
			wizard.addEventListener( EventConstants.WIZARD_CLOSE, closeWizard );
		}
		
		public function closeWizard( event:Event ) : void
		{
			trace( "WizardMediator.closeWizard( )" );
			dispatch( new Event( EventConstants.WIZARD_COMPLETE ) );
		}
		
	}
}