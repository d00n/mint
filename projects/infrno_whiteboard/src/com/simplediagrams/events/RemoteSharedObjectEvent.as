package com.simplediagrams.events
{
	import com.simplediagrams.commands.*;
	import com.simplediagrams.model.SDImageModel;
	
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
		public static const ADD_SD_OBJECT_MODEL:String = "rso_addSDObjectModel";
		public static const DELETE_SELECTED_SD_OBJECT_MODEL:String = "rso_DeleteSelectedSDObjectModel";
		public static const OBJECT_CHANGED:String = "rso_ObjectChanged";	
		public static const UPDATE_DEPTHS:String = "rso_ObjectUpdateDepths";
		
		public static const TEXT_WIDGET_ADDED:String = "rso_TextWidgetAdded";
		public static const TEXT_WIDGET_CREATED:String = "rso_TextWidgetCreated";
		public static const PENCIL_DRAWING_CREATED:String = "rso_PencilDrawingCreated";
		public static const CREATE_LINE_COMPONENT:String = "rso_CreateLineComponent";
		public static const REFRESH_ZOOM:String = "rso_RefreshZoom";
		public static const CHANGE_LINE_POSITION:String = "rso_ChangeLinePosition";
		public static const SYMBOL_TEXT_EDIT:String = "rso_SymbolTextEdit";
		public static const LOAD_FLASHVARS:String = "rso_LoadFlashvars";
		
		public static const GRID:String = "rso_Grid";
		public var show_grid:Boolean;
		public var cell_width:Number;
		public var alpha:Number;		
		
		private var _imageData:ByteArray
		public var imageName:String;
		public static const STYLE_PHOTO:String = "photoStyle";
		public var sdImageModel:SDImageModel;
		public var id:String;
		public var idArray:Array;
		public var changedSDObjectModelArray:Array;
		
		// Wowza will accept these values for specified hosts.
		public var auth_key:String = "sample_auth_key";
		
//		public var room_id:String = "err2015";
//		public var room_id:String = "neg-width-on-SDTextArea";
//		public var room_id:String = "staging_snap_err_wOfflineDB";
		public var room_id:String = "14";
		
		public var room_name:String = "";
		public var user_name:String = "";
		public var user_id:String = "";
		public var wowza_server:String = "rtmp://localhost";
		public var wowza_whiteboard_app:String = "whiteboard";
		public var wowza_whiteboard_port:String = "1936";
		public var image_server:String = "http://localhost";
//		public var google_analytics_report_interval_seconds:int = 60;
//		public var google_analytics_debug_mode:Boolean = false;

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