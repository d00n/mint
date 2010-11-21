package com.simplediagrams.controllers
{
	import com.simplediagrams.business.DBManager;
	import com.simplediagrams.events.DatabaseEvent;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.util.Logger;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	
	import org.swizframework.controller.AbstractController;
	
	/** Simple class to abstract out some of the desktop-specific functions */
	
	public class DesktopController extends AbstractController
	{
		public function DesktopController()
		{
		}
		
		
		[Inject]
		public var dbManager:DBManager
			
		
		
		/* Do all the things we need to do when starting up the desktop-version. 
		These functions are contained here so that they remain abstracted from core functions and are easy
		to turn-off when running in "integrated" mode */
				
		[Mediate("mx.events.FlexEvent.APPLICATION_COMPLETE" )] 
		public function setupDatabase():void
		{				
			return

			
		}
		
		
		
		protected function onDBConnectionOpened(event:Event):void
		{			
			return
		}
		
		protected function onDBConnectionError(event:Event):void
		{
			return
		}
		
		
		
		
		
	}
}