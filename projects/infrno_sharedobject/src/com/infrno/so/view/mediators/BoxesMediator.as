package com.infrno.so.view.mediators
{
	import com.infrno.so.model.events.BoxUpdateEvent;
	import com.infrno.so.model.events.SOUpdateEvent;
	import com.infrno.so.view.components.Boxes;
	
	import flash.events.MouseEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class BoxesMediator extends Mediator
	{
		[Inject]
		public var boxes		:Boxes;
		
		public function BoxesMediator()
		{
			super();
		}
		
		override public function onRegister():void
		{
			boxes.addEventListener(MouseEvent.MOUSE_DOWN,dragBoxStart);
			boxes.addEventListener(MouseEvent.MOUSE_UP,dragBoxStop);
			
			eventDispatcher.addEventListener(SOUpdateEvent.PROPERTY_UPDATE,updateUI);
		}
		
		private function dragBoxStart(e:MouseEvent):void
		{
			if(e.target.id == "box_container")
				return;
			e.target.startDrag();
		}
		
		private function dragBoxStop(e:MouseEvent):void
		{
			if(e.target.id == "box_container")
				return;
			e.target.stopDrag();
			dispatch(new BoxUpdateEvent(BoxUpdateEvent.PROPERTY_UPDATE,e.target));
		}
		
		private function updateUI(e:SOUpdateEvent):void
		{
			for(var i:String in e.value.value){
				boxes[e.value.prop][i] = e.value.value[i];
			}
		}
	}
}