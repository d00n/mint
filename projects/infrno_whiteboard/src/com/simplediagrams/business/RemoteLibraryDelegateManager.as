package com.simplediagrams.business
{
	import com.simplediagrams.events.RemoteLibraryEvent;
	import com.simplediagrams.model.libraries.LibraryInfo;
	
	import mx.collections.ArrayCollection;
	
	import org.swizframework.controller.AbstractController;
	import org.swizframework.events.BeanEvent;

	public class RemoteLibraryDelegateManager extends AbstractController
	{
		private var _remoteLibraryDelegateAC:ArrayCollection = new ArrayCollection();
		
		public function RemoteLibraryDelegateManager()
		{
		}

		public function readLibrary(libInfo:LibraryInfo):void
		{
		  var remoteLibraryDelegate:RemoteLibraryDelegate = new RemoteLibraryDelegate();
		  _remoteLibraryDelegateAC.addItem(remoteLibraryDelegate);
		  remoteLibraryDelegate.libInfo = libInfo;
			remoteLibraryDelegate.remoteLibraryDelegateId = _remoteLibraryDelegateAC.length - 1;
		  remoteLibraryDelegate.readLibrary();
			
			dispatcher.dispatchEvent(new BeanEvent(BeanEvent.SET_UP_BEAN, remoteLibraryDelegate));
		}	

		[Mediate(event="RemoteLibraryEvent.PROCESS_LIBRARY")]
		public function on_complete(remoteLibraryEvent:RemoteLibraryEvent):void
		{
			var rld:Object = _remoteLibraryDelegateAC.getItemAt(remoteLibraryEvent.remoteLibraryDelegateId);
			dispatcher.dispatchEvent(new BeanEvent(BeanEvent.REMOVE_BEAN, rld));
			_remoteLibraryDelegateAC.removeItemAt(remoteLibraryEvent.remoteLibraryDelegateId);
			
			if (_remoteLibraryDelegateAC.length == 0)
				_remoteLibraryDelegateAC = null;
		}
	}
}