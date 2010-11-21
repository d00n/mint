package com.simplediagrams.commands
{
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.util.Logger
	import mx.core.UIComponent;
	
	public class AddLineCommand extends UndoRedoCommand
	{
		private var _diagramModel:DiagramModel
		public var sdID:String= ""
		public var x:Number
		public var y:Number
		public var endX:Number
		public var endY:Number
		public var bendX:Number 
		public var bendY:Number
		public var startLineStyle:int 
		public var endLineStyle:int
		public var lineWeight:int 
		
		public function AddLineCommand(diagramModel:DiagramModel)
		{
			_diagramModel = diagramModel
			super();
		}
		
		override public function execute():void
		{	
			redo()
		}
		
		override public function undo():void
		{						
			_diagramModel.deleteSDObjectModelByID(sdID)		
		}
		
		override public function redo():void
		{
			var newLineModel:SDLineModel = new SDLineModel()
			setProperties(newLineModel)
			_diagramModel.addSDObjectModel(newLineModel)
			if (sdID!="")
			{
				newLineModel.sdID = sdID
			}
			else
			{				
				sdID = newLineModel.sdID
			}
			UIComponent(newLineModel.sdComponent).focusManager.getFocus()
			newLineModel.captureStartState()
		}
		
		protected function setProperties(newLineModel:SDLineModel):void
		{
			newLineModel.x = x
			newLineModel.y = y				
			newLineModel.endX = endX
			newLineModel.endY = endY			
			newLineModel.bendX = Math.ceil(endX / 2)
			newLineModel.bendY = Math.ceil(endY / 2)
			newLineModel.startLineStyle = startLineStyle
			newLineModel.endLineStyle = endLineStyle
			newLineModel.lineWeight = lineWeight
				
		}
	}
}