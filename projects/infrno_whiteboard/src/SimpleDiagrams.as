import com.simplediagrams.events.ApplicationEvent;
import com.simplediagrams.events.RemoteSharedObjectEvent;
import com.simplediagrams.util.Logger;

import flash.events.KeyboardEvent;

import org.swizframework.Swiz;


//TODO: Implement updated when AIR 2.0 released
//private var updater:ApplicationUpdaterUI 


protected function onKeyDown(event:KeyboardEvent):void
{
	Logger.debug("app level key down", this)
}


protected function onPreInit():void
{	
	
	Logger.info("#SIMPLEDIAGRAMS: PRE-INITIALIZED")
	Logger.info("==================================================") 
	
	/*
	updater = new ApplicationUpdaterUI();
	updater.configurationFile = new File("app:/config/updaterConfig.xml");
	updater.addEventListener(UpdateEvent.INITIALIZED, updaterInitialized);
	updater.initialize();  			
	*/
}

/*
private function updaterInitialized(event:UpdateEvent):void
{
updater.checkNow();
}
protected function onUpdaterInit(event:UpdateEvent):void
{
isFirstRun = event.target.isFirstRun
} 
*/



protected function onAppComplete():void
{
//	Security.loadPolicyFile("http://admin.infrno.net/crossdomain.xml");
	
	Swiz.dispatchEvent(new ApplicationEvent(ApplicationEvent.INIT_APP, true));
		
	var loader_info:LoaderInfo = this.loaderInfo;
	var flash_vars:Object = loader_info.parameters;

	var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.LOAD_FLASHVARS);

	try{
		Logger.debug("SimpleDiagrams.as onAppComplete() parent load parameters");
		flash_vars = loader_info.loader.loaderInfo.parameters;
	}catch(e:Object){
		Logger.debug("SimpleDiagrams.as onAppComplete() not loaded by another movie");

		// To facilitate dev work, rsoEvent has default values set for auth_key and room_id. 
		// Wowza will accept these values for specified hosts.
		Swiz.dispatchEvent(rsoEvent);
		return;
	}
		

	if (flash_vars.auth_key != null)
		rsoEvent.auth_key = flash_vars.auth_key;
	
	if (flash_vars.room_id != null)
		rsoEvent.room_id = flash_vars.room_id;
	
	if (flash_vars.room_name != null)
		rsoEvent.room_name = flash_vars.room_name;
	
	if (flash_vars.user_name != null)
		rsoEvent.user_name = flash_vars.user_name;
	
	if (flash_vars.user_id != null)
		rsoEvent.user_id = flash_vars.user_id;
	
	if (flash_vars.wowza_server != null)
		rsoEvent.wowza_server = flash_vars.wowza_server;
	
	if (flash_vars.wowza_whiteboard_app != null)
		rsoEvent.wowza_whiteboard_app = flash_vars.wowza_whiteboard_app;
	
	if (flash_vars.image_server != null)
		rsoEvent.image_server = flash_vars.image_server;
	
	
	Swiz.dispatchEvent(rsoEvent);
}


//TODO: implement this when Swiz remote calls are implemented
protected function genericFault(fe:FaultEvent):void
{
	Logger.error("#FAULT EVENT: " + fe)
}


