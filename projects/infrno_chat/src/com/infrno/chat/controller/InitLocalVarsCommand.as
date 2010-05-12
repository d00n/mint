package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	
	import org.robotlegs.mvcs.Command;
	
	public class InitLocalVarsCommand extends Command
	{
		[Inject]
		public var dataProxy		:DataProxy;
		
		override public function execute():void
		{
			var flash_vars:Object = contextView.loaderInfo.parameters;
			
			try{
				dataProxy.peer_enabled = flash_vars.peer_enabled=="false"?false:true;
			}catch(e:Object){
				dataProxy.peer_enabled = true;
			}

			trace("peer enabled: "+dataProxy.peer_enabled);
		}
	}
}