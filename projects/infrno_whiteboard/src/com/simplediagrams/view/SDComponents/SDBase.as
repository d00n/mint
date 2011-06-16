package com.simplediagrams.view.SDComponents
{
	import com.simplediagrams.controllers.RemoteSharedObjectController;
	import com.simplediagrams.events.ChangeDepthEvent;
	import com.simplediagrams.events.ConnectionEvent;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.util.Logger;
	
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.PropertyChangeEvent;
	import mx.managers.DragManager;
	import mx.managers.IFocusManagerComponent;
	
	import spark.components.Group;
	import spark.components.supportClasses.SkinnableComponent;

	[Bindable]
	public class SDBase extends SkinnableComponent implements IFocusManagerComponent 
	{	
		
		
		private var moveToBackCMI:ContextMenuItem
		private var moveBackwardCMI:ContextMenuItem
		private var moveForwardCMI:ContextMenuItem
		private var moveToFrontCMI:ContextMenuItem
		
		private var _sdID:String;
				
		public function SDBase()
		{
			super();
			
			this.doubleClickEnabled = true
			//this.addEventListener(DragEvent.DRAG_ENTER, onDragEnter, false, 0, true)
			//this.addEventListener(DragEvent.DRAG_DROP, onDragDrop, false, 0, true)
			//this.addEventListener(DragEvent.DRAG_EXIT, onDragExit, false, 0, true)
			//this.addEventListener(Event.COPY, onCopy, false, 0, true)
				
				
			//add all operations available to SDComponents' right click menu here
			moveToBackCMI = new ContextMenuItem("Move to back ", false, true)
			moveToBackCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveToBackSelected);

			moveBackwardCMI = new ContextMenuItem("Move backward ",false, true);
			moveBackwardCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveBackwardSelected);
			
			moveForwardCMI = new ContextMenuItem("Move forward ",false, true);
			moveForwardCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveForwardSelected);
			
			moveToFrontCMI = new ContextMenuItem("Move to front ",false, true);
			moveToFrontCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveToFrontSelected);
			
			var cm:ContextMenu = new ContextMenu()
				
			cm.builtInItems.forwardAndBack = false;
			cm.builtInItems.loop = false;
			cm.builtInItems.play = false;
			cm.builtInItems.print = false;
			cm.builtInItems.quality = false;
			cm.builtInItems.rewind = false;
			cm.builtInItems.save = false;
			cm.builtInItems.zoom = false;
			
			cm.customItems = [moveToBackCMI, moveBackwardCMI, moveForwardCMI, moveToFrontCMI]
		
			this.contextMenu = cm
			
		}
		
		public function get sdID():String
		{
			return _sdID;
		}
		public function set sdID(value:String):void
		{
			_sdID = value;
		}
		
		
		public function moveToBackSelected(event:ContextMenuEvent):void
		{
			var eventChangeDepth:ChangeDepthEvent = new ChangeDepthEvent(ChangeDepthEvent.MOVE_TO_BACK, true);
			eventChangeDepth.sdID = this.sdID;
			dispatchEvent(eventChangeDepth);
		}
		
		public function moveBackwardSelected(event:ContextMenuEvent):void
		{
			var eventChangeDepth:ChangeDepthEvent = new ChangeDepthEvent(ChangeDepthEvent.MOVE_BACKWARD, true);
			eventChangeDepth.sdID = this.sdID;
			dispatchEvent(eventChangeDepth);
		}
		
		
		public function moveForwardSelected(event:ContextMenuEvent):void
		{
			var eventChangeDepth:ChangeDepthEvent = new ChangeDepthEvent(ChangeDepthEvent.MOVE_FORWARD, true);
			eventChangeDepth.sdID = this.sdID;
			dispatchEvent(eventChangeDepth);
		}
		
		public function moveToFrontSelected(event:ContextMenuEvent):void
		{
			var eventChangeDepth:ChangeDepthEvent = new ChangeDepthEvent(ChangeDepthEvent.MOVE_TO_FRONT, true);
			eventChangeDepth.sdID = this.sdID;
			dispatchEvent(eventChangeDepth);
		}

		
		/*	
		protected function onCopy(event:Event):void
		{
			Logger.debug("onCopy() ", this)
			var evt:CopyEvent = new CopyEvent(CopyEvent.COPY, true)
			evt.objectModel = this.objectModel
			Logger.debug("model: " + objectModel, this)
			Swiz.dispatchEvent(evt)
		}		
		*/		
		protected function mouseEventHandler(event:Event):void
		{	
			Logger.debug("mouseEventHandler() event: " + event, this)
			
			//stop the click event to prevent the drawingboard from thinking the background was clicked and therefore it should remove all selections
			var mouseEvent:MouseEvent = event as MouseEvent;
       	    if(mouseEvent.type == MouseEvent.CLICK) 
       	    {
       	    	mouseEvent.stopPropagation()
       	    }
       	    
		}
		
		
			
		/* MODEL CONNECTION */
		
		protected function onModelChange(event:PropertyChangeEvent):void
		{
			switch( event.property )
            {
                case "x": 
                	x = event.newValue as Number
                	break
                	
                case "y":
                	y = event.newValue as Number
                	break
                	
                case "rotation": 
                	rotation = event.newValue as Number
                	break
                	
                case "width":      
                	width = event.newValue as Number
                	break
                	                            	
                case "height":    
                	height = event.newValue as Number
                	break
                	                            
                case "imageSource":
                	//TODO	
                	break
				
				case "depth":
					this.depth = event.newValue as Number;
					break
                                
                default: return;
            }
            positionDragCircle()
            
		}
		
		public function get objectModel():SDObjectModel
		{
			throw new Error("Abstract method")
		}
				
		
		/* ****************** */
		/* Drag handling code */
		/* ****************** */

		
		/* Commenting this code out for now b/c it's somehow causing this shape to turn color 
		   when somebody drags a shape from the library over top of this one when it's on the drawingboard.
			        
        public function onDragEnter(event:DragEvent):void 
        {
        	var dropTarget:UIComponent = event.currentTarget as UIComponent;        	
            if (event.dragSource.hasFormat('dragConnection') && this!=event.dragInitiator.parent)
            {   
            	//show visual feedback
            	setGlowFilter()
            	this.invalidateProperties()      	         
                DragManager.acceptDragDrop(dropTarget);
            }
        }
        
        private function setGlowFilter():void
        {
        	if (this.filters.length==0)
			{				
				this.filters = [this.getDropHoverFilter()]
			}
        }
        
        public function onDragDrop(event:DragEvent):void
        {
        	Logger.debug("onDragDrop()", this)
        	var evt:ConnectionEvent = new ConnectionEvent(ConnectionEvent.FINISH_CONNECTION_DRAG, true)
        	evt.endingComponent = this
        	dispatchEvent(evt)
        	this.filters = []
        	
        }
        
        public function onDragExit(event:DragEvent):void
        {
        	//this.filters = []
        }
		*/
		
		
        /*
        public function drawDragLine(event:MouseEvent):void
        {
        	var g:Graphics = this.graphics
        	g.clear()
        	g.lineStyle(3, 0x00CC00)
        	g.moveTo(_dragCircle.x, _dragCircle.y)
        	g.lineTo(this.mouseX, this.mouseY)
        }
        
        public function stopDrawDragLine(event:MouseEvent):void
        {
        	_dragProxy.removeEventListener(MouseEvent.MOUSE_MOVE, drawDragLine)
            _dragProxy.removeEventListener(MouseEvent.MOUSE_UP, stopDrawDragLine)
        	_dragProxy = null
        	this.graphics.clear()
        }
        */
        
  		protected function positionDragCircle():void
		{
			//throw new Error("Abstract method")			
		}
		
		private function getDropHoverFilter():BitmapFilter
		{
		
            var color:Number = 0xFFFFFF;
            var alpha:Number = 0.8;
            var blurX:Number = 35;
            var blurY:Number = 35;
            var strength:Number = 2;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;

            return new GlowFilter(color,
                                  alpha,
                                  blurX,
                                  blurY,
                                  strength,
                                  quality,
                                  inner,
                                  knockout);
        }

		public function destroy():void
		{
			
			//this.removeEventListener(DragEvent.DRAG_ENTER, onDragEnter)
			//this.removeEventListener(DragEvent.DRAG_DROP, onDragDrop)
			//this.removeEventListener(DragEvent.DRAG_EXIT, onDragExit)
				
			
			//add all operations available to SDComponents' right click menu here
			moveToBackCMI.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveToBackSelected);		
			moveBackwardCMI.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveBackwardSelected);
			moveForwardCMI.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveForwardSelected);
			moveToFrontCMI.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveToFrontSelected);	
			contextMenu = null
				
			//this.removeEventListener(Event.COPY, onCopy)
		}
	
		
		
	}
}