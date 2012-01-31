package com.simplediagrams.model.tools
{
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	import mx.states.OverrideBase;

	public class SelectTool extends ToolBase
	{
		public function SelectTool()
		{
			dictionary[Tools.MARQUEE_TOOL] = marqueeTool;
			dictionary[Tools.TRANSFORM_TOOL] = transformTool;
			dictionary[Tools.LINE_TRANSFORM_TOOL] = lineTransformTool;
			currentTool = Tools.MARQUEE_TOOL;
		}
		
		public override function set dispatcher(value:IEventDispatcher):void
		{
			super.dispatcher = value;
			marqueeTool.dispatcher = dispatcher;
			transformTool.dispatcher = dispatcher;
			lineTransformTool.dispatcher = dispatcher;
		}
		
		private var dictionary:Dictionary = new Dictionary();
		
		private var marqueeTool:MarqueeTool = new MarqueeTool();
		private var transformTool:TransformTool = new TransformTool();
		private var lineTransformTool:LineTransformTool = new LineTransformTool();

		private var _currentTool:String;
		
		[Bindable("change")]
		public function get currentTool():String
		{
			return _currentTool;
		}
		
		public function set currentTool(value:String):void
		{
			if(_currentTool != value)
			{
				_currentTool = value;
				if(_currentToolImpl)
					_currentToolImpl.deactivateTool();
				_currentToolImpl = dictionary[_currentTool];
				if(_currentToolImpl)
					_currentToolImpl.activateTool();
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		private var _currentToolImpl:ToolBase;
		

		public function get currentToolImpl():ToolBase
		{
			return _currentToolImpl;
		}

		
		private var _diagramModel:DiagramModel;
		
		[Inject(source='diagramManager.diagramModel',bind='true')]
		public function get diagramModel():DiagramModel
		{
			return _diagramModel;
		}
		
		public function set diagramModel(value:DiagramModel):void
		{
			if(_diagramModel)
			{
				_diagramModel.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
				_diagramModel.selectedObjects.removeEventListener( CollectionEvent.COLLECTION_CHANGE, onCollectionChange );
			}
			_diagramModel = value;
			currentTool = Tools.MARQUEE_TOOL;
			lineTransformTool.diagramModel = _diagramModel;
			if(_diagramModel)
			{
				onPropertyChange(null);
				_diagramModel.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
				_diagramModel.selectedObjects.addEventListener( CollectionEvent.COLLECTION_CHANGE, onCollectionChange );	
			}
		}
		
		private function onPropertyChange(event:Event):void
		{
			marqueeTool.setScale(diagramModel.scaleX, diagramModel.scaleY);
			transformTool.setScale(diagramModel.scaleX, diagramModel.scaleY);
			lineTransformTool.setScale(diagramModel.scaleX, diagramModel.scaleY);
		}
		
		
		private function onCollectionChange(event:CollectionEvent):void
		{
			if(event.kind != CollectionEventKind.UPDATE)
				updateSelection();
		}
		
		public override function activateTool():void
		{
			super.activateTool();
			if(diagramModel)
				updateSelection();
		}
		
		public override function deactivateTool():void
		{
			super.deactivateTool();
			lineTransformTool.line = null;
			transformTool.selectedObjects = null;
		}
		
		public function updateSelection():void
		{
			if(diagramModel.selectedObjects.length == 0)
			{
				currentTool = Tools.MARQUEE_TOOL;
			}
			if(diagramModel.selectedObjects.length == 1)
			{
				var line:SDLineModel = diagramModel.selectedObjects.getItemAt(0) as SDLineModel;
				if(line != null)
				{
					currentTool = Tools.LINE_TRANSFORM_TOOL;
					lineTransformTool.line = line;
				}
				else
				{
					currentTool = Tools.TRANSFORM_TOOL;
					transformTool.selectedObjects = diagramModel.selectedObjects;
				}
			}
			if(diagramModel.selectedObjects.length > 1)
			{
				currentTool = Tools.TRANSFORM_TOOL;
				transformTool.selectedObjects = diagramModel.selectedObjects;
			}			
		}

		
		
		public override function onMouseDown(toolMouseInfo:ToolMouseInfo):void
		{
			if(toolMouseInfo.target == null && toolMouseInfo.shiftKey == false)
			{
				diagramModel.select();
			}
			else
			{
				if(toolMouseInfo.target is SDObjectModel)
				{
					if(diagramModel.selectedObjects.getItemIndex(toolMouseInfo.target) == -1)
					{
						if(toolMouseInfo.shiftKey == false)
							diagramModel.select([toolMouseInfo.target]);
						else
						{
							var selection:Array = diagramModel.selectedObjects.source.concat();
							selection.push(toolMouseInfo.target);
							diagramModel.select(selection);
						}
					}
				}
			}
			_currentToolImpl.onMouseDown(toolMouseInfo);
		}
		
		public override function onMouseMove(toolMouseInfo:ToolMouseInfo):void
		{
			_currentToolImpl.onMouseMove(toolMouseInfo);
		}
		
		public override function onMouseUp(toolMouseInfo:ToolMouseInfo):void
		{
			_currentToolImpl.onMouseUp(toolMouseInfo);
		}
		
	}
}