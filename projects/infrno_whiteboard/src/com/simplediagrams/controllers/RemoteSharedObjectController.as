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
	import com.simplediagrams.commands.PasteCommand;
	import com.simplediagrams.commands.TransformCommand;
	import com.simplediagrams.events.*;
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
	import com.simplediagrams.vo.DummyUserInfoVO;
	
	import flash.display.BitmapData;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.SyncEvent;
	import flash.net.FileFilter;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.system.Capabilities;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.object_proxy;
	
	import org.swizframework.Swiz;
	import org.swizframework.controller.AbstractController;
	
	import spark.components.Group;
		
	public class RemoteSharedObjectController extends AbstractController 
	{

		/** A value of "success" means the client changed the shared object */
		private static const SUCCESS : String = "success";
		
		/** A value of "change" means another client changed the object or the server resynchronized the object. */
		private static const CHANGE : String = "change";
		
		private static const SHARED_OBJECT_NAME:String = "whiteboard_contents";
		
		private var _netConnection:NetConnection;
		private var _netStream:NetStream;
		private var _remoteSharedObject:SharedObject;
		
		private var _auth_key:String;
		private var _room_id:String;
		private var _room_name:String;
		private var _user_name:String;
		private var _wowza_server:String;
		private var _wowza_whiteboard_app:String;
		private var _image_server:String;
		
		
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
//			clientObj.getUserStats = function():void
//			{
//				Logger.info("getUserStats", this);			
//			}
				
				
//			clientObj.receiveJPG = function(params) : void
//			{
//				var sdImageModel:SDImageModel = new SDImageModel();
//				sdImageModel.imageData	 	= params["image"];
//				sdImageModel.sdID 			= parseInt(params["sdID"]);
//				sdImageModel.x 				= parseInt(params["x"]);
//				sdImageModel.y 				= parseInt(params["y"]);
//				sdImageModel.width 			= parseInt(params["width"]);
//				sdImageModel.height	 		= parseInt(params["height"]);
//				sdImageModel.zIndex 		= parseInt(params["zIndex"]);
////				sdImageModel.orig_height	= parseInt(params["orig_height"]);
////				sdImageModel.orig_width 	= parseInt(params["orig_width"]);
//				sdImageModel.styleName 		= params["styleName"];
//
//				diagramModel.addSDObjectModel(sdImageModel);
//			}			
				
			_netConnection.client = clientObj;
			
			var ws:String = _wowza_server +"/"+ _wowza_whiteboard_app +"/"+ _room_id;
			Logger.info("connect() about to connect to " + ws,this);
			
			var dummyUserInfoVO:DummyUserInfoVO = new DummyUserInfoVO();
			_netConnection.connect(ws, dummyUserInfoVO, _auth_key, _room_id, _room_name, _user_name);     
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
		
		public function securityErrorHandler(event : SecurityErrorEvent) : void {  Logger.info('Security Error: '+event, this);  }
		public function ioErrorHandler(event : IOErrorEvent) : void {  Logger.info('IO Error: '+event, this);  }
		public function asyncErrorHandler(event : AsyncErrorEvent) : void {  Logger.info('Async Error: '+event, this);  }  		
		
		private function onSyncEventHandler(event : SyncEvent):void {
			Logger.info("onSyncEventHandler event:" + event,this);	
			
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
			}
		}

		[Mediate(event="RemoteSharedObjectEvent.LOAD_IMAGE")]
		public function dispatchUpdate_LoadImage(rsoEvent:RemoteSharedObjectEvent):void
		{
			Logger.info("dispatchUpdate_LoadImage() rsoEvent.sdImageModel.sdID = " + rsoEvent.sdImageModel.sdID,this);
			
			var returnValueFunction:Function = function(imageDetails:Object):void
			{
				Logger.info("dispatchUpdate_LoadImage() responder.result() imageDetails[sdID] = " + imageDetails["sdID"],this);

				var sdImageModel:SDImageModel = diagramModel.getModelByID(imageDetails["sdID"]) as SDImageModel;
				sdImageModel.imageURL = imageDetails["imageURL"];
				
				var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
				rsoEvent.changedSDObjectModelArray = new Array;				
				rsoEvent.changedSDObjectModelArray.push(sdImageModel);
				Swiz.dispatchEvent(rsoEvent);	
			}
			
			var responder:Responder = new Responder(returnValueFunction);
			
			_netConnection.call("sendImage", responder, rsoEvent.imageData, 
				rsoEvent.imageName,
				rsoEvent.sdImageModel.sdID.toString());
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
			_wowza_server 			= event.wowza_server;
			_wowza_whiteboard_app 	= event.wowza_whiteboard_app;
			_image_server 			= event.image_server;
			
			connect();
		}
		

		[Mediate(event="RemoteSharedObjectEvent.DELETE_SELECTED_SD_OBJECT_MODEL")]
		public function dispatchUpdate_DeleteSelectedSDObjectModel(event:RemoteSharedObjectEvent) : void 
		{			
			Logger.info("dispatchUpdate_DeleteSelectedSDObjectModel()",this);
			
			for(var i:int=0; i< event.sdIDArray.length; i++) 
			{
				var sdID:Number = event.sdIDArray[i];
				var sd_obj:Object = {};
				sd_obj.commandName = "DeleteSelectedSDObjectModel";
				sd_obj.sdID = sdID;						
				_remoteSharedObject.setProperty(sd_obj.sdID.toString(), sd_obj);
			}			
		}	
		
		[Mediate(event="RemoteSharedObjectEvent.DISPATCH_TEXT_AREA_CHANGE")]
		public function processUpdate_DispatchTextAreaChange(event:RemoteSharedObjectEvent):void
		{
			Logger.info("processUpdate_DispatchTextAreaChange()",this);

			var sdTextAreaModel:SDTextAreaModel = diagramModel.getModelByID(event.sdID) as SDTextAreaModel;			
			
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED);	
			rsoEvent.changedSDObjectModelArray = new Array;				
			rsoEvent.changedSDObjectModelArray.push(sdTextAreaModel);
			Swiz.dispatchEvent(rsoEvent);	
		}
		
		public function processUpdate_DeleteSelectedSDObjectModel(changeObject:Object):void
		{
			Logger.info("processUpdate_DeleteSelectedSDObjectModel()",this);
			var sdID:Number = parseInt(changeObject.sdID);
			diagramModel.deleteSDObjectModelByID(sdID);
		}		
			
		[Mediate(event="RemoteSharedObjectEvent.OBJECT_CHANGED")]
		[Mediate(event="RemoteSharedObjectEvent.TEXT_WIDGET_ADDED")]
		[Mediate(event="RemoteSharedObjectEvent.TEXT_WIDGET_CREATED")]
		[Mediate(event="RemoteSharedObjectEvent.PENCIL_DRAWING_CREATED")]
		[Mediate(event="RemoteSharedObjectEvent.ADD_SD_OBJECT_MODEL")]
		public function dispatchUpdate_ObjectChanged(event:RemoteSharedObjectEvent) : void
		{
			Logger.info("dispatchUpdate_ObjectChanged()",this);
			
			for each (var sdObjectModel:SDObjectModel in event.changedSDObjectModelArray)
			{			
				var sd_obj:Object = {};
				sd_obj.commandName 	= "ObjectChanged";
				sd_obj.sdID 		= sdObjectModel.sdID;							
				sd_obj.x 			= sdObjectModel.x;
				sd_obj.y 			= sdObjectModel.y;		
				sd_obj.height 		= sdObjectModel.height;		
				sd_obj.width 		= sdObjectModel.width;		
				sd_obj.rotation 	= sdObjectModel.rotation;		
				sd_obj.color 		= sdObjectModel.color;	
				sd_obj.depth 		= sdObjectModel.depth;	
				
				if (sdObjectModel is SDSymbolModel){
					var sdSymbolModel:SDSymbolModel = sdObjectModel as SDSymbolModel;
					
					sd_obj.sdObjectModelType 	= "SDSymbolModel";
					sd_obj.libraryName 			= sdSymbolModel.libraryName;				
					sd_obj.symbolName 			= sdSymbolModel.symbolName;		
					sd_obj.textAlign 			= sdSymbolModel.textAlign;
					sd_obj.fontSize 			= sdSymbolModel.fontSize;
					sd_obj.fontWeight 			= sdSymbolModel.fontWeight;
					sd_obj.textPosition			= sdSymbolModel.textPosition;	
					sd_obj.text					= sdSymbolModel.text;	
				}
				else if (sdObjectModel is SDImageModel){
					var sdImageModel:SDImageModel = sdObjectModel as SDImageModel;
					
					sd_obj.sdObjectModelType 	= "SDImageModel";					
					sd_obj.imageURL				= sdImageModel.imageURL;
				}
				else if (sdObjectModel is SDLineModel){
					var sdLineModel:SDLineModel = sdObjectModel as SDLineModel;
					
					sd_obj.sdObjectModelType 	= "SDLineModel";
					sd_obj.endX 				= sdLineModel.endX;
					sd_obj.endY 				= sdLineModel.endY;	
					sd_obj.bendX 				= sdLineModel.bendX;
					sd_obj.bendY 				= sdLineModel.bendY;
					sd_obj.startLineStyle 		= sdLineModel.startLineStyle;
					sd_obj.endLineStyle 		= sdLineModel.endLineStyle;
					sd_obj.lineWeight 			= sdLineModel.lineWeight;
				}
				else if (sdObjectModel is SDPencilDrawingModel){
					var sdPencilDrawingModel:SDPencilDrawingModel = sdObjectModel as SDPencilDrawingModel;
					
					sd_obj.sdObjectModelType 	= "SDPencilDrawingModel";
					sd_obj.linePath 			= sdPencilDrawingModel.linePath;
					sd_obj.lineWeight 			= sdPencilDrawingModel.lineWeight;
				}
				else if (sdObjectModel is SDTextAreaModel){
					var sdTextAreaModel:SDTextAreaModel = sdObjectModel as SDTextAreaModel;
					
					sd_obj.sdObjectModelType 	= "SDTextAreaModel";
					sd_obj.styleName 			= sdTextAreaModel.styleName;
					sd_obj.maintainProportion 	= sdTextAreaModel.maintainProportion;		
					sd_obj.textAlign 			= sdTextAreaModel.textAlign;
					sd_obj.fontSize 			= sdTextAreaModel.fontSize;
					sd_obj.fontWeight 			= sdTextAreaModel.fontWeight;				
					sd_obj.text					= sdTextAreaModel.text;	
				}
				
				_remoteSharedObject.setProperty(sd_obj.sdID.toString(), sd_obj);
			}
		}
		
		public function processUpdate_ObjectChanged(changeObject:Object) : void 
		{
			Logger.info("processUpdate_ObjectChanged()",this);
			
			var sdID:Number = parseInt(changeObject.sdID);			
			var sdObjectModel:SDObjectModel;
			switch ( changeObject.sdObjectModelType) {
				case "SDSymbolModel": {
					var sdSymbolModel:SDSymbolModel = diagramModel.getModelByID(sdID) as SDSymbolModel;
					
					if (sdSymbolModel == null) {
						var libraryName:String = changeObject.libraryName;
						var symbolName:String = changeObject.symbolName;
						
						sdSymbolModel = libraryManager.getSDObject(libraryName, symbolName) as SDSymbolModel;
					}
					
					sdSymbolModel.textAlign 	= changeObject.textAlign;
					sdSymbolModel.fontWeight 	= changeObject.fontWeight;
					sdSymbolModel.fontSize 		= parseInt(changeObject.fontSize);
					sdSymbolModel.textPosition 	= changeObject.textPosition;
					sdSymbolModel.text		 	= changeObject.text;
					
					sdObjectModel = sdSymbolModel;
					break;
				}
				case "SDImageModel": {
					var sdImageModel:SDImageModel = diagramModel.getModelByID(sdID) as SDImageModel;
					
					if (sdImageModel == null){
						sdImageModel = new SDImageModel();
						sdImageModel.imageURL = changeObject.imageURL;

						Logger.info("processUpdate_ObjectChanged() changeObject.imageURL = " + changeObject.imageURL,this);
					}
					
					sdObjectModel = sdImageModel;
					break;
				}
				case "SDLineModel": {
					var sdLineModel:SDLineModel = diagramModel.getModelByID(sdID) as SDLineModel;
					
					if (sdLineModel == null){						
						sdLineModel = new SDLineModel();
					}
					
					sdLineModel.endX 			= changeObject.endX;
					sdLineModel.endY 			= changeObject.endY;	
					sdLineModel.bendX 			= changeObject.bendX;
					sdLineModel.bendY 			= changeObject.bendY;
					sdLineModel.startLineStyle 	= changeObject.startLineStyle;
					sdLineModel.endLineStyle 	= changeObject.endLineStyle;
					sdLineModel.lineWeight 		= changeObject.lineWeight;
					
					sdObjectModel = sdLineModel;
					break;
				}
				case "SDPencilDrawingModel": {
					var sdPencilDrawingModel:SDPencilDrawingModel = diagramModel.getModelByID(sdID) as SDPencilDrawingModel;
					
					if (sdPencilDrawingModel == null){
						sdPencilDrawingModel = new SDPencilDrawingModel();						
					}
					
					sdPencilDrawingModel.linePath = changeObject.linePath;
					sdPencilDrawingModel.lineWeight = changeObject.lineWeight;
					
					sdObjectModel = sdPencilDrawingModel;
					break;
				}
				case "SDTextAreaModel": {
					var sdTextAreaModel:SDTextAreaModel = diagramModel.getModelByID(sdID) as SDTextAreaModel;	
					
					if (sdTextAreaModel == null){
						sdTextAreaModel = new SDTextAreaModel();
					}
					
					sdTextAreaModel.styleName 			= changeObject.styleName;
					sdTextAreaModel.maintainProportion 	= changeObject.maintainProportion;		
					sdTextAreaModel.textAlign 			= changeObject.textAlign;
					sdTextAreaModel.fontSize 			= changeObject.fontSize;
					sdTextAreaModel.fontWeight 			= changeObject.fontWeight;
					sdTextAreaModel.text			 	= changeObject.text;
					
					sdObjectModel = sdTextAreaModel;
					break;
				}
			}
			
			sdObjectModel.sdID			= changeObject.sdID;
			sdObjectModel.color	 		= changeObject.color;
			sdObjectModel.x 			= changeObject.x;
			sdObjectModel.y 			= changeObject.y;
			sdObjectModel.width 		= changeObject.width;
			sdObjectModel.height		= changeObject.height;
			sdObjectModel.rotation		= changeObject.rotation;
			sdObjectModel.depth 		= changeObject.depth;
			
			// TODO Clean this up. The coupling is too tight.
			// To prevent throwing an RSOEvent from within diagramModel.addSDObjectModel()
			// we perform it's responsibilities here:	
			if (diagramModel.sdObjectModelsAC.contains(sdObjectModel) == false) {
				diagramModel.sdObjectModelsAC.addItem(sdObjectModel);
				diagramModel.addComponentForModel(sdObjectModel, false);
			}
		}	
		
		[Mediate(event="RemoteSharedObjectEvent.CUT")]
		public function dispatchUpdate_CutEvent(event:RemoteSharedObjectEvent) : void
		{
			Logger.info("dispatchUpdate_CutEvent()",this);
						
			for each (var sdObjectModel:SDObjectModel in event.cutCommand.clonesArr) 
			{
				var sd_obj:Object = {};
				sd_obj.commandName = "DeleteSelectedSDObjectModel";
				sd_obj.sdID = sdObjectModel.sdID;						
				_remoteSharedObject.setProperty(sd_obj.sdID.toString(), sd_obj);
			}		
			
		}
		
//		//[Mediate(event="CreateNewDiagramEvent.NEW_DIAGRAM_CREATED")]
//		public function dispatchUpdate_ClearDiagram(event:CreateNewDiagramEvent) : void
//		{
//			Logger.info("dispatchUpdate_ClearDiagram()",this);
//			_remoteSharedObject.setProperty("commandName", "ClearDiagram");
//		}
//		
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
//		
		
		
		// DEPRECATED
		
		//		[Mediate(event="RemoteSharedObjectEvent.PASTE")]
		//		public function dispatchUpdate_PasteEvent(event:RemoteSharedObjectEvent) : void
		//		{
		//			Logger.info("dispatchUpdate_PasteEvent()",this);
		//			
		//			for each (var sdObjectModel:SDObjectModel in event.pasteCommand.pastedObjectsArr)
		//			{			
		//				var sd_obj:Object = {};
		//
		//				var sdSymbolModel:SDSymbolModel = sdObjectModel as SDSymbolModel;
		//				if (sdSymbolModel != null) {
		//					sd_obj.is_LibraryItem = "true";
		//					sd_obj.libraryName = sdSymbolModel.libraryName;
		//					sd_obj.symbolName = sdSymbolModel.symbolName;								
		//					sd_obj.text = sdSymbolModel.text;
		//					sd_obj.textAlign = sdSymbolModel.textAlign;
		//					sd_obj.textPosition = sdSymbolModel.textPosition;
		//				}
		//				
		//				sd_obj.commandName = "PasteEvent";
		//				sd_obj.classInfo = describeType(sdObjectModel);
		//				sd_obj.sdID = sdObjectModel.sdID;
		//				sd_obj.color = sdObjectModel.color;
		//				sd_obj.height = sdObjectModel.height;
		//				sd_obj.width = sdObjectModel.width;
		//				sd_obj.rotation = sdObjectModel.rotation;
		//				sd_obj.x = sdObjectModel.x;
		//				sd_obj.y = sdObjectModel.y;
		//
		//				_remoteSharedObject.setProperty(sd_obj.sdID.toString(), sd_obj);
		//			}		
		//		}
		//		
		//		public function processUpdate_PasteEvent(changeObject:Object):void
		//		{
		//			Logger.info("processUpdate_PasteEvent()",this);
		//			
		//			var sdID:Number = parseInt(changeObject.sdID);
		//			var sdObjectModel:SDObjectModel = diagramModel.getModelByID(sdID);
		//			
		//			// this sort of error catching should not fire after persitence is completed
		//			if (sdObjectModel != null) {
		//				Logger.error("processUpdate_PasteEvent() found sdObjectModel for sdID " + sdID,this);
		//				return;	
		//			}
		//
		//			if (changeObject.is_LibraryItem == "true")
		//			{
		//				var libraryName:String = changeObject.libraryName;
		//				var symbolName:String = changeObject.symbolName;
		//				
		//				var cmd:AddLibraryItemCommand = new AddLibraryItemCommand(diagramModel, libraryManager, libraryName, symbolName);	
		//				
		//				cmd.sdID			= parseInt(changeObject.sdID);
		//				cmd.fontSize 		= parseInt(changeObject.fontSize);
		//				//cmd.color		 	= parseInt(changeObject.color);
		//				cmd.x 				= parseFloat(changeObject.x);
		//				cmd.y	 			= parseFloat(changeObject.y);
		//				cmd.fontWeight 		= changeObject.fontWeight;
		//				//cmd.text		 	= changeObject.text;
		//				cmd.textAlign		= changeObject.textAlign;
		//				cmd.textPosition	= changeObject.textPosition;
		//				
		//				cmd.execute();
		//			}			
		//		}
		
		
		//		public function dispatchUpdate_ChangeLinePosition(cmd:ChangeLinePositionCommand):void
		//		{
		//			Logger.info("dispatchUpdate_ChangeLinePosition()",this);
		//			
		//			_remoteSharedObject.setProperty("commandName", "ChangeLinePosition");
		//			
		//			//SDObjectMemento attributes
		//			_remoteSharedObject.setProperty("sdID", cmd.toState.sdID);
		//			_remoteSharedObject.setProperty("x", cmd.toState.x);
		//			_remoteSharedObject.setProperty("y", cmd.toState.y);
		//			_remoteSharedObject.setProperty("height", cmd.toState.height);
		//			_remoteSharedObject.setProperty("width", cmd.toState.width);
		//			_remoteSharedObject.setProperty("rotation", cmd.toState.rotation);
		//			_remoteSharedObject.setProperty("zIndex", cmd.toState.zIndex);
		//			_remoteSharedObject.setProperty("color", cmd.toState.color);
		//			
		//			// SDLineMemento attributes
		//			_remoteSharedObject.setProperty("startLineStyle", cmd.toState.startLineStyle);
		//			_remoteSharedObject.setProperty("endLineStyle", cmd.toState.endLineStyle);
		//			_remoteSharedObject.setProperty("lineWeight", cmd.toState.lineWeight);
		//			_remoteSharedObject.setProperty("startX", cmd.toState.startX);
		//			_remoteSharedObject.setProperty("startY", cmd.toState.startY);
		//			_remoteSharedObject.setProperty("endX", cmd.toState.endX);
		//			_remoteSharedObject.setProperty("endY", cmd.toState.endY);
		//			_remoteSharedObject.setProperty("bendX", cmd.toState.bendX);
		//			_remoteSharedObject.setProperty("bendY", cmd.toState.bendY);			
		//		}
		//		
		//		public function processUpdate_ChangeLinePosition(event:SyncEvent):void
		//		{
		//			Logger.info("processUpdate_ChangeLinePosition()",this);		
		//						
		//			var toState:SDLineMemento = new SDLineMemento();	
		//			toState.sdID 		= parseInt(event.target.data["sdID"]);
		//			toState.x 			= parseInt(event.target.data["x"]);
		//			toState.y 			= parseInt(event.target.data["y"]);
		//			toState.height 		= parseFloat(event.target.data["height"]);
		//			toState.width 		= parseFloat(event.target.data["width"]);
		//			toState.rotation 	= parseInt(event.target.data["rotation"]);
		//			toState.zIndex 		= parseInt(event.target.data["zIndex"]);
		//			toState.color 		= parseInt(event.target.data["color"]);
		//			
		//			toState.startLineStyle 	= parseInt(event.target.data["startLineStyle"]);
		//			toState.endLineStyle 	= parseInt(event.target.data["endLineStyle"]);
		//			toState.lineWeight 		= parseInt(event.target.data["lineWeight"]);			
		//			toState.startX 			= parseInt(event.target.data["startX"]);
		//			toState.startY 			= parseInt(event.target.data["startY"]);
		//			toState.endX 			= parseInt(event.target.data["endX"]);
		//			toState.endY 			= parseInt(event.target.data["endY"]);
		//			toState.bendX 			= parseInt(event.target.data["bendX"]);
		//			toState.bendY 			= parseInt(event.target.data["bendY"]);
		//			
		//			var cmd:ChangeLinePositionCommand = new ChangeLinePositionCommand(diagramModel)
		//			cmd.sdID 			= parseInt(event.target.data["sdID"]);
		//			cmd.toState = toState;
		//			
		//			var sdLineModel:SDLineModel = diagramModel.getModelByID(cmd.sdID) as SDLineModel;
		//			cmd.fromState = sdLineModel.getMemento() as SDLineMemento;
		//			
		//			cmd.execute();
		//		}
		//		
		//		public function dispatchUpdate_SymbolTextEdit(sdSymbolModel:SDSymbolModel):void
		//		{
		//			Logger.info("dispatchUpdate_SymbolTextEdit()",this);		
		//			
		//			_remoteSharedObject.setProperty("commandName", "SymbolTextEdit");
		//			_remoteSharedObject.setProperty("sdID", sdSymbolModel.sdID);
		//			_remoteSharedObject.setProperty("text", sdSymbolModel.text);
		//		}
		//		
		//		public function processUpdate_SymbolTextEdit(event:SyncEvent):void
		//		{
		//			Logger.info("processUpdate_SymbolTextEdit()",this);		
		//			
		//			var sdID:Number = parseInt(event.target.data["sdID"]);
		//			var sdObjectModel:SDObjectModel = diagramModel.getModelByID(sdID);
		//			SDSymbolModel(sdObjectModel).text = event.target.data["text"];			
		//		}
		//
		//		//[Mediate(event="RemoteSharedObjectEvent.DISPATCH_TEXT_AREA_CHANGE")]
		//		public function dispatchUpdate_SDTextAreaModel_Text(event:RemoteSharedObjectEvent):void
		//		{
		//			Logger.info("dispatchUpdate_SDTextAreaModel_Text()",this);		
		//			
		//			_remoteSharedObject.setProperty("commandName", "SDTextAreaModel_Text");
		//			_remoteSharedObject.setProperty("sdID", event.sdID);
		//			_remoteSharedObject.setProperty("text", event.text);
		//		}
		//		
		//		public function processUpdate_SDTextAreaModel_Text(event:SyncEvent):void
		//		{
		//			Logger.info("processUpdate_SDTextAreaModel_Text()",this);		
		//			
		//			var sdID:Number = parseInt(event.target.data["sdID"]);
		//			var sdObjectModel:SDObjectModel = diagramModel.getModelByID(sdID);
		//			(sdObjectModel as SDTextAreaModel).text = event.target.data["text"];	
		//		}
		//		
		
		//		public function processUpdate_sdChange():void
		//		{
		//			Logger.info("processUpdate_xmlDiagram()",this);		
		//			
		//			var xmlDiagram:XML = new XML(_remoteSharedObject.data.xmlDiagram);
		//			if (xmlDiagram != null ) {
		//				diagramModel.initDiagramModel();
		//				fileManager.loadXMLIntoDiagramModel(xmlDiagram);
		//				var evt:LoadDiagramEvent = new LoadDiagramEvent(LoadDiagramEvent.DIAGRAM_LOADED, true)							
		//				evt.success = true
		//				Swiz.dispatchEvent(evt)		
		//			}	
		//		}
		
		//		[Mediate(event="StyleEvent.CHANGE_STYLE")]
		//		[Mediate(event="CreateNewDiagramEvent.NEW_DIAGRAM_CREATED")]
		//		[Mediate(event="RemoteSharedObjectEvent.CHANGE_ALL_SHAPES_TO_DEFAULT_COLOR")]		
		//		[Mediate(event="RemoteSharedObjectEvent.REFRESH_Z_ORDER")]
		//		[Mediate(event="RemoteSharedObjectEvent.REFRESH_ZOOM")]
		//		public function dispatchUpdate_xmlDiagram(event:RemoteSharedObjectEvent):void
		//		{
		//			Logger.info("dispatchUpdate_xmlDiagram()",this);		
		//			
		//			var xmlDiagram:XML = fileManager.convertDiagramToXML();
		//			
		//			Logger.info("_remoteSharedObject.size = " + _remoteSharedObject.size ,this);
		//			_remoteSharedObject.setProperty("xmlDiagram", xmlDiagram.toString());
		//			Logger.info("_remoteSharedObject.size = " + _remoteSharedObject.size ,this);			
		//		}
		//		
		//		public function processUpdate_xmlDiagram():void
		//		{
		//			Logger.info("processUpdate_xmlDiagram()",this);		
		//			
		//			var xmlDiagram:XML = new XML(_remoteSharedObject.data.xmlDiagram);
		//			if (xmlDiagram != null ) {
		//				diagramModel.initDiagramModel();
		//				fileManager.loadXMLIntoDiagramModel(xmlDiagram);
		//				var evt:LoadDiagramEvent = new LoadDiagramEvent(LoadDiagramEvent.DIAGRAM_LOADED, true)							
		//				evt.success = true
		//				Swiz.dispatchEvent(evt)		
		//			}	
		//		}
		

		//		
		//		public function dispatchUpdate_TextWidgetAdded(cmd:AddTextWidgetCommand) : void
		//		{
		//			Logger.info("dispatchUpdate_TextWidgetAdded()",this);
		//			
		//			_remoteSharedObject.setProperty("commandName", "TextWidgetAdded");
		//			_remoteSharedObject.setProperty("sdID", cmd.sdID);
		//			_remoteSharedObject.setProperty("styleName", cmd.styleName);
		//			_remoteSharedObject.setProperty("x", cmd.x);
		//			_remoteSharedObject.setProperty("y", cmd.y);			
		//		}
		//		
		//		public function processUpdate_TextWidgetAdded(event:SyncEvent) : void
		//		{
		//			Logger.info("processUpdate_TextWidgetAdded()",this);		
		//			
		//			var cmd:AddTextWidgetCommand = new AddTextWidgetCommand(diagramModel)
		//			cmd.sdID		= parseInt(event.target.data["sdID"]);
		//			cmd.x 			= parseFloat(event.target.data["x"]);
		//			cmd.y 			= parseFloat(event.target.data["y"]);
		//			cmd.styleName	= event.target.data["styleName"];
		//			cmd.maintainProportion = true;
		//			
		//			cmd.execute();			
		//		}
		//		
		//		public function dispatchUpdate_TextAreaCreated(cmd:AddTextAreaCommand) : void
		//		{
		//			Logger.info("dispatchUpdate_TextAreaCreated()",this);
		//			
		//			_remoteSharedObject.setProperty("commandName", "TextAreaCreated");
		//			_remoteSharedObject.setProperty("sdID", cmd.sdID);
		//			_remoteSharedObject.setProperty("x", cmd.x);
		//			_remoteSharedObject.setProperty("y", cmd.y);			
		//			_remoteSharedObject.setProperty("width", cmd.width);
		//			_remoteSharedObject.setProperty("height", cmd.height);
		//			_remoteSharedObject.setProperty("styleName", cmd.styleName);
		//			_remoteSharedObject.setProperty("textAlign", cmd.textAlign);
		//			_remoteSharedObject.setProperty("fontSize", cmd.fontSize);
		//			_remoteSharedObject.setProperty("fontWeight", cmd.fontWeight);			
		//		}
		//		
		//		public function processUpdate_TextAreaCreated(event:SyncEvent) : void
		//		{
		//			Logger.info("processUpdate_TextAreaCreated()",this);		
		//			
		//			var cmd:AddTextAreaCommand = new AddTextAreaCommand(diagramModel)
		//			cmd.sdID		= parseInt(event.target.data["sdID"]);
		//			cmd.x 			= parseFloat(event.target.data["x"]);
		//			cmd.y 			= parseFloat(event.target.data["y"]);
		//			cmd.width		= parseFloat(event.target.data["width"]);
		//			cmd.height		= parseFloat(event.target.data["height"]);
		//			cmd.styleName	= event.target.data["styleName"];
		//			cmd.textAlign	= event.target.data["textAlign"];
		//			cmd.fontSize	= parseFloat(event.target.data["fontSize"]);
		//			cmd.fontWeight	= event.target.data["fontWeight"];
		//
		//			cmd.execute();		
		//		}
		//		
		//		public function dispatchUpdate_PencilDrawingCreated(cmd:AddPencilDrawingCommand) : void
		//		{
		//			Logger.info("dispatchUpdate_PencilDrawingCreated()",this);
		//			
		//			_remoteSharedObject.setProperty("commandName", "PencilDrawingCreated");
		//			_remoteSharedObject.setProperty("sdID", cmd.sdID);
		//			_remoteSharedObject.setProperty("linePath", cmd.linePath);
		//			_remoteSharedObject.setProperty("x", cmd.x);
		//			_remoteSharedObject.setProperty("y", cmd.y);			
		//			_remoteSharedObject.setProperty("width", cmd.width);
		//			_remoteSharedObject.setProperty("height", cmd.height);
		//			_remoteSharedObject.setProperty("color", cmd.color);			
		//		}
		//		
		//		public function processUpdate_PencilDrawingCreated(event:SyncEvent) : void
		//		{
		//			Logger.info("processUpdate_PencilDrawingCreated()",this);		
		//			
		//			var cmd:AddPencilDrawingCommand = new AddPencilDrawingCommand(diagramModel)
		//			cmd.sdID		= parseInt(event.target.data["sdID"]);
		//			cmd.linePath	= event.target.data["linePath"];
		//			cmd.x 			= parseFloat(event.target.data["x"]);
		//			cmd.y 			= parseFloat(event.target.data["y"]);
		//			cmd.width		= parseFloat(event.target.data["width"]);
		//			cmd.height		= parseFloat(event.target.data["height"]);
		//			cmd.color		= event.target.data["color"];
		//			
		//			cmd.execute();	
		//		}
		//		
		//		public function dispatchUpdate_CreateLineComponent(cmd:AddLineCommand) : void
		//		{
		//			Logger.info("dispatchUpdate_CreateLineComponent()",this);
		//			
		//			_remoteSharedObject.setProperty("commandName", "CreateLineComponent");
		//			_remoteSharedObject.setProperty("sdID", cmd.sdID);
		//			_remoteSharedObject.setProperty("x", cmd.x);
		//			_remoteSharedObject.setProperty("y", cmd.y);			
		//			_remoteSharedObject.setProperty("endX", cmd.endX);
		//			_remoteSharedObject.setProperty("endY", cmd.endY);			
		//			_remoteSharedObject.setProperty("startLineStyle", cmd.startLineStyle);
		//			_remoteSharedObject.setProperty("endLineStyle", cmd.endLineStyle);
		//			_remoteSharedObject.setProperty("lineWeight", cmd.lineWeight);		
		//		}
		//		
		//		public function processUpdate_CreateLineComponent(event:SyncEvent) : void
		//		{
		//			Logger.info("processUpdate_CreateLineComponent()",this);		
		//			
		//			var cmd:AddLineCommand = new AddLineCommand(diagramModel)
		//			cmd.sdID		= parseInt(event.target.data["sdID"]);
		//			cmd.x 			= parseFloat(event.target.data["x"]);
		//			cmd.y 			= parseFloat(event.target.data["y"]);
		//			cmd.endX		= parseFloat(event.target.data["endX"]);
		//			cmd.endY		= parseInt(event.target.data["endY"]);
		//			cmd.startLineStyle	= parseInt(event.target.data["defaultStartLineStyle"]);
		//			cmd.endLineStyle	= parseInt(event.target.data["defaultEndLineStyle"]);
		//			cmd.lineWeight		= event.target.data["defaultLineWeight"];
		//			
		//			cmd.execute();				
		//		}
		//		
		
		
		////		[Mediate(event="RemoteSharedObjectEvent.CHANGE_ALL_SHAPES_TO_DEFAULT_COLOR")]
		//		public function dispatchUpdate_ChangeAllShapesToDefaultColor():void
		//		{
		//			_remoteSharedObject.setProperty("commandName", "ChangeAllShapesToDefaultColor");			
		//		}
		//		
		//		public function processUpdate_ChangeAllShapesToDefaultColor(event:SyncEvent):void
		//		{
		//			diagramModel.changeAllShapesToDefaultColor();
		//		}
		//		
		//		[Mediate(event="RemoteSharedObjectEvent.CHANGE_COLOR")]
		//		public function dispatchUpdate_ChangeColor(event:RemoteSharedObjectEvent):void
		//		{
		//			Logger.info("dispatchUpdate_ChangeColor()",this);	
		//					
		//			_remoteSharedObject.setProperty("commandName", "ChangeColor");
		//			_remoteSharedObject.setProperty("sdID", event.sdID);
		//			_remoteSharedObject.setProperty("color", event.color);
		//		}
		//		
		//		public function processUpdate_ChangeColor(changeObject:Object):void
		//		{
		//			Logger.info("processUpdate_ChangeColor()",this);		
		//
		//			
		//			var cmd:ChangeColorCommand = new ChangeColorCommand(diagramModel, sdObjectModel);
		//			cmd.color = event.target.data["color"];	
		//			cmd.execute();
		//		}		
		
		//		public function dispatchUpdate_RefreshZOrder() : void
		//		{
		//			Logger.info("dispatchUpdate_RefreshZOrder()",this);
		//			
		//			var zOrderArray:Array = new Array();
		//			var numElements:uint = diagramModel.sdObjectModelsAC.length;
		//			for (var i:uint = 0; i<numElements; i++)
		//			{
		//				var sdObjectModel:SDObjectModel = diagramModel.sdObjectModelsAC.getItemAt(i) as SDObjectModel;
		//
		//				zOrderArray[i] = new Array();
		//				
		//				if (sdObjectModel != null) {
		//					zOrderArray[i]["sdID"] = sdObjectModel.sdID;
		//					zOrderArray[i]["depth"] = sdObjectModel.depth;
		//				}
		//			}
		//			
		//			_remoteSharedObject.setProperty("commandName", "RefreshZOrder");			
		//			_remoteSharedObject.setProperty("zOrderArray", zOrderArray);			
		//		}
		//		
		//		public function processUpdate_RefreshZOrder(event:SyncEvent) : void
		//		{
		//			Logger.info("processUpdate_RefreshZOrder()",this);			
		//			
		//			var zOrderArray:Array = event.target.data["zOrderArray"];
		//			for each (var zOrder:Array in zOrderArray)
		//			{
		//				var sdID:Number = parseInt(zOrder["sdID"]);
		//				var depth:Number = parseInt(zOrder["depth"]);
		//				
		//				var sdObjectModel:SDObjectModel = diagramModel.getModelByID(sdID);
		//								
		//				if (sdObjectModel != null) {
		//					Logger.info("processUpdate_RefreshZOrder() sdObjectModel.depth = " + sdObjectModel.depth.toString(),this);	
		//					sdObjectModel.depth = depth;	
		//				}				
		//			}			
		//		}
		
	}	
}

