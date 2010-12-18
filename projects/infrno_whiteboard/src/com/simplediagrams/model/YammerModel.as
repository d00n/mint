package com.simplediagrams.model
{
	
	
	import com.adobe.webapis.flickr.Permission;
	
//	import flash.data.EncryptedLocalStore;
	import flash.events.EventDispatcher;
//	import flash.filesystem.*;
//	import flash.utils.ByteArray;

	
	[Bindable]
	public class YammerModel extends EventDispatcher
	{
				
		public var saveLocally:Boolean = false
		
		public static const CONSUMER_ACCESS_KEY:String = "gC3Lx8SCsV1wqEv5sLv3Q";
		public static const CONSUMER_ACCESS_SECRET:String = "zjdKROND77rW9o8XTKx5WHRmy1al3XJCLphltty9lm4";		
		
		public static const GET_OAUTH_REQUEST_TOKEN_URL:String = "https://www.yammer.com/oauth/request_token"
		public static const GET_OAUTH_ACCESS_TOKEN_URL:String = "https://www.yammer.com/oauth/access_token"
		public static const OAUTH_AUTHORIZE_URL:String = "https://www.yammer.com/oauth/authorize"
		public static const YAMMER_API_MESSAGES:String = 'https://www.yammer.com/api/v1/messages'
		
		public var username:String = ""
		public var oauthToken:String =""
		public var oauthTokenSecret:String ="" 
		public var oauthVerifier:String ="" 
		public var permAccessToken:String =""
		public var permAccessSecret:String = ""
		
		public var isAuthorized:Boolean = false
		
		//values for each image sent
		public var message:String
					
		public var isDirty:Boolean = false
		
		public function YammerModel()
		{
			//upon creation, see if the user has saved basecamp credentials locally
			loadFromEncryptedStore()			
		}
							
		
		public function loadFromEncryptedStore():void
		{
			
//			var yammerUsernameBA:ByteArray = EncryptedLocalStore.getItem("com.simplediagrams.YammerUsername")
//			if (yammerUsernameBA) username = yammerUsernameBA.readUTFBytes(yammerUsernameBA.length)
//				
//			var yammerPermAccessTokenBA:ByteArray = EncryptedLocalStore.getItem("com.simplediagrams.YammerPermAccessToken")
//			if (yammerPermAccessTokenBA) permAccessToken = yammerPermAccessTokenBA.readUTFBytes(yammerPermAccessTokenBA.length)
//				
//			var yammerPermAccessSecretBA:ByteArray = EncryptedLocalStore.getItem("com.simplediagrams.YammerPermAccessSecret")
//			if (yammerPermAccessSecretBA) permAccessSecret = yammerPermAccessSecretBA.readUTFBytes(yammerPermAccessSecretBA.length)
			
		}
		
		public function saveToEncryptedStore():void
		{			
//			var ba:ByteArray = new ByteArray()
//			ba.writeUTFBytes(username)
//			EncryptedLocalStore.setItem("com.simplediagrams.YammerUsername", ba )	
//				
//			ba = new ByteArray()
//			ba.writeUTFBytes(permAccessToken)
//			EncryptedLocalStore.setItem("com.simplediagrams.YammerPermAccessToken", ba )
//				
//			ba = new ByteArray()
//			ba.writeUTFBytes(permAccessSecret)
//			EncryptedLocalStore.setItem("com.simplediagrams.YammerPermAccessSecret", ba )
		}
		
		public function clearFromEncryptedStore():void
		{
//			EncryptedLocalStore.removeItem("com.simplediagrams.YammerUsername")
//			EncryptedLocalStore.removeItem("com.simplediagrams.YammerPermAccessToken")
//			EncryptedLocalStore.removeItem("com.simplediagrams.YammerPermAccessSecret")
			
		}
		
		
	}
}