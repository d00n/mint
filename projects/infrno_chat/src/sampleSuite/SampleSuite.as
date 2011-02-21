package sampleSuite
{
	import sampleSuite.tests.SetupPeerNetStreamCommand_Test;
	import sampleSuite.tests.TestClass1;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class SampleSuite
	{
//		public var t1:TestClass1;
		public var t2:SetupPeerNetStreamCommand_Test;
		public function SampleSuite()
		{
		}
	}
}