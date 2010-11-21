package com.simplediagrams.model.libraries
{
	import com.simplediagrams.business.DBManager;
	import com.simplediagrams.model.SDCustomSymbolModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.model.dao.CustomLibraryDAO;
	import com.simplediagrams.util.Logger;

	[Bindable]
	public class CustomLibrary extends AbstractLibrary implements ILibrary
	{		
		protected var _customLibraryDAO:CustomLibraryDAO
		
		public function CustomLibrary()
		{
			_customLibraryDAO = new CustomLibraryDAO()
			_isPlugin = false
			_isCustom = true
		}
		
		override public function initShapes():void
		{
			//override this
		}
				
		override public function initLibrary():void
		{	
			Logger.debug("initLibrary() _sdLibraryObjectsAC.length: " + _sdLibraryObjectsAC.length, this)	
		}
		
		public function set customLibraryDAO(dao:CustomLibraryDAO):void
		{
			if (dao)
			{
				_customLibraryDAO = dao
			}
			else
			{
				throw new Error("CustomLibraryDAO cannot be null")
			}
		}
		
		public function load(dbManager:DBManager, libraryID:int):void
		{
			_customLibraryDAO = dbManager.findByID(CustomLibraryDAO, libraryID) as CustomLibraryDAO
			if (_customLibraryDAO==null)
			{
				throw new Error("Couldn't find library with id: " + libraryID)
			}
		}
		
		public function save(dbManager:DBManager):void
		{
			dbManager.save(_customLibraryDAO)
		}
				
		override public function get libraryName():String
		{
			return _customLibraryDAO.libraryName 
		}
		
		override public function set libraryName(value:String):void
		{
			_customLibraryDAO.libraryName  = value
		}
				
		override public function get displayName():String
		{
			return _customLibraryDAO.displayName 
		}
		override public function set displayName(value:String):void
		{
			_customLibraryDAO.displayName = value
		}
		
		override public function get description():String
		{
			return _customLibraryDAO.description
		}
		override public function set description(value:String):void
		{
			_customLibraryDAO.description = value
			super.description = value
		}
						
		override public function get showInPanel():Boolean
		{
			return _customLibraryDAO.showInPanel 
		}				
		override public function set showInPanel(value:Boolean):void
		{
			_customLibraryDAO.showInPanel = value
			super.showInPanel = value
		}		
				
		override public function get canBeDeleted():Boolean
		{
			return true
		}		
		
		public function deleteLibraryFromDB(dbManager:DBManager):void
		{
			//TODO: delete each child symbol from library			
			dbManager.remove(this._customLibraryDAO)
		}
		
		public function get id():int
		{
			return _customLibraryDAO.id
		}
		
		
		public function renameSymbol(oldName:String, newName:String, dbManager:DBManager):void
		{
			if(oldName==newName) return
			if(oldName=="")
			{
				Logger.error("renameSymbol() oldName is null", this)
				return
			}
			if(newName=="")
			{
				Logger.error("renameSymbol() newName is null", this)
				return
			}
			
			//find object directly (don't get a clone) to rename it
			for each (var obj:SDCustomSymbolModel in sdLibraryObjectsAC)
			{
				if (obj.symbolName == oldName)
				{
					obj.symbolName = newName
					obj.save(dbManager)
					return
				}
			}
			
			throw new Error("Couldn't find symbol with name " + oldName + " in library " + this.libraryName) 
							
			
		}
		
		public function deleteSymbol(symbolName:String, dbManager:DBManager):void
		{
			
			//find object and remove from arrayCollection
			var len:uint = sdLibraryObjectsAC.length
			for (var i:uint=0;i<len;i++)
			{
				var sdCustomSymbol:SDCustomSymbolModel = sdLibraryObjectsAC.getItemAt(i) as SDCustomSymbolModel
				if (sdCustomSymbol.symbolName == symbolName)
				{
					sdLibraryObjectsAC.removeItemAt(i)
					break
				}
			}
			
			if (sdCustomSymbol!=null)
			{
				try
				{
					sdCustomSymbol.deleteSymbol(dbManager)
				}
				catch(error:Error)
				{
					throw new Error("Couldn't delete symbol " + symbolName + " from the database. Error: " + error)
				}
			}
			else
			{
				throw new Error("Couldn't delete symbol " + symbolName + " since it can't be found in database")
			}
			
		}
		
		
		
		
	}
}