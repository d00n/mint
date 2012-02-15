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
		private var _remoteLibraryRegistryDelegate:RemoteLibraryRegistryDelegate;
		
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
		

		private var _library_server:String;
		private var _library_base_path:String;
		private var _library_registry_file:String;
		
//		private var url:String;
		
		public function RemoteLibraryController()
		{
		}
		
		public function library_registry_file_url():String{
			return _library_server + _library_base_path + _library_registry_file;
		}
		
		public function library_url():String{
			return _library_server + _library_base_path;
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
			
			_library_server = event.library_server;
			_library_base_path = event.library_base_path;
			_library_registry_file = event.library_registry_file;
		}		
		
		public function loadRegistry():void{
			_remoteLibraryRegistryDelegate = new RemoteLibraryRegistryDelegate();
			dispatcher.dispatchEvent(new BeanEvent(BeanEvent.SET_UP_BEAN, _remoteLibraryRegistryDelegate));
			_remoteLibraryRegistryDelegate.loadRegistry();
		}

		public function readLibrary(libInfo:LibraryInfo):void
		{
		  var remoteLibraryDelegate:RemoteLibraryDelegate = new RemoteLibraryDelegate();
			_remoteLibraryDelegateAC.addItem(remoteLibraryDelegate);
		  remoteLibraryDelegate.libInfo = libInfo;
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
				Logger.error("RemoteLibraryController.assetPath was passed a null libItem", this);
				return '';
			}
			
			var path:String = library_url + libItem.libraryName +'/';	
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