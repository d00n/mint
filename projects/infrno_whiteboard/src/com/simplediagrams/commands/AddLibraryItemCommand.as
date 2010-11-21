package com.simplediagrams.commands
{
	import com.simplediagrams.errors.SDObjectModelNotFoundError;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.util.Logger;
	
	import mx.core.UIComponent;

	public class AddLibraryItemCommand extends UndoRedoCommand
	{
		private var _diagramModel:DiagramModel
		private var _libraryManager:LibraryManager
		private var _libraryName:String
		private var _symbolName:String
		private var _sdID:String = ""
		public var x:Number
		public var y:Number
		public var textAlign:String
		public var fontSize:Number
		public var fontWeight:String
		public var fontFamily:String
		public var textPosition:String
		public var color:Number;
		
		/* Adds a SDSymbolModel to the diagram. 
		* This class remembers the id first given to the symbol so that it can be restored correctly 
		*/
		
		public function get sdID():String { return _sdID; }
		public function set sdID(value:String):void { _sdID = value; }
		public function get libraryName():String { return _libraryName; }
		public function get symbolName():String { return _symbolName; }
		
		
		public function AddLibraryItemCommand(diagramModel:DiagramModel, libraryManager:LibraryManager, libraryName:String, symbolName:String)
		{
			_diagramModel = diagramModel
			_libraryManager = libraryManager
			_libraryName = libraryName
			_symbolName = symbolName
			super();
		}
		
		override public function execute():void
		{	
			redo()
		}
		
		override public function undo():void
		{						
			_diagramModel.deleteSDObjectModelByID(_sdID)		
		}
		
		override public function redo():void
		{
			try
			{
				var newSymbolModel:SDSymbolModel = _libraryManager.getSDObjectModel(_libraryName, _symbolName) as SDSymbolModel					
			}
			catch(error:SDObjectModelNotFoundError)
			{
				Logger.error("Couldn't find symbol: " + _symbolName + " in library " + _libraryName, this)
				return
			}
				
			setProperties(newSymbolModel)			
			_diagramModel.addSDObjectModel(newSymbolModel)
			if (_sdID!="")
			{
				newSymbolModel.sdID = _sdID
			}
			else
			{				
				_sdID = newSymbolModel.sdID
			}
			
			
			UIComponent(newSymbolModel.sdComponent).focusManager.getFocus()
		}
		
		protected function setProperties(sdSymbolModel:SDSymbolModel):void
		{
			sdSymbolModel.x = x
			sdSymbolModel.y = y
			sdSymbolModel.textAlign = textAlign
			sdSymbolModel.fontSize = fontSize
			sdSymbolModel.fontWeight = fontWeight
			sdSymbolModel.fontFamily = fontFamily
			sdSymbolModel.textPosition = textPosition
			sdSymbolModel.color = color;
		}
	}
}