package com.simplediagrams.model
{
	
	import com.roguedevelopment.objecthandles.ObjectHandles;
	import com.roguedevelopment.objecthandles.constraints.*;
	import com.simplediagrams.errors.DiagramIncompleteDueToMissingSymbolsError;
	import com.simplediagrams.errors.SymbolNotFoundError;
	import com.simplediagrams.events.ClearDiagramEvent;
	import com.simplediagrams.events.ConnectorAddedEvent;
	import com.simplediagrams.events.CreateNewDiagramEvent;
	import com.simplediagrams.events.DeleteSDComponentEvent;
	import com.simplediagrams.events.DiagramModelEvent;
	import com.simplediagrams.events.LoadDiagramEvent;
	import com.simplediagrams.events.RemoteSharedObjectEvent;
	import com.simplediagrams.events.StyleEvent;
	import com.simplediagrams.events.ToolEvent;
	import com.simplediagrams.model.mementos.SDObjectMemento;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.SDComponents.ISDComponent;
	import com.simplediagrams.view.SDComponents.SDBase;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.BitmapAsset;
	import mx.events.CollectionEvent;
	import mx.events.DynamicEvent;
	import mx.events.PropertyChangeEvent;
	import mx.utils.UIDUtil;
	
	import spark.components.Group;




	[Bindable]
	public class DiagramModel extends EventDispatcher
	{
	
	
		public static const SD_OBJECT_ADDED:String = "sdObjectAddedToDrawingBoardModel"
		public static const TOOL_CHANGED:String = "toolChanged"
		public static const SIZE_CHANGED:String = "toolChanged"
		
		public static const POINTER_TOOL:String = "pointerTool"
		public static const PENCIL_TOOL:String = "pencilTool"
		public static const TEXT_TOOL:String = "textTool"
		public static const PICTURE_TOOL:String = "pictureTool"
		public static const LINE_TOOL:String = "lineTool";
		public static const ZOOM_TOOL:String = "zoomTool";
		
		public static const DIAGRAM_BUILT:String = "diagramBuilt";
		
		[Dispatcher]
		public var dispatcher:IEventDispatcher;
		
		[Inject]
		public var settingsModel:SettingsModel;
		
		[Inject]
		public var sdObjectHandles:SDObjectHandles;
		
		[Inject]
		public var diagramStyleManager:DiagramStyleManager
				
		
		public var firstBuild:Boolean = true
			
			
		//background
		public var currSDBackgroundModel:SDBackgroundModel			
			
		protected var _name:String = ""
		protected var _description:String	
		protected var _styleName:String		
		protected var _horizontalScrollPosition:Number 
		protected var _verticalScrollPosition:Number
		protected var _width:Number = 2000
		protected var _height:Number = 1600;
		protected var _baseBackgroundColor:Number = 0xFFFFFF;	
		protected var _scaleX:Number = 1
		protected var _scaleY:Number = 1
		protected var _createdAt:Date = new Date()
		protected var _updatedAt:Date = new Date()
			
			
		protected var _isDirty:Boolean = false //flag for tracking user changes beyond saved state
		protected var _currToolType:String = POINTER_TOOL
		protected var _objectConnectors:ObjectConnectors 
		//protected var _diagramDAO:DiagramDAO 
		protected var _currColor:Number = 0xFFFFFF;
		
		public var sdObjectModelsAC:ArrayCollection 
	
		public function DiagramModel()
		{        	
			Logger.debug("DiagramModel() constructor")
		}
		
		[PostConstruct]
		public function createObjectHandles():void
		{
			sdObjectModelsAC = new ArrayCollection()	
			sdObjectModelsAC.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange)
			//var constraint:MaintainProportionConstraint = new MaintainProportionConstraint()
			//objectHandles.constraints.push(constraint)
		}
		
		public function onCollectionChange(event:CollectionEvent):void
		{
			if (event.items && event.items[0] is PropertyChangeEvent) 
			{
				//don't track this if the user just selected something
				if (event.items[0].property=="selected")
				{
					return
				}
				
				//don't track if image was loaded after buildDiagram() finished
				if (event.target && event.target[0] is SDImageModel)
				{
					if (event.items[0].property=="origWidth" || event.items[0].property=="origHeight")
					{
						return
					}
				}
				
			}
			
				
			_isDirty = true
		}
		
		public function initDiagramModel():void
		{	
										
			
			_currToolType = POINTER_TOOL
				
			dispatcher.dispatchEvent(new ClearDiagramEvent(ClearDiagramEvent.CLEAR_DIAGRAM, true))
			
			//clear out any existing stuff
			if (_objectConnectors)	_objectConnectors.removeAll()
			if (sdObjectHandles) sdObjectHandles.removeAll()
						
			//setup for new diagram
			sdObjectModelsAC.removeAll()	
			
				
			_isDirty = false	
		
		}
		
		public function getModelByID(sdID:String):SDObjectModel
		{
			var len:uint =sdObjectModelsAC.length
			for (var i:uint =0;i<len;i++)
			{
				if (SDObjectModel(sdObjectModelsAC.getItemAt(i)).sdID == sdID) 
				{
					return sdObjectModelsAC.getItemAt(i) as SDObjectModel
				}
			}
			Logger.debug("getModelByID() couldn't find model with sdID : " + sdID, this)
			return null
		}
		
		public function addToSelected(sdObjectModel:SDObjectModel):void
		{
			sdObjectHandles.selectionManager.addToSelected(sdObjectModel)
		}
		
		public function findModel(sdBase:SDBase):SDObjectModel
		{
			return sdObjectHandles.findModel(sdBase) as SDObjectModel
		}
		
		public function set selectedArray(objArr:Array):void
		{
			//clear the existing selection
			sdObjectHandles.selectionManager.clearSelection()
			
			for each (var obj:Object in objArr)
			{
				if (obj is SDObjectModel) this.addToSelected(obj as SDObjectModel)
			}
		}
		
		public function get selectedArray():Array
		{
			return sdObjectHandles.selectionManager.currentlySelected
		}
		
		public function get selectedVisuals():Array
		{
			return sdObjectHandles.getSelectedVisuals()
		}
		
		public function clearSelection():void
		{
			sdObjectHandles.selectionManager.clearSelection()
		}
		
			
		public function get isDirty():Boolean
		{
			return _isDirty
		}
		
		public function set isDirty(v:Boolean):void
		{
			_isDirty = v
		}
		
		
		public function setContainer(s:Group):void
		{
			sdObjectHandles.setContainer(s)
		}
		
		public function setHandlesContainer(s:Group):void
		{
			sdObjectHandles.setHandlesContainer(s)
		}
		
		/*
		public function onConnectorAdded(evt:ConnectorAddedEvent):void
		{
			dispatcher.dispatchEvent(evt)
		}
		*/
		
		
		
		
		/** builds the diagram from the sdObjectModels preloaded into the sdObjectModelsAC 
		   This is used when a diagram is loaded from file.
		*/
		public function buildDiagram():void
		{
			
			//clear out any existing stuff
			sdObjectHandles.removeAll()
			
			//change style 
			var styleEvent:StyleEvent = new StyleEvent(StyleEvent.CHANGE_STYLE, true)
			styleEvent.styleName = _styleName
			styleEvent.isLoadedStyle = true
			dispatcher.dispatchEvent(styleEvent)
			
			//add symbols to objectHandles	
			var modelsForMissingSymbolsArr:Array = []
			for each (var sdModel:SDObjectModel in sdObjectModelsAC)
			{				
				try
				{
					addComponentForModel(sdModel, false)
				}
				catch(error:SymbolNotFoundError)
				{					
					modelsForMissingSymbolsArr.push(sdModel)
				}
			}
			
				
			if (modelsForMissingSymbolsArr.length > 0)
			{
				var error:DiagramIncompleteDueToMissingSymbolsError = new DiagramIncompleteDueToMissingSymbolsError()
				error.modelsForMissingSymbolsArr = modelsForMissingSymbolsArr
				throw error
			}		
			
			dispatcher.dispatchEvent(new LoadDiagramEvent(LoadDiagramEvent.DIAGRAM_BUILT))
			
			isDirty = false	
		}
		
		
		/** Adds a new SDObjectModel to the diagram.
		 *  This function doesn't directly update the view, but indirectly launches an 
		 *  event (via the addComponentForModel function) indicating that a new model and it's related component
		 *  have been added. Views will listen for this event and update appropriately
		 * 
		 *  @param newSDObjectModel a new object model, to be used to create related component
		 *  @param fromFile indicates whether these are being added programmatically as file is read
		 *  @param isPaste  is this the results of a "paste" action
		 *  */
		 
		public function addSDObjectModel(newSDObjectModel:SDObjectModel, fromFile:Boolean = false, isPaste:Boolean = false):void
		{					
			Logger.info("addSDObjectModel() sdID="+newSDObjectModel.sdID,this);
			
			//if this objectModel doesn't have an id, give it a new unique one
			if (newSDObjectModel.sdID=="")
			{
				newSDObjectModel.sdID = getUniqueID()
			}
						
			sdObjectModelsAC.addItem(newSDObjectModel)
									
			//If we're adding this dynamically because of user interaction, rather than from a file, 	
			//we have to supply initial values for stuff like depth
			if (fromFile==false || newSDObjectModel.depth<0)
			{				
				newSDObjectModel.depth = this.sdObjectModelsAC.length - 1;
			}
			
			if (fromFile==false)
			{
				//set default color if model doesn't already have color
				if (newSDObjectModel.color == -1) 
				{
					newSDObjectModel.color = _currColor
				}
				var setSelected:Boolean = !isPaste
				addComponentForModel(newSDObjectModel, setSelected)		
				isDirty = true
			}
		
			// This is how add/delete/modify/cut/copy/paste actions hit the RSO
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.ADD_SD_OBJECT_MODEL);
			rsoEvent.changedSDObjectModelArray = new Array;
			rsoEvent.changedSDObjectModelArray.push(newSDObjectModel);
			dispatcher.dispatchEvent(rsoEvent);		
		}
		
		protected function addComponentForModel(sdModel:SDObjectModel, setSelected:Boolean = true):Object
		{
			//create visual object and add to ObjectHandles				
			var newSDComponent:ISDComponent = sdModel.createSDComponent()
			newSDComponent.objectModel = sdModel
			newSDComponent.sdID = sdModel.sdID;
				
			//Tell visual layer that new SDObjectModel has been added 
			var evt:DiagramModelEvent = new DiagramModelEvent(DiagramModelEvent.SD_OBJECT_ADDED_TO_MODEL, true)
			evt.newSDComponent = newSDComponent
			dispatcher.dispatchEvent(evt)
			
			//register with objecthandles 
			var captureKeyEvents:Boolean = !(sdModel is SDTextAreaModel)
			sdObjectHandles.registerComponent(sdModel, newSDComponent as EventDispatcher, null, captureKeyEvents)
				
			if (setSelected) sdObjectHandles.selectionManager.setSelected(sdModel)
						
			return newSDComponent
		}
		
		
		
		public function get objectConnectors():ObjectConnectors
		{
			return _objectConnectors;
		}

		public function set objectConnectors(v:ObjectConnectors):void
		{
			_objectConnectors = v;
		}
		
		public function get currToolType():String
		{
			return _currToolType;
		}

		public function set currToolType(toolType:String):void
		{
			if (toolType==_currToolType) return
						
			var evt:ToolEvent = new ToolEvent(ToolEvent.TOOL_CHANGED, true)
			evt.prevTool = _currToolType
			evt.currTool = toolType
			
			_currToolType = toolType
			
			dispatcher.dispatchEvent(evt)
		}
		
		
		
		public function get name():String
		{
			return _name
		}
		
		public function set name(v:String):void
		{
			_name = v
		}
		
		public function get updatedAt():Date
		{
			return _updatedAt
		}
		
		public function set updatedAt(v:Date):void
		{
			_updatedAt = v
		}
		
		public function get createdAt():Date
		{
			return _createdAt
		}
		
		public function set createdAt(v:Date):void
		{
			_createdAt = v
		}
		
		
		public function get description():String
		{
			return _description
		}
		
		public function set description(v:String):void
		{
			_description = v
		}
		
		
		public function get styleName():String
		{
			return _styleName
		}
		
		public function set styleName(v:String):void
		{
			_styleName = v
		}
		
		public function get verticalScrollPosition():Number
		{
			return _verticalScrollPosition
		}
		
		public function set verticalScrollPosition(v:Number):void
		{
			_verticalScrollPosition = v
		}
		
		public function get width():Number
		{
			return _width
		}
		
		public function set width(v:Number):void
		{
			_width = v
		}
		
		public function get height():Number
		{
			return _height
		}
		
		public function set height(v:Number):void
		{
			_height = v
		}	
		
		public function get baseBackgroundColor():Number
		{
			return _baseBackgroundColor
		}
		
		public function set baseBackgroundColor(v:Number):void
		{
			_baseBackgroundColor = v
		}
		
		
		
		   
		
		/* Can't use getters and setters for color since often same value is sent as held internally.
		In this case the setter wouldn't get called*/
		public function getColor():Number
		{
			return _currColor
		}
		public function setColor(v:Number, changeShapeColors:Boolean=false):void
		{
			_currColor = v
		}
		
		public function changeAllShapesToDefaultColor():void
		{	
			for each (var objModel:SDObjectModel in sdObjectModelsAC)
			{
				objModel.color = _currColor
			}
		}
		
		
		public function get horizontalScrollPosition():Number
		{
			return _horizontalScrollPosition
		}
		
		public function set horizontalScrollPosition(v:Number):void
		{
			_horizontalScrollPosition = v
		}
		
		public function get scaleX():Number
		{
			return _scaleX
		}
		
		public function set scaleX(v:Number):void
		{
			_scaleX = v
		}
		
		public function get scaleY():Number
		{
			return _scaleY
		}
		
		public function set scaleY(v:Number):void
		{
			_scaleY = v
		}
		
			
		
		public function deleteSelectedSDObjectModels():void
		{			
			//remove all SD objects that are currently selected
			
			var sdObjectModelsArr:Array = sdObjectHandles.selectionManager.currentlySelected
			
			for each (var sdObjectModel:SDObjectModel in sdObjectModelsArr)
			{
				deleteSDObjectModel(sdObjectModel)
			}
			
			sdObjectHandles.selectionManager.clearSelection()   			
			isDirty = true
		}
		
		
		public function deleteSDObjectModel(sdObjectModel:SDObjectModel):void
		{			
			//remove from the DrawingBoardModel...making sure to delete the model and the SDComponent
			var len:uint = sdObjectModelsAC.length
			for (var i:uint=0;i<len;i++)			 
			{
				if (sdObjectModelsAC.getItemAt(i) as SDObjectModel == sdObjectModel)
				{
					sdObjectHandles.unregisterComponent(sdObjectModel.sdComponent as EventDispatcher)  	//remove from object handles
					sdObjectModelsAC.removeItemAt(i)													//remove from our local arrayCollection
					packDepthSlots(sdObjectModel.depth);
					break	
				}
			}
			
			// todo: this should be dispatched after all the deletes are done
			// PasteCommand.redo() and ClipboardController.onPaste() call this in a loop
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.UPDATE_DEPTHS);
			rsoEvent.changedSDObjectModelArray = sdObjectModelsAC.toArray();
			dispatcher.dispatchEvent(rsoEvent);
				
			var evt:DeleteSDComponentEvent = new DeleteSDComponentEvent(DeleteSDComponentEvent.DELETE_FROM_DIAGRAM, true)
			evt.sdComponent = sdObjectModel.sdComponent
			dispatcher.dispatchEvent(evt)
			
			sdObjectHandles.selectionManager.clearSelection()   			
			isDirty = true
		}
		
		
		public function packDepthSlots(depth:int): void {
			var len:uint = sdObjectModelsAC.length
			for (var i:uint=0;i<len;i++)			 
			{
				var sdObjectModel:SDObjectModel = sdObjectModelsAC.getItemAt(i) as SDObjectModel;
				if (sdObjectModel.depth > depth)
				{
					sdObjectModel.depth--;	
				}
			}			
		}
						
		public function deleteSDObjectModelByID(id:String):void
		{
			var sdObjectModel:SDObjectModel = this.getModelByID(id)
			if (sdObjectModel!=null)
			{
				deleteSDObjectModel(sdObjectModel)
			}
		}
	
		/* Do all things necessary to init DiagramModel for a new diagram */		
		public function createNew():void
		{
			
				
			initDiagramModel()	
									
			//launch the loaded event before actually building the diagram
			//b/c on the first load, the DrawingBoard stage won't be set up correctly.			
			var evt:CreateNewDiagramEvent = new CreateNewDiagramEvent(CreateNewDiagramEvent.NEW_DIAGRAM_CREATED, true)
			dispatcher.dispatchEvent(evt)			
			
		}		
		
		public function updateUpdatedAt():void
		{			
			_updatedAt = new Date()
		}
		
				
		public function get numSDObjects():Number
		{
			return this.sdObjectModelsAC.length
		}
	
		[Mediate(event="StyleEvent.STYLE_CHANGED")]
		public function onStyleChanged(event:StyleEvent):void
		{
			_styleName = event.styleName
			_currColor = diagramStyleManager.defaultSymbolColor
		}
		
		protected function getUniqueID():String
		{
			return UIDUtil.createUID();
		}
		
		
		
	}
}