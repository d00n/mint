package com.simplediagrams.business
{
	
	import com.simplediagrams.model.ApplicationModel;
	import com.simplediagrams.model.BasecampModel;
	import com.simplediagrams.model.LibraryManager;
	import com.simplediagrams.model.SettingsModel;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.vo.RecentFileVO;
	
//	import flash.filesystem.*;
	
	import mx.collections.ArrayCollection;

	public class SettingsDelegate
	{
						
		private var sdSettingsXML:XML; 				// The settings XML data
//		public var sdSettingsFile:File; 			// The preferences file stored in application storage dir -- this is the working file
//		private var stream:FileStream; 				// The FileStream object used to read and write prefsFile data.
		
		[Inject]
		[Bindable]
		public var settingsModel:SettingsModel
		
		[Inject]
		[Bindable]
		public var applicationModel:ApplicationModel
		
		
		[Inject]
		[Bindable]
		public var basecampModel:BasecampModel
		
		[Inject]
		[Bindable]
		public var libraryManager:LibraryManager
			
		public function SettingsDelegate()
		{
//			//get settings xml path from ModelLocator
//			var sdSettingsFileDir:File = File.applicationStorageDirectory.resolvePath("settings")					
//			sdSettingsFile = sdSettingsFileDir.resolvePath("simplediagrams_settings.xml")	
//				
//			if(!sdSettingsFileDir.exists)
//			{
//				try
//				{
//					sdSettingsFileDir.createDirectory()
//				}
//				catch(error:Error)
//				{					
//					Logger.error("Couldn't create settings directory. Error : " + error,this)
//				}
//			}
//			
			
		}
		
		/** Load settings from .xml file and return a value object */
		public function loadSettings():void
		{
			Logger.debug("loadSettings()", this)
			loadXML()
		}
		
		/** Save settings to .xml file based on information passed in via value object */
		public function saveSettings():Boolean
		{	
			try
			{
				createAppSettingsXML(); 
				writeAppSettingsXML();
			}
			catch(err:Error)
			{
				Logger.error("couldn't save settings: " + err, this)
				return false
			}
			return true
		}
		
		/** Load xml from settings file */ 
		private function loadXML():void
		{
//			if (sdSettingsFile.exists) 
//			{
//				stream = new FileStream();
//    			stream.open(sdSettingsFile, FileMode.READ);
//    			try
//    			{
//    				sdSettingsXML = XML(stream.readUTFBytes(stream.bytesAvailable));
//			    	processXMLData();
//    			}
//    			catch(err:Error)
//    			{
//    				Logger.error(" error reading settings XML file. Reverting to internal settings defaults. Error: " + err, this)
//    			}    			
//				stream.close();
//			}
//			else
//			{
//				//if file doesn't exist, use internal defaults
//				Logger.debug(" no XML file exists for settings...leaving internal defaults.", this)
//				saveSettings()
//			}			
			
		}

		private function processXMLData():void
		{
//			var path:String = sdSettingsXML.defaultDirectory.@path	
//			
//			if (path!=null && path!="")
//			{
//				settingsModel.defaultDirectoryPath = path
//			}
//			
//			 path = sdSettingsXML.defaultExportDirectory.@path	
//			
//			if (path!=null && path!="")
//			{
//				settingsModel.defaultExportDirectoryPath = path
//			}	
//						
//			settingsModel.defaultImageStyle = sdSettingsXML.defaultStyle.@defaultImageStyle
//			settingsModel.defaultLineStyle = sdSettingsXML.defaultStyle.@defaultLineStyle
//			settingsModel.defaultEndLineStyle = sdSettingsXML.defaultStyle.@defaultEndLineStyle
//			settingsModel.defaultStartLineStyle = sdSettingsXML.defaultStyle.@defaultStartLineStyle 
//			settingsModel.defaultTextPosition = sdSettingsXML.defaultStyle.@defaultTextPosition 
//			settingsModel.appVersion = sdSettingsXML.appVersion;
//			
//			
//			//sticky note
//			var value:String = 	sdSettingsXML.defaultStyle.annotations.defaultStickyNote.backgroundColor
//			if (value!=null && value!="")
//			{				
//				settingsModel.defaultStickyNoteBGColor = uint(value)
//			}
//			value = sdSettingsXML.defaultStyle.annotations.defaultStickyNote.width
//			if (value!=null && value!="")
//			{				
//				settingsModel.defaultStickyNoteWidth = uint(value)
//			}
//			value = sdSettingsXML.defaultStyle.annotations.defaultStickyNote.height
//			if (value!=null && value!="")
//			{				
//				settingsModel.defaultStickyNoteWidth = uint(value)
//			}
//			
//			//index card
//			value = sdSettingsXML.defaultStyle.annotations.defaultIndexCard.backgroundColor 
//			if (value!=null && value!="")
//			{				
//				settingsModel.defaultIndexCardBGColor = uint(value)
//			}
//			value = sdSettingsXML.defaultStyle.annotations.defaultIndexCard.width
//			if (value!=null && value!="")
//			{				
//				settingsModel.defaultIndexCardWidth = uint(value)
//			}
//			value = sdSettingsXML.defaultStyle.annotations.defaultIndexCard.height
//			if (value!=null && value!="")
//			{				
//				settingsModel.defaultIndexCardHeight = uint(value)
//			}
//			value = sdSettingsXML.defaultStyle.annotations.defaultIndexCard.showTape
//			if (value!=null && value!="")
//			{				
//				settingsModel.defaultIndexCardShowTape = (value =="true")
//			}
//			
//			
//			
//			var height:Number = Number(sdSettingsXML.defaultDiagramSize.@height)
//			if (isNaN(height)==false && height > 0)
//			{				
//				settingsModel.defaultDiagramHeight = height
//			}
//			
//			var width:Number = Number(sdSettingsXML.defaultDiagramSize.@width)
//			if (isNaN(width)==false && width > 0)
//			{				
//				settingsModel.defaultDiagramWidth = width
//			}
//			
//			
//			if("promptDatabaseImport" in sdSettingsXML)
//			{
//				settingsModel.promptDatabaseImport = (sdSettingsXML.promptDatabaseImport == "true");
//			}
//			
//			var fontFamily:String = sdSettingsXML.defaultStyle.@defaultFontFamily 
//			if (applicationModel.fontAvailable(fontFamily))
//			{
//				settingsModel.defaultFontFamily = fontFamily
//			}
//			else
//			{
//				settingsModel.defaultFontFamily = ApplicationModel.DEFAULT_SYSTEM_FONT
//			}
//			
//			settingsModel.hideBGOnExport = (sdSettingsXML.export.@hideBackgroundOnExport=="true")
//			
//			
//			var lineWeight:uint = sdSettingsXML.defaultStyle.@defaultLineWeight
//			if (lineWeight<1) lineWeight = 0
//			if (lineWeight>100) lineWeight = 100
//			settingsModel.defaultLineWeight = lineWeight	
//				
//			
//			var pencilLineWeight:uint = sdSettingsXML.defaultStyle.@pencilLineWeight
//			if (pencilLineWeight<1) pencilLineWeight = 0
//			if (pencilLineWeight>100) pencilLineWeight = 100
//			settingsModel.defaultPencilLineWeight = pencilLineWeight	
//				
//			var symbolLineWeight:uint = sdSettingsXML.defaultStyle.@defaultSymbolLineWeight
//			if (symbolLineWeight<1) lineWeight = 0
//			if (symbolLineWeight>10) lineWeight = 10
//			settingsModel.defaultSymbolLineWeight = lineWeight	
//				
//			//read in previously opened files
//			for each (var fileXML:XML in sdSettingsXML.recentFiles.*)
//			{
//				var nativePath:String = fileXML.@nativePath
//				var recentFileVO:RecentFileVO = new RecentFileVO()
//				if (nativePath!="")
//				{
//					recentFileVO.data = nativePath
//					recentFileVO.label = new File(nativePath).name
//					settingsModel.recentDiagramsAC.addItem(recentFileVO)
//				}
//			}
//			
		}
		
				
		private function createAppSettingsXML():void 
		{
			sdSettingsXML = <appSettings>
								<defaultDirectory/>
								<defaultStyle/>
								<recentFiles/>
								<export/>
								<basecamp/>
							</appSettings>
			/*
			appSettingsXML.windowState.@width = stage.nativeWindow.width;
			appSettingsXML.windowState.@height = stage.nativeWindow.height;
			appSettingsXML.windowState.@x = stage.nativeWindow.x;
			appSettingsXML.windowState.@y = stage.nativeWindow.y;
			*/
			
			
			sdSettingsXML.appVersion = settingsModel.appVersion;
			sdSettingsXML.promptDatabaseImport = settingsModel.promptDatabaseImport;
			sdSettingsXML.defaultDirectory.@path = settingsModel.defaultDirectoryPath
			sdSettingsXML.defaultExportDirectory.@path = settingsModel.defaultExportDirectoryPath
			sdSettingsXML.defaultStyle.@defaultImageStyle = settingsModel.defaultImageStyle
			sdSettingsXML.defaultStyle.@defaultLineStyle = settingsModel.defaultLineStyle
			sdSettingsXML.defaultStyle.@defaultEndLineStyle = settingsModel.defaultEndLineStyle
			sdSettingsXML.defaultStyle.@defaultStartLineStyle = settingsModel.defaultStartLineStyle
			sdSettingsXML.defaultStyle.@defaultLineWeight = settingsModel.defaultLineWeight
			sdSettingsXML.defaultStyle.@defaultPencilLineWeight = settingsModel.defaultPencilLineWeight
			sdSettingsXML.defaultStyle.@defaultSymbolLineWeight = settingsModel.defaultSymbolLineWeight
			sdSettingsXML.defaultStyle.@defaultTextPosition = settingsModel.defaultTextPosition
			sdSettingsXML.defaultStyle.@defaultFontFamily = settingsModel.defaultFontFamily
			
			sdSettingsXML.defaultStyle.annotations.defaultStickyNote.backgroundColor = settingsModel.defaultStickyNoteBGColor
			sdSettingsXML.defaultStyle.annotations.defaultStickyNote.width = settingsModel.defaultStickyNoteWidth
			sdSettingsXML.defaultStyle.annotations.defaultStickyNote.height = settingsModel.defaultStickyNoteHeight
				
			sdSettingsXML.defaultStyle.annotations.defaultIndexCard.backgroundColor = settingsModel.defaultIndexCardBGColor
			sdSettingsXML.defaultStyle.annotations.defaultIndexCard.width = settingsModel.defaultIndexCardWidth
			sdSettingsXML.defaultStyle.annotations.defaultIndexCard.height = settingsModel.defaultIndexCardHeight
			sdSettingsXML.defaultStyle.annotations.defaultIndexCard.showTape = settingsModel.defaultIndexCardShowTape.toString()
				
				
			sdSettingsXML.defaultDiagramSize.@width = settingsModel.defaultDiagramWidth
			sdSettingsXML.defaultDiagramSize.@height = settingsModel.defaultDiagramHeight
			
			sdSettingsXML.export.@hideBackgroundOnExport = settingsModel.hideBGOnExport
				
			var len:uint = settingsModel.recentDiagramsAC.length
			for (var i:uint=0;i<len;i++)
			{
				var newChild:XML = <recentFile />
				newChild.@nativePath = settingsModel.recentDiagramsAC.getItemAt(i).data	
				sdSettingsXML.recentFiles.appendChild(newChild)		
			}
			
			
		}
		
		private function writeAppSettingsXML():void 
		{
//			Logger.debug("writing settings file to : " + sdSettingsFile.nativePath, this)
//				
//			var outputString:String = '<?xml version="1.0" encoding="utf-8"?>' +  File.lineEnding
//			outputString += sdSettingsXML.toXMLString();
//			//outputString = outputString.replace(/\n/g, File.lineEnding);
//			
//			stream = new FileStream()
//			stream.open(sdSettingsFile, FileMode.WRITE);
//			try
//			{
//				stream.writeUTFBytes(outputString);
//			}
//			catch(err:Error)
//			{
//				Logger.error("couldn't write settings file to : " + sdSettingsFile.nativePath, this)
//			}
//			stream.close();
		}

	}
}