package com.simplediagrams.view.SDComponents
{
	import com.simplediagrams.events.ChangeDepthEvent;
	import com.simplediagrams.events.ConnectionEvent;
	import com.simplediagrams.events.LockEvent;
	import com.simplediagrams.events.RemoteSharedObjectEvent;
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
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.MoveEvent;
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
		private var lockCMI:ContextMenuItem
		private var unlockCMI:ContextMenuItem
		
		private var _sdID:String;
		public var isLocked:Boolean;
		private var _contextMenu:ContextMenu;
				
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
			
		  unlockCMI = new ContextMenuItem("Unlock",false, true);
		  unlockCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, unlockSelected);
				
		  lockCMI = new ContextMenuItem("Lock",false, true);
		  lockCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, lockSelected);
			
			_contextMenu = new ContextMenu()
				
			_contextMenu.builtInItems.forwardAndBack = false;
			_contextMenu.builtInItems.loop = false;
			_contextMenu.builtInItems.play = false;
			_contextMenu.builtInItems.print = false;
			_contextMenu.builtInItems.quality = false;
			_contextMenu.builtInItems.rewind = false;
			_contextMenu.builtInItems.save = false;
			_contextMenu.builtInItems.zoom = false;
			
			_contextMenu.customItems = [moveToBackCMI, moveBackwardCMI, moveForwardCMI, moveToFrontCMI, lockCMI, unlockCMI]
//			updateContextMenu();
		
			this.contextMenu = _contextMenu
		}
		
//		public function get contextMenuBaseDefaults():ContextMenu{
//			return _contextMenu;
//		}
		
//		private function updateContextMenu():void{
//			if (isLocked) {
//				_contextMenu.customItems = [moveToBackCMI, moveBackwardCMI, moveForwardCMI, moveToFrontCMI, unlockCMI]
//			} else {
//				_contextMenu.customItems = [moveToBackCMI, moveBackwardCMI, moveForwardCMI, moveToFrontCMI, lockCMI]
//			}
//		}
		
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
		
		public function lockSelected(event:ContextMenuEvent):void
		{
			var lockEvent:LockEvent = new LockEvent(LockEvent.LOCK, true);
			dispatchEvent(lockEvent);
		}

		public function unlockSelected(event:ContextMenuEvent):void
		{
			var lockEvent:LockEvent = new LockEvent(LockEvent.UNLOCK, true);
			dispatchEvent(lockEvent);
		}

		
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
                	                            
//                case "isLocked":    
//                	isLocked = event.newValue as Boolean;
//									updateContextMenu();
//                	break
                	                            
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
			moveToBackCMI.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveToBackSelected);		
			moveBackwardCMI.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveBackwardSelected);
			moveForwardCMI.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveForwardSelected);
			moveToFrontCMI.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, moveToFrontSelected);	
			lockCMI.removeEventListener(LockEvent.LOCK, lockSelected);	
			lockCMI.removeEventListener(LockEvent.UNLOCK, unlockSelected);	
			contextMenu = null				
		}
	
		
		
	}
}