package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.StatsProxy;
	
	import flash.display.LoaderInfo;
	
	import org.robotlegs.mvcs.Command;
	
	public class InitLocalVarsCommand extends Command
	{
		[Inject]
		public var dataProxy:DataProxy;
		
		[Inject]
		public var statsProxy:StatsProxy;
		
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
			
			if (flash_vars.auth_key != null)
				dataProxy.auth_key = flash_vars.auth_key;
			
			if (flash_vars.room_id != null)
				dataProxy.room_id = flash_vars.room_id;
			
			if (flash_vars.room_name != null)
				dataProxy.room_name = flash_vars.room_name;
			
			if (flash_vars.user_name != null)
				dataProxy.local_userInfoVO.user_name = flash_vars.user_name;
			
			if (flash_vars.user_id != null)
				dataProxy.local_userInfoVO.user_id = flash_vars.user_id;
			
			if (flash_vars.wowza_server != null)
				dataProxy.media_server = flash_vars.wowza_server;
			
			if (flash_vars.wowza_chat_app != null)
				dataProxy.media_app = flash_vars.wowza_chat_app;
			
			trace("InitLocalVarsCommand.execute() flashvars loaded:" + dataProxy.room_name +":"+ dataProxy.local_userInfoVO.user_name +":"+ dataProxy.room_id +":"+ dataProxy.auth_key);
			
			if (flash_vars.seconds_between_stat_collection != null)
				statsProxy.seconds_between_stat_collection = flash_vars.seconds_between_stat_collection;
			
			if (flash_vars.peer_enabled != null && flash_vars.peer_enabled=="false")
				dataProxy.peer_enabled = false;

			trace("InitLocalVarsCommand.execute() peer enabled: "+dataProxy.peer_enabled);
		}
	}
}