package com.simplediagrams.errors
{
	public class SDObjectModelNotFoundError extends Error
	{
		public function SDObjectModelNotFoundError(message:*="", id:*=0)
		{
			super(message, id);
		}
	}
}