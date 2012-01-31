package com.simplediagrams.business
{
	
	import com.simplediagrams.errors.SDObjectModelNotFoundError;
	import com.simplediagrams.events.LoadDiagramEvent;
	import com.simplediagrams.events.SaveDiagramEvent;
	import com.simplediagrams.model.*;
	import com.simplediagrams.model.libraries.ImageBackground;
	import com.simplediagrams.model.libraries.ImageShape;
	import com.simplediagrams.model.libraries.Library;
	import com.simplediagrams.model.libraries.LibraryItem;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.dialogs.NewDiagramDialog;
	import com.simplediagrams.view.dialogs.SaveBeforeActionDialog;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
//	import flash.filesystem.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.graphics.BitmapFillMode;
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	import mx.utils.UIDUtil;
	
	
	public class FileManager 
	{
		[Dispatcher]
		public var dispatcher:IEventDispatcher;
		
		[Inject]
		public var appModel:ApplicationModel;
		
		[Inject]
		public var diagramManager:DiagramManager;
		
		
		[Inject]
		public var settingsModel:SettingsModel
		
		[Inject]
		public var libraryManager:LibraryManager;
		
		[Inject]
		public var undoRedoManager:UndoRedoManager;
		
		[Inject]
		public var diagramDelegate:DiagramDelegate;
		
		public static const MODE_SAVE_BEFORE_NEW:String = "saveBeforeNewMode";
		public static const MODE_SAVE_BEFORE_CLOSE:String = "saveBeforeCloseMode";
		public static const MODE_SAVE_BEFORE_OPEN:String = "saveBeforeOpenMode";
		
		public var unavailableFontsArr:Array
		
		//these variables help keep state during controller actions that take place in more than one method
		public var saveBeforeActionDialog:SaveBeforeActionDialog		
		public var newDiagramDialog:NewDiagramDialog
		public var filePathToOpen:String  //which file to open after users closes current one
		public var actionAfterSave:String //remembers what to do after a saveBeforeAction event is processed
		
		protected var _currFilePath:String
		
//		protected var _diagramFile:File = File.documentsDirectory
		protected var _diagramFileXML:XML //the file's contents converted to an XML object
//		protected var _imageFile:File
		public var missingSymbolsArr:Array = []
		
		public function FileManager() 
		{
			
		}
		
		
		public function clearFilePaths():void
		{
			_currFilePath = ""
		}
		
		
		
		/* LOADING DIAGRAM */
		
		/* Browse to load diagram */
		
		public function browseToLoadDiagram():void
		{
		}
		
		protected function onBrowseToLoadDiagramResponse(event:Event):void
		{

		}
		
		protected function onBrowseToLoadDiagramCancel(event:Event):void
		{
//			var loadFile:File = event.target as File
//			loadFile.removeEventListener(Event.SELECT, onBrowseToLoadDiagramResponse)
//			loadFile.removeEventListener(Event.CANCEL, onBrowseToLoadDiagramCancel)
		}
		
		
		/* Load diagram directly (we know path) */
		
		public function loadDiagramFromFile(nativePath:String):void
		{
//			if (nativePath==null)
//			{
//				throw new Error("native path is null")
//			}
//			_diagramFile.nativePath = nativePath
//			_currFilePath = nativePath
//			settingsModel.defaultDirectoryPath = _diagramFile.nativePath.slice(0,_diagramFile.nativePath.lastIndexOf(File.separator))
//			
//			loadDiagram()
		}
		
		
		
		
		protected function loadDiagram():void
		{		

		}
		
		private function collectMissingSymbols(diagramModel:DiagramModel):void
		{
			//find missing symbols and attach to event
			var missingSymbolsArr:Array = [];
			var libItem:LibraryItem = libraryManager.getLibraryItem(diagramModel.background.libraryName, diagramModel.background.symbolName);
			var ms:MissingSymbolInfo;
			if(libItem == null)
			{
				ms = new MissingSymbolInfo()
				ms.symbolDisplayName = diagramModel.background.symbolName;
				ms.libraryName = diagramModel.background.libraryName;
				missingSymbolsArr.push(ms)
			}
			for each(var element:SDObjectModel in diagramModel.sdObjects)
			{
				var resourceLink:IResourceLink = element as IResourceLink;
				if(resourceLink && !(element is SDImageModel))
				{
					libItem = libraryManager.getLibraryItem(resourceLink.libraryName, resourceLink.symbolName);
					if(libItem == null)
					{
						ms = new MissingSymbolInfo()
						ms.symbolDisplayName = resourceLink.symbolName;
						ms.libraryName = resourceLink.libraryName;
						missingSymbolsArr.push(ms)
					}
				}
			}
			
//			var parsedEvt:LoadDiagramEvent = new LoadDiagramEvent(LoadDiagramEvent.DIAGRAM_PARSED, true)
//			parsedEvt.missingSymbolsArr = missingSymbolsArr
//			parsedEvt.nativePath = _currFilePath;
//			parsedEvt.fileName = new File(_currFilePath).name;
//			dispatcher.dispatchEvent(parsedEvt)
		}
		
		
		private function loadOldXmlFormat():void
		{
//			var fileStream:FileStream = new FileStream()
//			fileStream.open(_diagramFile, FileMode.READ)
//			var diagramText:String = fileStream.readUTFBytes(fileStream.bytesAvailable)
//			fileStream.close()
//			try
//			{
//				_diagramFileXML = XML(diagramText)
//			}
//			catch(error:Error)
//			{
//				Logger.error("Error parsing XML in file: " + _diagramFile.nativePath,this)
//				throw new Error("There was an error loading this diagram file. The XML in the file appears corrupted.")
//			}
//			loadSDXMLIntoDiagramModel(_diagramFileXML)					
//			
		}
		
		
		
		
		
		
		
		/* SAVING DIAGRAM */
		
		public function saveDiagram():void
		{											

		}
		
		
		public function saveDiagramAs():void
		{	

		}
		
		protected function onCancelSaveAs(event:Event):void
		{

		}
		
		protected function onSaveFileAsSelected(event:Event):void
		{
		}
		
		protected function saveDiagramToFile():void
		{
//			
//			if(_diagramFile.extension=="xml")
//			{
//				//for now lets leave it as such
//			}
//			else if(!_diagramFile.extension || _diagramFile.extension != "sdxml")
//			{
//				_diagramFile.url = _diagramFile.url + ".sdxml";
//			}
//			
//			diagramDelegate.exportDiagram(_diagramFile, diagramManager.diagramModel);
//			
//			Logger.debug("sending DIAGRAM_SAVED event for file path: " + _diagramFile.nativePath,this)
//			var savedEvent:SaveDiagramEvent = new SaveDiagramEvent(SaveDiagramEvent.DIAGRAM_SAVED, true)
//			savedEvent.nativePath = _diagramFile.nativePath
//			savedEvent.fileName = _diagramFile.name
//			dispatcher.dispatchEvent(savedEvent)	
		}
		
		
		/* CONVERTING FUNCTIONS */
		
		
		public function convertDiagramToXML():XML
		{			
			var s:XML = sdTemplateXML()	
			s.diagram.@version = appModel.version
			s.diagram.@width = diagramManager.diagramModel.width
			s.diagram.@height = diagramManager.diagramModel.height	
			s.diagram.name = diagramManager.diagramModel.name
			s.diagram.description = diagramManager.diagramModel.description
			
			//background
			var bg:SDBackgroundModel = diagramManager.diagramModel.background
			s.diagram.background.@libraryName = bg.libraryName
			s.diagram.background.@backgroundName = bg.symbolName
			s.diagram.background.@fillMode = bg.fillMode
			s.diagram.background.@tintColor = bg.tintColor
			s.diagram.background.@tintAlpha = bg.tintAlpha
			//save each of the SD objects
			for each (var sdObjModel:SDObjectModel in diagramManager.diagramModel.sdObjects)
			{			
				if (sdObjModel is SDLineModel)
				{
					var o:XML = <SDLine/>
					var lm:SDLineModel = SDLineModel(sdObjModel)
					o.startX = lm.startX
					o.startY = lm.startY
					o.endX = lm.endX
					o.endY = lm.endY
					o.bendX = lm.bendX
					o.bendY = lm.bendY
					o.lineWeight = lm.lineWeight
					o.startLineStyle = lm.startLineStyle
					o.endLineStyle = lm.endLineStyle
					if(lm.fromObject)
					{
						o.fromObject = lm.fromObject.id;
						o.fromPoint = lm.fromPoint.id;;
					}
					if(lm.toObject)
					{
						o.toObject = lm.toObject.id;
						o.toPoint = lm.toPoint.id;;
					}
				}
				else if (sdObjModel is SDPencilDrawingModel)
				{
					o = <SDPencilDrawing/>
					var pdm:SDPencilDrawingModel = SDPencilDrawingModel(sdObjModel)
					o.linePath = pdm.linePath
					o.lineWeight = pdm.lineWeight				
				}
				else if (sdObjModel is SDTextAreaModel)
				{
					o = <SDTextArea/>
					var tm:SDTextAreaModel = SDTextAreaModel(sdObjModel)
					o.styleName = tm.styleName										
					var txt:String = tm.text
					o.text = <text>{cdata(txt)}</text>
					o.fontWeight = tm.fontWeight
					o.fontSize = tm.fontSize
					o.textAlign = tm.textAlign
					o.fontFamily = tm.fontFamily
				}
				else if (sdObjModel is SDImageModel)
				{
					o = <SDImage/>
					var im:SDImageModel = SDImageModel(sdObjModel)
					var enc:PNGEncoder = new PNGEncoder()
					var b:Base64Encoder = new Base64Encoder();
					var libItem:ImageShape = libraryManager.getLibraryItem(im.libraryName, im.symbolName) as ImageShape;
					var imageData:ByteArray = libraryManager.getAssetData(libItem,libItem.path) as ByteArray;
					if (imageData && imageData.length>0)
					{
						//enc.encodeByteArray(im.imageData, im.width, im.height, false)			
						b.encodeBytes(imageData)
						o.imageData = b.toString()	
					}	
					else
					{
						o.imageData = 0
					}
					o.styleName = im.styleName	
				}
				else
				{
					o = <SDObject/>
				}
				
				o.@id = sdObjModel.id
				o.@x = sdObjModel.x
				o.@y = sdObjModel.y
				o.@height = sdObjModel.height
				o.@width = sdObjModel.width
				o.@rotation = sdObjModel.rotation
				o.@color = sdObjModel.color
				o.@colorizable = sdObjModel.colorizable.toString();
				o.@depth = sdObjModel.depth;
				if(sdObjModel.connectionPoints.length > 0)
				{
					var connectionPoints:XML = <connectionPoints/>;
					for each(var connectionPoint:ConnectionPoint in sdObjModel.connectionPoints)
					{
						var cPointXML:XML = <connectionPoint/>;
						cPointXML.id = connectionPoint.id;
						cPointXML.x = connectionPoint.x;
						cPointXML.y = connectionPoint.y;
						connectionPoints.appendChild(cPointXML);
					}
					o.appendChild(connectionPoints);
				}
				s.sdObjects.appendChild(o)
				
				
			}
			
			return s
			
		}
		
		
		
		
		
		
		public function loadSDXMLIntoDiagramModel(s:XML):void
		{	
			missingSymbolsArr = []
			unavailableFontsArr = []
			
			var fileVersion:String =  s.diagram.@version;
			var majorVersion:Number = fileVersion.split(".")[0];
			var minorVersion:Number = fileVersion.split(".")[1];
			var isEarlyVersion:Boolean = (fileVersion=="")
			var diagramModel:DiagramModel = new DiagramModel();
			
			//handle old way (v1.1) of setting background
			var styleName:String = s.diagram.@styleName;
			var bg:SDBackgroundModel =  new SDBackgroundModel();
			if (styleName=="chalkboardStyle")
			{
				bg.libraryName = "com.simplediagrams.backgroundLibrary.basic";
				bg.symbolName = "Chalkboard";
			}
			else if (styleName=="whiteboardStyle")
			{	
				bg.libraryName = "com.simplediagrams.backgroundLibrary.basic";
				bg.symbolName = "Whiteboard";
			}
			else if (styleName=="basicStyle")
			{
				bg.libraryName = "com.simplediagrams.backgroundLibrary.basic";
				bg.symbolName = "Blank";
				if (s.diagram.@baseBackgroundColor)
				{
					bg.tintColor = s.diagram.@baseBackgroundColor
				}
				bg.tintAlpha = 100
			}
			else
			{
				//new way of defining background
				var bgName:String = s.diagram.background.@backgroundName
				var bgLibraryName:String = s.diagram.background.@libraryName
				
				try
				{
					bg = new SDBackgroundModel();
					bg.libraryName = bgLibraryName;
					bg.symbolName= bgName;
				}
				catch(error:Error)
				{
					Logger.error("Couldn't find background library: " + bgLibraryName + " name: " + bgName, this)
					Alert.show("Couldn't find the '"+ bgName+"' background in any of your background libraries. Defaulting to the standard background.")
					//get default
					bg = libraryManager.getDefaultBackgroundModel()
				}
				var fillMode:String = s.diagram.background.@fillMode
				if (fillMode==BitmapFillMode.CLIP || fillMode==BitmapFillMode.REPEAT || BitmapFillMode.SCALE)
				{
					bg.fillMode = fillMode
				}
				
				var tintColor:Number = Number(s.diagram.background.@tintColor)
				if (isNaN(tintColor)==false)
				{
					bg.tintColor =tintColor
				}
				var tintAlpha:Number = Number(s.diagram.background.@tintAlpha)
				if (isNaN(tintColor)==false && tintAlpha >=0 && tintAlpha <=1)
				{
					bg.tintAlpha =tintAlpha
				}
			}
			
			
			diagramModel.background = bg		
			var width:Number = s.diagram.@width
			if (isNaN(width)||width<0)
			{
				width=20
			}
			diagramModel.width = s.diagram.@width
			
			var height:Number = s.diagram.@height
			if (isNaN(height)||height<0)
			{
				height=20
			}
			diagramModel.height = height
			diagramModel.name = s.diagram.name 
			diagramModel.description = s.diagram.description 
			
			var dec:Base64Decoder = new Base64Decoder()
			
			//if we have multiple objects with depth==0 (or depth is missing, which gives a value of 0)
			//we'll assign a -1, which will be reassigned to a proper depth by the diagramModel
			var itemWithDepthZeroAlreadyAdded:Boolean = false
			
			for each (var sdXML:XML in s.sdObjects.*)
			{				
				var sdObjModel:SDObjectModel				
				var isDefaultSymbolModel:Boolean = false	
				
				
				if (sdXML.name() == "SDSymbol" || sdXML.name()=="SDCustomSymbol")
				{					
					
					var libraryName:String = sdXML.@libraryName
					
					//correct for stupid case change when migrating from 1.2 to 1.3
					if (libraryName.indexOf("com.simplediagrams.shapelibrary")>-1)
					{
						var libNameArr:Array = libraryName.split(".")
						libNameArr[2]="shapeLibrary"
						libraryName = libNameArr.join(".")
					}
					
					var symbolName:String = sdXML.@symbolName
					
					try
					{
						var symbolModel:SDSymbolModel = new SDSymbolModel();
						
						
						var library:Library = libraryManager.getLibrary(libraryName)
						if (library==null)
						{
							//if library was custom library, we have to match the name against the new "ported" library's displayName
							library = libraryManager.getLibraryWithPrevName(libraryName)
							if (library)
							{
								libraryName = library.name //this will be a unique identifier in the 1.5 fashion
								symbolName = library.getSymbolNameByDisplayName(symbolName)
							}
							else
							{
								throw new SDObjectModelNotFoundError()
							}
						}					
						
						symbolModel.libraryName = libraryName;
						symbolModel.symbolName = symbolName;
						
						var txt:String = sdXML.text
						txt = txt.replace(/\r\n/gm, "\n");
						symbolModel.text = txt	
						
						sdObjModel = symbolModel;
					}
					catch(err:SDObjectModelNotFoundError)
					{						
						sdObjModel = libraryManager.getDefaultSDObjectModel()		
						isDefaultSymbolModel = true
					}
					
					if(!isDefaultSymbolModel)
					{
						
						var sdSymbolModel:SDSymbolModel = SDSymbolModel(sdObjModel)	
						var fontFamily:String = sdXML.fontFamily
						if (fontFamily=="")
						{
							sdSymbolModel.fontFamily = ApplicationModel.DEFAULT_SYSTEM_FONT
						}
						else
						{
							if(appModel.fontAvailable(fontFamily))
							{
								sdSymbolModel.fontFamily = fontFamily
							}
							else
							{
								sdSymbolModel.fontFamily = ApplicationModel.DEFAULT_SYSTEM_FONT
								unavailableFontsArr.push(fontFamily)
							}
							
						}
						
						sdSymbolModel.textAlign = sdXML.textAlign	
						sdSymbolModel.fontWeight = sdXML.fontWeight	
						sdSymbolModel.textPosition = sdXML.textPosition	
						sdSymbolModel.fontSize = sdXML.fontSize	
						sdSymbolModel.lineWeight = sdXML.lineWeight
						
					}
					
					
				}
				else if (sdXML.name() == "SDLine")
				{
					//this is one of those 'bad' lines that shows up sometimes in older diagrams
					//just adjust it and let user delete
					if (sdXML.startX==0 && sdXML.endX==0 && sdXML.startY==0 && sdXML.endY==0)
					{
						continue
					}
					
					sdObjModel = new SDLineModel()
					var lm:SDLineModel = SDLineModel(sdObjModel)
					lm.startX = sdXML.startX
					lm.startY = sdXML.startY 
					lm.endX = sdXML.endX 
					lm.endY = sdXML.endY 
					lm.bendX = sdXML.bendX
					lm.bendY = sdXML.bendY
					
					
						
					
					if(majorVersion <= 1 && minorVersion< 4)
					{
						var offX:Number = sdXML.@x;
						var offY:Number = sdXML.@y;
						
						lm.startX += offX;
						lm.startY += offY;
						lm.endX += offX;
						lm.endY += offY;
						lm.bendX += offX;
						lm.bendY += offY;
					}
					lm.lineWeight = sdXML.lineWeight 
					lm.startLineStyle = sdXML.startLineStyle
					lm.endLineStyle	= sdXML.endLineStyle 
				}				
				else if (sdXML.name() == "SDPencilDrawing")
				{
					sdObjModel = new SDPencilDrawingModel()
					var pdm:SDPencilDrawingModel = SDPencilDrawingModel(sdObjModel)
					pdm.linePath = sdXML.linePath
					pdm.lineWeight = sdXML.lineWeight				
				}
				else if (sdXML.name() == "SDTextArea")
				{
					sdObjModel = new SDTextAreaModel()
					var tm:SDTextAreaModel = SDTextAreaModel(sdObjModel)
					tm.styleName = sdXML.styleName						
					txt = sdXML.text
					txt = txt.replace(/\r\n/gm, "\n");
					tm.text = txt
					tm.fontSize = sdXML.fontSize
					tm.fontWeight = sdXML.fontWeight	
					tm.textAlign = sdXML.textAlign
					fontFamily = sdXML.fontFamily
					if (fontFamily=="")
					{
						tm.fontFamily = ApplicationModel.DEFAULT_SYSTEM_FONT
					}
					else
					{
						if(appModel.fontAvailable(fontFamily))
						{
							tm.fontFamily = fontFamily
						}
						else
						{
							tm.fontFamily = ApplicationModel.DEFAULT_SYSTEM_FONT
							unavailableFontsArr.push(fontFamily)
						}
						
					}
					
				}
				else if (sdXML.name() == "SDImage")
				{
					sdObjModel = new SDImageModel()
					var im:SDImageModel = SDImageModel(sdObjModel)		
					if (sdXML.imageData!="0")
					{
						dec.decode(sdXML.imageData)
						var imageData:ByteArray = dec.toByteArray();
						im.symbolName = UIDUtil.createUID();
						im.libraryName = "local";
						var libraryItem:ImageShape = new ImageShape();
						libraryItem.name = im.symbolName;
						libraryItem.path = im.symbolName + ".png";
						libraryManager.addToLocalLibrary(libraryItem, imageData);
					}
					else
					{
						im.symbolName = null
					}
					im.styleName = sdXML.styleName		
				}
				else
				{
					Logger.warn("unrecognized xml fragment: " + sdXML.toXMLString(), this)
				}
				
				//all models share these attributes	
				if("id" in sdXML)
				{
					sdObjModel.id = sdXML.@id;
				}
				sdObjModel.x = sdXML.@x 
				sdObjModel.y = sdXML.@y 
				sdObjModel.height = sdXML.@height 
				sdObjModel.width = sdXML.@width 
				sdObjModel.rotation = sdXML.@rotation;
				sdObjModel.depth = sdXML.@depth;
				if(sdXML.hasOwnProperty("connectionPoints"))
				{
					var points:Array = [];
					for each(var connecionPointXml:XML in sdXML.connectionPoints.connectionPoint)
					{
						var connectionPoint:ConnectionPoint = new ConnectionPoint(connecionPointXml.id, connecionPointXml.x, connecionPointXml.y);
						points.push(connectionPoint);
					}
					sdObjModel.connectionPoints = points;
				}
				if (!isDefaultSymbolModel)
				{					
					sdObjModel.color = sdXML.@color 
					sdObjModel.colorizable = (sdXML.@colorizable=="true")	
				}
				
				diagramModel.sdObjects.addItem(sdObjModel)	
			}		
			var j:int = 0;
			for each (sdXML in s.sdObjects.*)
			{				
				if (sdXML.name() == "SDLine")
				{	
					//this is one of those 'bad' lines that shows up sometimes in older diagrams
					//just adjust it and let user delete
					if (sdXML.startX==0 && sdXML.endX==0 && sdXML.startY==0 && sdXML.endY==0)
					{
						continue
					}
					
					var sdLineModel:SDLineModel = diagramModel.sdObjects.getItemAt(j) as SDLineModel;							
					if(sdXML.hasOwnProperty("fromObject") )
					{
						var from:SDObjectModel = diagramModel.getModelByID(sdXML.fromObject);
						sdLineModel.fromObject = from;
						sdLineModel.fromPoint = from.getConnectionPoint(sdXML.fromPoint);
					}
					if(sdXML.hasOwnProperty("toObject"))
					{
						var to:SDObjectModel = diagramModel.getModelByID(sdXML.toObject);
						sdLineModel.toObject = to;
						sdLineModel.toPoint = to.getConnectionPoint(sdXML.toPoint);
					}
				}
				j++;
			}
			diagramManager.openDiagram(diagramModel);
			
			
		}
		
		protected function sdTemplateXML():XML
		{
			var xml:XML = <SimpleDiagram>
							<diagram/>
							<sdObjects/>
						  </SimpleDiagram>
			return xml
			
			
		}
		
		protected function cdata(theURL:String):XML
		{
			var x:XML = new XML("<![CDATA[" + theURL + "]]>");
			return x;
		}
		
		protected var _currDiagramImageBA:ByteArray
		
		public function saveDiagramImageToFile(ba:ByteArray):void
		{
//			_currDiagramImageBA = ba
//			
//			if (appModel.currFileName=="New SimpleDiagram" || appModel.currFileName=="SimpleDiagrams")
//			{
//				var fileName:String = "my_simplediagram.png"
//			}
//			else
//			{
//				try
//				{
//					fileName = appModel.currFileName.split(".")[0] + ".png"
//				}
//				catch(error:Error)
//				{
//					fileName = "my_simplediagram.png"
//				}
//			}			
//			
//			var f:File = File.desktopDirectory
//			
//			if (settingsModel.defaultExportDirectoryPath!=null && settingsModel.defaultExportDirectoryPath!="")
//			{
//				f.nativePath = settingsModel.defaultExportDirectoryPath
//			}
//			
//			f.resolvePath(fileName)
//			
//			f.addEventListener(Event.SELECT,  onSaveDiagramImageAsSelected);
//			f.addEventListener(Event.CANCEL,  onCancelSaveDiagramImageAsSelected);
//			f.browseForSave("Save as .PNG")
		}		
		
		private function onCancelSaveDiagramImageAsSelected(e:Event):void
		{			
//			var saveFileRef:File =  e.target as File  
//			saveFileRef.removeEventListener(Event.SELECT,  onSaveDiagramImageAsSelected);
//			saveFileRef.removeEventListener(Event.CANCEL,  onCancelSaveDiagramImageAsSelected);
//			_currDiagramImageBA = null
		}
		
		
		private function onSaveDiagramImageAsSelected(e:Event):void
		{
//			var saveFileRef:File =  e.target as File    			
//			var stream:FileStream  = new FileStream()
//			
//			//make sure extension is .png...this is important b/c we get an error if user tries to save "test" image (no extension) where a "test" folder exists
//			var extension:String = saveFileRef.extension
//			if (extension != "png")
//			{
//				saveFileRef.nativePath = saveFileRef.nativePath + ".png"
//			}
//			
//			stream.open(saveFileRef,  FileMode.WRITE)
//			stream.writeBytes(_currDiagramImageBA, 0, _currDiagramImageBA.length)
//			stream.close()	
//			
//			saveFileRef.removeEventListener(Event.SELECT,  onSaveDiagramImageAsSelected);
//			saveFileRef.removeEventListener(Event.CANCEL,  onCancelSaveDiagramImageAsSelected);
//			
//			settingsModel.defaultExportDirectoryPath = saveFileRef.nativePath.slice(0,saveFileRef.nativePath.lastIndexOf(File.separator))	
//			
//			_currDiagramImageBA = null
		}
		
		
		
	}
}