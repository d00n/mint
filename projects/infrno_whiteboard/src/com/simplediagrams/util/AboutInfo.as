package com.simplediagrams.util
{
//	import flash.desktop.NativeApplication;    
	import flash.system.Capabilities
	
	public class AboutInfo
	{
		
		/* TODO: implement this class so that it grabs version and name info from AIR (if this is an AIR app) or from MDM (if this is a zinc app) */
		
		public static var applicationName:String = "SimpleDiagram"
		public static const VERSION:String		= "v0.2.11";
		
		public function AboutInfo()
		{
		
			
		}
	
		public static function get applicationVersion():String
		{
			return VERSION;
//			var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor
//			var air:Namespace = appXML.namespaceDeclarations()[0]
//			var version:String = appXML.air::version
//			
//			if (version.indexOf("v")==0) version = version.substr(1)
//			return version
		}
		
		public static function get flashPlayerVersion():String
		{
			return Capabilities.version
		}
		
				
		

	}
}