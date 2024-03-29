package com.simplediagrams.model
{
	
	
	import com.simplediagrams.model.vo.PersonVO;
	
//	import flash.data.EncryptedLocalStore;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import mx.collections.SortField;
	import mx.collections.Sort;

	import mx.collections.ArrayCollection;
		
	[Bindable]
	public class BasecampModel extends EventDispatcher
	{
		
		
		public var selectedProjectID:String
					
		public var saveLocally:Boolean = false
		
		private var _peopleArr:Array = []
		private var _basecampURL:String = "" 
		private var _basecampLogin:String = "" 
		private var _basecampPassword:String = "" 
			
		public var isDirty:Boolean = false
			
		public var projectsAC:ArrayCollection = new ArrayCollection()
		public var peopleAC:ArrayCollection = new ArrayCollection() //holds PersonVO's
		public var selectedPeopleAC:ArrayCollection = new ArrayCollection() //holds PersonVO's
		public var msgIsPrivate:Boolean = true
			
		public function BasecampModel()
		{
			//upon creation, see if the user has saved basecamp credentials locally
			loadFromEncryptedStore()
						
			var dataSortField:SortField = new SortField();
			dataSortField.name = "name";
			dataSortField.caseInsensitive = true
							
			var projectNameSort:Sort = new Sort();
			projectNameSort.fields = [dataSortField];
			
			projectsAC.sort = projectNameSort;
			projectsAC.refresh();

			
		}
		
		
		
		public function set peopleArr(peopleArr:Array):void
		{
			_peopleArr = peopleArr
			peopleAC = new ArrayCollection(_peopleArr)
			selectedPeopleAC = new ArrayCollection(_peopleArr)
			selectedPeopleAC.filterFunction = filterPeopleToNotify;
			selectedPeopleAC.refresh();
			
		}
		
		
		protected function filterPeopleToNotify(item:Object):Boolean
		{
			return item.notify
		}
		

		public function get basecampURL():String
		{
			return _basecampURL
		}
		
		public function set basecampURL(value:String):void
		{
			_basecampURL = value
		}
		
		public function get basecampLogin():String
		{
			return _basecampLogin
		}
		
		public function set basecampLogin(value:String):void
		{
			_basecampLogin = value
		}
		
		public function get basecampPassword():String
		{
			return _basecampPassword
		}
		
		public function set basecampPassword(value:String):void
		{
			_basecampPassword = value
		}
		
		
		public function selectAllPeopleForNotification():void
		{
			for each (var person:PersonVO in _peopleArr)
			{
				person.notify = true
			}
		}
		
		public function selectNoPeopleForNotification():void
		{
			for each (var person:PersonVO in _peopleArr)
			{
				person.notify = false
			}
		}
		
		/* Notifications is managed separately from credentials */
		
		public function get enableNotifications():Boolean
		{		
			return false
			
//			var enableNotificationsBA:ByteArray = EncryptedLocalStore.getItem("enableNotifications")
//			if (enableNotificationsBA) 
//			{
//				return (enableNotificationsBA.readUTFBytes(enableNotificationsBA.length) == "true")
//			}
//			else
//			{
//				return false
//			}
		}
		
		public function set enableNotifications(value:Boolean):void
		{					
//			var ba:ByteArray = new ByteArray()
//			ba.writeUTFBytes(value.toString())
//			EncryptedLocalStore.setItem("enableNotifications", ba )		
		}
		
		
		public function get defaultMessageToPrivate():Boolean
		{			
//			var defaultMessageToPrivateBA:ByteArray = EncryptedLocalStore.getItem("defaultMessageToPrivate")
//			if (defaultMessageToPrivateBA) 
//			{
//				return (defaultMessageToPrivateBA.readUTFBytes(defaultMessageToPrivateBA.length) == "true")
//			}
//			else
//			{
//				return true
//			}
			return true;
		}
		
		public function set defaultMessageToPrivate(value:Boolean):void
		{					
//			var ba:ByteArray = new ByteArray()
//			ba.writeUTFBytes(value.toString())
//			EncryptedLocalStore.setItem("defaultMessageToPrivate", ba )		
		}
		
		
				
		public function loadFromEncryptedStore():void
		{
			
//			var basecampURLBA:ByteArray = EncryptedLocalStore.getItem("basecampURL")
//			if (basecampURLBA) _basecampURL = basecampURLBA.readUTFBytes(basecampURLBA.length)
//				
//			var loginBA:ByteArray = EncryptedLocalStore.getItem("basecampLogin")
//			if (loginBA) _basecampLogin = loginBA.readUTFBytes(loginBA.length)
//				
//			var passwordBA:ByteArray = EncryptedLocalStore.getItem("basecampPassword")
//			if (passwordBA) _basecampPassword = passwordBA.readUTFBytes(passwordBA.length)
//				
//			
//			if (_basecampURL)
//			{
//				saveLocally = true
//			}
		
		}
		
		public function saveToEncryptedStore():void
		{
			
//			ba = new ByteArray()
//			ba.writeUTFBytes(_basecampURL)
//			EncryptedLocalStore.setItem("basecampURL", ba )	
//			
//			ba = new ByteArray()
//			ba.writeUTFBytes(_basecampLogin)
//			EncryptedLocalStore.setItem("basecampLogin", ba )
//				
//			var ba:ByteArray = new ByteArray()
//			ba.writeUTFBytes(_basecampPassword)
//			EncryptedLocalStore.setItem("basecampPassword", ba )
//						
			
		}
		
		public function clearFromEncryptedStore():void
		{
//			EncryptedLocalStore.removeItem("basecampURL")
//			EncryptedLocalStore.removeItem("basecampLogin")
//			EncryptedLocalStore.removeItem("basecampPassword")
		}
		
		
	}
}