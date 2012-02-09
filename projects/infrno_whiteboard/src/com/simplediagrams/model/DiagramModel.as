package com.simplediagrams.model
{
	import com.simplediagrams.events.RemoteSharedObjectEvent;
	import com.simplediagrams.util.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	import mx.utils.UIDUtil;

	[Bindable]
	[RemoteClass]
	public class DiagramModel extends EventDispatcher
	{		
		public var backgroundVisible:Boolean = true;
		private var _background:SDBackgroundModel = new SDBackgroundModel("com.simplediagrams.backgroundLibrary.basic","Chalkboard","Chalkboard");			
			
		public var name:String = ""
		public var description:String	
		public var width:Number = 2000
		public var height:Number = 1200;
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		public var sdObjects:ArrayCollection = new ArrayCollection(); 
		public var selectedObjects:ArrayCollection = new ArrayCollection();
		public var maxSeed:int = -1;
		public var maxDepth:int = -1;
		
		public function DiagramModel()
		{        	
			sdObjects.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
		}
		
		private function onCollectionChange(event:CollectionEvent):void
		{
			switch(event.kind)
			{
				case CollectionEventKind.ADD: onAdd(event.items);break;
				case CollectionEventKind.REMOVE: onRemove(event.items);break;
			}
		}
		
		[Mediate(event="RemoteSharedObjectEvent.TEXT_CHANGED")]
		public function hello(e:RemoteSharedObjectEvent):void{
			Logger.info("hello");
		}
		
		private function onAdd(items:Array):void
		{
			for each(var item:SDObjectModel in items)
			{
				if(item.id == -1)
					item.id = maxSeed + 1;
				if(item.depth == -1)
					item.depth = maxDepth + 1;
				maxSeed++;
				maxDepth++;
				if(item.id > maxSeed)
					maxSeed = item.id;
				if(item.depth > maxDepth)
					maxDepth = item.depth;
			}
		}
		
		private function onRemove(items:Array):void
		{
			var selection:Array = selectedObjects.source.concat();
			for each(var item:Object in items)
			{
				var i:int = selection.indexOf(item);
				if(i != -1)
					selection.splice(i, 1);
			}
			select(selection);
		}
		
		public function get background():SDBackgroundModel
		{
			return _background;
		}

		public function set background(value:SDBackgroundModel):void
		{
			_background = value;
		}
		
		public function getModelByID(sdID:int):SDObjectModel
		{
			var len:uint = sdObjects.length;
			for (var i:uint =0;i<len;i++)
			{
				if (SDObjectModel(sdObjects.getItemAt(i)).id == sdID) 
				{
					return sdObjects.getItemAt(i) as SDObjectModel
				}
			}
			return null;
		}
		
		
		public function select(items:Array = null):void
		{
			if(items != null && items.length > 0)
			{
				selectedObjects.source = items.concat();
			}
			else
				selectedObjects.removeAll();
		}
		
		public function selectInRect(x:Number, y:Number, width:Number, height:Number):void
		{
			var rect:Rectangle = new Rectangle(x, y, width, height);
			var items:Array = [];
			var matrix:Matrix = new Matrix();
			var point:Point = new Point();
			for each(var sdObject:SDObjectModel in sdObjects)
			{
				var transformData:TransformData = sdObject.getTransform();
				matrix.identity();
				matrix.rotate(transformData.rotation * Math.PI/ 180);
				matrix.translate( transformData.x, transformData.y );
				
				point.x=0;
				point.y=0;
				point = matrix.transformPoint(point);                             
				
				if(!rect.containsPoint(point))
					continue;
				
				point.x= 0;
				point.y= transformData.height;
				point = matrix.transformPoint(point);                             
				if(!rect.containsPoint(point))
					continue;
				
				point.x= transformData.width;
				point.y= 0;
				point = matrix.transformPoint(point);                             
				if(!rect.containsPoint(point))
					continue;
				
				point.x= transformData.width;
				point.y= transformData.height;
				point = matrix.transformPoint(point);                             
				if(!rect.containsPoint(point))
					continue;
				items.push(sdObject);
			}
			select(items);
		}
	}
}