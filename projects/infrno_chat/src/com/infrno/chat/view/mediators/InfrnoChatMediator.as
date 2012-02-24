package com.infrno.chat.view.mediators
{
	import com.infrno.chat.view.components.StatsGroup;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class InfrnoChatMediator extends Mediator
	{
		[Inject]
		public var infrnoChat:InfrnoChat;
		
		// TODO map this in ApplicationContext, or ShowStatsGroupCommand?
		public var statsGroup:StatsGroup;
		
		override public function onRegister():void{
		}
		
		override public function onRemove():void {			
		}
		
		public function addStatsGroup():void {
			statsGroup = new StatsGroup();		
//			infrnoChat.videosComponent.height = 126;
//			infrnoChat.ChatVDividedBox.addElementAt(statsGroup,1);
		}
		public function removeStatsGroup():void {
			if (statsGroup != null && statsGroup.initialized) {
//				infrnoChat.ChatVDividedBox.removeElementAt(1);
			}
		}
	}
}