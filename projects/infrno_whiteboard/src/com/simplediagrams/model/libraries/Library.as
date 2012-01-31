package com.simplediagrams.model.libraries
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	public class Library 
	{
		public function Library()
		{
			items = new ArrayCollection();
		}
		
		public var name:String;
		
		[Bindable]
		public var displayName:String;
		public var type:String;
		
		public var prevName:String //only used for libraries ported from database pre v1.5
		
		[Bindable]
		public var custom:Boolean;
		
		private var _items:ArrayCollection;
	
		[Bindable]
		public function get items():ArrayCollection
		{
			return _items;
		}

		public function set items(value:ArrayCollection):void
		{
			if(_items)
				_items.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
			_items = value;
			onCollectionChange(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
			if(_items)
				_items.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
		}
		
		private function onCollectionChange(event:CollectionEvent):void
		{
			switch(event.kind)
			{
				case CollectionEventKind.ADD: registerItems(event.items);break;
				case CollectionEventKind.REMOVE: unregisterItems(event.items);break;
				case CollectionEventKind.RESET: 
					dictionary = new Dictionary();
					registerItems(_items.source);break;
				default: throw new Error("Collection change handler not implemented.");break;
			}
		}
				
		
		private function unregisterItems(items:Array):void
		{
			for each(var item:LibraryItem in items)
			{
				delete dictionary[item.name];
			}
		}
		
		private function registerItems(items:Array):void
		{
			for each(var item:LibraryItem in items)
			{
				dictionary[item.name] = item;
			}
		}
			
		private var dictionary:Dictionary = new Dictionary();
		
		public function getLibraryItem(name:String):LibraryItem
		{
			return dictionary[name];
		}
		
		public function getSymbolNameByDisplayName(displayName:String):String
		{
			for each(var item:LibraryItem in items)
			{
				if (item.displayName==displayName)
				{
					return item.name
				}
			}
			return null
		}
		
		
	}
}