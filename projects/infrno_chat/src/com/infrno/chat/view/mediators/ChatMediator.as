package com.infrno.chat.view.mediators
{
	import com.infrno.chat.model.events.ChatEvent;
	import com.infrno.chat.view.components.Chat;
	
	import flash.events.FocusEvent;
	import flash.text.engine.FontWeight;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.binding.utils.BindingUtils;
	import mx.effects.easing.Back;
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	
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
			var span1:SpanElement = new SpanElement();
			var para:ParagraphElement = new ParagraphElement();

			if (e.dieRoll) {
				span1.fontWeight = FontWeight.BOLD;
			}
			
			span1.text =  e.message;
			para.addChild(span1);
			chat.chat_display.textFlow.addChild(para);
			setTimeout(function():void{
				chat.chat_display.scroller.verticalScrollBar.value = chat.chat_display.scroller.verticalScrollBar.maximum + 100;
			},100);

		}
		
		private function sendChat(e:FlexEvent):void
		{
			var msg:String = StringUtil.trim(chat.chat_in.text);
			
			var lastCharWasSpace:Boolean = false;
			var msgSingleSpaces:String = "";
			for (var i:int=0; i < msg.length; i++) {
				if (msg.charAt(i) != " ") {
					lastCharWasSpace = false;
					msgSingleSpaces += msg.charAt(i);
				}
				
				if (msg.charAt(i) == " " && !lastCharWasSpace) 
					msgSingleSpaces += msg.charAt(i);
			
				if (msg.charAt(i) == " ")
					lastCharWasSpace = true;
			}
				
			if(msgSingleSpaces.length == 0)
				return;
			
			dispatch(new ChatEvent(ChatEvent.SEND_CHAT, msgSingleSpaces));
			clearChat();
		}
		
//		private function stripWhite(stringIn:String):String
//		{
//			var stripped_string:String="";
//			var no_whitespace:Array = stringIn.split(" ");
//			for(var i:String in no_whitespace){
//				stripped_string+=no_whitespace[i];
//			}
//			return stripped_string;
//		}
	}
}