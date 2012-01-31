package com.simplediagrams.commands
{
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDObjectModel;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;

	public class MoveCommand extends UndoRedoCommand
	{
		public function MoveCommand(diagram:DiagramModel, object:SDObjectModel, newIndex:int)
		{
			super();
			this.diagram = diagram;
			this.target = object;
			this.newIndex = newIndex;
			index = diagram.sdObjects.getItemIndex(object);
		}
		
		private var diagram:DiagramModel;
		private var target:SDObjectModel;
		private var index:int;
		private var newIndex:int;

		public override function undo() : void
		{
			//TODO -  hackish way to generate MOVE event
			var sourceArray:Array = diagram.sdObjects.source;
			var oldValue:Object = sourceArray[newIndex];
			var newValue:Object = sourceArray[index];
			sourceArray[newIndex] = newValue;
			sourceArray[index] = oldValue;
			updateMove(newIndex, index, oldValue);
			updateMove(index, newIndex, newValue);	
		}
		
		
		public override function redo() : void
		{
			//TODO - hackish way to generate MOVE event
			var sourceArray:Array = diagram.sdObjects.source;
			var oldValue:Object = sourceArray[index];
			var newValue:Object = sourceArray[newIndex];
			sourceArray[index] = newValue;
			sourceArray[newIndex] = oldValue;
			updateMove(index, newIndex, oldValue);
			updateMove(newIndex, index, newValue);
		}
		
		private function updateMove(index:int, newIndex:int, item:Object):void
		{
			var collectionEvent:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			collectionEvent.kind = CollectionEventKind.MOVE;
			collectionEvent.location = newIndex;
			collectionEvent.oldLocation = index;
			collectionEvent.items = [item];
			diagram.sdObjects.dispatchEvent(collectionEvent);
		}
	}
}