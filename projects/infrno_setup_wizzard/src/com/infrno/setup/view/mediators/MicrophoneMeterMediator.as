package com.infrno.setup.view.mediators
{
	import com.infrno.setup.model.DeviceProxy;
	import com.infrno.setup.model.events.DeviceEvent;
	import com.infrno.setup.view.components.MicrophoneMeter;
	
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
			eventMap.mapListener(eventDispatcher,DeviceEvent.MIC_LEVEL,micLevelUpdate);
		}
		
		override public function onRemove( ):void
		{
			eventMap.unmapListener(eventDispatcher,DeviceEvent.MIC_LEVEL,micLevelUpdate);
		}

		private function micLevelUpdate(e:DeviceEvent):void
		{
			microphoneMeter.level = e.value as int;
		}
		
	}
}