package com.infrno.chat.controller
{
	import com.infrno.chat.model.events.SettingsEvent;
	
	import flash.system.Security;
	import flash.system.SecurityPanel;
	
	import org.robotlegs.mvcs.Command;
	
	public class SettingsCommand extends Command
	{
		[Inject]
		public var event:SettingsEvent;
		
		override public function execute( ) : void
		{
			Security.showSettings( SecurityPanel.CAMERA );
		}
	}
}