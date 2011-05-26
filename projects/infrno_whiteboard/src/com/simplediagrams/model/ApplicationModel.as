package com.simplediagrams.model
{
	import com.simplediagrams.util.Logger;
	
//	import flash.data.EncryptedLocalStore;
//	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
//	import flash.filesystem.File;
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
		public static const VERSION:String		= "Whiteboard v0.1.71";
		
		public static var menuDataArr:Array
		
		/* ******************** */
		/* DESKTOP MODE TOGGLE  */
		/* ******************** */
			
		public static var integratedMode:Boolean = false	
			
		/* ********************* */
		
		/**
		 * 
		 */
		public static var testMode:Boolean = false
			
		public static var alwaysCopyDB:Boolean = false
			
		public static const BASE_STORAGE_PATH:String ="Application Data/SimpleDiagrams/"
		public static const BASE_STORAGE_PATH_W7:String ="AppData/SimpleDiagrams/"
		public static const BASE_STORAGE_PATH_OSX:String ="SimpleDiagrams/"
				
		public static const DB_PATH:String = "db/simplediagrams.sqlite"
		public static const DB_BACKUP_DIR_PATH:String = "db/backup/"
			
		public static const REGISTRATION_URL:String = "http://simplediagrams.heroku.com/registrations/validate"		
		
		public static const VIEW_EULA:String = "eulaView"
		public static const VIEW_REGISTRATION:String = "registrationView"
		public static const VIEW_STARTUP:String = "startupView"
		public static const VIEW_DIAGRAM:String = "diagramView";
						
		public static const DEFAULT_SYSTEM_FAULT:String = "Arial"	
		
		public static var logFileDir:String = "logs"
		public static var logFileName:String = "application-log.txt"
		
			
		//public var dbPath:String = "db/simplediagram.sqlite"
				
		public var loggingOn:Boolean = false	
				
		public var menuEnabled:Boolean = true		
		public var version:String = ""		
		public var txtStatus:String = "" //status messages for startup dialog
		public var app:SimpleDiagrams = FlexGlobals.topLevelApplication as SimpleDiagrams
						
//		public var defaultFileDirectory:File
		public var diagramLoaded:Boolean = false
		
		public var fontsAC:ArrayCollection 
		
		protected var _viewing:String = VIEW_DIAGRAM
		
		
		//protected static var _baseStorageDir:File	
			
		public function ApplicationModel()
		{
			//define menu data			
			ApplicationModel.menuDataArr  = 	[]
			
			var menuObj:Object =	{label:"SimpleDiagrams", id:"simpleDiagrams", children: [
				{ label:"About SimpleDiagrams", id:"about", data:"about"},
				{ label:"Register...", id:"registration", data:"registration"},
				{ label:"Preferences...", id:"preferences", data:"preferences"},
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
				{ label:"Properties", id:"edit_properties",  data:"edit_properties" },
				{ type:"separator", id:"separator"},
				{ label:"Export to PNG", id:"export_diagram_to_file", data:"export_diagram_to_file"},
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
				{ label:"Cut", id:"cut", data:"cut", keyEquivalent:"x", controlKey:true },
				{ label:"Copy", id:"copy", data:"copy", keyEquivalent:"c", controlKey:true },
				{ label:"Paste", id:"paste", data:"paste", keyEquivalent:"v", controlKey:true },
				
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
			ApplicationModel.menuDataArr.push(menuObj)
			
			
			menuObj =	{ label:"Style", id:"style", enabled:false, children:[
				{ label:"Chalkboard", id:"chalkboard_style",  data:"chalkboard_style"},	
				{ label:"Whiteboard", id:"whiteboard_style", data:"whiteboard_style"},								
				{ label:"Basic", id:"basic_style",  data:"basic_style" }			
			]
			}
			ApplicationModel.menuDataArr.push(menuObj)
			
			
			menuObj =	{ label:"Libraries", id:"libraries", children:[
				{ label:"Manage libraries", id:"manage_local_libraries",  data:"manage_local_libraries" }	,
				{ label:"Load library plugin from file", id:"load_library_plugin_from_file",  data:"load_library_plugin_from_file" },
				{ type:"separator", id:"separator"},
				{ label:"New custom library", id:"new_custom_library", data:"new_custom_library"}
				
			]
			}
			
			
			
			ApplicationModel.menuDataArr.push(menuObj)
			
			
			menuObj =	{ label:"View", id:"view", enabled:false, children:[
				{ label:"Zoom out", id:"zoom_out", data:"zoom_out", keyEquivalent:"-", controlKey:true},			
				{ label:"Zoom in", id:"zoom_in", data:"zoom_in", keyEquivalent:":", controlKey:true}
			]
			}
			ApplicationModel.menuDataArr.push(menuObj)
			
			
			menuObj =	{ label:"Help", id:"help", children:[
				{ label:"Get Help", id:"view_help", data:"view_help"}	
			]
			}	
			ApplicationModel.menuDataArr.push(menuObj)
				
			//DONE defining menu data
			
			
			
			
			
			
//			defaultFileDirectory = File.userDirectory.resolvePath("SimpleDiagrams")
//						
//			if (!defaultFileDirectory.exists)
//			{
//				defaultFileDirectory.createDirectory()
//			}			
			
//			nagWindowTimer = new Timer(1000 * 60 * 5) 			
//			nagWindowTimer.addEventListener(TimerEvent.TIMER, onNagWindowTimer)
				
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
			
			return VERSION;
		
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
		
		
		public function userAgreedToEULA():void
		{
//			var ba:ByteArray = new ByteArray()
//			ba.writeUTFBytes("true")
//			EncryptedLocalStore.setItem("userAgreedToEULA", ba )
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
