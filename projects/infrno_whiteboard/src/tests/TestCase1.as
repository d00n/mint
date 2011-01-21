package tests
{
	import com.simplediagrams.controllers.DiagramController;
	import com.simplediagrams.events.ChangeDepthEvent;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDObjectModel;
	
	import org.flexunit.Assert;
	
	public class TestCase1 
	{
		
		
		private var count:int = 0;	
		private var diagramController:DiagramController;
		public var diagramModel:DiagramModel
		
		[Before]
		public function runBeforeEveryTest():void { 
			diagramController = new DiagramController();
			diagramModel = new DiagramModel();
			count = 10;
		}   
		
		[After]  
		public function runAfterEveryTest():void {   
			count = 0;  
		} 
		
		[Test]  
		public function moveToBack():void { 
			var event:ChangeDepthEvent = new ChangeDepthEvent(ChangeDepthEvent.MOVE_TO_BACK);			
			diagramController.moveToBack(event);
		}
		
		[Test]  
		public function dcIntheHizzy():void { 
			Assert.assertNotNull(diagramController);  
			Assert.assertNotNull(diagramModel);  
		}
		
		[Test( description = "This tests addition" )]
		public function ssimpleAdd():void 
		{
			var x:int = 5 + 3;
			Assert.assertEquals( 8, x );
		}	
		
	}
}