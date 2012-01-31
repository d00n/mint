package com.simplediagrams.model.libraries
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;

	public class LibrariesRegistry
	{
		public function LibrariesRegistry()
		{
			libraries = new ArrayCollection();
		}
		
		private var _libraries:ArrayCollection ;
		
		public function get libraries():ArrayCollection
		{
			return _libraries;
		}
		
		public function set libraries(value:ArrayCollection):void
		{
			if(_libraries)
			{
				_libraries.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
			}
			_libraries = value;
			onCollectionChange(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
			if(_libraries)
			{
				_libraries.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
			}
		}
		
		private function onCollectionChange(event:CollectionEvent):void
		{
			switch(event.kind)
			{
				case CollectionEventKind.ADD: registerItems(event.items);break;
				case CollectionEventKind.REMOVE: unregisterItems(event.items);break;
				case CollectionEventKind.RESET: 
					dictionary = new Dictionary();
					registerItems(_libraries.source);break;
				case CollectionEventKind.UPDATE: break;
				case CollectionEventKind.REFRESH: break;
				case CollectionEventKind.MOVE: break;
				default: throw new Error("Collection change handler not implemented.");break;
			}
		}
		
		
				
		private function unregisterItems(items:Array):void
		{
			for each(var item:LibraryInfo in items)
			{
				delete dictionary[item.name];
			}
		}
		
		private function registerItems(items:Array):void
		{
			for each(var item:LibraryInfo in items)
			dictionary[item.name] = item;
		}
		
		private var dictionary:Dictionary = new Dictionary();
		
		public function getLibraryInfo(name:String):LibraryInfo
		{
			return dictionary[name];
		}
	}
}