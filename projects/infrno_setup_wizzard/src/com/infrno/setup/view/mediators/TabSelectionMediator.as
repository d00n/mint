package com.infrno.setup.view.mediators
{
	import com.infrno.setup.model.DeviceProxy;
	import com.infrno.setup.model.events.SettingsEvent;
	import com.infrno.setup.view.components.TabSelection;
	
	import mx.core.UIComponent;
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class TabSelectionMediator extends Mediator
	{
		[Inject]
		public var tab_selection	:TabSelection;
		
		[Inject]
		public var deviceProxy		:DeviceProxy;
		
		public function TabSelectionMediator()
		{
			super();
		}
		
		override public function onRegister():void
		{
			tab_selection.addEventListener(SettingsEvent.SHOW_CAMERA_SETTINGS,showSettings);
			tab_selection.addEventListener(SettingsEvent.SHOW_MIC_SETTINGS,showSettings);
			tab_selection.addEventListener(SettingsEvent.SHOW_SAVE_SETTINGS,showSettings);
			tab_selection.addEventListener("WIZZARD_CLOSE", handleWizzardClose, false, 0, true );
		}
		
		override public function onRemove():void
		{
			tab_selection.removeEventListener(SettingsEvent.SHOW_CAMERA_SETTINGS,showSettings);
			tab_selection.removeEventListener(SettingsEvent.SHOW_MIC_SETTINGS,showSettings);
			tab_selection.removeEventListener(SettingsEvent.SHOW_SAVE_SETTINGS,showSettings);
		}
		
		public function handleWizzardClose( event:Event ) : void
		{
			deviceProxy.releaseResources( );
		}
		private function showSettings(e:SettingsEvent):void
		{
			dispatch(new SettingsEvent(e.type));
		}
	}
}