package com.simplediagrams.commands
{
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.model.mementos.SDSymbolMemento;
	import com.simplediagrams.model.mementos.SDTextAreaMemento;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.SDComponents.SDTextArea;
	
	import mx.core.UIComponent;
	
	public class ChangeSymbolPropertiesCommand extends UndoRedoCommand
	{
		private var _diagramModel:DiagramModel
		protected var _oldSDSymbolModelMemento:SDSymbolMemento
		protected var _newSDSymbolModelMemento:SDSymbolMemento			
		
		public function ChangeSymbolPropertiesCommand(diagramModel:DiagramModel, oldSDSymbolModelMemento:SDSymbolMemento, newSDSymbolModel:SDSymbolModel)
		{
			_diagramModel = diagramModel;
			_oldSDSymbolModelMemento = oldSDSymbolModelMemento
			_newSDSymbolModelMemento = newSDSymbolModel.getMemento() as SDSymbolMemento
			super();
		}
		
		override public function execute():void
		{
			redo()
		}
		
		override public function undo():void
		{
			try
			{
				var sdSymbolModel:SDSymbolModel = _diagramModel.getModelByID(_oldSDSymbolModelMemento.sdID) as SDSymbolModel
				if (sdSymbolModel) 
				{
					sdSymbolModel.setMemento(this._oldSDSymbolModelMemento)
				} 
				else 
				{
					Logger.error("undo() Object lookup by sdID failed: " + _oldSDSymbolModelMemento.sdID, this);
				}
			}
			catch(error:Error)
			{
				Logger.error("undo() error: " + error, this)
			}
		}
		
		override public function redo():void
		{
			try
			{
				var sdSymbolModel:SDSymbolModel = _diagramModel.getModelByID(_oldSDSymbolModelMemento.sdID) as SDSymbolModel
				if (sdSymbolModel) 
				{
					sdSymbolModel.setMemento(this._newSDSymbolModelMemento)
				} 
				else 
				{
					Logger.error("redo() Object lookup by sdID failed: " + _newSDSymbolModelMemento.sdID, this);
				}
			}
			catch(error:Error)
			{
				Logger.error("redo() error: " + error, this)
			}
		}
		
	}
}