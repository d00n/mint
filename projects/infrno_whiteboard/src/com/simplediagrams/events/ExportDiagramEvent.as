package com.simplediagrams.events
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
	import mx.validators.StringValidator;
	
	import spark.components.Scroller;
	
	public class ExportDiagramEvent extends ExportDiagramUserRequestEvent
	{
		
		public static const EXPORT_TO_BASECAMP:String = "exportDiagramToBaseCamp"
		public static const EXPORT_TO_YAMMER:String = "exportToYammer"		
		public static const EXPORT_TO_CLIPBOARD:String = "exportToClipboard"
			
		public static const CREATE_IMAGE_FOR_EXPORT:String = "createImageForFile"	
		public static const SAVE_IMAGE_TO_FILE:String = "saveImageToFile"
			
		public static const FORMAT_PNG:String = "pngFormat"
		public static const FORMAT_JPG:String = "jpgFormat"
		public static const FORMAT_PDF:String = "pdfFormat"				
			
		public var view:UIComponent				//this is a ref to the view we want to export as image
		public var format:String 				//types are const's described above
		public var scroller:Scroller 			//keep this ref so controller can hide it			
		
		public var imageByteArray:ByteArray		//for final step of saving generated image to file
		
		public function ExportDiagramEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}