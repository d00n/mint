package com.simplediagrams.view.tools
{
	import com.simplediagrams.model.ToolsManager;
	import com.simplediagrams.model.tools.Tools;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;

	public class ToolRepeater
	{
		public function ToolRepeater()
		{
			dictionary[Tools.POINTER_TOOL] = new SelectToolView;
			dictionary[Tools.PENCIL_TOOL] =  new PencilDrawingLayer;
			dictionary[Tools.TEXT_TOOL] =  new EmptyToolView;
			dictionary[Tools.PICTURE_TOOL] =  new EmptyToolView;
			dictionary[Tools.LINE_TOOL] =  new LineToolView;
			dictionary[Tools.ZOOM_TOOL] =  new EmptyToolView;
		}
		
		private var dictionary:Dictionary = new Dictionary();
		
		private var _targetContainer:IVisualElementContainer;
		
		private var _toolManager:ToolsManager;
		

		public function get targetContainer():IVisualElementContainer
		{
			return _targetContainer;
		}

		public function set targetContainer(value:IVisualElementContainer):void
		{
			_targetContainer = value;
			if(_currentView && _currentView.parent == null)
				_targetContainer.addElement(_currentView);
		}

		public function get toolManager():ToolsManager
		{
			return _toolManager;
		}

		public function set toolManager(value:ToolsManager):void
		{
			if(_toolManager)
				_toolManager.removeEventListener(Event.CHANGE, onToolChange);
			_toolManager = value;
			if(toolManager)
			{
				currentView = dictionary[_toolManager.selectedTool];
				_toolManager.addEventListener(Event.CHANGE, onToolChange);
			}
		}
		
		private var _currentView:IVisualElement;
		
		
		public function get currentView():IVisualElement
		{
			return _currentView;
		}
		
		public function set currentView(value:IVisualElement):void
		{
			if(targetContainer && _currentView)
				targetContainer.removeElement(_currentView);
			_currentView = value;
			Object(_currentView).tool = _toolManager.selectedToolImpl;
			if(targetContainer && _currentView)
				targetContainer.addElement(_currentView);	
		}

		
		public function onToolChange(event:Event):void
		{
			currentView = dictionary[_toolManager.selectedTool];
		}

	}
}