package com.simplediagrams.controllers
{
	import com.simplediagrams.business.FileManager;
	import com.simplediagrams.commands.TransformCommand;
	import com.simplediagrams.errors.SDObjectModelNotFoundError;
	import com.simplediagrams.events.*;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.ConnectionPoint;
	import com.simplediagrams.model.DiagramManager;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDPencilDrawingModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.model.SDTextAreaModel;
	import com.simplediagrams.model.SettingsModel;
	import com.simplediagrams.model.UndoRedoManager;
	import com.simplediagrams.model.libraries.Library;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.SDComponents.SDBase;
	import com.simplediagrams.view.SDComponents.SDLine;
	import com.simplediagrams.view.SDComponents.SDTextArea;
	import com.simplediagrams.view.dialogs.DiagramPropertiesDialog;
	import com.simplediagrams.vo.UserInfoVO;
	
	import flash.display.BitmapData;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.SyncEvent;
	import flash.events.TimerEvent;
	import flash.net.FileFilter;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.describeType;
	
	import flashx.textLayout.formats.Category;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.object_proxy;
	
	import org.swizframework.controller.AbstractController;
	
	import spark.components.Group;
		
	public class RemoteSharedObjectController extends AbstractController
	{
		/** SUCCESS means the client changed the shared object */
		private static const SUCCESS : String = "success";
		
		/** CHANGE means another client changed the object or the server resynchronized the object. */
		private static const CHANGE : String = "change";
		
		private static const SHARED_OBJECT_NAME:String = "whiteboard_contents";
		
		private var _netConnection:NetConnection;
		private var _netStream:NetStream;
		private var _remoteSharedObject:SharedObject;
		
		private var _auth_key:String;
		private var _room_id:String;
		private var _room_name:String;
		private var _user_name:String;
		private var _user_id:String;
		private var _image_server:String;
		private var _wowza_server:String;
		private var _wowza_whiteboard_app:String;
		private var _wowza_whiteboard_port:String;
		
		[Inject]
		public var diagramManager:DiagramManager

		[Inject]
		public var libraryManager:LibraryManager;
		
		public function RemoteSharedObjectController() {
		}
		
		[Mediate(event="RemoteSharedObjectEvent.START")]
		public function connect():void{
				Logger.info("connect", this);
			_netConnection = new NetConnection();
			_netConnection.client = this; 
			
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetConnStatus);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_netConnection.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			
			var clientObj:Object = new Object();
			
			clientObj.initUser = function(user_info:Object):void
			{
				// NOP
			}
				
				
			// TODO: Create/attach (?) a NetStream object, so we can tie it to a chair and ask awkward questions. 
			// Look at ReportStatsCommand.execute for what to report
			clientObj.getUserStats = function():void
			{
//				Logger.info("getUserStats", this);
				
				var user_stats:Object = new Object();
				var ns_info:NetStreamInfo = _netStream.info;
				
				user_stats.application_name			  = "whiteboard";
				user_stats.room_name				      = _room_name;
				user_stats.room_id					      = _room_id;
				user_stats.user_name			      	= _user_name;
				user_stats.user_id					      = _user_id;
				
				user_stats.wowza_protocol			    = _netConnection.protocol;
				user_stats.SRTT 					        = ns_info.SRTT;
				
				user_stats.audioBytesPerSecond 		= int(ns_info.audioBytesPerSecond);
				user_stats.videoBytesPerSecond 		= int(ns_info.videoBytesPerSecond);
				user_stats.dataBytesPerSecond 		= int(ns_info.dataBytesPerSecond);
				
				user_stats.currentBytesPerSecond 	= int(ns_info.currentBytesPerSecond);
				user_stats.maxBytesPerSecond 		  = int(ns_info.maxBytesPerSecond);
				user_stats.byteCount 				      = ns_info.byteCount;
				user_stats.dataByteCount 			    = ns_info.dataByteCount;
				user_stats.videoByteCount			    = ns_info.videoByteCount;
				
				user_stats.audioLossRate 			    = ns_info.audioLossRate;
				user_stats.droppedFrames 			    = ns_info.droppedFrames;
				
				_netConnection.call("reportUserStats",null,user_stats);
			}
						
				
			_netConnection.client = clientObj;
			
			var connection_uri:String = _wowza_server +":"+ _wowza_whiteboard_port +"/"+ _wowza_whiteboard_app  +"/"+ _room_id;
			Logger.info("connect() about to connect to " + connection_uri,this);
			
			
			var userInfoObj:Object = new Object();
			userInfoObj.room_name = _room_name;
			userInfoObj.room_id = _room_id;
			userInfoObj.user_name = _user_name;
			userInfoObj.user_id = _user_id;
			userInfoObj.application_name = "whiteboard";
			userInfoObj.application_version = ApplicationModel.VERSION;
			var userInfoVO:UserInfoVO = new UserInfoVO(userInfoObj);
			
			
			_netConnection.connect(connection_uri, 
				userInfoVO, 
				_auth_key, 
				_room_id, 
				_room_name, 
				_wowza_whiteboard_app, 
				ApplicationModel.VERSION, 
				Capabilities.serverString);     
		}
		
		public function onNetConnStatus( event : NetStatusEvent) : void {
			Logger.info("onNetConnStatus()" + event,this);	
			if (event.info !== '' || event.info !== null) {  
				switch (event.info.code) {
					case "NetConnection.Connect.Success":   
						Logger.info("onNetConnStatus NetConnection.Connect.Success", this);  
						createSharedObject();  
						break;
					case "NetConnection.Connect.Closed":  
						// TODO: tell the user the connection failed
						Logger.info("onNetConnStatus NetConnection.Connect.Closed", this);  
						break;
				}      
			}
		}
		
		private function createSharedObject() : void {
			Logger.info("createSharedObject()",this);	
			_netStream = new NetStream(_netConnection);
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, onCreateSOStatus);
			_netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			_netStream.client = this;    
						
			try {
				_remoteSharedObject = SharedObject.getRemote(SHARED_OBJECT_NAME, _netConnection.uri, true);
			} catch(error:Error) {
				Logger.info("createSharedObject() could not create remote shared object: " + error.toString(),this);		
			}
			
			_remoteSharedObject.client = this;
			_remoteSharedObject.addEventListener(SyncEvent.SYNC, onSyncEventHandler);
			_remoteSharedObject.connect(_netConnection); 
		}
		
		public function onCreateSOStatus( event : NetStatusEvent) : void {
			Logger.info("onCreateSOStatus()" + event,this);	
			if (event.info !== '' || event.info !== null) {  
				switch (event.info.code) {
					case "NetConnection.Connect.Success":   
						Logger.info("onCreateSOStatus NetConnection.Connect.Success", this);  
						break;
					case "NetConnection.Connect.Closed":  
						// TODO: tell the user the connection failed
						Logger.info("onCreateSOStatus NetConnection.Connect.Closed", this);  
						break;
				}      
			}
		}		
		
		public function securityErrorHandler(event : SecurityErrorEvent) : void {  Logger.error('securityErrorHandler() '+event, this);  }
		public function ioErrorHandler(event : IOErrorEvent) : void {  Logger.error('ioErrorHandler() :'+event, this);  }
		public function asyncErrorHandler(event : AsyncErrorEvent) : void {  Logger.error('asyncErrorHandler() :'+event, this);  }  		
		
		[Mediate(event="RemoteSharedObjectEvent.RESET")]
		public function reset():void {
			stop();			
			connect();
		}
		
		[Mediate(event="RemoteSharedObjectEvent.STOP")]
		public function stop():void {
			_remoteSharedObject.close();
			_remoteSharedObject = null;
			_netConnection.close();
			_netConnection = null;
			_netStream.close();
			_netStream = null;
		}
		
		[Mediate(event="RemoteSharedObjectEvent.LOAD_FLASHVARS")]
		public function loadFlashvars(event:RemoteSharedObjectEvent):void {
			Logger.info("loadFlashVars", this);
			_auth_key 				= event.auth_key;
			_room_id 				= event.room_id;			
			_room_name 				= event.room_name;			
			_user_name 				= event.user_name;
			_user_id 				= event.user_id;
			_image_server 			= event.image_server;
			_wowza_server 			= event.wowza_server;
			_wowza_whiteboard_app 	= event.wowza_whiteboard_app;
			_wowza_whiteboard_port 	= event.wowza_whiteboard_port;
		}			
		
		private function onSyncEventHandler(event : SyncEvent):void {
			Logger.info("onSyncEventHandler event.changeList.length:" + event.changeList.length,this);	
			var i:int;
			var recordName:String;
			var changeObject:Object;
			for (i = 0; i < event.changeList.length; i++) {
				switch (event.changeList[i].code){
					case SUCCESS:   
						break;
					case CHANGE:  {
						Logger.info("onSyncEventHandler non-Line pass, event.changeList[" +i + "].name:" + event.changeList[i].name,this);	
						
//						if (event.changeList[i].name == 'GridState') {
//   						changeObject = event.target.data.GridState;
//						} else {
//   						id = event.changeList[i].name;
//   						changeObject = event.target.data[id];
//						}
						recordName = event.changeList[i].name;
						changeObject = event.target.data[recordName];
						
						if (changeObject.commandName == "ObjectChanged" && changeObject.sdObjectModelType != "SDLineModel") {
     					processUpdate_ObjectChanged(changeObject);
						}
				    if (changeObject.commandName ==  "ConfigureGrid") {
					    processUpdate_ConfigureGrid(changeObject);
						}
				    if (changeObject.commandName ==  "TextChanged") {
							processUpdate_TextChanged(changeObject);
						}
						break;
					}
				}
			}
				
			for (i = 0; i < event.changeList.length; i++) {
				switch (event.changeList[i].code){
					case SUCCESS:   
						break;
					case CHANGE:  {
						Logger.info("onSyncEventHandler Line pass, event.changeList[" +i + "].name:" + event.changeList[i].name,this);	
						recordName = event.changeList[i].name;
						changeObject = event.target.data[recordName];
      			if (changeObject.commandName == "ObjectChanged" && changeObject.sdObjectModelType == "SDLineModel")
     					processUpdate_LineChanged(changeObject);
						break;
					}
				}
			}
				
			for (i = 0; i < event.changeList.length; i++) {
				switch (event.changeList[i].code){
					case SUCCESS:   
						break;
					case CHANGE:  {
						Logger.info("onSyncEventHandler delete pass, event.changeList[" +i + "].name:" + event.changeList[i].name,this);	
						recordName = event.changeList[i].name;
						changeObject = event.target.data[recordName];
      			if (changeObject.commandName == "DeleteSelectedSDObjectModel")
    					processUpdate_DeleteSelectedFromModel(changeObject);
						break;
					}
				}
			}
		}
	
//		private function routeChange(changeObject:Object) : void {
//			switch (changeObject.commandName) {
//				case "DeleteSelectedSDObjectModel": {
//					processUpdate_DeleteSelectedFromModel(changeObject);
//					break;
//				}
//				case "ObjectChanged": {
//					processUpdate_ObjectChanged(changeObject);
//					break;
//				}			
////				case "UpdateDepths": {
////					processUpdate_UpdateDepths(changeObject);
////					break;
////				}			
//				case "ConfigureGrid": {
//					processUpdate_ConfigureGrid(changeObject);
//					break;
//				}			
//			}
//		}

		[Mediate(event="RemoteSharedObjectEvent.LOAD_IMAGE")]
		public function dispatchUpdate_LoadImage(rsoEvent:RemoteSharedObjectEvent):void {
//			Logger.info("dispatchUpdate_LoadImage() id="+rsoEvent.sdImageModel.id,this);
//			
//			var returnValueFunction:Function = function(imageDetails:Object):void
//			{
//				Logger.info("dispatchUpdate_LoadImage() responder.result() id="+imageDetails["id"]+", url="+imageDetails["imageURL"],this);
//
//				var sdImageModel:SDImageModel = diagramManager.diagramModel.getModelByID(imageDetails["id"]) as SDImageModel;
//				sdImageModel.imageURL = imageDetails["imageURL"];
//				
//				var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
//				rsoEvent.changedSDObjectModelArray = new Array;				
//				rsoEvent.changedSDObjectModelArray.push(sdImageModel);
//				dispatcher.dispatchEvent(rsoEvent);	
//			}
//			
//			var responder:Responder = new Responder(returnValueFunction);
//			
//			_netConnection.call("sendImage", responder, 
//				rsoEvent.imageData, 
//				rsoEvent.imageName,
//				rsoEvent.sdImageModel.id.toString(),
//				_image_server);
		}		

		[Mediate(event="RemoteSharedObjectEvent.DISPATCH_DELETE_SELECTED_FROM_MODEL")]
		public function dispatchUpdate_DeleteSelectedFromModel(event:RemoteSharedObjectEvent) : void {			
			Logger.info("dispatchUpdate_DeleteSelectedFromModel()",this);
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.PROCESS_DELETE_SELECTED_FROM_MODEL);	
			
			for(var i:int=0; i< event.idAC.length; i++) 
			{
				var id:int = event.idAC[i];
				var sd_obj:Object = {};
				sd_obj.commandName = "DeleteSelectedSDObjectModel";
				sd_obj.id = id;						
				_remoteSharedObject.setProperty(sd_obj.id.toString(), sd_obj);
				
  			rsoEvent.idAC.addItem(id);
			}			
			
			dispatcher.dispatchEvent(rsoEvent);   
		}	
		
		public function processUpdate_DeleteSelectedFromModel(changeObject:Object):void {
			Logger.info("processUpdate_DeleteSelectedFromModel()",this);
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.PROCESS_DELETE_SELECTED_FROM_MODEL);	
			rsoEvent.idAC.addItem(changeObject.id);
			dispatcher.dispatchEvent(rsoEvent);   
		}
		
//		[Mediate(event="GridEvent.SHOW_GRID")]    
//		[Mediate(event="GridEvent.CELL_WIDTH")]    
//		[Mediate(event="GridEvent.ALPHA")] 		
		[Mediate(event="RemoteSharedObjectEvent.GRID")]    
		public function onRsoGridEvent(event:RemoteSharedObjectEvent):void{
			var grid_state_obj:Object = {};
			grid_state_obj.commandName 		= "ConfigureGrid";
			grid_state_obj.cell_width 		= event.cell_width;
			grid_state_obj.alpha 					= event.alpha;
			grid_state_obj.show_grid 			= event.show_grid;
			_remoteSharedObject.setProperty("GridState", grid_state_obj);
		}				
		
		public function processUpdate_ConfigureGrid(changeObject:Object) : void {
			Logger.info("processUpdate_ConfigureGrid()",this);
			
			var cellWidthEvent:GridEvent 	= new GridEvent(GridEvent.CELL_WIDTH);
			cellWidthEvent.cell_width 		= changeObject.cell_width;
			var alphaEvent:GridEvent 			= new GridEvent(GridEvent.ALPHA);
			alphaEvent.alpha 							= changeObject.alpha;	
			var showGridEvent:GridEvent 	= new GridEvent(GridEvent.SHOW_GRID);
			showGridEvent.show_grid 			= changeObject.show_grid;
			
			dispatcher.dispatchEvent(alphaEvent);				
			dispatcher.dispatchEvent(cellWidthEvent);				
			dispatcher.dispatchEvent(showGridEvent);				
		}
		
		[Mediate(event="RemoteSharedObjectEvent.TEXT_CHANGED")]
		public function dispatchUpdate_TextChanged(event:RemoteSharedObjectEvent) : void {
			Logger.info("dispatchUpdate_TextChanged() event:"+event.type,this);
			
			for each (var sdObjectModel:SDObjectModel in event.sdObjects)
			{			
				var sd_obj:Object = {};
				sd_obj.commandName 	= "TextChanged";
				sd_obj.id    				= sdObjectModel.id;							
				
				if (sdObjectModel is SDSymbolModel){
					var sdSymbolModel:SDSymbolModel = sdObjectModel as SDSymbolModel;
					
					sd_obj.sdObjectModelType 	= "SDSymbolModel";
					sd_obj.text								= event.text;	
				}
				else if (sdObjectModel is SDTextAreaModel){
					var sdTextAreaModel:SDTextAreaModel = sdObjectModel as SDTextAreaModel;
					
					sd_obj.sdObjectModelType 		= "SDTextAreaModel";
					sd_obj.text									= event.text;	
				}
				
				_remoteSharedObject.setProperty(sd_obj.id.toString(), sd_obj);
			}
		}
		
		public function processUpdate_TextChanged(changeObject:Object) : void {
			Logger.info("processUpdate_TextChanged()",this);
			
			var id:int = changeObject.id;
			switch ( changeObject.sdObjectModelType) {
				case "SDSymbolModel": {
					var sdSymbolModel:SDSymbolModel = diagramManager.diagramModel.getModelByID(id) as SDSymbolModel;
					
					if (sdSymbolModel != null) {
  					sdSymbolModel.text		 			= changeObject.text;
					}
					break;
				}
				case "SDTextAreaModel": {
					var sdTextAreaModel:SDTextAreaModel = diagramManager.diagramModel.getModelByID(id) as SDTextAreaModel;	
					
					if (sdTextAreaModel != null){
  					sdTextAreaModel.text			 					= changeObject.text;
					}
					break;
				}
			}
		}	
		
//		[Mediate(event="RemoteSharedObjectEvent.ADD_SD_OBJECT_MODEL")]
		[Mediate(event="RemoteSharedObjectEvent.DISPATCH_LINE_CONNECTIONS")]
		[Mediate(event="RemoteSharedObjectEvent.LIBRARY_ITEM_ADDED")]
		[Mediate(event="RemoteSharedObjectEvent.TEXT_WIDGET_ADDED")]
		[Mediate(event="RemoteSharedObjectEvent.TEXT_WIDGET_CREATED")]
		[Mediate(event="RemoteSharedObjectEvent.PENCIL_DRAWING_CREATED")]
		[Mediate(event="RemoteSharedObjectEvent.UPDATE_DEPTHS")]
		[Mediate(event="RemoteSharedObjectEvent.OBJECT_CHANGED")]
		public function dispatchUpdate_ObjectChanged(event:RemoteSharedObjectEvent) : void {
			Logger.info("dispatchUpdate_ObjectChanged() event:"+event.type,this);
			
			for each (var sdObjectModel:SDObjectModel in event.sdObjects)
			{			
//				isCorrupt("dispatchUpdate_ObjectChanged", sdObjectModel);
				
				
				
				var sd_obj:Object = {};
				sd_obj.commandName 	= "ObjectChanged";
				sd_obj.id    				= sdObjectModel.id;							
				sd_obj.x 						= sdObjectModel.x;
				sd_obj.y 						= sdObjectModel.y;		
				sd_obj.height 			= sdObjectModel.height;		
				sd_obj.width 				= sdObjectModel.width;		
				sd_obj.rotation			= sdObjectModel.rotation;		
				sd_obj.color 				= sdObjectModel.color;	
				sd_obj.depth 				= sdObjectModel.depth;	
				
				if (sdObjectModel.width < 0) {
					Logger.error("dispatchUpdate_ObjectChanged() sdObjectModel.width is negative: " + sdObjectModel.width, this);
				}
				
				if (sdObjectModel.height < 0){
					Logger.error("dispatchUpdate_ObjectChanged() sdObjectModel.height is negative: " + sdObjectModel.height, this);
				}
				
				if (sdObjectModel is SDSymbolModel){
					var sdSymbolModel:SDSymbolModel = sdObjectModel as SDSymbolModel;
					
					sd_obj.sdObjectModelType 	= "SDSymbolModel";
					sd_obj.libraryName 				= sdSymbolModel.libraryName;				
					sd_obj.symbolName 				= sdSymbolModel.symbolName;		
					sd_obj.fontSize 					= sdSymbolModel.fontSize;
					sd_obj.fontWeight 				= sdSymbolModel.fontWeight;
					sd_obj.fontFamily 				= sdSymbolModel.fontFamily;
					sd_obj.textAlign 					= sdSymbolModel.textAlign;
					sd_obj.textPosition				= sdSymbolModel.textPosition;	
					sd_obj.text								= sdSymbolModel.text;	
					sd_obj.lineWeight 				= sdSymbolModel.lineWeight;
				}
//				else if (sdObjectModel is SDImageModel){
//					var sdImageModel:SDImageModel = sdObjectModel as SDImageModel;
//					
//					sd_obj.sdObjectModelType 	= "SDImageModel";	
//					if (sdImageModel.imageURL.length > 0) {
//						Logger.info("dispatchUpdate_ObjectChanged() sdImageModel.imageURL="+sdImageModel.imageURL,this);
//						sd_obj.imageURL				= sdImageModel.imageURL;
//					}
//					
//					sd_obj.styleName =  sdImageModel.styleName;
//				}
				else if (sdObjectModel is SDLineModel){
					var sdLineModel:SDLineModel = sdObjectModel as SDLineModel;
					
					sd_obj.sdObjectModelType 	= "SDLineModel";
					sd_obj.startX							= sdLineModel.startX;
					sd_obj.startY							= sdLineModel.startY;	
					sd_obj.endX 							= sdLineModel.endX;
					sd_obj.endY 							= sdLineModel.endY;	
					sd_obj.bendX 							= sdLineModel.bendX;
					sd_obj.bendY 							= sdLineModel.bendY;
					sd_obj.startLineStyle 		= sdLineModel.startLineStyle;
					sd_obj.endLineStyle 			= sdLineModel.endLineStyle;
					sd_obj.lineWeight 				= sdLineModel.lineWeight;
					sd_obj.lineStyle  				= sdLineModel.lineStyle;
					
					//Connections
					if (sdLineModel.fromObject)
						sd_obj.fromObject_id 					= sdLineModel.fromObject.id;	
					else
						sd_obj.fromObject_id 					= '';
					
					if (sdLineModel.toObject)
						sd_obj.toObject_id 						= sdLineModel.toObject.id;	
					else
						sd_obj.toObject_id 						= '';
					
					if (sdLineModel.fromPoint) {
					  sd_obj.fromPoint_id 					= sdLineModel.fromPoint.id;	
					} else {
					  sd_obj.fromPoint_id 					= '';
					}
					
					if (sdLineModel.toPoint) {
  					sd_obj.toPoint_id 			  		= sdLineModel.toPoint.id;	
					}else{
  					sd_obj.toPoint_id 			  		= '';
					}
					
				}
				else if (sdObjectModel is SDPencilDrawingModel){
					var sdPencilDrawingModel:SDPencilDrawingModel = sdObjectModel as SDPencilDrawingModel;
					
					sd_obj.sdObjectModelType 	= "SDPencilDrawingModel";
					sd_obj.linePath 					= sdPencilDrawingModel.linePath;
					sd_obj.lineWeight 				= sdPencilDrawingModel.lineWeight;
				}
				else if (sdObjectModel is SDTextAreaModel){
					var sdTextAreaModel:SDTextAreaModel = sdObjectModel as SDTextAreaModel;
					
					sd_obj.sdObjectModelType 		= "SDTextAreaModel";
					sd_obj.styleName 						= sdTextAreaModel.styleName;
					sd_obj.maintainProportion 	= sdTextAreaModel.maintainProportion;		
					sd_obj.textAlign 						= sdTextAreaModel.textAlign;
					sd_obj.fontSize 						= sdTextAreaModel.fontSize;
					sd_obj.fontWeight 					= sdTextAreaModel.fontWeight;				
					sd_obj.fontFamily 					= sdTextAreaModel.fontFamily;				
					sd_obj.text									= sdTextAreaModel.text;	
					sd_obj.backgroundColor			= sdTextAreaModel.backgroundColor;	
					sd_obj.showTape       			= sdTextAreaModel.showTape;	
					
					Logger.info("dispatchUpdate_ObjectChanged() sdTextAreaModel.text=" + sdTextAreaModel.text + ", depth=" + sdTextAreaModel.depth.toString() + ", depth=" + sdTextAreaModel.depth.toString(), this);
				}
				
				_remoteSharedObject.setProperty(sd_obj.id.toString(), sd_obj);
			}
		}
		
		public function processUpdate_ObjectChanged(changeObject:Object) : void {
			Logger.info("processUpdate_ObjectChanged()",this);
			var isCorruptObject:Boolean = false;
			
			var id:int = changeObject.id;
			var sdObjectModel:SDObjectModel;			
			switch ( changeObject.sdObjectModelType) {
				case "SDSymbolModel": {
					var sdSymbolModel:SDSymbolModel = diagramManager.diagramModel.getModelByID(id) as SDSymbolModel;
					
					if (sdSymbolModel == null) {
						var libraryName:String = changeObject.libraryName;
						var symbolName:String = changeObject.symbolName;
						
						sdSymbolModel = new SDSymbolModel();
						
						var library:Library = libraryManager.getLibrary(libraryName);
						if (library==null)
						{
							//if library was custom library, we have to match the name against the new "ported" library's displayName
							library = libraryManager.getLibraryWithPrevName(libraryName)
							if (library)
							{
								libraryName = library.name //this will be a unique identifier in the 1.5 fashion
								symbolName = library.getSymbolNameByDisplayName(symbolName)
							}
							else
							{
								throw new SDObjectModelNotFoundError()
							}
						}					
						
						sdSymbolModel.libraryName = libraryName;
						sdSymbolModel.symbolName = symbolName;
					}
					
					sdSymbolModel.fontWeight 		= changeObject.fontWeight;
					sdSymbolModel.fontSize 			= parseInt(changeObject.fontSize);
					sdSymbolModel.fontFamily		= changeObject.fontFamily;
					sdSymbolModel.textAlign 		= changeObject.textAlign;
					sdSymbolModel.textPosition 	= changeObject.textPosition;
					sdSymbolModel.text		 			= changeObject.text;
					sdSymbolModel.lineWeight		= changeObject.lineWeight;
					
					
					sdObjectModel = sdSymbolModel;
					break;
				}
//				case "SDImageModel": {					
//					var sdImageModel:SDImageModel = diagramManager.diagramModel.getModelByID(id) as SDImageModel;
//					
//					if (sdImageModel == null){
//						sdImageModel = new SDImageModel();
//					}
//					
//					if (changeObject.imageURL == undefined ) {
//						Logger.error("processUpdate_ObjectChanged() changeObject.imageURL is undefined, id="+id,this);
//					} else {
//						Logger.info("processUpdate_ObjectChanged() changeObject.imageURL = " + changeObject.imageURL,this);
//						sdImageModel.imageURL = changeObject.imageURL;
//					}
//										  
//					sdImageModel.styleName = changeObject.styleName;
//					
//					sdObjectModel = sdImageModel;
//					break;
//				}
				case "SDPencilDrawingModel": {
					var sdPencilDrawingModel:SDPencilDrawingModel = diagramManager.diagramModel.getModelByID(id) as SDPencilDrawingModel;
					
					if (sdPencilDrawingModel == null){
						sdPencilDrawingModel = new SDPencilDrawingModel();						
					}
					
					sdPencilDrawingModel.linePath 	= changeObject.linePath;
					sdPencilDrawingModel.lineWeight = changeObject.lineWeight;
					
					sdObjectModel = sdPencilDrawingModel;
					break;
				}
				case "SDTextAreaModel": {
					var sdTextAreaModel:SDTextAreaModel = diagramManager.diagramModel.getModelByID(id) as SDTextAreaModel;	
					
					if (sdTextAreaModel == null){
						sdTextAreaModel = new SDTextAreaModel();
					}
					
					sdTextAreaModel.styleName 					= changeObject.styleName;
					sdTextAreaModel.maintainProportion 	= changeObject.maintainProportion;		
					sdTextAreaModel.fontSize 						= changeObject.fontSize;
					sdTextAreaModel.fontWeight 					= changeObject.fontWeight;
					sdTextAreaModel.fontFamily					= changeObject.fontFamily;
					sdTextAreaModel.textAlign 					= changeObject.textAlign;
					sdTextAreaModel.text			 					= changeObject.text;
					sdTextAreaModel.backgroundColor			= changeObject.backgroundColor;
					sdTextAreaModel.showTape			 			= changeObject.showTape;
					
					sdObjectModel = sdTextAreaModel;
					
					Logger.info("processUpdate_ObjectChanged() sdTextAreaModel.text=" + sdTextAreaModel.text + ", depth=" + sdTextAreaModel.depth.toString(), this);
					break;
				}
			}
			
			
			sdObjectModel.id			  = changeObject.id;
			sdObjectModel.color	 		= changeObject.color;
			sdObjectModel.x 				= changeObject.x;
			sdObjectModel.y 				= changeObject.y;
			sdObjectModel.width 		= changeObject.width;
			sdObjectModel.height		= changeObject.height;
			sdObjectModel.rotation	= changeObject.rotation;
			sdObjectModel.depth 		= changeObject.depth;
			
			var placementDetails:String = ">>" + changeObject.sdObjectModelType + stateString(changeObject);
//			
//			var reportPrefix:String = "processUpdate_ObjectChanged"
//			reportPrefix += " :"+ changeObject.commandName;
//			reportPrefix += " :"+ changeObject.sdObjectModelType ;
//			isCorruptObject =  isCorrupt(reportPrefix, changeObject);
//			
//			if (isCorruptObject){
//				if (isNaN(sdObjectModel.x) || isNaN(sdObjectModel.y) || isNaN(sdObjectModel.height) || isNaN(sdObjectModel.width) || isNaN(sdObjectModel.rotation) ) {
//					sdObjectModel.x = 50;
//					sdObjectModel.y = 50;
//					sdObjectModel.height = 50;
//					sdObjectModel.width = 50;
//					sdObjectModel.rotation = 0;
//				}
//				
//				if (sdObjectModel.height <= 0)
//					sdObjectModel.height = 50;
//				if (sdObjectModel.width <= 0)
//					sdObjectModel.width = 50;
//				
//				if (sdObjectModel.x <= 0 && ((sdObjectModel.width + sdObjectModel.x) < 0) )
//					sdObjectModel.x = 200;
//				if (sdObjectModel.y <= 0 && ((sdObjectModel.height + sdObjectModel.y) < 0) )
//					sdObjectModel.y = 50;
//				
//				isCorruptObject = false;
//				placementDetails += ' <--> ' + stateString(sdObjectModel);
//			}
//			
//			var isBlank:Boolean = false;

			
			if (diagramManager.diagramModel.sdObjects.contains(sdObjectModel) == false) {
				Logger.info("processUpdate_ObjectChanged() about to add sdObjectModel=" +placementDetails,	this);
				
				// TODO Clean this up. The coupling is too tight.
				// To prevent throwing an RSOEvent from within diagramManager.diagramModel.addSDObjectModel()
				// we perform it's responsibilities here:	
				diagramManager.diagramModel.sdObjects.addItem(sdObjectModel);
//				diagramManager.diagramModel.addComponentForModel(sdObjectModel, false);
			}
		}		
		
		public function processUpdate_LineChanged(changeObject:Object) : void {
			Logger.info("processUpdate_LineChanged()",this);
			
			var id:int = changeObject.id;
			var sdObjectModel:SDObjectModel;			
			switch ( changeObject.sdObjectModelType) {
				case "SDLineModel": {
					var sdLineModel:SDLineModel = diagramManager.diagramModel.getModelByID(id) as SDLineModel;
					
					if (sdLineModel == null){						
						sdLineModel = new SDLineModel();
					}
					
					sdLineModel.startX 					= changeObject.startX;
					sdLineModel.startY 					= changeObject.startY;	
					sdLineModel.endX 						= changeObject.endX;
					sdLineModel.endY 						= changeObject.endY;	
					sdLineModel.bendX 					= changeObject.bendX;
					sdLineModel.bendY 					= changeObject.bendY;
					sdLineModel.startLineStyle 	= changeObject.startLineStyle;
					sdLineModel.endLineStyle 		= changeObject.endLineStyle;
					sdLineModel.lineWeight 			= changeObject.lineWeight;
					sdLineModel.lineStyle 			= changeObject.lineStyle;
					
					if (changeObject.fromObject_id && changeObject.fromObject_id != '')
						sdLineModel.fromObject		= diagramManager.diagramModel.getModelByID(changeObject.fromObject_id);	
					else
						sdLineModel.fromObject		= null;
					
					if (sdLineModel.fromObject && changeObject.fromPoint_id && changeObject.fromPoint_id.toString() != '')
						sdLineModel.fromPoint		= sdLineModel.fromObject.getConnectionPoint(changeObject.fromPoint_id);
					else 
						sdLineModel.fromPoint		= null;
					
					if (changeObject.toObject_id && changeObject.toObject_id != '')
						sdLineModel.toObject		= diagramManager.diagramModel.getModelByID(changeObject.toObject_id);	
					else
						sdLineModel.toObject		= null;
					
					if (sdLineModel.toObject && changeObject.toPoint_id && changeObject.toPoint_id.toString() != '') {
		        sdLineModel.toPoint		= sdLineModel.toObject.getConnectionPoint(changeObject.toPoint_id);
		        Logger.info("process_LineChange toPoint.id= " + sdLineModel.toPoint.id);
					} else
						sdLineModel.toPoint		= null;
					
					sdObjectModel = sdLineModel;
					break;
				}
			}
			
			sdObjectModel.id			  = changeObject.id;
			sdObjectModel.color	 		= changeObject.color;
			sdObjectModel.x 				= changeObject.x;
			sdObjectModel.y 				= changeObject.y;
			sdObjectModel.width 		= changeObject.width;
			sdObjectModel.height		= changeObject.height;
			sdObjectModel.rotation	= changeObject.rotation;
			sdObjectModel.depth 		= changeObject.depth;
			
	
			var placementDetails:String = ">>" + changeObject.sdObjectModelType + stateString(changeObject);
			if (diagramManager.diagramModel.sdObjects.contains(sdObjectModel) == false) {
				Logger.info("processUpdate_LineChanged() about to add sdObjectModel=" +placementDetails,	this);
				
				// TODO Clean this up. The coupling is too tight.
				// To prevent throwing an RSOEvent from within diagramManager.diagramModel.addSDObjectModel()
				// we perform it's responsibilities here:	
				diagramManager.diagramModel.sdObjects.addItem(sdObjectModel);
				//				diagramManager.diagramModel.addComponentForModel(sdObjectModel, false);
			}
		}		
		
		private function stateString(o:Object):String{
			var d:String = " x=" +o.x;
			d += " width=" +o.width;
			d += " y=" +o.y;
			d += " height=" +o.height;
			d += " rotation=" +o.rotation;
			d += " depth=" +o.depth;		
			
			return d;
		}
		

		private function isBlank(changeObject:Object):Boolean{
			var blank:Boolean = false;
//			
//			switch ( changeObject.sdObjectModelType) {
//				case "SDSymbolModel": {
//					if ( changeObject.libraryName == null || changeObject.symbolName == null)
//						blank = true;					
//					break;
//				}
//				case "SDImageModel": {					
//					if (changeObject.imageURL == undefined ) 
//						blank = true;					
//					break;
//				}
//				case "SDLineModel": {
//					if((changeObject.startX == changeObject.endX) &&
//						(changeObject.startY ==changeObject.endY) &&
//						(changeObject.bendX == 0) &&
//						(changeObject.bendY == 0) )
//						blank = true;
//					break;
//				}
//				case "SDPencilDrawingModel": {
//					if (changeObject.linePath == null)
//						blank = true;
//					break;
//				}
//				case "SDTextAreaModel": {
//					if (changeObject.text == null)
//						blank = true;
//					break;
//				}
//			}
			return blank;
		}
		
		private function isCorrupt(reportPrefix:String, changeObject:Object):Boolean{
			
			var isCorruptObject:Boolean = false;
			var reportString:String = reportPrefix;
			
			if (changeObject.x == null) {
				reportString += " #null:x";
				isCorruptObject = true;
			}
			if (changeObject.color == null) {
				reportString += " #null:color";
				isCorruptObject = true;
			}
			if (changeObject.y == null) {
				reportString += " #null:y";
				isCorruptObject = true;
			}
			if (changeObject.width == null) {
				reportString += " #null:width";
				isCorruptObject = true;
			}
			if (changeObject.height == null) {
				reportString += " #null:height";
				isCorruptObject = true;
			}
			if (changeObject.rotation == null) {
				reportString += " #null:rotation";
				isCorruptObject = true;
			}
			if (changeObject.depth == null) {
				reportString += " #null:depth";
				isCorruptObject = true;
			}
			if (changeObject.id == null) {
				reportString += " #null:id";
				isCorruptObject = true;
			}
			
			if (isNaN(changeObject.x) ) {
				reportString += " #NaN:x";
				isCorruptObject = true;
			}
			if (isNaN(changeObject.color)) {
				reportString += " #NaN:color";
				isCorruptObject = true;
			}
			if (isNaN(changeObject.y)) {
				reportString += " #NaN:y";
				isCorruptObject = true;
			}
			
			// width and height are NaN for SDLineModel
//			if (isNaN(changeObject.width)) {
//				reportString += " #NaN:width";
//				isCorruptObject = true;
//			}
//			if (isNaN(changeObject.height)) {
//				reportString += " #NaN:height";
//				isCorruptObject = true;
//			}
			if (isNaN(changeObject.rotation)) {
				reportString += " #NaN:rotation";
				isCorruptObject = true;
			}
			if (isNaN(changeObject.depth)) {
				reportString += " #NaN:depth";
				isCorruptObject = true;
			}
			
			if (changeObject.x <= 0) {
				reportString += " #negative:x("+ changeObject.x.toString() +")";
				isCorruptObject = true;
			}
			if (changeObject.y <= 0) {
				reportString += " #negative:y("+ changeObject.y.toString() +")";
				isCorruptObject = true;
			}
			if (changeObject.width <= 0) {
				reportString += " #negative:width("+ changeObject.width.toString() +")";
				isCorruptObject = true;
			}
			if (changeObject.height <= 0) {
				reportString += " #negative:height("+ changeObject.height.toString() +")";
				isCorruptObject = true;
			}
			if (changeObject.depth <= 0) {
				reportString += " #negative:depth("+ changeObject.depth.toString() +")";
				isCorruptObject = true;
			}
			if (changeObject.color < 0) {
				reportString += " #negative:color("+ changeObject.color.toString() +")";
				isCorruptObject = true;
			}
			
			if (changeObject.hasOwnProperty('text'))
				reportString += " #text=" + changeObject.text.toString();

			
			if (isCorruptObject) {				
				Logger.error(reportString, this);
			} else {
				Logger.info(reportString, this);
			}
			
			return isCorruptObject;
		}
	
		
	}	
}

