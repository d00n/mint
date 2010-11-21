package com.simplediagrams.model
{;
	import com.roguedevelopment.objecthandles.*;
	import com.simplediagrams.events.SelectionEvent;
	import com.simplediagrams.view.SDComponents.SDLine;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.core.IFactory;
	import mx.events.PropertyChangeEvent;
	import mx.events.ScrollEvent;
	
	import spark.components.Group;
	

	public class SDObjectHandles extends ObjectHandles
	{
		
		
		[Inject]
		public var undoRedoManager:UndoRedoManager
		
		
		[Dispatcher]
		public function set dispatcher(value:IEventDispatcher):void
		{
			super._dispatcher = value
			selectionManager.dispatcher = value
		}
	
		
		//public var objectConnectors:ObjectConnectors 
		
		/*
		public function SDObjectHandles( dispatcher:IEventDispatcher, selectionManager:ObjectHandlesSelectionManager = null, handleFactory:IFactory = null)
		{
			//we pass in a blank sprite here since we'll set the container explicitly later on
			super(new Group(), dispatcher, selectionManager, handleFactory)	
		}
		*/
		public function SDObjectHandles()
		{
			//we pass in a blank sprite here since we'll set the container explicitly later on
			super(new Group())	
		}
		
		public function setContainer(s:Group):void
		{
			if (container)
			{
            	container.removeEventListener( ScrollEvent.SCROLL, onContainerScroll );
			}
			container = s
			container.addEventListener( ScrollEvent.SCROLL, onContainerScroll );
		}
		
		/* Making a separate group to hold the handles so the don't get in the way of re-ordering the actual SD objects*/
		public function setHandlesContainer(s:Group):void
		{
			handlesContainer = s
		}
		
		/** Overriding object handles registerComponent so we can apply some standard settings for different types of SDObjects */
		
		override public function registerComponent(dataModel:Object, visualDisplay:EventDispatcher, handleDescriptions:Array=null, captureKeyEvents:Boolean=true) : void
		{
			if (visualDisplay is SDLine)
			{
				handleDescriptions = []
			}									
			super.registerComponent(dataModel, visualDisplay, handleDescriptions, captureKeyEvents)				
		}
				
				
		public function unregisterComponentByModel( dataModel:Object ) : EventDispatcher
		{			
			var visualDisplay:EventDispatcher = visuals[dataModel]
			if( !visualDisplay) return null 
				
		    visualDisplay.removeEventListener( MouseEvent.MOUSE_DOWN, onComponentMouseDown);
			visualDisplay.removeEventListener( SelectionEvent.SELECTED, handleSelection );
			visualDisplay.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			dataModel.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
			
			delete visuals[dataModel]
			delete models[visualDisplay]
			
			return visualDisplay
		}
		
        
        public function removeAll():void
		{
			selectionManager.clearSelection()			
			//clear out all objects currently registered in ObjectHandles, except for the DragGeometry used for groups
			for(var key:Object in this.visuals)
			{
				if (key is DragGeometry)
				{
					continue
				}	
				this.unregisterComponent(EventDispatcher(key))
			}			
		}
		
		[Mediate(event="SelectionEvent.ADDED_TO_SELECTION")]
		public function onSelectionAdded( event:SelectionEvent ) : void
		{
			setupHandles();                 
		}
		
		
		[Mediate(event="SelectionEvent.REMOVED_FROM_SELECTION")]
		public function onSelectionRemoved( event:SelectionEvent ) : void
		{
			setupHandles();            
		}
		
		[Mediate(event="SelectionEvent.SELECTION_CLEARED")]
		public function onSelectionCleared( event:SelectionEvent ) : void
		{                       
			setupHandles();
			lastSelectedModel=null;
		}
		
		
		
		
		
	}
}