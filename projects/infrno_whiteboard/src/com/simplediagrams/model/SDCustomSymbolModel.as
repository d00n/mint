package com.simplediagrams.model
{
	import com.simplediagrams.business.DBManager;
	import com.simplediagrams.model.dao.CustomSymbolDAO;
	
	import flash.utils.ByteArray;

	
	public class SDCustomSymbolModel extends SDSymbolModel
	{
		
		protected var _customSymbolDAO:CustomSymbolDAO = new CustomSymbolDAO()
		
		public function SDCustomSymbolModel(symName:String="", initialWidth:Number=50, initialHeight:Number=50, colorizable:Boolean=true)
		{
			super(symName, initialWidth, initialHeight, colorizable);
			this.isCustom = true
			_customSymbolDAO = new CustomSymbolDAO()
		}
					
		public function save(dbManager:DBManager):void
		{
			dbManager.save(_customSymbolDAO)
		}
		
		public function deleteSymbol(dbManager:DBManager):void
		{
			dbManager.remove(_customSymbolDAO)
			_customSymbolDAO = null
		}
		
		public function load(dbManager:DBManager, id:int):void
		{
			_customSymbolDAO = dbManager.findByID(CustomSymbolDAO, id) as CustomSymbolDAO
			if (_customSymbolDAO==null)
			{
				throw new Error ("Couldn't find custom symbol with id: " + id)
			}
			super.imageData = _customSymbolDAO.imageData
			super.symbolName = _customSymbolDAO.symbolName	
			super.displayName = _customSymbolDAO.symbolName			
			super.colorizable = false
			_width = _customSymbolDAO.initialWidth
			_height = _customSymbolDAO.initialHeight
		}
						
		public function get id():int
		{
			return _customSymbolDAO.id 
		}		
		public override function set imageData(ba:ByteArray):void
		{
			super.imageData = ba
			_customSymbolDAO.imageData = ba
		}
		
			
		public function get libraryID():int
		{
			return _customSymbolDAO.libraryID 
		}		
		public function set libraryID(value:int):void
		{
			_customSymbolDAO.libraryID = value
		}
		
		override public function get symbolName():String
		{
			return _customSymbolDAO.symbolName
		}		
		override public function set symbolName(value:String):void
		{
			_customSymbolDAO.symbolName = value
			this.displayName = value
		}
		
		
		
	}
}