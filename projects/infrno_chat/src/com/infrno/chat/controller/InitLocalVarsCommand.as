package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	
	import flash.display.LoaderInfo;
	
	import org.robotlegs.mvcs.Command;
	
	public class InitLocalVarsCommand extends Command
	{
		[Inject]
		public var dataProxy		:DataProxy;
		
		override public function execute():void
		{
			var loader_info:LoaderInfo = contextView.loaderInfo;
			var flash_vars:Object = loader_info.parameters;
			
			try{
				trace("InitLocalVarsCommand.execute() parent load parameters");
				flash_vars = loader_info.loader.loaderInfo.parameters;
			}catch(e:Object){
				trace("InitLocalVarsCommand.execute() not loaded by another movie");
			}
			
			dataProxy.auth_key = flash_vars.auth_key;
			dataProxy.room_id = flash_vars.room_id;
			dataProxy.room_name = flash_vars.room_name;
			dataProxy.user_name = flash_vars.user_name;
			dataProxy.media_server = flash_vars.wowza_server;
			dataProxy.media_app = flash_vars.wowza_chat_app;
			
			trace("InitLocalVarsCommand.execute() flashvars loaded:" + dataProxy.room_name +":"+ dataProxy.user_name +":"+ dataProxy.room_id +":"+ dataProxy.auth_key);
			
			try{
				dataProxy.peer_enabled = flash_vars.peer_enabled=="false"?false:true;
			}catch(e:Object){
				dataProxy.peer_enabled = true;
			}
			trace("InitLocalVarsCommand.execute() peer enabled: "+dataProxy.peer_enabled);
		}
	}
}