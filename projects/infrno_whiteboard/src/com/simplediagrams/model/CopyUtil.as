package com.simplediagrams.model
{
	import avmplus.getQualifiedClassName;
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;

	public class CopyUtil
	{
		public function CopyUtil()
		{
		}
		
		public static function clone(object:Object):Object
		{
			if(object is Array)
				return cloneArray(object as Array);
			var objectClass:Class = getDefinitionByName(getQualifiedClassName(object)) as Class;//TODO can be optimized - add descriptors cache
			var copy:Object = new objectClass();
			copyFrom(copy, object);
			return copy;
		}
		
		private static function cloneArray(array:Array):Array
		{
			var result:Array = [];
			for each(var o:Object in array)
				result.push(clone(o));
			return result;
		}
		
		public static function copyFrom(target:Object, source:Object):void
		{
			var sourceInfo:XML = describeType(source);//TODO can be optimized - add descriptors cache
			var objectProperty:XML;
			var propertyName:String;
			for each(objectProperty in sourceInfo.variable)
			{
				propertyName = objectProperty.@name;
				target[propertyName] = source[propertyName];
			}
			for each(objectProperty in sourceInfo.accessor) 
			{
				if(objectProperty.@access == "readwrite") 
				{
					propertyName = objectProperty.@name;
					target[propertyName] = source[propertyName];
				}
			}
		}
	}
}