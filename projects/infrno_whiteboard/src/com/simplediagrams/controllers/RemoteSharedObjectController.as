package com.simplediagrams.controllers
{
	import com.simplediagrams.business.FileManager;
	import com.simplediagrams.commands.AddImageItem;
	import com.simplediagrams.commands.AddLibraryItemCommand;
	import com.simplediagrams.commands.AddLineCommand;
	import com.simplediagrams.commands.AddPencilDrawingCommand;
	import com.simplediagrams.commands.AddTextAreaCommand;
	import com.simplediagrams.commands.AddTextWidgetCommand;
	import com.simplediagrams.commands.ChangeColorCommand;
	import com.simplediagrams.commands.ChangeLinePositionCommand;
	import com.simplediagrams.commands.CutCommand;
	import com.simplediagrams.commands.DeleteSDObjectModelCommand;
	import com.simplediagrams.commands.DeleteSelectedSDObjectModelsCommand;
	import com.simplediagrams.commands.TransformCommand;
	import com.simplediagrams.events.*;
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.DiagramStyleManager;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDPencilDrawingModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.model.SDTextAreaModel;
	import com.simplediagrams.model.SettingsModel;
	import com.simplediagrams.model.UndoRedoManager;
	import com.simplediagrams.model.mementos.*;
	import com.simplediagrams.model.mementos.SDLineMemento;
	import com.simplediagrams.model.mementos.TransformMemento;
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
	import flash.net.FileFilter;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	
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
			
		[Autowire(bean='diagramModel')]
		public var diagramModel:DiagramModel

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
				case "UpdateDepths": {
					processUpdate_UpdateDepths(changeObject);
					break;
				}			
			}
		}

		[Mediate(event="RemoteSharedObjectEvent.LOAD_IMAGE")]
		public function dispatchUpdate_LoadImage(rsoEvent:RemoteSharedObjectEvent):void
		{
			Logger.info("dispatchUpdate_LoadImage() sdID="+rsoEvent.sdImageModel.sdID,this);
			
			var returnValueFunction:Function = function(imageDetails:Object):void
			{
				Logger.info("dispatchUpdate_LoadImage() responder.result() sdID="+imageDetails["sdID"]+", url="+imageDetails["imageURL"],this);

				var sdImageModel:SDImageModel = diagramModel.getModelByID(imageDetails["sdID"]) as SDImageModel;
				sdImageModel.imageURL = imageDetails["imageURL"];
				
				var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
				rsoEvent.changedSDObjectModelArray = new Array;				
				rsoEvent.changedSDObjectModelArray.push(sdImageModel);
				dispatcher.dispatchEvent(rsoEvent);	
			}
			
			var responder:Responder = new Responder(returnValueFunction);
			
			_netConnection.call("sendImage", responder, 
				rsoEvent.imageData, 
				rsoEvent.imageName,
				rsoEvent.sdImageModel.sdID.toString(),
				_image_server);
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
			Logger.info("processUpdate_DeleteSelectedSDObjectModel()",this);
			var sdID:String = changeObject.sdID;
			var sdObjectModel:SDObjectModel = diagramModel.getModelByID(sdID);
			
			var len:uint = diagramModel.sdObjectModelsAC.length;
			for (var i:uint=0;i<len;i++)			 
			{
				if (diagramModel.sdObjectModelsAC.getItemAt(i) as SDObjectModel == sdObjectModel)
				{
					diagramModel.sdObjectHandles.unregisterComponent(sdObjectModel.sdComponent as EventDispatcher);
					diagramModel.sdObjectModelsAC.removeItemAt(i);
					break;
				}
			}	
			
			if (sdObjectModel) {
				var evt:DeleteSDComponentEvent = new DeleteSDComponentEvent(DeleteSDComponentEvent.DELETE_FROM_DIAGRAM, true)
				evt.sdComponent = sdObjectModel.sdComponent
				dispatcher.dispatchEvent(evt)
			}
		}
		
		[Mediate(event="RemoteSharedObjectEvent.UPDATE_DEPTHS")]
		public function dispatchUpdate_UpdateDepths(event:RemoteSharedObjectEvent):void
		{
			Logger.info("dispatchUpdate_UpdateDepthsChange()",this);
			
			for each (var sdObjectModel:SDObjectModel in event.changedSDObjectModelArray)
			{			
				var sd_obj:Object = {};
				sd_obj.commandName 	= "UpdateDepths";
				sd_obj.sdID 		= sdObjectModel.sdID;								
				sd_obj.depth 		= sdObjectModel.depth;	
				_remoteSharedObject.setProperty(sd_obj.sdID.toString(), sd_obj);
			}
		}
		
		public function processUpdate_UpdateDepths(changeObject:Object) : void 
		{
			Logger.info("processUpdate_UpdateDepths()",this);
			var sdID:String = changeObject.sdID;
			var sdObjectModel:SDObjectModel = diagramModel.getModelByID(sdID);
			if (sdObjectModel) {
				sdObjectModel.depth = changeObject.depth;
			}
		}
		

		
		[Mediate(event="RemoteSharedObjectEvent.TEXT_AREA_CHANGE")]
		public function dispatchUpdate_TextAreaChange(event:RemoteSharedObjectEvent):void
		{
			Logger.info("dispatchUpdate_TextAreaChange()",this);
			
			var sdTextAreaModel:SDTextAreaModel = diagramModel.getModelByID(event.sdID) as SDTextAreaModel;			
			
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.changedSDObjectModelArray = new Array;				
			rsoEvent.changedSDObjectModelArray.push(sdTextAreaModel);
			dispatcher.dispatchEvent(rsoEvent);	
		}
			
		[Mediate(event="RemoteSharedObjectEvent.OBJECT_CHANGED")]
		[Mediate(event="RemoteSharedObjectEvent.TEXT_WIDGET_ADDED")]
		[Mediate(event="RemoteSharedObjectEvent.TEXT_WIDGET_CREATED")]
		[Mediate(event="RemoteSharedObjectEvent.PENCIL_DRAWING_CREATED")]
		[Mediate(event="RemoteSharedObjectEvent.ADD_SD_OBJECT_MODEL")]
		public function dispatchUpdate_ObjectChanged(event:RemoteSharedObjectEvent) : void
		{
			Logger.info("dispatchUpdate_ObjectChanged() event:"+event.type,this);
			
			for each (var sdObjectModel:SDObjectModel in event.changedSDObjectModelArray)
			{			
				var sd_obj:Object = {};
				sd_obj.commandName 	= "ObjectChanged";
				sd_obj.sdID 				= sdObjectModel.sdID;							
				sd_obj.x 						= sdObjectModel.x;
				sd_obj.y 						= sdObjectModel.y;		
				sd_obj.height 			= sdObjectModel.height;		
				sd_obj.width 				= sdObjectModel.width;		
				sd_obj.rotation			= sdObjectModel.rotation;		
				sd_obj.color 				= sdObjectModel.color;	
				sd_obj.depth 				= sdObjectModel.depth;	
				
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
				}
				else if (sdObjectModel is SDImageModel){
					var sdImageModel:SDImageModel = sdObjectModel as SDImageModel;
					
					sd_obj.sdObjectModelType 	= "SDImageModel";	
					if (sdImageModel.imageURL.length > 0) {
						Logger.info("dispatchUpdate_ObjectChanged() sdImageModel.imageURL="+sdImageModel.imageURL,this);
						sd_obj.imageURL				= sdImageModel.imageURL;
					}
					
					sd_obj.styleName =  sdImageModel.styleName;
				}
				else if (sdObjectModel is SDLineModel){
					var sdLineModel:SDLineModel = sdObjectModel as SDLineModel;
					
					sd_obj.sdObjectModelType 	= "SDLineModel";
					sd_obj.endX 							= sdLineModel.endX;
					sd_obj.endY 							= sdLineModel.endY;	
					sd_obj.bendX 							= sdLineModel.bendX;
					sd_obj.bendY 							= sdLineModel.bendY;
					sd_obj.startLineStyle 		= sdLineModel.startLineStyle;
					sd_obj.endLineStyle 			= sdLineModel.endLineStyle;
					sd_obj.lineWeight 				= sdLineModel.lineWeight;
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
					
					Logger.info("dispatchUpdate_ObjectChanged() sdTextAreaModel.text=" + sdTextAreaModel.text + ", depth=" + sdTextAreaModel.depth.toString() + ", depth=" + sdTextAreaModel.depth.toString(), this);
				}
				
				if (sd_obj.sdID == '1295068066312')
				{
					Logger.info("whaszzzup!!!")
				}
				
				_remoteSharedObject.setProperty(sd_obj.sdID.toString(), sd_obj);
			}
		}
		
		public function processUpdate_ObjectChanged(changeObject:Object) : void 
		{
			Logger.info("processUpdate_ObjectChanged()",this);
			
			if (changeObject.sdID == '1295068066312')
			{
				Logger.info("whaszzzup!!!")
			}
			
			var sdID:String = changeObject.sdID;
			
			// probably should see if sdObjectModelsAC already contains something with this sdID 
			// before creating a new sdObjectModel.
			var sdObjectModel:SDObjectModel;
			
			switch ( changeObject.sdObjectModelType) {
				case "SDSymbolModel": {
					var sdSymbolModel:SDSymbolModel = diagramModel.getModelByID(sdID) as SDSymbolModel;
					
					if (sdSymbolModel == null) {
						var libraryName:String = changeObject.libraryName;
						var symbolName:String = changeObject.symbolName;
						
						sdSymbolModel = libraryManager.getSDObjectModel(libraryName, symbolName) as SDSymbolModel;
					}
					
					sdSymbolModel.fontWeight 		= changeObject.fontWeight;
					sdSymbolModel.fontSize 			= parseInt(changeObject.fontSize);
					sdSymbolModel.fontFamily		= changeObject.fontFamily;
					sdSymbolModel.textAlign 		= changeObject.textAlign;
					sdSymbolModel.textPosition 	= changeObject.textPosition;
					sdSymbolModel.text		 			= changeObject.text;
					
					
					sdObjectModel = sdSymbolModel;
					break;
				}
				case "SDImageModel": {					
					var sdImageModel:SDImageModel = diagramModel.getModelByID(sdID) as SDImageModel;
					
					if (sdImageModel == null){
						sdImageModel = new SDImageModel();
					}
					
					if (changeObject.imageURL == undefined ) {
						Logger.error("processUpdate_ObjectChanged() changeObject.imageURL is undefined, sdID="+sdID,this);
					} else {
						Logger.info("processUpdate_ObjectChanged() changeObject.imageURL = " + changeObject.imageURL,this);
						sdImageModel.imageURL = changeObject.imageURL;
					}
										  
					sdImageModel.styleName = changeObject.styleName;
					
					sdObjectModel = sdImageModel;
					break;
				}
				case "SDLineModel": {
					var sdLineModel:SDLineModel = diagramModel.getModelByID(sdID) as SDLineModel;
					
					if (sdLineModel == null){						
						sdLineModel = new SDLineModel();
					}
					
					sdLineModel.endX 						= changeObject.endX;
					sdLineModel.endY 						= changeObject.endY;	
					sdLineModel.bendX 					= changeObject.bendX;
					sdLineModel.bendY 					= changeObject.bendY;
					sdLineModel.startLineStyle 	= changeObject.startLineStyle;
					sdLineModel.endLineStyle 		= changeObject.endLineStyle;
					sdLineModel.lineWeight 			= changeObject.lineWeight;
					
					sdObjectModel = sdLineModel;
					break;
				}
				case "SDPencilDrawingModel": {
					var sdPencilDrawingModel:SDPencilDrawingModel = diagramModel.getModelByID(sdID) as SDPencilDrawingModel;
					
					if (sdPencilDrawingModel == null){
						sdPencilDrawingModel = new SDPencilDrawingModel();						
					}
					
					sdPencilDrawingModel.linePath 	= changeObject.linePath;
					sdPencilDrawingModel.lineWeight = changeObject.lineWeight;
					
					sdObjectModel = sdPencilDrawingModel;
					break;
				}
				case "SDTextAreaModel": {
					var sdTextAreaModel:SDTextAreaModel = diagramModel.getModelByID(sdID) as SDTextAreaModel;	
					
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
					
					sdObjectModel = sdTextAreaModel;
					
					Logger.info("processUpdate_ObjectChanged() sdTextAreaModel.text=" + sdTextAreaModel.text + ", depth=" + sdTextAreaModel.depth.toString(), this);
					break;
				}
			}
			
			sdObjectModel.sdID			= changeObject.sdID;
			sdObjectModel.color	 		= changeObject.color;
			sdObjectModel.x 				= changeObject.x;
			sdObjectModel.y 				= changeObject.y;
			sdObjectModel.width 		= changeObject.width;
			sdObjectModel.height		= changeObject.height;
			sdObjectModel.rotation	= changeObject.rotation;
			sdObjectModel.depth 		= changeObject.depth;
			
			// TODO Clean this up. The coupling is too tight.
			// To prevent throwing an RSOEvent from within diagramModel.addSDObjectModel()
			// we perform it's responsibilities here:	
			if (diagramModel.sdObjectModelsAC.contains(sdObjectModel) == false) {
				Logger.info("processUpdate_ObjectChanged() about to call diagramModel.addSDObjectModel(sdObjectModel) with sdObjectModel.sdID=" + sdObjectModel.sdID, this);
				diagramModel.addSDObjectModel(sdObjectModel);
			}
		}		
		
		[Mediate(event="RemoteSharedObjectEvent.CUT")]
		public function dispatchUpdate_CutStart(event:RemoteSharedObjectEvent) : void
		{
			// Our goal now is to stop propagating updates until this cut action is finished.
			
			Logger.info("dispatchUpdate_CutEvent()",this);
						
			for each (var sdObjectModel:SDObjectModel in event.cutCommand.clonesArr) 
			{
				var sd_obj:Object = {};
				sd_obj.commandName = "DeleteSelectedSDObjectModel";
				sd_obj.sdID = sdObjectModel.sdID;						
				_remoteSharedObject.setProperty(sd_obj.sdID.toString(), sd_obj);
			}		
			
		}
		
		
//		public function processUpdate_ClearDiagram(event:SyncEvent):void
//		{
//			Logger.info("processUpdate_ClearDiagram()",this);
//			diagramModel.initDiagramModel();		
//		}
		
//		public function dispatchUpdate_RefreshZoom(): void
//		{
//			Logger.info("dispatchUpdate_RefreshZoom()",this);
//			
//			_remoteSharedObject.setProperty("commandName", "RefreshZoom");
//			_remoteSharedObject.setProperty("scaleX", diagramModel.scaleX);
//			_remoteSharedObject.setProperty("scaleY", diagramModel.scaleY);						
//		}
//		
//		public function processUpdate_RefreshZoom(event:SyncEvent) : void
//		{
//			Logger.info("processUpdate_CreateLineComponent()",this);	
//			diagramModel.scaleX = parseFloat(event.target.data["scaleX"]);
//			diagramModel.scaleY = parseFloat(event.target.data["scaleY"]);			
//		}
//		
//		//[Mediate(event="StyleEvent.CHANGE_STYLE")]
//		public function dispatchUpdate_StyleChanged(event:StyleEvent):void
//		{
//			_remoteSharedObject.setProperty("commandName", "StyleChanged");
//			_remoteSharedObject.setProperty("styleName", event.styleName);
//		}
//		
//		public function processUpdate_StyleChanged(event:SyncEvent):void
//		{
//			diagramStyleManager.changeStyle(event.target.data["styleName"])
//		}
		
	}	
}

