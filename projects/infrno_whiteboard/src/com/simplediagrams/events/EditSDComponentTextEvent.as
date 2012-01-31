package com.simplediagrams.events
{
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.view.SDComponents.SDBase;
	
	import flash.events.Event;
	
	import mx.controls.Text;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class EditSDComponentTextEvent extends Event
	{
		public static const START_EDIT:String = "startEditComponentText"
		public static const COMPLETE_EDIT:String = "completeEditComponentText"
		public static const CANCEL_EDIT:String = "cancelEditComponentText"
			
		public var sdObjectModel:SDObjectModel
		public var finalText:String
		
		public function EditSDComponentTextEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}