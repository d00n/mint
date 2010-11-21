package com.simplediagrams.events
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	public class AddImageFileToCustomLibraryEvt extends Event
	{
		public static const ADD_IMAGE_FROM_FILE:String = "addImageFromFileToCustomLibrary"
		public static const IMAGE_FROM_FILE_ADDED:String = "imageFromFileAddedToCustomLibrary"
		
		public var libraryID:int
		public var imageFile:File
			
		public function AddImageFileToCustomLibraryEvt(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}