package com.simplediagrams.events
{
	import com.simplediagrams.commands.*;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.mementos.TransformMemento;
	
	import flash.events.Event;
	import flash.utils.ByteArray;

	
	public class RemoteSharedObjectEvent extends Event
	{
		// Cutting locally appears as a delete to peers
		public static const CUT:String = "rso_CutEvent";
		
		public static const RESET:String = "rso_reset";
		public static const STOP:String = "rso_stop";
		public static const START:String = "rso_start";
		public static const LOAD_IMAGE:String = "rso_loadImage";
		public static const DISPATCH_TEXT_AREA_CHANGE:String = "rso_dispatchTextAreaChange";
		public static const ADD_SD_OBJECT_MODEL:String = "rso_addSDObjectModel";
		public static const DELETE_SELECTED_SD_OBJECT_MODEL:String = "rso_DeleteSelectedSDObjectModel";
		public static const OBJECT_CHANGED:String = "rso_ObjectChanged";
		
		public static const REFRESH_Z_ORDER:String = "rso_refreshZOrder";
		public static const TEXT_WIDGET_ADDED:String = "rso_TextWidgetAdded";
		public static const TEXT_WIDGET_CREATED:String = "rso_TextWidgetCreated";
		public static const PENCIL_DRAWING_CREATED:String = "rso_PencilDrawingCreated";
		public static const CREATE_LINE_COMPONENT:String = "rso_CreateLineComponent";
		public static const REFRESH_ZOOM:String = "rso_RefreshZoom";
		public static const CHANGE_LINE_POSITION:String = "rso_ChangeLinePosition";
		public static const SYMBOL_TEXT_EDIT:String = "rso_SymbolTextEdit";
		public static const LOAD_FLASHVARS:String = "rso_LoadFlashvars";
		
		
		private var _imageData:ByteArray
		public var imageName:String;
		public static const STYLE_PHOTO:String = "photoStyle";
		public var sdImageModel:SDImageModel;
		public var sdID:Number;
		public var sdObjectModel:SDObjectModel;
		public var addLibraryItemCommand:AddLibraryItemCommand;
		public var cutCommand:CutCommand;
		public var sdIDArray:Array;
		public var changedSDObjectModelArray:Array;
		
		// Wowza will accept these values for specified hosts.
		public var auth_key:String = "sample_auth_key";
		public var room_id:String = "whiteboard_default";
		public var room_name:String = "whiteboard_default";
		public var user_name:String = "whiteboard_default";
		public var user_id:String = "whiteboard_default";
		public var wowza_server:String = "rtmp://localhost";
		public var wowza_whiteboard_app:String = "whiteboard";
		public var wowza_whiteboard_port:String = "1936";
		public var image_server:String = "http://localhost";

		public function RemoteSharedObjectEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set imageData(v:ByteArray):void
		{
			_imageData = v;
		}
		public function get imageData():ByteArray
		{
			return _imageData;
		}
	}
}