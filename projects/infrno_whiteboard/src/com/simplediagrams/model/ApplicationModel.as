package com.simplediagrams.model
{
	import com.simplediagrams.util.AboutInfo;
	import com.simplediagrams.util.Logger;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.system.Capabilities;
	import flash.text.Font;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
		
	[Bindable]
	public class ApplicationModel extends EventDispatcher
	{
		
		public static var menuDataArr:Array
		
		/* ******************** */
		/* DESKTOP MODE TOGGLE  */
		/* ******************** */
			
		public static var integratedMode:Boolean = false	
			
		/* ********************* */
		
			
		public static const BASE_STORAGE_PATH:String ="Application Data/SimpleDiagrams/"
		public static const BASE_STORAGE_PATH_W7:String ="AppData/SimpleDiagrams/"
		public static const BASE_STORAGE_PATH_OSX:String ="SimpleDiagrams/"
					
			
		public static const LIBRARY_PATH:String = "libraries/" 		//for 2.0 libraries
		public static const LIBRARY_PLUGIN_PATH:String = "lib/"	 	//for pre 2.0 libraries
			
		public static const DB_PATH:String = "db/simplediagrams.sqlite"
		public static const DB_BACKUP_DIR_PATH:String = "db/backup/"
			
		public static const REGISTRATION_URL:String = "http://simplediagrams.heroku.com/registrations/validate"		
		public static const UNREGISTER_URL:String = "http://simplediagrams.heroku.com/registrations/unregister"		
		
		public static const VIEW_EULA:String = "eulaView"
		public static const VIEW_REGISTRATION:String = "registrationView"
		public static const VIEW_STARTUP:String = "default"
		public static const VIEW_REMOTE_STARTUP:String = "multiuser_default"
		public static const VIEW_DIAGRAM:String = "diagramView";
						
		public static const DEFAULT_SYSTEM_FONT:String = "Arial"	
		
		public static const LOG_PATH:String = "logs/application-log.txt"
								
			
			
		/* TESTING VARIABLES */
		public static var testMode:Boolean = false		
		public static var alwaysCopyDB:Boolean = false
		/* END TESTING VARIABLES */	
			
		public var loggingOn:Boolean = true					
		public var menuEnabled:Boolean = true		
		public var version:String = ""		
		public var txtStatus:String = "" //status messages for startup dialog
		public var app:SimpleDiagrams = FlexGlobals.topLevelApplication as SimpleDiagrams
						
		public var diagramLoaded:Boolean = false
		
		public var fontsAC:ArrayCollection 
		
		public var isMinimized:Boolean = false
//		public var fileToOpenOnStart:File
		
//		public var updater:ApplicationUpdaterUI
		
		protected var _viewing:String = VIEW_STARTUP
		
		public var showManageLibraries:Boolean = false;
		public var showCreateCustomLibrary:Boolean = false;
		public var showImportDatabasePrompt:Boolean = false;
		
		
//		protected static var _baseStorageDir:File	
		
		public static function get isWin():Boolean
		{
			return Capabilities.os.indexOf("Windows") >= 0
		}
		
		public static function get isMac():Boolean
		{
			return Capabilities.os.indexOf("Mac OS") >= 0
		}
		
		public static function get isLinux():Boolean
		{
			return Capabilities.os.indexOf("Linux") >= 0
		}
		

		public function ApplicationModel()
		{
			//define menu data			
			ApplicationModel.menuDataArr  = 	[]
			
			var menuObj:Object =	{label:"SimpleDiagrams", id:"simpleDiagrams", children: [
				{ label:"About SimpleDiagrams", id:"about", data:"about"},
				{ label:"Register...", id:"registerApp", data:"registerApp"},
				{ label:"Preferences...", id:"preferences", data:"preferences"},
				{ type:"separator", id:"separator"},
				{ label:"Unregister", id:"unregister", data:"unregister"},
				{ type:"separator", id:"separator"},				
				{ label:"Import old v1.3 libraries database", id:"load_libraries_database",  data:"load_libraries_database" },
				{ type:"separator", id:"separator"},		
				{ label:"Quit", id:"quit_application", data:"quit_application", keyEquivalent:"q", controlKey:true }
			]		
			}
			ApplicationModel.menuDataArr.push(menuObj)
			
			
			
//			menuObj =	{ label:"File", id:"file", children:[
//				{ label:"New", id:"new_diagram", data:"new_diagram", controlKey:true, keyEquivalent:"n"},
//				{ label:"Open File...", id:"open_diagram", data:"open_diagram", keyEquivalent:"o", controlKey:true},
//				{ type:"separator", id:"separator"},
//				{ label:"Save", id:"save_diagram",  data:"save_diagram", enabled:false, keyEquivalent:"s", controlKey:true},
//				{ label:"Save As...", id:"save_diagram_as",  data:"save_diagram_as", enabled:false},
//				{ type:"separator", id:"separator"},
//				{ label:"Close", id:"close_diagram", data:"close_diagram", enabled:false, keyEquivalent:"w", controlKey:true}
//			]
//			}
//			ApplicationModel.menuDataArr.push(menuObj)
			
			
			menuObj =	{ label:"Diagram", id:"diagram",  enabled:false, children:[
				{ label:"Properties", id:"edit_properties",  data:"edit_properties",  keyEquivalent:"r", controlKey:true  },
				{ label:"Fit to background size", id:"fit_to_bg",  data:"fit_to_bg", keyEquivalent:"b", controlKey:true, shiftKey:true },
				{ type:"separator", id:"separator"},
				{ label:"Copy diagram to clipboard", id:"copy_diagram_to_clipboard",  data:"copy_diagram_to_clipboard", keyEquivalent:"c", controlKey:true , shiftKey:true },
				{ type:"separator", id:"separator"},
				{ label:"Export to PNG", id:"export_diagram_to_file", data:"export_diagram_to_file", keyEquivalent:"e", controlKey:true},
				{ label:"Export to Basecamp", id:"export_diagram_to_basecamp", data:"export_diagram_to_basecamp"},
				{ label:"Export to Yammer", id:"export_diagram_to_yammer", data:"export_diagram_to_yammer"}	
			]
			}
			ApplicationModel.menuDataArr.push(menuObj)
			
			
			menuObj =	{ label:"Edit", id:"edit", enabled:false, children:[						
				{ label:"Select All", id:"selectAll", data:"selectAll", keyEquivalent:"a", controlKey:true }	,						
				{ type:"separator", id:"separator"},
				{ label:"Undo", id:"undo", keyEquivalent:"z", controlKey:true, data:"undo"},
				{ label:"Redo", id:"redo", keyEquivalent:"y", controlKey:true, data:"redo" },				
				{ type:"separator", id:"separator"},
				{ label:"Cut", id:"cut", data:"cut"},
				{ label:"Copy",  id:"copy", data:"copy"},
				{ label:"Paste",  id:"paste", data:"paste"},
				
				{ type:"separator", id:"separator"},
				
				{ label:"Align", id:"align", children: 	[
					{ label:"Top", id:"alignTop", data:"alignTop" },
					{ label:"Middle", id:"alignMiddle", data:"alignMiddle" },
					{ label:"Bottom", id:"alignBottom", data:"alignBottom" },
					{ label:"Left", id:"alignLeft", data:"alignLeft"},
					{ label:"Center", id:"alignCenter", data:"alignCenter" },
					{ label:"Right", id:"alignRight", data:"alignRight" }
				]
				} 
			]
			}	
				
				/*
				{ label:"Cut", id:"cut", data:"cut", keyEquivalent:"x", controlKey:true, data:"cut"},
				{ label:"Copy",  id:"copy", data:"copy", keyEquivalent:"c", controlKey:true, data:"copy"},
				{ label:"Paste",  id:"paste", data:"paste", keyEquivalent:"v", controlKey:true, data:"paste"},
				*/
			ApplicationModel.menuDataArr.push(menuObj)
						
			menuObj =	{ label:"Libraries", id:"libraries", children:[
				{ label:"Manage libraries", id:"manage_local_libraries",  data:"manage_local_libraries", keyEquivalent:"j", controlKey:true}	,					
				{ type:"separator", id:"separator"},
				{ label:"Load library plugin", id:"load_library_plugin_from_file",  data:"load_library_plugin_from_file" },
				{ type:"separator", id:"separator"},
				{ label:"New custom library", id:"new_custom_library", data:"new_custom_library", keyEquivalent:"k", controlKey:true}
				
			]
			}
			ApplicationModel.menuDataArr.push(menuObj)
			
				
			menuObj =	{ label:"Annotations", id:"libraries", children:[
				{ label:"Edit sticky note default properties", id:"edit_sticky_note_default_properties",  data:"edit_sticky_note_default_properties"}	,	
				{ label:"Edit index card default properties", id:"edit_index_card_default_properties",  data:"edit_index_card_default_properties"}
				
			]
			}
			
			
			
			ApplicationModel.menuDataArr.push(menuObj)
			
			
			menuObj =	{ label:"View", id:"view", enabled:false, children:[
				{ label:"Zoom out", id:"zoom_out", data:"zoom_out", keyEquivalent:"-", controlKey:true},			
				{ label:"Zoom in", id:"zoom_in", data:"zoom_in", keyEquivalent:"=", controlKey:true}
			]
			}
			ApplicationModel.menuDataArr.push(menuObj)
			
			menuObj =	{ label:"Window", id:"window", children:[
				{ label:"Minimize / Maximize", id:"window_minimize", data:"window_minimize", keyEquivalent:"m", controlKey:true}	
			]
			}	
			ApplicationModel.menuDataArr.push(menuObj)
				
			
			menuObj =	{ label:"Help", id:"help", children:[
				{ label:"Get Help", id:"view_help", data:"view_help"}	
			]
			}	
			ApplicationModel.menuDataArr.push(menuObj)
				
			//DONE defining menu data
						
				
				
			// Read in fonts available on the user's machine and make available to controls 
			var fonts:Array = Font.enumerateFonts(true)
			fontsAC = new ArrayCollection(fonts)
				
			var dataSortField:SortField = new SortField();
			dataSortField.name = "fontName";
			
			var sortByFontNameSort:Sort = new Sort();
			sortByFontNameSort.fields = [dataSortField];

			fontsAC.sort = sortByFontNameSort
			fontsAC.refresh()
							
			version = getAppVersion()
				
		}
		
		public function get versionMajor():Number
		{
			if (version=="")
			{
				version = getAppVersion()
			}
			
			try
			{
				var major:Number = Number(version.split(".")[0])
				return major
			}
			catch(err:Error)
			{
				Logger.error("Error getting major version")
			}
			return 0
		}
		
		public function get versionMinor():Number
		{
			if (version=="")
			{
				version = getAppVersion()
			}
			
			try
			{
				var minor:Number = Number(version.split(".")[1])
				return minor
			}
			catch(err:Error)
			{
				Logger.error("Error getting major version")
			}
			return 0
		}
		
		protected function getAppVersion():String
		{
		
//			// Get the Application Descriptor File
//			var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
//				
//			// Define the Namespace (there is only one by default in the application descriptor file)
//			var air:Namespace = appXML.namespaceDeclarations()[0];
//			
//			// Use E4X To Extract the Needed Information
//			//this.airApplicationID = appXML.air::id;
//			return appXML.air::version;
//			//this.airApplicationName = appXML.air::name;
			
			return AboutInfo.VERSION;
		
		}
				
		public function get viewing():String
		{
			return _viewing
		}
		
		public function set viewing(v:String):void
		{
			_viewing = v
		}
				
		public function set currFileName(value:String):void
		{
//			FlexGlobals.topLevelApplication.title = value
		}
		
		public function get currFileName():String
		{
//			return FlexGlobals.topLevelApplication.title
			return '';
		}
		
		public function userAgreedToEULA():void
		{
//			var ba:ByteArray = new ByteArray()
//			ba.writeUTFBytes("true")
//			EncryptedLocalStore.setItem("userAgreedToEULA1.3", ba )
				
			//remember the date
//			var dateBA:ByteArray = new ByteArray()
//			dateBA.writeUTFBytes(new Date().time.toString())
//			EncryptedLocalStore.setItem("firstInstallDate", dateBA)
		}
		
		public function didUserAgreeToEULA():Boolean
		{
			return true;
//			var agreedBA:ByteArray = EncryptedLocalStore.getItem("userAgreedToEULA")
//			return (agreedBA && agreedBA.readUTFBytes(agreedBA.length) == "true")
		}
		
		
		public function get firstInstallDate():Date
		{
			//doon
			return null
//			var dateBA:ByteArray = EncryptedLocalStore.getItem("firstInstallDate")
//			return new Date(Number(dateBA.readUTFBytes(dateBA.length)))
		}
		
		public function fontAvailable(fontName:String):Boolean
		{
			for each (var font:Font in this.fontsAC)
			{
				if (font.fontName == fontName) return true
			}
			return false
		}
		
		

		
		
		
	}
}
