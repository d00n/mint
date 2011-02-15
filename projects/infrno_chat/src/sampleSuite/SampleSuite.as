package sampleSuite
{
	import sampleSuite.tests.TestClass1;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class SampleSuite
	{
		public var t1:TestClass1;
		public function SampleSuite()
		{
		}
	}
}