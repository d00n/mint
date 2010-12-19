package com.simplediagrams.events
{
	import flash.events.Event;
	
	public class LoadDiagramEvent extends Event
	{
		public static const LOAD_DIAGRAM:String = "loadDiagram"
		public static const DIAGRAM_PARSED:String = "diagramParsed" 				//the xml was loaded in but we haven't completed the load yet
		public static const DIAGRAM_LOADED:String = "diagramLoaded"
		public static const DIAGRAM_READY:String = "diagramReady"					//everything is ready for the diagram to be built...including views being ready to receive events
		public static const DIAGRAM_LOAD_ERROR:String = "diagramLoadedError"
		public static const DIAGRAM_LOAD_CANCELED:String = "diagramLoadCanceled"
		public static const DIAGRAM_BUILT:String = "diagramBuilt"					//this is launched after the model has completely built the diagram
		
		public var id:int
		
		public var success:Boolean = false				
		public var nativePath:String = ""		
		public var fileName:String =""
		public var usesUnavailableLibraries:Boolean = false
			
		public var errorMessage:String
				
		public function LoadDiagramEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}