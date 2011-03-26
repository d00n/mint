package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.events.ChatEvent;
	import com.infrno.chat.view.components.Chat;
	
	import flash.events.FocusEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.events.FlexEvent;
	
	import org.robotlegs.core.IMediator;
	import org.robotlegs.mvcs.Mediator;
	
	public class ChatMediator extends Mediator
	{
		[Inject]
		public var chat:Chat;
		
		private var _firstFocusEvent:Boolean = true;
		
		public function ChatMediator()
		{
		}
		
		override public function onRegister():void
		{
			chat.chat_in.addEventListener(FlexEvent.ENTER,sendChat);
			chat.chat_in.addEventListener(FocusEvent.FOCUS_IN,clearDefaultMessage);
			eventMap.mapListener(eventDispatcher,ChatEvent.RECEIVE_CHAT,receiveChat);
		}
		
		private function clearDefaultMessage(focusEvent:FocusEvent):void
		{
			if (_firstFocusEvent){
				_firstFocusEvent = false;
				clearChat();
			}
		}
		
		private function clearChat():void
		{
				chat.chat_in.text = "";
		}
		
		private function receiveChat(e:ChatEvent):void
		{
			chat.chat_display.appendText(e.message+"\n");
		}
		
		private function sendChat(e:FlexEvent):void
		{
			if(stripWhite(chat.chat_in.text).length == 0)
				return;
			
			var msg:String = chat.chat_in.text;			
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