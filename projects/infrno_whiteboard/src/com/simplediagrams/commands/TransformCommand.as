package com.simplediagrams.commands
{
	import com.simplediagrams.model.CopyUtil;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.TransformData;
	
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;

	public class TransformCommand extends UndoRedoCommand
	{
		public function TransformCommand(targets:Array, newTransforms:Array, oldTransforms:Array, backups:Array)
		{
			super();
			this.targets = targets;
			this.newTransforms = newTransforms;
			this.oldTransforms = oldTransforms;
			this.backups = backups;
		}
		
		public var oldTransforms:Array;
		public var newTransforms:Array;
		private var targets:Array;
		private var backups:Array;

		public override function redo():void
		{
			for( var i:int = 0; i < targets.length;i++)
			{
				var c:SDObjectModel = targets[i];
				c.applyTransform(newTransforms[i], oldTransforms[i],backups[i]);
			}
		}
		
		public override function undo():void
		{
			for( var i:int = 0; i < targets.length;i++)
			{
				CopyUtil.copyFrom(targets[i],backups[i]);
			}
		}
	}
}