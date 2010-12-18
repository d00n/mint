//import air.update.ApplicationUpdaterUI;
//import air.update.events.UpdateEvent;

import com.simplediagrams.controllers.MenuController;
import com.simplediagrams.events.ApplicationEvent;
import com.simplediagrams.events.CloseDiagramEvent;
import com.simplediagrams.events.CreateNewDiagramEvent;
import com.simplediagrams.events.LoadDiagramEvent;
import com.simplediagrams.util.Logger;

import flash.events.KeyboardEvent;

//import mx.events.FlexNativeMenuEvent;

import com.simplediagrams.events.RemoteSharedObjectEvent;

//protected var _updater:ApplicationUpdaterUI

import flash.system.Capabilities; 
import flash.ui.Keyboard; 
import com.simplediagrams.model.ApplicationModel;
import com.simplediagrams.util.MenuItem;
//import flash.display.NativeMenuItem;
import com.simplediagrams.events.SDMenuEvent;
import mx.rpc.events.FaultEvent;

private var _isWin:Boolean; 
private var _isMac:Boolean; 


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


//TODO: implement this when Swiz remote calls are implemented
protected function genericFault(fe:FaultEvent):void
{
	Logger.error("#FAULT EVENT: " + fe)
}





