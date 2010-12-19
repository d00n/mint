package com.simplediagrams.model.libraries
{
	
	import com.simplediagrams.errors.SDObjectModelNotFoundError;
	import com.simplediagrams.model.SDBackgroundModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.util.Logger;
	
	public class BackgroundsLibrary extends AbstractLibrary implements ILibrary
	{
		
		
		public function BackgroundsLibrary()
		{			
		}
		
		public override function initLibrary():void
		{
			//attach actual graphic symbol to class
			for each (var sdObj:SDBackgroundModel in _sdLibraryObjectsAC)
			{
				sdObj.libraryName = _libraryName
			}
			
			sdLibraryObjectsAC.refresh()
		}
		
		public override function getSDObjectModel(name:String):SDObjectModel
		{
			for each (var obj:SDObjectModel in sdLibraryObjectsAC)
			{				
				if(obj is SDBackgroundModel && SDBackgroundModel(obj).backgroundName==name)
				{					
					return obj
				}				
			}			
			throw new SDObjectModelNotFoundError()			
		}
	}
}