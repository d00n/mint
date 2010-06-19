package com.infrno.setup.view.mediators
{
	import com.infrno.setup.model.DeviceProxy;
	import com.infrno.setup.view.components.MicrophoneMeter;
	import flash.events.Event;
	import org.robotlegs.mvcs.Mediator;
	
	public class MicrophoneMeterMediator extends Mediator
	{
		[Inject]
		public var microphoneMeter:MicrophoneMeter;
		
		[Inject]
		public var deviceProxy:DeviceProxy;
		
		public function MicrophoneMeterMediator( )
		{
			super( );
		}
		
		override public function onRegister( ):void
		{
			microphoneMeter.addEventListener( Event.ENTER_FRAME, handleEnterFrame, false, 0, true );
		}
		
		override public function onRemove( ):void
		{
			microphoneMeter.removeEventListener( Event.ENTER_FRAME, handleEnterFrame );
		}
		
		public function handleEnterFrame( event:Event ) : void 
		{
			if( null == deviceProxy ) 
			{
				return;
			}
			
			var microphoneValue:int = deviceProxy.mic_level;
			trace( "handleEnterFrame( ) microphoneValue=" + microphoneValue );
			microphoneMeter.level = microphoneValue; 
		}
	}
}