package tests
{
	import com.simplediagrams.controllers.DiagramController;
	import com.simplediagrams.events.ChangeDepthEvent;
	import com.simplediagrams.model.DiagramModel;
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
		public var diagramModel:DiagramModel
		
		[Before(async, timeout=5000)]
		public function runBeforeEveryTest():void { 
			Async.proceedOnEvent(this,
				prepare(IEventDispatcher),
				Event.COMPLETE);		

		}   
		
		[Before(order=2)]
		public function setup():void {
			diagramModel = new DiagramModel();
			diagramModel.sdObjectModelsAC = new ArrayCollection();
			diagramController = new DiagramController();
			diagramController.diagramModel = diagramModel;
			var dispatcher:IEventDispatcher = strict(IEventDispatcher);
			mock(dispatcher).method("dispatchEvent");
			diagramController.dispatcher = dispatcher;
		}
		
		[After]  
		public function runAfterEveryTest():void {   
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
			
			
			diagramModel.sdObjectModelsAC.removeItemAt(1);
			
			var subject:SDObjectModel = diagramModel.sdObjectModelsAC.getItemAt(0) as SDObjectModel;
			Assert.assertEquals('a', subject.sdID);
			Assert.assertEquals(0, subject.depth);
			
			var subject:SDObjectModel = diagramModel.sdObjectModelsAC.getItemAt(1) as SDObjectModel;
			Assert.assertEquals('c', subject.sdID);
//			Assert.assertEquals(1, subject.depth);
//			
//			var subject:SDObjectModel = diagramModel.sdObjectModelsAC.getItemAt(2) as SDObjectModel;
//			Assert.assertNull(subject);
//			
//			
//			diagramModel.sdObjectModelsAC.addItem(sdObjectModel_b);
//
//			var subject:SDObjectModel = diagramModel.sdObjectModelsAC.getItemAt(0) as SDObjectModel;
//			Assert.assertEquals('a', subject.sdID);
//			Assert.assertEquals(0, subject.depth);
//			
//			var subject:SDObjectModel = diagramModel.sdObjectModelsAC.getItemAt(1) as SDObjectModel;
//			Assert.assertEquals('c', subject.sdID);
//			Assert.assertEquals(1, subject.depth);
//			
//			var subject:SDObjectModel = diagramModel.sdObjectModelsAC.getItemAt(2) as SDObjectModel;
//			Assert.assertEquals('b', subject.sdID);
//			Assert.assertEquals(2, subject.depth);
//			
//			
//			var event:ChangeDepthEvent = new ChangeDepthEvent(ChangeDepthEvent.MOVE_TO_BACK);		
//			event.sdID = "c";
//			diagramController.moveToBack(event);
//			
//			Assert.assertEquals(0, sdObjectModel_c.depth);
//			Assert.assertEquals(1, sdObjectModel_a.depth);
//			Assert.assertEquals(2, sdObjectModel_b.depth);
		}
		
	}
}