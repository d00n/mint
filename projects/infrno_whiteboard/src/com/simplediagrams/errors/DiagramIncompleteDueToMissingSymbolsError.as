package com.simplediagrams.errors
{
	public class DiagramIncompleteDueToMissingSymbolsError extends Error
	{
		public var modelsForMissingSymbolsArr:Array
		
		public function DiagramIncompleteDueToMissingSymbolsError(message:*="", id:*=0)
		{
			super(message, id);
		}
	}
}