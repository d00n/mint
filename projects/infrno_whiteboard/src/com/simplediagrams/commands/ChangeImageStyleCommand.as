package com.simplediagrams.commands
{
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.mementos.SDImageMemento;
	import com.simplediagrams.model.mementos.SDLineMemento;
	import com.simplediagrams.util.Logger;
		
		
		public class ChangeImageStyleCommand extends UndoRedoCommand
		{
			private var _diagramModel:DiagramModel
			private var _mementosArr:Array = []//holds mementos as {sdID:(sdID of sdObjectModel), fromState:SDImageMemento, toState:SDImageMemento}	
			
			public var newImageStyle:String = ""
			
			/* Note that the images to be changed come in as an array, since multiple images may be selected 
			The style values passed into this function are the style we want to change all images to.
			So, this command remembers the styles the images were before the command, and also the style they were changed to during this command
			*/		
			public function ChangeImageStyleCommand(diagramModel:DiagramModel)
			{
				_diagramModel = diagramModel					
			}
			
			override public function execute():void
			{	
				for each (var sdObjectModel:SDObjectModel in _diagramModel.selectedArray)
				{
					if (sdObjectModel is SDImageModel)
					{
						var sdImageModel:SDImageModel = SDImageModel(sdObjectModel)
						
						var fState:SDImageMemento = sdImageModel.getMemento() as SDImageMemento
						sdImageModel.styleName = newImageStyle						
						var tState:SDImageMemento = sdImageModel.getMemento() as SDImageMemento						
						_mementosArr.push({sdID:sdImageModel.sdID, fromState:fState, toState:tState})						
					}				
				}			
			}
			
			override public function redo():void
			{							
				for each (var obj:Object in _mementosArr)
				{
					var image:SDImageModel = _diagramModel.getModelByID(obj.sdID) as SDImageModel
					if (image)
					{
						image.setMemento(obj.toState)
					}
				}
			}
			
			override public function undo():void
			{						
				for each (var obj:Object in _mementosArr)
				{
					var image:SDImageModel = _diagramModel.getModelByID(obj.sdID) as SDImageModel
					if (image)
					{
						image.setMemento(obj.fromState)
					}
				}
			}
			
			
			
		}
}