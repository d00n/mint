package com.simplediagrams.controllers
{
	
	import com.simplediagrams.events.LoginEvent;
	import com.simplediagrams.events.LogoutEvent;
	import com.simplediagrams.events.SimpleDiagramsLoginEvent;
	import com.simplediagrams.model.*;
	import com.simplediagrams.util.Logger;
	
	import flash.net.URLRequest;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;            
	import flash.net.navigateToURL;
	

	public class LoginController
	{
		
		
		[Inject]
	    public var appModel:ApplicationModel
	    	    	    	    	    	    	    	    	    
	    public function LoginController():void {}
	   	  	    
	    // Logging in    	
        [Mediate(event="LoginEvent.DO_LOGIN")]
		public function login(event:LoginEvent):void 
		{		
			Logger.debug("#login()",this)
			appModel.viewing = ApplicationModel.VIEW_DIAGRAM			
			
			//model.loginUser = event.loginUser			
			//executeServiceCall(delegate.login(event.loginUser), loginResults, loginFault, [event.loginUser.rememberMe])
 		}
 		
 		public function loginResults( event: ResultEvent, rememberMe:Boolean):void
 		{ 			
 						
 		}
 		
 		public function loginFault( fault:FaultEvent ):void
 		{
 			Logger.debug("#loginFault: " + fault, this)
 		}
	    
	    
	    // Logging out
	    [Mediate(event="LogoutEvent.LOGOUT")]
	    public function logout(event:LogoutEvent):void
	    {
	    	var req:URLRequest = new URLRequest('http://www.simplediagrams.com:3000/user_session')
	    	req.method="POST"
	    	req.data = {_method:"delete"}
	    	navigateToURL(req,"_self")
	    	
	    }
	        
	    
	    
	    
    
 }
}