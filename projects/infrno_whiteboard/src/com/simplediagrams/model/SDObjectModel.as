package com.simplediagrams.model
{
	import com.simplediagrams.events.RemoteSharedObjectEvent;
	import com.simplediagrams.util.Logger;
	
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import mx.events.PropertyChangeEvent;

	[Bindable]		
	[RemoteClass]
	public class SDObjectModel
	{
		public var id:int = -1;
		public var x:Number = 50;
		public var y:Number  = 50;
		public var height:Number = 50; 
		public var width:Number = 50; 
		public var rotation:Number = 0;
		protected var _color:uint= 0xffffff;
		public var maintainProportion:Boolean = false;
		public var colorizable:Boolean = true;
		public var allowRotation:Boolean = true;
		public var depth:Number = -1;
		public var connectionPoints:Array = [new ConnectionPoint(0, 0,0.5), new ConnectionPoint(1, 1.0,0.5), new ConnectionPoint(2, 0.5, 0 ), new ConnectionPoint(3, 0.5, 1)];
		
		public function getConnectionPoint(id:int):ConnectionPoint
		{
			return connectionPoints[id];
		}
		
		public function SDObjectModel()
		{		
			
		}
			
		[Bindable(event="propertyChange")]
		public function set color(value:uint):void
		{
			var e:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent(this, "color", _color, value)
			_color = value
			dispatchEvent(e)
			
			// XXX dispatchEvent exists, but doesn't appear to be doing anything
//			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED, true);
//			rsoEvent.sdObjects.addItem(this);
//			dispatchEvent(rsoEvent);	
		}
		
		public function get color():uint
		{
			return _color
		}
								  
		
		
		public function getTransform():TransformData
		{
			return new TransformData(x, y, width, height, rotation);
		}
		
		public function applyTransform(data:TransformData, originalTransform:TransformData, originalObject:SDObjectModel):void
		{
			x = data.x;
			y = data.y;
			width = data.width;
			height = data.height;
			rotation = data.rotation;	
			
			// XXX dispatchEvent exists, but doesn't appear to be doing anything
//			Logger.info("XXX applyTransform", this);
//			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.OBJECT_CHANGED, true);
//			rsoEvent.sdObjects.addItem(this);
//			dispatchEvent(rsoEvent);	
		}
	}
}

