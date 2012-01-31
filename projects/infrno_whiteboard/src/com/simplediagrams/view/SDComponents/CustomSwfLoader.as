package com.simplediagrams.view.SDComponents
{
	import flash.system.LoaderContext;
	
	import mx.controls.SWFLoader;
	
	public class CustomSwfLoader extends SWFLoader
	{
		public function CustomSwfLoader()
		{
			super();
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.allowCodeImport = true;
			this.loaderContext = loaderContext;
		}
	}
}