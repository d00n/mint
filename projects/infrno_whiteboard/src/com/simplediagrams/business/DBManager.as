package com.simplediagrams.business
{
	import com.simplediagrams.events.DatabaseEvent;
	import com.simplediagrams.model.*;
	import com.simplediagrams.util.Logger;
	
//	import flash.data.SQLConnection;
//	import flash.data.SQLStatement;
//	import flash.errors.SQLError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
//	import flash.events.SQLErrorEvent;
//	import flash.events.SQLEvent;
//	import flash.filesystem.File;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	/** 
	 *  DBMANGER FOR AIR
	 * 
	 *  DBManager is a singleton that manages all connections and 
	 *  operations on the SimpleDiagram DB. It also acts as an ORM for certain Classes.
	 *
	 * 
	 * 	Some code adapted from: http://coenraets.org/blog/2008/12/using-the-sqlite-database-access-api-in-air%E2%80%A6-part-3-annotation-based-orm-framework/
	 * 
	 */
	
	
	public class DBManager extends EventDispatcher
	{
		
		
		public static var DB_CONNECTION_OPEN:String = "dbConnectionOpen"
		public static var DB_CONNECTION_ERROR:String = "dbConnectionError"
		private static var _instance:DBManager					//hold singleton instance
		private static var _localInstantiation:Boolean			//simple internal flag for proper creation of singleton
		
		private var _dbLocation:String = "db/simplediagram.sqlite"	
		
		private var _map:Object = new Object()
//		private var _sqlConnection:SQLConnection
//		private var _dbFile:File
		
		//custom SQL commands
//		private var findByForeignKeyStmt:SQLStatement
//		private var getDBVersionStmt:SQLStatement
//		private var setDBVersionStmt:SQLStatement
//		private var removeAllSymbolsFromDiagramStmt:SQLStatement
		
		public function DBManager()
		{
		}
		
		
		public function close():void
		{
//			if (sqlConnection.connected)
//				sqlConnection.close()
		}
		
		public function get isConnected():Boolean
		{
//			return sqlConnection.connected
			return false
		}
				
		public function get dbLocation():String
		{
			return _dbLocation
		}
		
		public function set dbLocation(value:String):void
		{
//			if (sqlConnection.connected)
//			{
//				throw new Error("Can't change dbLocation after sqlConnection has been made")
//			}
//			_dbLocation = value
		}
		
		
		public function openDB():void
		{
//			Logger.debug("openDB()", this)
//			_dbFile	= File.applicationDirectory.resolvePath(dbLocation)
//			
//			Logger.debug("looking for db in : " + _dbFile.nativePath, this)
//			if (!_dbFile.exists)
//			{
//				throw new Error("DB File doesn't exist at path: " + _dbFile.nativePath, this)
//			}			
//			sqlConnection = new SQLConnection()
//			sqlConnection.addEventListener(SQLEvent.OPEN, onConnectionOpen)
//			sqlConnection.addEventListener(SQLErrorEvent.ERROR, onConnectionError)
//			sqlConnection.open(_dbFile)
		}
		
	
		
		public function findByID(c:Class, id:Number):Object
		{
			//doon
			return null

			
//			if (id==0) throw new Error("ID cannot be 0")
//	
//			if (!_map[c]) loadMetadata(c);
//			var stmt:SQLStatement = _map[c].findStmt
//			var identity:Object = _map[c].identity;
//		
//			stmt.parameters[":id"] = id
//			stmt.execute()
//			var result:Object = stmt.getResult().data
//			if (result==null) return null
//			var o:Object = typeObject(result[0],c)
//			return o
						
		}
		
		public function findByName(c:Class, name:String):Object
		{
			//doon
			return null
			
//			if (name=="") throw new Error("Name cannot be empty")
//	
//			if (!_map[c]) loadMetadata(c);
//			var stmt:SQLStatement = _map[c].findByNameStmt
//			var identity:Object = _map[c].identity;
//			
//			stmt.parameters[":name"] = name
//			Logger.debug(" findByName stmt" + stmt.text)
//			stmt.execute()
//			
//			// Return array typed objects
//			var result:Array = stmt.getResult().data;
//			Logger.debug(" findAll stmt: " + stmt.text.toString())
//			if (result==null) return new ArrayCollection()
//			return typeArray(result, c);
			
		}
		
		public function findFirstByName(c:Class, name:String):Object
		{
			//doon
			return null
			
//			//Logger.debug(" findByName c:" + c + " name: " + name)
//			if (name=="") throw new Error("Name cannot be empty")
//	
//			if (!_map[c]) loadMetadata(c);
//			var stmt:SQLStatement = _map[c].findByNameStmt
//			var identity:Object = _map[c].identity;
//			
//			stmt.parameters[":name"] = name
//			Logger.debug(" findByName stmt" + stmt.text)
//			stmt.execute()
//			
//			// Return first typed object in results
//			var o:Object = stmt.getResult().data
//			if (o==null) return null
//			return typeObject(o[0],c)
		}
		
				
		public function findByForeignKey(c:Class, foreignKeyColumnName:String, foreignKeyID:int):ArrayCollection
		{
			//doon
			return null
			
//			if (foreignKeyColumnName=="") throw new Error("foreignKeyColumnName cannot be empty")
//			if (foreignKeyID<1) throw new Error("foreignKey must be greater than 0")
//			
//			if (!_map[c]) loadMetadata(c);
//						
//			var tableName:String = _map[c].table
//			var stmt:SQLStatement = new SQLStatement()
//			stmt.sqlConnection = sqlConnection
//			stmt.text = "SELECT * FROM "+ tableName +" WHERE " + foreignKeyColumnName +"=:foreignKeyID"	
//			//stmt.parameters[":foreignKeyColumnName"] = foreignKeyColumnName	
//			stmt.parameters[":foreignKeyID"] = foreignKeyID		
//			
//			stmt.execute()	
//						
//			var result:Array = stmt.getResult().data;
//			if (result==null) return new ArrayCollection()
//			return typeArray(result, c);
		}
		
		public function findFirst(c:Class):Object
		{
			//doon
			return null
			
//			//Logger.info("#DBM: findFirst c:" + c)
//			// If not yet done, load the metadata for this class
//			if (!_map[c]) loadMetadata(c);
//			var stmt:SQLStatement = _map[c].findFirstStmt;
//			stmt.execute();
//			// Return typed object
//			var o:Object = stmt.getResult().data
//			if (o==null) return null
//			return typeObject(o[0],c)
		}
		
		public function findAll(c:Class):ArrayCollection
		{
			//doon
			return null
			
//			// If not yet done, load the metadata for this class
//			if (!_map[c]) loadMetadata(c);
//			var stmt:SQLStatement = _map[c].findAllStmt;
//			stmt.execute();
//			// Return typed objects
//			var result:Array = stmt.getResult().data;
//			if (result==null) return new ArrayCollection()
//			return typeArray(result, c);
		}
		
		/** @returns id of object saved */
		
		public function save(o:Object, createWithID:int=0):uint
		{
//			Logger.debug(" save() o: " + o)
//			var c:Class = Class(getDefinitionByName(getQualifiedClassName(o)));
//			Logger.debug("c: " + c, this)
//			var objectID:uint //id of object being saved
//						
//			if (!_map[c] || _map[c].identity==null) loadMetadata(c);
//						
//			var identity:Object = _map[c].identity;
//											
//			// Check if the object has an identity
//			try
//			{
//				if (createWithID>0)
//				{
//					objectID = createItem(o,c, createWithID)	
//				}				
//				else if (o[identity.field]>0)
//				{
//					// If yes, we deal with an update
//					updateItem(o,c);
//					objectID = o.id
//				}
//				else
//				{
//					// If no, this is a new item
//					objectID = createItem(o,c);
//				}
//				return objectID
//			}
//			catch(err:Error)
//			{
//				Logger.error("database error on save: " + err + " " + err.message, this)
//				//if database locked, just show Alert
//				if (err.errorID == 3119)
//				{
//					Alert.show("Database is locked. Please close any programs using the database and try again.")
//					return null
//				}
//				throw err
//			}
			return null
		}
		
		
		public function remove(o:Object):void
		{
//			var c:Class = Class(getDefinitionByName(getQualifiedClassName(o)));
//			// If not yet done, load the metadata for this class
//			if (!_map[c]) loadMetadata(c)
//			var identity:Object = _map[c].identity
//			var stmt:SQLStatement = _map[c].deleteStmt
//			stmt.parameters[":"+identity.field] = o[identity.field]
//			stmt.execute()
		}
		
		public function removeByName(o:Object, name:String):void
		{
//			var c:Class = Class(getDefinitionByName(getQualifiedClassName(o)))
//			// If not yet done, load the metadata for this class
//			if (!_map[c]) loadMetadata(c)
//			var stmt:SQLStatement = _map[c].deleteByNameStmt
//			stmt.parameters[":name"] = name
//			stmt.execute();
		}
		
		public function removeByID(o:Object, id:uint):void
		{
//			var c:Class = Class(getDefinitionByName(getQualifiedClassName(o)))
//			// If not yet done, load the metadata for this class
//			if (!_map[c]) loadMetadata(c)
//			var stmt:SQLStatement = _map[c].deleteByIDStmt
//			stmt.parameters[":id"] = id
//			stmt.execute();
		}
	
		

	}
}