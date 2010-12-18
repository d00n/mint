package com.simplediagrams.business
{
	import com.adobe.crypto.MD5;
	import com.simplediagrams.model.YammerModel;
	import com.simplediagrams.util.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
//	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.http.HTTPService;
	
	import org.osmf.utils.URL;
	
	public class YammerDelegate extends EventDispatcher
	{
		
		public static const UPLOAD_COMPLETE:String = "uploadComplete";
		public static const UPLOAD_ERROR:String = "uploadError";
		
		[Inject(bean="yammerService")]
		public var service:HTTPService 
		
		[Inject]
		public var yammerModel:YammerModel;
							
		private var _token:AsyncToken
		
		private var _boundary:String = "----------thisistheboundary!"
		
		public function YammerDelegate()
		{
			
		}
		
		public function getRequestTokenAndSecret():AsyncToken
		{
			Logger.debug("getRequestTokenAndSecret() ", this)				
			service.url = YammerModel.GET_OAUTH_REQUEST_TOKEN_URL
				
			var headersObj:Object = {}
			headersObj.Authorization = getOAuthHeaders(null,null,null)
			service.headers = headersObj
			service.method = "POST"	
						
			return service.send()			
		}
		
				
		public function getPermTokenAndSecretToken():AsyncToken
		{
			Logger.debug("getPermTokenAndSecretToken() ", this)	
		
			service.url = YammerModel.GET_OAUTH_ACCESS_TOKEN_URL
			var headersObj:Object = {}
			headersObj.Authorization = getOAuthHeaders(yammerModel.oauthToken, yammerModel.oauthTokenSecret, yammerModel.oauthVerifier)
			service.headers = headersObj
			service.method = "POST"		
							
			return service.send()		
		}
		
		
		public function showAuthorizePage():void
		{			
			Logger.debug("showAuthorizePage() ", this)				
			var url:String = YammerModel.OAUTH_AUTHORIZE_URL	
			url+= "?oauth_token=" + yammerModel.oauthToken
			var urlRequest:URLRequest = new URLRequest(url)
			navigateToURL(urlRequest, "_blank");			
		}
		
	
		
		protected function getOAuthHeaders(token:String=null, tokenSecret:String=null, verifier:String=null):String
		{
			var header:String = 'OAuth realm="", '
			header += 'oauth_consumer_key="' + YammerModel.CONSUMER_ACCESS_KEY + '", '
			
			if (token != null) 
			{
				header += 'oauth_token="' + token + '", '
			}
			
			header += 'oauth_signature_method="PLAINTEXT", '
			header += 'oauth_signature="' + YammerModel.CONSUMER_ACCESS_SECRET + '%26'
			if (tokenSecret != null) 
			{
				header += tokenSecret
			}
			header += '", '
			header += 'oauth_timestamp="' + time + '", '
			header += 'oauth_nonce="' + nonce
			
			if (verifier != null) 
			{
				header += '", '					
				header += 'oauth_verifier="'
				header += verifier
			}
			
			header += '", oauth_version="1.0"'
			
			Logger.debug("getOAuthHeaders() header: " + header, this)	
			
			return header
			
			
		}
		
		protected function get time():String
		{
			return Math.round(new Date().getTime() / 1000).toString(); 
		}
		
		protected function get nonce():String
		{
			return Math.round(Math.random() * 99999).toString();
		}
		

				
		public function cancelServiceCall():void
		{
			service.cancel()
		}
		
		
		/* We are going to use URLRequest first and then see if we can get HTTPService to work */
		
		public function postMessage(message:String, imageBytes:ByteArray, repliedToID:String = null, groupID:String = null, directToID:String = null):void
		{
			
			_boundary = getBoundary()
			
			var req:URLRequest = new URLRequest()
			req.url = YammerModel.YAMMER_API_MESSAGES
			req.method = URLRequestMethod.POST
			req.contentType = "multipart/form-data; boundary=" + _boundary;
			
			//headers
			var headersArr:Array = []
			headersArr.push(new URLRequestHeader("Authorization", getOAuthHeaders(yammerModel.permAccessToken, yammerModel.permAccessSecret, null)))
			//headersArr.push(new URLRequestHeader("Cookie", ""))
			req.requestHeaders = headersArr
			
			Logger.debug("Headers: " + headersArr.toString(),this)
							
			//parameters				
			var params:Object = {}	
			if (message=="" || message==null)
			{
				message = "--" 
			}
			params.body = message;				
			if (repliedToID) { params.replied_to_id = repliedToID; }
			if (groupID) { params.group_id = groupID; }
			if (directToID) { params.direct_to_id = directToID; }		
			
			req.data = getMultiPartRequestData( "someSimpleDiagram.png", imageBytes, params)
													
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, postMessageHandler);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, handleHTTPStatus);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			urlLoader.load(req);		
		
		}
		
		
		protected function getMultiPartRequestData(imageName:String, imageBytes:ByteArray, parameters:Object = null):ByteArray
		{			
			var returnData:ByteArray = new ByteArray();
			returnData.endian = Endian.BIG_ENDIAN;
						
			//add parameters to returnData
			for(var paramName:String in parameters)
			{
				returnData = BOUNDARY(returnData);
				returnData = LINEBREAK(returnData);
				            
				var content:String = 'Content-Disposition: form-data; name="' + paramName + '"';
				
				for ( var i:uint = 0; i < content.length; i++ ) 
				{
					returnData.writeByte( content.charCodeAt(i) );
				}
				
				returnData = LINEBREAK(returnData);
				returnData = LINEBREAK(returnData);
				returnData.writeUTFBytes(parameters[paramName]);
				returnData = LINEBREAK(returnData);
			}						
				
			//add image data to returnData
			returnData = BOUNDARY(returnData);
			returnData = LINEBREAK(returnData);
			
			content = 'Content-Disposition: form-data; name="attachment1"; filename="';
				
			for ( i = 0; i < content.length; i++ ) 
			{
				returnData.writeByte( content.charCodeAt(i) );
			}			
			returnData.writeUTFBytes(imageName);
			
			returnData = QUOTATIONMARK(returnData);
			returnData = LINEBREAK(returnData);
				
			content = 'Content-Type: image/png'
				
			for ( i = 0; i < content.length; i++ ) 
			{
				returnData.writeByte( content.charCodeAt(i) );
			}
			
			
			Logger.debug("returnData (before adding image): " + returnData, this)
				
			returnData = LINEBREAK(returnData);
			returnData = LINEBREAK(returnData);
			returnData.writeBytes(imageBytes, 0, imageBytes.length);
			returnData = LINEBREAK(returnData);
		
			//Upload information
			returnData = LINEBREAK(returnData);
			returnData = BOUNDARY(returnData);
			returnData = LINEBREAK(returnData);
			
			content = 'Content-Disposition: form-data; name="Upload"';
			
			for ( i = 0; i < content.length; i++ ) 
			{
				returnData.writeByte( content.charCodeAt(i) );
			}
			
			returnData = LINEBREAK(returnData);
			returnData = LINEBREAK(returnData);
			
			content = 'Submit Query';
			
			for ( i = 0; i < content.length; i++ ) 
			{
				returnData.writeByte( content.charCodeAt(i) );
			}
			
			returnData = LINEBREAK(returnData);
			
			//closing boundary
			returnData = BOUNDARY(returnData);
			returnData = DOUBLEDASH(returnData);
			
			
			return returnData;
		}
		

		
		
		/**
		 * Add a boundary to the PostData with leading doubledash
		 */
		private function BOUNDARY(p:ByteArray):ByteArray
		{
			var l:int = _boundary.length;
			
			p = DOUBLEDASH(p);
			
			for (var i:int = 0; i < l; i++ ) 
			{
				p.writeByte( _boundary.charCodeAt( i ) );
			}
			return p;
		}
		
		/**
		 * Add one linebreak
		 */
		private function LINEBREAK(p:ByteArray):ByteArray
		{
			p.writeShort(0x0d0a);
			return p;
		}
		
		/**
		 * Add quotation mark
		 */
		private function QUOTATIONMARK(p:ByteArray):ByteArray
		{
			p.writeByte(0x22);
			return p;
		}
		
		/**
		 * Add Double Dash
		 */
		private function DOUBLEDASH(p:ByteArray):ByteArray
		{
			p.writeShort(0x2d2d);
			return p;
		}
		
		
		
		
		protected function postMessageHandler(event:Event):void
		{
			Logger.debug("postMessageHandler() event: " + event.target.data, this)
			dispatchEvent(new Event(UPLOAD_COMPLETE, true))
		}
		
		protected function handleHTTPStatus(event:HTTPStatusEvent):void
		{
			Logger.debug("handleHTTPStatus() event: " + event, this)			
		}
		
		protected function handleIOError(event:IOErrorEvent):void
		{
			Logger.debug("handleIOError() event: " + event, this)		
			dispatchEvent(new Event(UPLOAD_ERROR, true))	
		}
		
		public static function getBoundary():String
		{
			var b:String = ""
			for (var i:int = 0; i < 20; i++ ) 
			{
				b += String.fromCharCode( int( 97 + Math.random() * 25 ) );
			}
			return b;
		}
		
		
		
		
		
	}
}