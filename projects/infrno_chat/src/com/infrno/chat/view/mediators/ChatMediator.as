package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.events.ChatEvent;
	import com.infrno.chat.view.components.Chat;
	
	import mx.events.FlexEvent;
	
	import org.robotlegs.core.IMediator;
	import org.robotlegs.mvcs.Mediator;
	
	public class ChatMediator extends Mediator
	{
		[Inject]
		public var chat:Chat;
		
		public function ChatMediator()
		{
		}
		
		override public function onRegister():void
		{
			chat.chat_in.addEventListener(FlexEvent.ENTER,sendChat);
			eventMap.mapListener(eventDispatcher,ChatEvent.RECEIVE_CHAT,receiveChat);
		}
		
		private function clearChat():void
		{
			chat.chat_in.text = "";
		}
		
		private function receiveChat(e:ChatEvent):void
		{
			trace("here is the chat: "+e.message);
			chat.chat_display.appendText(e.message+"\n");
		}
		
		private function sendChat(e:FlexEvent):void
		{
			if(stripWhite(chat.chat_in.text).length == 0)
				return;
			
			var msg:String = chat.chat_in.text;
			
			//
			// pattern: [roll] <number of die>d<number of sides>
			//
			var dieRollRE:RegExp = /^(roll )?(?P<numOfDie>\d*)d(?P<numOfSides>\d+)$/i;
			var result:Array = dieRollRE.exec(msg);
			var numOfDie:int = 1;
			var rollDice:Boolean = false;
			
			// 
			// check to see if the pattern is a command for rolling the die
			//
			if (result != null && result.numOfSides != null && result.numOfSides > 0 && result.numOfSides < 101) {
				if (result.numOfDie != null && result.numOfDie > 0 && result.numOfDie < 101) {
					numOfDie = result.numOfDie;					
				}
				var numOfSides:int = result.numOfSides;
				var rollsArray:Array = new Array(numOfDie);
				var sumOfRolls:int = 0;
				var roll:int = 0;
				for (var i:int=0; i<numOfDie; i++) {
					roll = Math.ceil(Math.random() * numOfSides);
					rollsArray[i] = roll;
					sumOfRolls += rollsArray[i]
				}				
				rollsArray.sort();
				
				msg += ": "
				
				for (var n:int=0; n<numOfDie; n++) {
					msg += rollsArray[n] + ", " 
				}								
				msg += "total = " + sumOfRolls;	
			}
			
			dispatch(new ChatEvent(ChatEvent.SEND_CHAT, msg));
			clearChat();
		}
		
		private function stripWhite(stringIn:String):String
		{
			var stripped_string:String="";
			var no_whitespace:Array = stringIn.split(" ");
			for(var i:String in no_whitespace){
				stripped_string+=no_whitespace[i];
			}
			return stripped_string;
		}
	}
}