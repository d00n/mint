package com.simplediagrams.controllers
{
	import com.simplediagrams.business.RemoteLibraryDelegate;
	import com.simplediagrams.events.RemoteLibraryEvent;
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
		private var _remoteLibraryDelegateAC:ArrayCollection = new ArrayCollection();
		
		private static var HOST:String = "http://localhost";
		private static var PATH:String = "/libraries/";
		private var url:String;
		
		public function RemoteLibraryController()
		{
		}
		

		public function readLibrary(libInfo:LibraryInfo):void
		{
		  var remoteLibraryDelegate:RemoteLibraryDelegate = new RemoteLibraryDelegate();
			_remoteLibraryDelegateAC.addItem(remoteLibraryDelegate);
		  remoteLibraryDelegate.libInfo = libInfo;
		  remoteLibraryDelegate.url = HOST + PATH + libInfo.name + "/";
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
		
		public static function assetPath(libItem:LibraryItem):String{
			if (libItem == null){
				Logger.error("RemoteLibraryController.assetPath was passed a null libItem");
				return '';
			}
			
			var path:String = HOST + PATH + libItem.libraryName +'/';	
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