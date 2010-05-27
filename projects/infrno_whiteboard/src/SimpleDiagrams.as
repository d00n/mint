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
//	Swiz.dispatchEvent(new ApplicationEvent(ApplicationEvent.INIT_APP, true));
		
	var loader_info:LoaderInfo = this.loaderInfo;
	var flash_vars:Object = loader_info.parameters;
	
	try{
		trace("SimpleDiagrams onAppComplete() parent load parameters");
		flash_vars = loader_info.loader.loaderInfo.parameters;
	}catch(e:Object){
		trace("SimpleDiagrams onAppComplete() not loaded by another movie");
	}
		
	var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.LOAD_FLASHVARS);
	
	try{
		rsoEvent.auth_key = flash_vars.auth_key;
	}catch(e:Object){
		trace("SimpleDiagrams onAppComplete() flash_vars.auth_key not set");
	}

	try{
		rsoEvent.username = flash_vars.username;
	}catch(e:Object){
		trace("SimpleDiagrams onAppComplete() flash_vars.username not set");
	}

	try{
		rsoEvent.room_id = flash_vars.room_id;
	}catch(e:Object){
		trace("SimpleDiagrams onAppComplete() flash_vars.room_id not set");
	}
	
	Swiz.dispatchEvent(rsoEvent);
}


//TODO: implement this when Swiz remote calls are implemented
protected function genericFault(fe:FaultEvent):void
{
	Logger.error("#FAULT EVENT: " + fe)
}


