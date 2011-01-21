package tests
{

	import com.simplediagrams.controllers.DiagramController;
	import com.simplediagrams.model.SDObjectModel;
	
	import org.flexunit.Assert;
	
	public class TestCase1 {
		private var count:int = 0;	
		private var diagramController:DiagramController;
		
		[Before]
		public function runBeforeEveryTest():void { 
			diagramController = new DiagramController();
			count = 10;
		}   
		
		[After]  
		public function runAfterEveryTest():void {   
			count = 0;  
		} 
		
		[Test]  
		public function dcIntheHizzy():void { 
			Assert.assertNotNull(diagramController);  
		}
		
		[Test( description = "This tests addition" )]
		public function ssimpleAdd():void 
		{
			var x:int = 5 + 3;
			Assert.assertEquals( 8, x );
		}	
		
		[Test( description = "This tests addition" )]
		public function badAdd():void 
		{
			var x:int = 52 + 3;
			Assert.assertEquals( 8, x );
		}
	}
}