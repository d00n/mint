package com.simplediagrams.commands
{
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDObjectModel;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	public class ChangeDepthCommand extends UndoRedoCommand
	{
		public function ChangeDepthCommand(diagramModel:DiagramModel, newDepths:Array)
		{
			super();
			this.diagramModel = diagramModel;
			this.newDepths = newDepths;
		}
		
		private var diagramModel:DiagramModel;
		private var oldDepths:Array;
		private var newDepths:Array;
		
		public override function execute():void
		{
			var count:Number = diagramModel.sdObjects.length;
			var items:ArrayCollection = diagramModel.sdObjects;
			var i:int;
			oldDepths = new Array(count);
			for(i = 0;i < count;i++)
			{
				oldDepths[i] = SDObjectModel(items.getItemAt(i)).depth;
			}
			redo();
		}
				
		public override function redo():void
		{
			var items:ArrayCollection = diagramModel.sdObjects;
			for(var i:int = 0;i < items.length;i++)
			{
				SDObjectModel(items.getItemAt(i)).depth  = newDepths[i];
			}
		}
		
		public override function undo():void
		{
			var items:ArrayCollection = diagramModel.sdObjects;
			for(var i:int = 0;i < items.length;i++)
			{
				SDObjectModel(items.getItemAt(i)).depth  = oldDepths[i];
			}
		}
	}
}