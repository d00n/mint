package com.simplediagrams.commands
{
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDObjectModel;

	public class RemoveCommand extends UndoRedoCommand
	{
		public function RemoveCommand(diagram:DiagramModel, object:SDObjectModel)
		{
			super();
			this.diagram = diagram;
			this.target = object;
		}
		
		private var diagram:DiagramModel;
		private var target:SDObjectModel;
		private var index:int;
		
		public override function undo() : void
		{	
			diagram.sdObjects.addItemAt(target, index);
		}
		
		public override function redo() : void
		{
			index = diagram.sdObjects.getItemIndex(target);
			diagram.sdObjects.removeItemAt(index);
		}
		
	}
}