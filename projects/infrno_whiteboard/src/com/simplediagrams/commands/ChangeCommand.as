package com.simplediagrams.commands
{
	import com.simplediagrams.model.CopyUtil;
	
	import mx.utils.ObjectUtil;

	public class ChangeCommand extends UndoRedoCommand
	{
		public function ChangeCommand(target:Object, state:Object)
		{
			super();
			this.target = target;
			oldState = CopyUtil.clone(target);
			newState = state;
		}
		
		public var target:Object;
		public var oldState:Object;
		public var newState:Object;
		
		public override function undo():void
		{
			CopyUtil.copyFrom(target, oldState);				
		}
		
		public override function redo():void
		{
			CopyUtil.copyFrom(target, newState);	
		}
	}
}