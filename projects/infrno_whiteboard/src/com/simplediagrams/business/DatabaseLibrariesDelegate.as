package com.simplediagrams.business
{
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.libraries.ImageShape;
	import com.simplediagrams.model.libraries.Library;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.utils.UIDUtil;

	public class DatabaseLibrariesDelegate
	{
		public function DatabaseLibrariesDelegate()
		{
		}
		
		public var libraryDelegate:LibraryDelegate;
		
		public function doImport(file:File):Array
		{
			var sqlConnection:SQLConnection = new SQLConnection();
			sqlConnection.open(file);
			var sqlStatement:SQLStatement = new SQLStatement();
			sqlStatement.text = "SELECT * FROM custom_libraries";
			sqlStatement.sqlConnection = sqlConnection;
			sqlStatement.execute();
			var result:SQLResult = sqlStatement.getResult();
			var libraries:Array = [];
			for each(var object:Object in result.data)
			{
				var id:int = object.id;
				var library:Library = new Library();
				library.custom = true;
				library.type = "shapes";
				library.prevName = object.library_name
				library.name = UIDUtil.createUID();
				library.displayName = object.display_name;
				
				sqlStatement.text = "SELECT * FROM custom_symbols WHERE library_id=" + id;
				sqlStatement.sqlConnection = sqlConnection;
				sqlStatement.execute();
				result = sqlStatement.getResult();
				for each(var item:Object in result.data)
				{
					var imageShape:ImageShape = new ImageShape();
					imageShape.displayName = item.symbol_name;
					imageShape.width = item.initial_width;
					imageShape.height = item.initial_height;
					imageShape.name = UIDUtil.createUID();
					imageShape.libraryName = library.name;
					imageShape.path = imageShape.name + ".png";
					library.items.addItem(imageShape);
					
					var imageData:ByteArray = item.image_data;
					var itemFile:File = ApplicationModel.baseStorageDir.resolvePath("libraries/" + library.name + "/" + imageShape.path);
					var s:FileStream = new FileStream();
					s.open(itemFile, FileMode.WRITE);
					s.writeBytes(imageData);
					s.close();
				}
				libraries.push(library);
				libraryDelegate.saveLibrary(library);
			}
			return libraries;
		}
	}
}