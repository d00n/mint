package com.simplediagrams.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;

	[Bindable]
	public class SelectionModel extends EventDispatcher
	{
		public function SelectionModel()
		{
		}
		
		public var hasSelection:Boolean = false;

		public var displayTransform:TransformData;

		public var marqueeTansform:TransformData;
				
		public var showMarquee:Boolean = false;
		
		public var selectionLine:Boolean = false;
		
		public function changeMarquee(showMarquee:Boolean, marqueeTansform:TransformData):void
		{
			this.showMarquee = showMarquee;
			this.marqueeTansform = marqueeTansform;
			dispatchEvent(new Event(Event.CHANGE));
		}

	}
}