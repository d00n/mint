import com.simplediagrams.events.RemoteSharedObjectEvent;

import com.simplediagrams.controllers.MenuController;
import com.simplediagrams.events.ApplicationEvent;
import com.simplediagrams.events.CloseDiagramEvent;
import com.simplediagrams.events.CreateNewDiagramEvent;
import com.simplediagrams.events.LoadDiagramEvent;
import com.simplediagrams.events.SDMenuEvent;
import com.simplediagrams.model.ApplicationModel;
import com.simplediagrams.util.Logger;
import com.simplediagrams.util.MenuItem;

import flash.events.KeyboardEvent;
import flash.system.Capabilities;
import flash.ui.Keyboard;

import mx.rpc.events.FaultEvent;

//import org.swizframework.processors.DispatcherProcessor;
import com.simplediagrams.events.RemoteSharedObjectEvent;

private var _isWin:Boolean; 
private var _isMac:Boolean; 

[Dispatcher]
public var dispatcher:IEventDispatcher;

protected function onPreInit():void
{	
	
	_isWin = (Capabilities.os.indexOf("Windows") >= 0); 
	_isMac = (Capabilities.os.indexOf("Mac OS") >= 0); 
	
	Logger.info("#SIMPLEDIAGRAMS: PRE-INITIALIZED")
	Logger.info("==================================================") 
		
		
	
//	_updater = new ApplicationUpdaterUI();
//	_updater.configurationFile = File.applicationDirectory.resolvePath("config/updaterConfig.xml");
//	_updater.addEventListener(UpdateEvent.INITIALIZED, updaterInitialized);
//	_updater.initialize();  			
//	Logger.info("updater initialized")
	
}



//protected function keyEquivalentModifiers(item:Object):Array 
//{ 
//	var result:Array = new Array(); 
//	
//	var keyEquivField:String = menu.keyEquivalentField; 
//	var altKeyField:String; 
//	var controlKeyField:String; 
//	var shiftKeyField:String; 
//	if (item is XML) 
//	{ 
//		altKeyField = "@altKey"; 
//		controlKeyField = "@controlKey"; 
//		shiftKeyField = "@shiftKey"; 
//	} 
//	else if (item is Object) 
//	{ 
//		altKeyField = "altKey"; 
//		controlKeyField = "controlKey"; 
//		shiftKeyField = "shiftKey"; 
//	} 
//	
//	if (item[keyEquivField] == null || item[keyEquivField].length == 0) 
//	{ 
//		return result; 
//	} 
//	
//	if (item[altKeyField] != null && item[altKeyField] == true) 
//	{ 
//		if (_isWin) 
//		{ 
//			result.push(Keyboard.ALTERNATE); 
//		} 
//	} 
//	
//	var val:Boolean = false
//	val = item[controlKeyField]
//	
//	if (item[controlKeyField] != null && item[controlKeyField] == true) 
//	{ 
//		if (_isMac) 
//		{ 
//			result.push(Keyboard.COMMAND); 
//		} 
//		else
//		{
//			result.push(Keyboard.CONTROL); 
//		}
//	} 
//	
//	if (item[shiftKeyField] != null && item[shiftKeyField] == true) 
//	{ 
//		result.push(Keyboard.SHIFT); 
//	} 
//	
//	return result; 
//} 


//protected function updaterInitialized(event:UpdateEvent):void
//{
//	_updater.checkNow();
//}


//protected function onMenuItemClick(event:FlexNativeMenuEvent):void
//{
//	if (event.item && event.item.data)
//	{
//		var evt:SDMenuEvent = new SDMenuEvent(SDMenuEvent.MENU_COMMAND)
//		evt.command = event.item.data
//		dispatchEvent(evt)
//	}
//}


protected function onApplicationComplete():void
{
//	Security.loadPolicyFile("http://admin.infrno.net/crossdomain.xml");
//	dispatcher.dispatchEvent(new ApplicationEvent(ApplicationEvent.INIT_APP, true));
		
	Logger.debug("onApplicationComplete()", this);
		
	var loader_info:LoaderInfo = this.loaderInfo;
	var flash_vars:Object = loader_info.parameters;

	var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.LOAD_FLASHVARS);

	try{
		flash_vars = loader_info.loader.loaderInfo.parameters;
	}catch(e:Object){
		Logger.debug("onApplicationComplete() not loaded by another movie", this);
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
	
	if (flash_vars.library_server != null)
		rsoEvent.library_server = flash_vars.library_server;
	
	if (flash_vars.library_base_path != null)
		rsoEvent.library_base_path = flash_vars.library_base_path;
	
	if (flash_vars.library_registry_file != null)
		rsoEvent.library_registry_file = flash_vars.library_registry_file;
	
//	if (flash_vars.google_analytics_debug_mode != null)
//		rsoEvent.google_analytics_debug_mode = (Boolean) flash_vars.google_analytics_debug_mode;
//	
//	if (flash_vars.google_analytics_report_interval_seconds != null)
//		rsoEvent.google_analytics_report_interval_seconds = (int) flash_vars.google_analytics_report_interval_seconds;
	
	
	dispatcher.dispatchEvent(rsoEvent);
}


//TODO: implement this when Swiz remote calls are implemented
protected function genericFault(fe:FaultEvent):void
{
	Logger.error("#FAULT EVENT: " + fe)
}


