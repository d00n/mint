package com.simplediagrams.model
{
	import com.simplediagrams.events.CloseDiagramEvent;
	import com.simplediagrams.events.CreateNewDiagramEvent;
	import com.simplediagrams.events.LoadDiagramEvent;
	
	import flash.events.IEventDispatcher;

	public class DiagramManager
	{
		public function DiagramManager()
		{
		}
		
		[Dispatcher]
		public var dispatcher:IEventDispatcher;
		
		[Bindable]
		public var diagramModel:DiagramModel = new DiagramModel();
		
		public function newDiagram(diagramModel:DiagramModel):void
		{
			this.diagramModel = diagramModel;
			dispatcher.dispatchEvent(new CreateNewDiagramEvent(CreateNewDiagramEvent.NEW_DIAGRAM_CREATED));
		}
		
		public function openDiagram(diagramModel:DiagramModel):void
		{
			this.diagramModel = diagramModel;
		}
		
		public function clearDiagram():void
		{
			this.diagramModel = null;
			dispatcher.dispatchEvent(new CloseDiagramEvent(CloseDiagramEvent.DIAGRAM_CLOSED));
		}
	}
}