package com.simplediagrams.model
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	public class DepthUtil
	{
		public function DepthUtil()
		{
		}
		
		public static const MOVE_TO_BACK:int = int.MIN_VALUE;
		public static const MOVE_TO_FRONT:int = int.MAX_VALUE;
		public static const MOVE_BACKWARD:int = -1;
		public static const MOVE_FORWARD:int = +1;
		
		public static function calculateNewDepths(diagramModel:DiagramModel, targets:Array, type:int):Array
		{
			var count:Number = diagramModel.sdObjects.length;
			var items:ArrayCollection = diagramModel.sdObjects;
			var i:int;
			var depthToIndex:Dictionary = new Dictionary();
			var newDepths:Array = new Array(count);
			for(i = 0;i < count;i++)
			{
				newDepths[i] = SDObjectModel(items.getItemAt(i)).depth;
				depthToIndex[newDepths[i]] = i;
			}
			var selectedDepths:Array = new Array(targets.length);
			for(i = 0;i < targets.length;i++)
				selectedDepths[i] = SDObjectModel(targets[i]).depth;
			selectedDepths.sort();			
			
			if(type < 0)
				moveBackward(selectedDepths, depthToIndex, newDepths, type);
			else
				moveForwards(selectedDepths, depthToIndex , newDepths, type);
			var updated:Boolean = false;
			for(i = 0;i < count && updated == false;i++)
			{
				var value:int = SDObjectModel(items.getItemAt(i)).depth;
				if(value != newDepths[i])
					updated = true;
			}
			return updated?newDepths:null;		
		}
		
		
		public static  function moveBackward(selectedDepths:Array, depthToIndex:Dictionary, newDepths:Array, type:int):void
		{
			var maxSelectedDepth:Number = selectedDepths[selectedDepths.length - 1];
			var minSelectedDepth:Number = selectedDepths[0];
			var i:int;
			var value:Number;
			var newStartDepth:Number = minSelectedDepth;
			if(type == MOVE_TO_BACK)
			{
				for(i = 0; i < newDepths.length;i++)
				{ 
					value = newDepths[i];
					if(value < newStartDepth)
						newStartDepth = value;
				}
			}
			else
			{
				newStartDepth = Number.MIN_VALUE;
				for(i = 0; i < newDepths.length;i++)
				{ 
					value = newDepths[i];
					if(value > newStartDepth && value < minSelectedDepth)
						newStartDepth = value;
				}
				if(newStartDepth == Number.MIN_VALUE)
					newStartDepth = minSelectedDepth;
			}
			for(i = 0; i < newDepths.length;i++)
			{
				value = newDepths[i];
				if(value <= maxSelectedDepth && value >= newStartDepth)
					newDepths[i] = value +  selectedDepths.length; 
			}
			for(i = 0; i < selectedDepths.length;i++)
			{
				var currentDepth:Number = selectedDepths[i];
				newDepths[depthToIndex[currentDepth]] = newStartDepth + i;
			}
		}
		
		public static  function moveForwards(selectedDepths:Array, depthToIndex:Dictionary,  newDepths:Array, type:int):void
		{
			var maxSelectedDepth:Number = selectedDepths[selectedDepths.length - 1];
			var minSelectedDepth:Number = selectedDepths[0];
			var i:int;
			var value:Number;
			var newEndDepth:Number = maxSelectedDepth;
			if(type == MOVE_TO_FRONT)
			{
				for(i = 0; i < newDepths.length;i++)
				{ 
					value = newDepths[i];
					if(value > newEndDepth)
						newEndDepth = value;
				}
			}
			else
			{
				newEndDepth = Number.MAX_VALUE;
				for(i = 0; i < newDepths.length;i++)
				{ 
					value = newDepths[i];
					if(value < newEndDepth && value > maxSelectedDepth)
						newEndDepth = value;
				}
				if(newEndDepth == Number.MAX_VALUE)
					newEndDepth = maxSelectedDepth;
			}
			for(i = 0; i < newDepths.length;i++)
			{
				value = newDepths[i];
				if(value >= minSelectedDepth && value <= newEndDepth)
					newDepths[i] = value -  selectedDepths.length; 
			}
			for(i = 0; i < selectedDepths.length;i++)
			{
				var currentDepth:Number = selectedDepths[i];
				newDepths[depthToIndex[currentDepth]] = newEndDepth + i - selectedDepths.length + 1;
			}
		}
	}
}