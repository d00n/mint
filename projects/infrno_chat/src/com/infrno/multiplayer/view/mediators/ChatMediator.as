package com.infrno.multiplayer.view.mediators
{
	import com.infrno.multiplayer.model.events.ChatEvent;
	import com.infrno.multiplayer.view.components.Chat;
	
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
			
			dispatch(new ChatEvent(ChatEvent.SEND_CHAT,chat.chat_in.text));
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