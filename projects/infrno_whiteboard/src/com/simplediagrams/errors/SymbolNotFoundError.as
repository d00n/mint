package com.simplediagrams.errors
{
	public class SymbolNotFoundError extends Error
	{		
		
		public function SymbolNotFoundError(message:*="", id:*=0)
		{
			super(message, id);
		}
	}
}