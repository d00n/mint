package com.infrno.setup.controller
{
	import com.infrno.setup.model.events.SettingsEvent;
	
	import flash.system.Security;
	import flash.system.SecurityPanel;
	
	import org.robotlegs.mvcs.Command;
	
	public class SettingsCommand extends Command
	{
		[Inject]
		public var event		:SettingsEvent;
		
		override public function execute():void
		{
			switch (event.type){
				case SettingsEvent.SHOW_CAMERA_SETTINGS:
					Security.showSettings(SecurityPanel.CAMERA);
					break;
				case SettingsEvent.SHOW_MIC_SETTINGS:
					Security.showSettings(SecurityPanel.MICROPHONE);
					break;
				case SettingsEvent.SHOW_SAVE_SETTINGS:
					Security.showSettings(SecurityPanel.PRIVACY);
					break;
			}
		}
	}
}