package com.simplediagrams.controllers
{
	import com.simplediagrams.business.FileManager;
	import com.simplediagrams.commands.TransformCommand;
	import com.simplediagrams.events.*;
	import com.simplediagrams.model.ApplicationModel;
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
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.DrawingBoard;
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
		
//		[Autowire(bean='diagramModel')]
//		public var diagramModel:DiagramModel

		[Autowire(bean='libraryManager')]
		public var libraryManager:LibraryManager;
		
		public function RemoteSharedObjectController() {
		}

		[Mediate(event="RemoteSharedObjectEvent.START")]
		private function connect():void{
			_netConnection = new NetConnection();
			_netConnection.client = this; 
			
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
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
		
		public function onStatus( event : NetStatusEvent) : void {
			Logger.info("onStatus()" + event,this);	
			if (event.info !== '' || event.info !== null) {  
				switch (event.info.code) {
					case "NetConnection.Connect.Success":   
						Logger.info("NetConnection.Connect.Success", this);  
						createSharedObject();  
						break;
					case "NetConnection.Connect.Closed":  
						// TODO: tell the user the connection failed
						Logger.info("NetConnection.Connect.Closed", this);  
						break;
				}      
			}
		}
		
		private function createSharedObject() : void {
			Logger.info("createSharedObject()",this);	
			_netStream = new NetStream(_netConnection);
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
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
		
		public function securityErrorHandler(event : SecurityErrorEvent) : void {  Logger.error('securityErrorHandler() '+event, this);  }
		public function ioErrorHandler(event : IOErrorEvent) : void {  Logger.error('ioErrorHandler() :'+event, this);  }
		public function asyncErrorHandler(event : AsyncErrorEvent) : void {  Logger.error('asyncErrorHandler() :'+event, this);  }  		
		
		private function onSyncEventHandler(event : SyncEvent):void {
			Logger.info("onSyncEventHandler event:" + event.type,this);	
			
			Logger.info("onSyncEventHandler event.changeList.length:" + event.changeList.length,this);	
			for (var i:Number = 0; i < event.changeList.length; i++) {
				Logger.info("onSyncEventHandler event.changeList[" +i + "].code:" + event.changeList[i].code,this);	

				switch (event.changeList[i].code){
					case SUCCESS:   
						break;
					case CHANGE:  {
						Logger.info("onSyncEventHandler event.changeList[" +i + "].name:" + event.changeList[i].name,this);	
						var sdID:String = event.changeList[i].name;
						var changeObject:Object = event.target.data[sdID];
						routeChange(changeObject);
						break;
					}
				}
					
			}
		}				
		
		private function routeChange(changeObject:Object) : void 
		{
			switch (changeObject.commandName) {
				case "DeleteSelectedSDObjectModel": {
					processUpdate_DeleteSelectedSDObjectModel(changeObject);
					break;
				}
				case "ObjectChanged": {
					processUpdate_ObjectChanged(changeObject);
					break;
				}			
//				case "UpdateDepths": {
//					processUpdate_UpdateDepths(changeObject);
//					break;
//				}			
				case "ConfigureGrid": {
					processUpdate_ConfigureGrid(changeObject);
					break;
				}			
			}
		}

		[Mediate(event="RemoteSharedObjectEvent.LOAD_IMAGE")]
		public function dispatchUpdate_LoadImage(rsoEvent:RemoteSharedObjectEvent):void
		{
//			Logger.info("dispatchUpdate_LoadImage() sdID="+rsoEvent.sdImageModel.sdID,this);
//			
//			var returnValueFunction:Function = function(imageDetails:Object):void
//			{
//				Logger.info("dispatchUpdate_LoadImage() responder.result() sdID="+imageDetails["sdID"]+", url="+imageDetails["imageURL"],this);
//
//				var sdImageModel:SDImageModel = diagramModel.getModelByID(imageDetails["sdID"]) as SDImageModel;
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
//				rsoEvent.sdImageModel.sdID.toString(),
//				_image_server);
		}		

		[Mediate(event="RemoteSharedObjectEvent.RESET")]
		public function reset():void
		{
			stop();			
			connect();
		}

		[Mediate(event="RemoteSharedObjectEvent.STOP")]
		public function stop():void
		{
			_remoteSharedObject.close();
			_remoteSharedObject = null;
			_netConnection.close();
			_netConnection = null;
			_netStream.close();
			_netStream = null;
		}
		
		[Mediate(event="RemoteSharedObjectEvent.LOAD_FLASHVARS")]
		public function loadFlashvars(event:RemoteSharedObjectEvent):void
		{
			_auth_key 				= event.auth_key;
			_room_id 				= event.room_id;			
			_room_name 				= event.room_name;			
			_user_name 				= event.user_name;
			_user_id 				= event.user_id;
			_image_server 			= event.image_server;
			_wowza_server 			= event.wowza_server;
			_wowza_whiteboard_app 	= event.wowza_whiteboard_app;
			_wowza_whiteboard_port 	= event.wowza_whiteboard_port;
			
			connect();
		}
		

		[Mediate(event="RemoteSharedObjectEvent.DELETE_SELECTED_SD_OBJECT_MODEL")]
		public function dispatchUpdate_DeleteSelectedSDObjectModel(event:RemoteSharedObjectEvent) : void 
		{			
			Logger.info("dispatchUpdate_DeleteSelectedSDObjectModel()",this);
			
			for(var i:int=0; i< event.sdIDArray.length; i++) 
			{
				var sdID:String = event.sdIDArray[i];
				var sd_obj:Object = {};
				sd_obj.commandName = "DeleteSelectedSDObjectModel";
				sd_obj.sdID = sdID;						
				_remoteSharedObject.setProperty(sd_obj.sdID.toString(), sd_obj);
			}			
		}	
		
		public function processUpdate_DeleteSelectedSDObjectModel(changeObject:Object):void
		{
//			Logger.info("processUpdate_DeleteSelectedSDObjectModel()",this);
//			var sdID:String = changeObject.sdID;
//			var sdObjectModel:SDObjectModel = diagramModel.getModelByID(sdID);
//			
//			var len:uint = diagramModel.sdObjectModelsAC.length;
//			for (var i:uint=0;i<len;i++)			 
//			{
//				if (diagramModel.sdObjectModelsAC.getItemAt(i) as SDObjectModel == sdObjectModel)
//				{
//					diagramModel.sdObjectHandles.unregisterComponent(sdObjectModel.sdComponent as EventDispatcher);
//					diagramModel.sdObjectModelsAC.removeItemAt(i);
//					break;
//				}
//			}	
//			
//			if (sdObjectModel) {
//				var evt:DeleteSDComponentEvent = new DeleteSDComponentEvent(DeleteSDComponentEvent.DELETE_FROM_DIAGRAM, true)
//				evt.sdComponent = sdObjectModel.sdComponent
//				dispatcher.dispatchEvent(evt)
//			}
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
		
		public function processUpdate_ConfigureGrid(changeObject:Object) : void 
		{
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
		

		
		[Mediate(event="RemoteSharedObjectEvent.OBJECT_CHANGED")]
		[Mediate(event="RemoteSharedObjectEvent.TEXT_WIDGET_ADDED")]
		[Mediate(event="RemoteSharedObjectEvent.TEXT_WIDGET_CREATED")]
		[Mediate(event="RemoteSharedObjectEvent.PENCIL_DRAWING_CREATED")]
		[Mediate(event="RemoteSharedObjectEvent.ADD_SD_OBJECT_MODEL")]
		[Mediate(event="RemoteSharedObjectEvent.UPDATE_DEPTHS")]
		public function dispatchUpdate_ObjectChanged(event:RemoteSharedObjectEvent) : void
		{
//			Logger.info("dispatchUpdate_ObjectChanged() event:"+event.type,this);
//			
//			for each (var sdObjectModel:SDObjectModel in event.changedSDObjectModelArray)
//			{			
//				isCorrupt("dispatchUpdate_ObjectChanged", sdObjectModel);
//				
//				var sd_obj:Object = {};
//				sd_obj.commandName 	= "ObjectChanged";
//				sd_obj.sdID 				= sdObjectModel.sdID;							
//				sd_obj.x 						= sdObjectModel.x;
//				sd_obj.y 						= sdObjectModel.y;		
//				sd_obj.height 			= sdObjectModel.height;		
//				sd_obj.width 				= sdObjectModel.width;		
//				sd_obj.rotation			= sdObjectModel.rotation;		
//				sd_obj.color 				= sdObjectModel.color;	
//				sd_obj.depth 				= sdObjectModel.depth;	
//				
//				if (sdObjectModel.width < 0) {
//					Logger.error("dispatchUpdate_ObjectChanged() sdObjectModel.width is negative: " + sdObjectModel.width, this);
//				}
//				
//				if (sdObjectModel.height < 0){
//					Logger.error("dispatchUpdate_ObjectChanged() sdObjectModel.height is negative: " + sdObjectModel.height, this);
//				}
//				
//				if (sdObjectModel is SDSymbolModel){
//					var sdSymbolModel:SDSymbolModel = sdObjectModel as SDSymbolModel;
//					
//					sd_obj.sdObjectModelType 	= "SDSymbolModel";
//					sd_obj.libraryName 				= sdSymbolModel.libraryName;				
//					sd_obj.symbolName 				= sdSymbolModel.symbolName;		
//					sd_obj.fontSize 					= sdSymbolModel.fontSize;
//					sd_obj.fontWeight 				= sdSymbolModel.fontWeight;
//					sd_obj.fontFamily 				= sdSymbolModel.fontFamily;
//					sd_obj.textAlign 					= sdSymbolModel.textAlign;
//					sd_obj.textPosition				= sdSymbolModel.textPosition;	
//					sd_obj.text								= sdSymbolModel.text;	
//				}
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
//				else if (sdObjectModel is SDLineModel){
//					var sdLineModel:SDLineModel = sdObjectModel as SDLineModel;
//					
//					sd_obj.sdObjectModelType 	= "SDLineModel";
//					sd_obj.startX							= sdLineModel.startX;
//					sd_obj.startY							= sdLineModel.startY;	
//					sd_obj.endX 							= sdLineModel.endX;
//					sd_obj.endY 							= sdLineModel.endY;	
//					sd_obj.bendX 							= sdLineModel.bendX;
//					sd_obj.bendY 							= sdLineModel.bendY;
//					sd_obj.startLineStyle 		= sdLineModel.startLineStyle;
//					sd_obj.endLineStyle 			= sdLineModel.endLineStyle;
//					sd_obj.lineWeight 				= sdLineModel.lineWeight;
//				}
//				else if (sdObjectModel is SDPencilDrawingModel){
//					var sdPencilDrawingModel:SDPencilDrawingModel = sdObjectModel as SDPencilDrawingModel;
//					
//					sd_obj.sdObjectModelType 	= "SDPencilDrawingModel";
//					sd_obj.linePath 					= sdPencilDrawingModel.linePath;
//					sd_obj.lineWeight 				= sdPencilDrawingModel.lineWeight;
//				}
//				else if (sdObjectModel is SDTextAreaModel){
//					var sdTextAreaModel:SDTextAreaModel = sdObjectModel as SDTextAreaModel;
//					
//					sd_obj.sdObjectModelType 		= "SDTextAreaModel";
//					sd_obj.styleName 						= sdTextAreaModel.styleName;
//					sd_obj.maintainProportion 	= sdTextAreaModel.maintainProportion;		
//					sd_obj.textAlign 						= sdTextAreaModel.textAlign;
//					sd_obj.fontSize 						= sdTextAreaModel.fontSize;
//					sd_obj.fontWeight 					= sdTextAreaModel.fontWeight;				
//					sd_obj.fontFamily 					= sdTextAreaModel.fontFamily;				
//					sd_obj.text									= sdTextAreaModel.text;	
//					
//					Logger.info("dispatchUpdate_ObjectChanged() sdTextAreaModel.text=" + sdTextAreaModel.text + ", depth=" + sdTextAreaModel.depth.toString() + ", depth=" + sdTextAreaModel.depth.toString(), this);
//				}
//				
//				_remoteSharedObject.setProperty(sd_obj.sdID.toString(), sd_obj);
//			}
		}
		
		public function processUpdate_ObjectChanged(changeObject:Object) : void 
		{
//			Logger.info("processUpdate_ObjectChanged()",this);
//			var isCorruptObject:Boolean = false;
//			
//			var sdID:String = changeObject.sdID;
//			var sdObjectModel:SDObjectModel;			
//			switch ( changeObject.sdObjectModelType) {
//				case "SDSymbolModel": {
//					var sdSymbolModel:SDSymbolModel = diagramModel.getModelByID(sdID) as SDSymbolModel;
//					
//					if (sdSymbolModel == null) {
//						var libraryName:String = changeObject.libraryName;
//						var symbolName:String = changeObject.symbolName;
//						
//						sdSymbolModel = libraryManager.getSDObjectModel(libraryName, symbolName) as SDSymbolModel;
//					}
//					
//					sdSymbolModel.fontWeight 		= changeObject.fontWeight;
//					sdSymbolModel.fontSize 			= parseInt(changeObject.fontSize);
//					sdSymbolModel.fontFamily		= changeObject.fontFamily;
//					sdSymbolModel.textAlign 		= changeObject.textAlign;
//					sdSymbolModel.textPosition 	= changeObject.textPosition;
//					sdSymbolModel.text		 			= changeObject.text;
//					
//					
//					sdObjectModel = sdSymbolModel;
//					break;
//				}
//				case "SDImageModel": {					
//					var sdImageModel:SDImageModel = diagramModel.getModelByID(sdID) as SDImageModel;
//					
//					if (sdImageModel == null){
//						sdImageModel = new SDImageModel();
//					}
//					
//					if (changeObject.imageURL == undefined ) {
//						Logger.error("processUpdate_ObjectChanged() changeObject.imageURL is undefined, sdID="+sdID,this);
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
//				case "SDLineModel": {
//					var sdLineModel:SDLineModel = diagramModel.getModelByID(sdID) as SDLineModel;
//					
//					if (sdLineModel == null){						
//						sdLineModel = new SDLineModel();
//					}
//					
//					sdLineModel.startX 					= changeObject.startX;
//					sdLineModel.startY 					= changeObject.startY;	
//					sdLineModel.endX 						= changeObject.endX;
//					sdLineModel.endY 						= changeObject.endY;	
//					sdLineModel.bendX 					= changeObject.bendX;
//					sdLineModel.bendY 					= changeObject.bendY;
//					sdLineModel.startLineStyle 	= changeObject.startLineStyle;
//					sdLineModel.endLineStyle 		= changeObject.endLineStyle;
//					sdLineModel.lineWeight 			= changeObject.lineWeight;
//
//					sdObjectModel = sdLineModel;
//					break;
//				}
//				case "SDPencilDrawingModel": {
//					var sdPencilDrawingModel:SDPencilDrawingModel = diagramModel.getModelByID(sdID) as SDPencilDrawingModel;
//					
//					if (sdPencilDrawingModel == null){
//						sdPencilDrawingModel = new SDPencilDrawingModel();						
//					}
//					
//					sdPencilDrawingModel.linePath 	= changeObject.linePath;
//					sdPencilDrawingModel.lineWeight = changeObject.lineWeight;
//					
//					sdObjectModel = sdPencilDrawingModel;
//					break;
//				}
//				case "SDTextAreaModel": {
//					var sdTextAreaModel:SDTextAreaModel = diagramModel.getModelByID(sdID) as SDTextAreaModel;	
//					
//					if (sdTextAreaModel == null){
//						sdTextAreaModel = new SDTextAreaModel();
//					}
//					
//					sdTextAreaModel.styleName 					= changeObject.styleName;
//					sdTextAreaModel.maintainProportion 	= changeObject.maintainProportion;		
//					sdTextAreaModel.fontSize 						= changeObject.fontSize;
//					sdTextAreaModel.fontWeight 					= changeObject.fontWeight;
//					sdTextAreaModel.fontFamily					= changeObject.fontFamily;
//					sdTextAreaModel.textAlign 					= changeObject.textAlign;
//					sdTextAreaModel.text			 					= changeObject.text;
//					
//					sdObjectModel = sdTextAreaModel;
//					
//					Logger.info("processUpdate_ObjectChanged() sdTextAreaModel.text=" + sdTextAreaModel.text + ", depth=" + sdTextAreaModel.depth.toString(), this);
//					break;
//				}
//			}
//			
//			
//			sdObjectModel.sdID			= changeObject.sdID;
//			sdObjectModel.color	 		= changeObject.color;
//			sdObjectModel.x 				= changeObject.x;
//			sdObjectModel.y 				= changeObject.y;
//			sdObjectModel.width 		= changeObject.width;
//			sdObjectModel.height		= changeObject.height;
//			sdObjectModel.rotation	= changeObject.rotation;
//			sdObjectModel.depth 		= changeObject.depth;
//			
//			var placementDetails:String = ">>" + changeObject.sdObjectModelType + stateString(changeObject);
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
//
//			
//			if (!isCorruptObject && diagramModel.sdObjectModelsAC.contains(sdObjectModel) == false) {
//				Logger.info("processUpdate_ObjectChanged() about to add sdObjectModel=" +placementDetails,	this);
//				
//				// TODO Clean this up. The coupling is too tight.
//				// To prevent throwing an RSOEvent from within diagramModel.addSDObjectModel()
//				// we perform it's responsibilities here:	
//				diagramModel.sdObjectModelsAC.addItem(sdObjectModel);
//				diagramModel.addComponentForModel(sdObjectModel, false);
//			} else {
//				Logger.error(placementDetails);
//			}
//		}		
//		
//		private function stateString(o:Object):String{
//			var d:String = " x=" +o.x;
//			d += " width=" +o.width;
//			d += " y=" +o.y;
//			d += " height=" +o.height;
//			d += " rotation=" +o.rotation;
//			d += " depth=" +o.depth;		
//			
//			return d;
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
			if (changeObject.sdID == null) {
				reportString += " #null:sdID";
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

