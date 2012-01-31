package com.simplediagrams.commands
{
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDObjectModel;

	public class AddCommand extends UndoRedoCommand
	{
		public function AddCommand(diagram:DiagramModel, object:SDObjectModel)
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
			diagram.sdObjects.removeItemAt(index);
		}
		

		public override function redo() : void
		{
			index = diagram.sdObjects.length;
			diagram.sdObjects.addItem(target);
		}
	}
}