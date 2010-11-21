package com.simplediagrams.commands
{
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDPencilDrawingModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.model.SDTextAreaModel;
	import com.simplediagrams.model.mementos.*;
	
	;
	
	public class DeleteSelectedSDObjectModelsCommand extends UndoRedoCommand
	{
		private var _diagramModel:DiagramModel
		private var _libraryManager:LibraryManager
		private var _mementosArr:Array = []
		
		public function get mementosArr():Array 
		{
			return _mementosArr;
		}
			
		public function DeleteSelectedSDObjectModelsCommand(diagramModel:DiagramModel, libraryManager:LibraryManager)
		{
			_diagramModel = diagramModel
			_libraryManager = libraryManager
			for each (var sdObjectModel:SDObjectModel in diagramModel.selectedArray)
			{
				_mementosArr.push(sdObjectModel.getMemento())
			}
			super();
		}
		
		override public function execute():void
		{	
			redo()
		}
		
		override public function undo():void
		{										
			for each (var memento:SDObjectMemento in _mementosArr)
			{
				if (memento is SDSymbolMemento)
				{
					var newSymbolModel:SDSymbolModel = _libraryManager.getSDObjectModel(SDSymbolMemento(memento).libraryName, SDSymbolMemento(memento).symbolName) as SDSymbolModel		
					if (newSymbolModel)
					{
						newSymbolModel.setMemento(memento)
						_diagramModel.addSDObjectModel(newSymbolModel)
					}	
				}
				else if (memento is SDLineMemento)
				{
					var lineModel:SDLineModel = new SDLineModel()
					lineModel.setMemento(memento)
					_diagramModel.addSDObjectModel(lineModel)						
				}
				else if (memento is SDTextAreaMemento)
				{
					var textAreaModel:SDTextAreaModel = new SDTextAreaModel()
					textAreaModel.setMemento(memento)
					_diagramModel.addSDObjectModel(textAreaModel)
				}
				else if (memento is SDPencilDrawingMemento)
				{
					var pencilDrawingModel:SDPencilDrawingModel = new SDPencilDrawingModel()
					pencilDrawingModel.setMemento(memento)
					_diagramModel.addSDObjectModel(pencilDrawingModel)
				}
				else if (memento is SDImageMemento)
				{
					var imageModel:SDImageModel = new SDImageModel()
					imageModel.setMemento(memento)
					_diagramModel.addSDObjectModel(imageModel)
					
				}
			}
		}
		
		override public function redo():void
		{					
			_mementosArr = []
			for each (var sdObjectModel:SDObjectModel in _diagramModel.selectedArray)
			{
				_mementosArr.push(sdObjectModel.getMemento())
			}
			
			_diagramModel.deleteSelectedSDObjectModels()		
		}
		
		
		
		
		
	}
}
	