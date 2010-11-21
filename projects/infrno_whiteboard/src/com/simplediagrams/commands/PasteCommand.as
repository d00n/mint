package com.simplediagrams.commands
{
	
	import com.simplediagrams.errors.SDObjectModelNotFoundError;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.SDCustomSymbolModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.util.Logger;
		
	public class PasteCommand extends UndoRedoCommand
	{
		protected var _diagramModel:DiagramModel
		protected var _libraryManager:LibraryManager
		
		public var pastedObjectsArr:Array //this is an array of clones derived from objects selected when cut or copy was selected
		
		public function PasteCommand(diagramModel:DiagramModel, libraryManager:LibraryManager)
		{
			_libraryManager = libraryManager
			_diagramModel = diagramModel
		}
				
		override public function execute():void
		{	
			redo()
		}
		
		override public function undo():void
		{						
			for each (var sdObject:SDObjectModel in pastedObjectsArr)
			{
				_diagramModel.deleteSDObjectModelByID(sdObject.sdID)
			}
		}
		
		override public function redo():void
		{
			Logger.debug("paste redo() ",this)
			for each (var sdObjectToPaste:SDObjectModel in pastedObjectsArr)
			{					
				Logger.debug("sdObjectToPaste: " + sdObjectToPaste + "   sdObjectToPaste.sdID: " + sdObjectToPaste.sdID,this)
							
				if (sdObjectToPaste!=null)
				{
					
					if (sdObjectToPaste is SDCustomSymbolModel)
					{
						/* If user deleted a custom symbol in the library, and we still have it in the undo/redo stack
						   then we just need to paste out a notFoundObject */
						try
						{
							var checkObj:SDCustomSymbolModel = _libraryManager.getSDObjectModel(SDCustomSymbolModel(sdObjectToPaste).libraryName, SDCustomSymbolModel(sdObjectToPaste).symbolName) as SDCustomSymbolModel			
						}
						catch(err:SDObjectModelNotFoundError)
						{
							var notFoundObject:SDObjectModel = _libraryManager.getDefaultSDObjectModel()
							notFoundObject.x = sdObjectToPaste.x + 50
							notFoundObject.y = sdObjectToPaste.y
							_diagramModel.addToSelected(notFoundObject)	
							continue								
						}
					}
					
					sdObjectToPaste.x =  sdObjectToPaste.x + 50
					_diagramModel.addSDObjectModel(sdObjectToPaste, false, true)
					_diagramModel.addToSelected(sdObjectToPaste)			
				}
			}
						
		}
		
		
	}
}