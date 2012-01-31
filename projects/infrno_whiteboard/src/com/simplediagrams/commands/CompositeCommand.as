package com.simplediagrams.commands
{
	public class CompositeCommand extends UndoRedoCommand
	{

		public function CompositeCommand(commands:Array)
		{
			this.commands = commands;
		}
		
		public var commands:Array = [];
		
		public function addCommand(command:IUndoRedoCommand):void
		{
			commands.push(command);
		}
		
		public override function redo():void
		{
			for each(var c:IUndoRedoCommand in commands)
				c.redo();
		}
		
		public override function undo():void
		{
			for(var i:int = commands.length - 1; i >= 0;i--)
			{
				var command:IUndoRedoCommand = commands[i];
				command.undo();
			}
		}
		
	}
}