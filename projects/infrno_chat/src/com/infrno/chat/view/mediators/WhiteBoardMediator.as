package com.infrno.chat.view.mediators
{
	import com.infrno.chat.view.components.WhiteBoard;
	
	import flash.display.Loader;
	import flash.net.URLRequest;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class WhiteBoardMediator extends Mediator
	{
		[Inject]
		public var whiteBoard			:WhiteBoard;
		
		public function WhiteBoardMediator()
		{
			super();
		}
		
		override public function onRegister():void
		{
			loadWhiteBoard();
		}
		
		private function loadWhiteBoard():void
		{
//			secur
			
//			var request:URLRequest = new URLRequest("http://staging.infrno.net/test/sd/SimpleDiagrams.swf");
//			var loader:Loader = new Loader()
//			loader.load(request);
			
//			loader.
			
//			whiteBoard.addElement(loader);
		}
	}
}