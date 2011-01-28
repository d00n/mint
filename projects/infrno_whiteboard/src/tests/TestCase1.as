package tests
{
	import com.roguedevelopment.objecthandles.ObjectHandlesSelectionManager;
	import com.simplediagrams.controllers.DiagramController;
	import com.simplediagrams.controllers.RemoteSharedObjectController;
	import com.simplediagrams.events.ChangeDepthEvent;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDImageModel;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectHandles;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.mementos.SDObjectMemento;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mockolate.mock;
	import mockolate.prepare;
	import mockolate.strict;
	
	import mx.collections.ArrayCollection;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	
	public class TestCase1 
	{
		private var diagramController:DiagramController;
		private var diagramModel:DiagramModel;
		private var remoteSharedObjectController:RemoteSharedObjectController;
		
		[Before(async, timeout=5000)]
		public function runBeforeEveryTest():void { 
			Async.proceedOnEvent(this,
				prepare(IEventDispatcher,SDObjectHandles,ObjectHandlesSelectionManager),
				Event.COMPLETE);		
		}   
		
		[Before(order=2)]
		public function setup():void {
			diagramModel = new DiagramModel();
			diagramModel.sdObjectModelsAC = new ArrayCollection();
			
			diagramController = new DiagramController();
			diagramController.diagramModel = diagramModel;
			
			remoteSharedObjectController = new RemoteSharedObjectController;
			remoteSharedObjectController.diagramModel = diagramModel;
			
			var dispatcher:IEventDispatcher = strict(IEventDispatcher);
			mock(dispatcher).method("dispatchEvent");
			diagramController.dispatcher = dispatcher;
			diagramModel.dispatcher = dispatcher;
			
			var selectionManager:ObjectHandlesSelectionManager = strict(ObjectHandlesSelectionManager);
			mock(selectionManager).method("setSelected");
			mock(selectionManager).method("clearSelection");
			
			var sdObjectHandles:SDObjectHandles = strict(SDObjectHandles);
			mock(sdObjectHandles).method("registerComponent");
			mock(sdObjectHandles).method("unregisterComponent");
			sdObjectHandles.selectionManager = selectionManager;
			diagramModel.sdObjectHandles = sdObjectHandles;
		}
		
		[After]  
		public function runAfterEveryTest():void {   
		} 
		
		[Test]  
		public function rsoController_only_add_item_once_to_DiagraModel_sdObjectModelsAC():void { 
			var sdImageModel_a:SDImageModel = new SDImageModel();
			sdImageModel_a.sdID = "a";
			sdImageModel_a.depth = 0;			
			var changeObject:Object = new Object();
			changeObject.sdID = 'a';
			changeObject.sdObjectModelType = 'SDImageModel';

			
			Assert.assertEquals(0, diagramModel.sdObjectModelsAC.length);

			
			remoteSharedObjectController.processUpdate_ObjectChanged(changeObject);					
			Assert.assertEquals(1, diagramModel.sdObjectModelsAC.length);			
			var subject:SDImageModel = diagramModel.getModelByID(sdImageModel_a.sdID) as SDImageModel;
			Assert.assertEquals(sdImageModel_a.sdID, subject.sdID);
			Assert.assertEquals(sdImageModel_a.depth, subject.depth);

			
			changeObject = new Object();
			changeObject.sdID = 'a';
			changeObject.sdObjectModelType = 'SDImageModel';
			remoteSharedObjectController.processUpdate_ObjectChanged(changeObject);					
			Assert.assertEquals(1, diagramModel.sdObjectModelsAC.length);			
			subject = diagramModel.getModelByID(sdImageModel_a.sdID) as SDImageModel;
			Assert.assertEquals(sdImageModel_a.sdID, subject.sdID);
			Assert.assertEquals(sdImageModel_a.depth, subject.depth);
			
			Assert.assertEquals(1, diagramModel.sdObjectModelsAC.length);
		}
		
		[Test]  
		public function moveToBack():void {
			var sdObjectModel_a:SDObjectModel = new SDObjectModel();
			sdObjectModel_a.sdID = "a";
			sdObjectModel_a.depth = 0;
			diagramModel.sdObjectModelsAC.addItem(sdObjectModel_a);
			
			var sdObjectModel_b:SDObjectModel = new SDObjectModel();
			sdObjectModel_b.sdID = "b";
			sdObjectModel_b.depth = 1;
			diagramModel.sdObjectModelsAC.addItem(sdObjectModel_b);
			
			var sdObjectModel_c:SDObjectModel = new SDObjectModel();
			sdObjectModel_c.sdID = "c";
			sdObjectModel_c.depth = 2;
			diagramModel.sdObjectModelsAC.addItem(sdObjectModel_c);
			
			var event:ChangeDepthEvent = new ChangeDepthEvent(ChangeDepthEvent.MOVE_TO_BACK);		
			event.sdID = "c";
			diagramController.moveToBack(event);
			
			Assert.assertEquals(0, sdObjectModel_c.depth);
			Assert.assertEquals(1, sdObjectModel_a.depth);
			Assert.assertEquals(2, sdObjectModel_b.depth);
		}
		
		[Test]  
		public function moveToBackAfterDeletingOne():void { 
			
			// We're using SDLineModel because we need this overridden: SDObjectModel.createSDComponent()
			var sdObjectModel_a:SDObjectModel = new SDLineModel();
			sdObjectModel_a.sdID = "a";
			sdObjectModel_a.depth = 0;
			diagramModel.addSDObjectModel(sdObjectModel_a);
			
			var sdObjectModel_b:SDObjectModel = new SDLineModel();
			sdObjectModel_b.sdID = "b";
			sdObjectModel_b.depth = 1;
			diagramModel.addSDObjectModel(sdObjectModel_b);
			
			var sdObjectModel_c:SDObjectModel = new SDLineModel();
			sdObjectModel_c.sdID = "c";
			sdObjectModel_c.depth = 2;
			diagramModel.addSDObjectModel(sdObjectModel_c);
			
			
			diagramModel.deleteSDObjectModel(sdObjectModel_b);
			
			var subject:SDObjectModel = diagramModel.sdObjectModelsAC.getItemAt(0) as SDObjectModel;
			Assert.assertEquals('a', subject.sdID);
			Assert.assertEquals(0, subject.depth);
			
			subject = diagramModel.sdObjectModelsAC.getItemAt(1) as SDObjectModel;
			Assert.assertEquals('c', subject.sdID);
			Assert.assertEquals(1, subject.depth);
			
			Assert.assertEquals(2, diagramModel.sdObjectModelsAC.length);
			
			
			diagramModel.addSDObjectModel(sdObjectModel_b);

			subject = diagramModel.sdObjectModelsAC.getItemAt(0) as SDObjectModel;
			Assert.assertEquals('a', subject.sdID);
			Assert.assertEquals(0, subject.depth);
			
			subject = diagramModel.sdObjectModelsAC.getItemAt(1) as SDObjectModel;
			Assert.assertEquals('c', subject.sdID);
			Assert.assertEquals(1, subject.depth);
			
			subject = diagramModel.sdObjectModelsAC.getItemAt(2) as SDObjectModel;
			Assert.assertEquals('b', subject.sdID);
			Assert.assertEquals(2, subject.depth);
			
			
			var event:ChangeDepthEvent = new ChangeDepthEvent(ChangeDepthEvent.MOVE_TO_BACK);		
			event.sdID = "c";
			diagramController.moveToBack(event);
			
			Assert.assertEquals(0, sdObjectModel_c.depth);
			Assert.assertEquals(1, sdObjectModel_a.depth);
			Assert.assertEquals(2, sdObjectModel_b.depth);
		}
		
	}
}