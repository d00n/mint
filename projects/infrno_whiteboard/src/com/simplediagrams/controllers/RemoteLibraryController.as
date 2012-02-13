package com.simplediagrams.controllers
{
	import com.simplediagrams.business.RemoteLibraryDelegate;
	import com.simplediagrams.business.RemoteLibraryRegistryDelegate;
	import com.simplediagrams.events.RemoteLibraryEvent;
	import com.simplediagrams.events.RemoteSharedObjectEvent;
	import com.simplediagrams.model.libraries.ImageBackground;
	import com.simplediagrams.model.libraries.ImageShape;
	import com.simplediagrams.model.libraries.LibraryInfo;
	import com.simplediagrams.model.libraries.LibraryItem;
	import com.simplediagrams.model.libraries.SWFBackground;
	import com.simplediagrams.model.libraries.SWFShape;
	import com.simplediagrams.util.Logger;
	
	import mx.collections.ArrayCollection;
	import mx.logging.Log;
	
	import org.swizframework.controller.AbstractController;
	import org.swizframework.events.BeanEvent;

	public class RemoteLibraryController extends AbstractController
	{
		[Inject]
		public var remoteLibraryRegistryDelegate:RemoteLibraryRegistryDelegate;
		
		private var _remoteLibraryDelegateAC:ArrayCollection = new ArrayCollection();
		
		private var _auth_key:String;
		private var _room_id:String;
		private var _room_name:String;
		private var _user_name:String;
		private var _user_id:String;
		private var _image_server:String;
		private var _wowza_server:String;
		private var _wowza_whiteboard_app:String;
		private var _wowza_whiteboard_port:String;
		

		private static var PATH:String = "/libraries/";
		private var url:String;
		
		public function RemoteLibraryController()
		{
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
		
		public function loadRegistry():void{
			remoteLibraryRegistryDelegate.loadRegistry();
		}

		public function readLibrary(libInfo:LibraryInfo):void
		{
		  var remoteLibraryDelegate:RemoteLibraryDelegate = new RemoteLibraryDelegate();
			_remoteLibraryDelegateAC.addItem(remoteLibraryDelegate);
		  remoteLibraryDelegate.libInfo = libInfo;
		  remoteLibraryDelegate.url = _image_server + PATH + libInfo.name + "/";
		  remoteLibraryDelegate.readLibrary();
			
			dispatcher.dispatchEvent(new BeanEvent(BeanEvent.SET_UP_BEAN, remoteLibraryDelegate));
		}	

		[Mediate(event="RemoteLibraryEvent.PROCESS_LIBRARY")]
		public function on_complete(rlEvent:RemoteLibraryEvent):void
		{
			var index:int = _remoteLibraryDelegateAC.getItemIndex(rlEvent.remoteLibraryDelegate);
			 _remoteLibraryDelegateAC.removeItemAt(index);
			
			dispatcher.dispatchEvent(new BeanEvent(BeanEvent.REMOVE_BEAN, rlEvent.remoteLibraryDelegate));
			
//			if (_remoteLibraryDelegateAC.length == 0)
//				_remoteLibraryDelegateAC = null;
		}
		
		public function assetPath(libItem:LibraryItem):String{
			if (libItem == null){
				Logger.error("RemoteLibraryController.assetPath was passed a null libItem");
				return '';
			}
			
			var path:String = _image_server + PATH + libItem.libraryName +'/';	
			if  (libItem is ImageShape)  {
				path = path + (libItem as ImageShape).path;
			}else if (libItem is SWFShape)  {
				path = path + (libItem as SWFShape).path;
			}else if (libItem is SWFBackground)  {
				path = path + (libItem as SWFBackground).path;
			}else if (libItem is ImageBackground)  {
				path = path + (libItem as ImageBackground).path;
			}else{
				Logger.error("RemoteLibraryController.assetPath was passed a non-image and non-swf libItem: " + libItem.name);
				return '';
			}
			
   		Logger.info("RemoteLibraryController.assetPath path: " + path);
			return path;
		}
	}
}