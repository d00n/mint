package com.simplediagrams.commands
{
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDTextAreaModel;
	import com.simplediagrams.model.mementos.SDTextAreaMemento;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.SDComponents.SDTextArea;
	
	import mx.core.UIComponent;
	
	public class ChangeTextFieldPropertiesCommand extends UndoRedoCommand
	{
		private var _diagramModel:DiagramModel
		protected var _oldSDTextAreaMemento:SDTextAreaMemento
		protected var _newSDTextAreaMemento:SDTextAreaMemento			
					
		public function ChangeTextFieldPropertiesCommand(diagramModel:DiagramModel, oldSDTextAreaMemento:SDTextAreaMemento, newSDTextAreaModel:SDTextAreaModel)
		{
			_diagramModel = diagramModel;
			_oldSDTextAreaMemento = oldSDTextAreaMemento
			_newSDTextAreaMemento = newSDTextAreaModel.getMemento() as SDTextAreaMemento
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
				var sdTextAreaModel:SDTextAreaModel = _diagramModel.getModelByID(_oldSDTextAreaMemento.sdID) as SDTextAreaModel
				if (sdTextAreaModel) 
				{
					sdTextAreaModel.setMemento(this._oldSDTextAreaMemento)
				} 
				else 
				{
					Logger.error("undo() Object lookup by sdID failed: " + _oldSDTextAreaMemento.sdID, this);
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
				var sdTextAreaModel:SDTextAreaModel = _diagramModel.getModelByID(_oldSDTextAreaMemento.sdID) as SDTextAreaModel
				if (sdTextAreaModel) 
				{
					sdTextAreaModel.setMemento(this._newSDTextAreaMemento)
				} 
				else 
				{
					Logger.error("redo() Object lookup by sdID failed: " + _oldSDTextAreaMemento.sdID, this);
				}
			}
			catch(error:Error)
			{
				Logger.error("redo() error: " + error, this)
			}
		}
		
	}
}