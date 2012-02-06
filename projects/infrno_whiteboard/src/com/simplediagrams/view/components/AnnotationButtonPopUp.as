////////////////////////////////////////////////////////////////////////////////
//
//  Andy Andreas Hulstkamp. AH 2009.
//  Flex 4 beta.
//
////////////////////////////////////////////////////////////////////////////////

package com.simplediagrams.view.components
{
	
	import com.simplediagrams.events.AlignEvent;
	import com.simplediagrams.events.DrawingBoardItemDroppedEvent;
	import com.simplediagrams.events.ToolPanelEvent;
	import com.simplediagrams.model.tools.Tools;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	import flashx.textLayout.formats.VerticalAlign;
	
	import mx.events.FlexEvent;
	import mx.events.SandboxMouseEvent;
	import mx.graphics.SolidColor;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.VGroup;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.DropDownEvent;
	import spark.primitives.Rect;
	import spark.primitives.supportClasses.FilledElement;
	
						
	/**
	 *  Open State of the DropDown component
	 */
	[SkinState("open")]
	
	/**
	 * Over State of the DropDown component.
	 * When the mouse is over the open element
	 */
	[SkinState("over")]
	
		
	public class AnnotationButtonPopUp extends SkinnableComponent
	{
		
		
		[Dispatcher]
		public var dispatcher:IEventDispatcher

		/**
		 * 
		 */
		[SkinPart(required="true")]
		public var dropDown:Group;
		
		[SkinPart(required="true")]
		public var openButton:Button
		
		[SkinPart(required="true")]
		public var buttonGroup:VGroup;
		
		
		[SkinPart(required="true")]
		public var btnTextArea:Button
		
		[SkinPart(required="true")]
		public var btnStickyNote:Button
		
		[SkinPart(required="true")]
		public var btnIndexCard:Button
		

		
		
		
				
		
		public function AnnotationButtonPopUp()
		{
			super();
			init();
		}
		
		/**
		 * Sets up the Component. Called from the constructor 
		 * 
		 */
		protected function init():void
		{
			this.useHandCursor = true;
			this.buttonMode = true;
		}
		
				
		//stores state for open of dropdown
		private var _isOpen:Boolean = false;
		
		//stores state for button over
		private var _isOver:Boolean = false;
		
		//The gap between the rating icons fetched from the skin
		private var gap:Number = 0;
		
				
		/**
		 *  @private
		 */
		override public function set enabled(value:Boolean):void
		{
			if (value == enabled)
				return;
			
			super.enabled = value;
			if (openButton)
				openButton.enabled = value;
		}
		
		/**
		 *  Leverage the SkinStates
		 */ 
		override protected function getCurrentSkinState():String
		{
			return !enabled ? "disabled" : _isOpen ? "open" : _isOver ? "over" : "normal";
		}   
		
		/**
		 * Overriden.
		 * Add behaviours to the SkinParts and setup the containers with the icons
		 *  @private
		 */ 
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == openButton)
			{				
				openButton.addEventListener(MouseEvent.MOUSE_DOWN, dropDownButton_buttonDownHandler);
				openButton.addEventListener(MouseEvent.MOUSE_OVER, dropDownButton_buttonOverHandler);
				openButton.addEventListener(MouseEvent.MOUSE_OUT, dropDownButton_buttonOutHandler);
			}
			
			
			if (instance == btnTextArea)
			{
				btnTextArea.addEventListener(MouseEvent.MOUSE_DOWN, onTextButton)
			}
			if (instance == btnStickyNote)
			{
				btnStickyNote.addEventListener(MouseEvent.MOUSE_DOWN, onTextButton)
			}
			if (instance == btnIndexCard)
			{
				btnIndexCard.addEventListener(MouseEvent.MOUSE_DOWN, onTextButton)
			}
		
		}
		
		/**
		 * Overriden.
		 * Cleans up the skins-parts when they are removed by the framework.
		 * Remove EventListeners that have been added when part was added
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if (instance == openButton) 
			{
				openButton.removeEventListener(FlexEvent.BUTTON_DOWN, dropDownButton_buttonDownHandler);
				openButton.removeEventListener(MouseEvent.MOUSE_OVER, dropDownButton_buttonOverHandler);
				openButton.removeEventListener(MouseEvent.MOUSE_OUT, dropDownButton_buttonOutHandler);
			}
			
			if (instance == btnTextArea)
			{
				btnTextArea.removeEventListener(MouseEvent.MOUSE_DOWN, onTextButton)
			}
			if (instance == btnStickyNote)
			{
				btnStickyNote.removeEventListener(MouseEvent.MOUSE_DOWN, onTextButton)
			}
			if (instance == btnIndexCard)
			{
				btnIndexCard.removeEventListener(MouseEvent.MOUSE_DOWN, onTextButton)
			}
			
			super.partRemoved(partName, instance);
		}
		
		/**
		 * Overriden.
		 * Manage the properties that are used and centralize updates here.
		 *  @private
		 */ 
		override protected function commitProperties():void
		{
			super.commitProperties();
		}  
		
		//--------------------------------------------------------------------------
		//
		//  New Methods
		//
		//--------------------------------------------------------------------------   
		
		
		public function onTextButton(event:MouseEvent):void
		{
			
			if (event.target==btnTextArea)
			{
				var toolPanelEvent:ToolPanelEvent = new ToolPanelEvent(ToolPanelEvent.TOOL_SELECTED, true);
				toolPanelEvent.toolTypeSelected = Tools.TEXT_TOOL;
  			dispatcher.dispatchEvent(toolPanelEvent)	;
			}
			else if (event.target==btnStickyNote)
			{
				var dbidEvent:DrawingBoardItemDroppedEvent = new DrawingBoardItemDroppedEvent(DrawingBoardItemDroppedEvent.STICKY_NOTE_ADDED, true)      
				dbidEvent.dropX = 40;
				dbidEvent.dropY = 40;
  			dispatcher.dispatchEvent(dbidEvent)	;
			}
			else if (event.target==btnIndexCard)
			{
				dbidEvent = new DrawingBoardItemDroppedEvent(DrawingBoardItemDroppedEvent.INDEX_CARD_ADDED, true)      
				dbidEvent.dropX = 40;
				dbidEvent.dropY = 40;
  			dispatcher.dispatchEvent(dbidEvent)	;
			}
			
		}
		
		public function openDropDown():void
		{
			_isOpen = true;
			addMoveHandlers();
			invalidateSkinState();
			this.dispatchEvent(new DropDownEvent(DropDownEvent.OPEN));
		}
		
		public function closeDropDown():void
		{
			_isOpen = false;
			_isOver = false;
			removeMoveHandlers();
			invalidateSkinState();
			this.dispatchEvent(new DropDownEvent(DropDownEvent.CLOSE));
		}
				
		protected function addMoveHandlers():void 
		{
			openButton.systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler);
			openButton.systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemManager_mouseUpHandler);
		}
		
		protected function removeMoveHandlers():void 
		{
			openButton.systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler);
			openButton.systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemManager_mouseUpHandler);
		}
		
			
		protected function systemManager_mouseUpHandler(event:Event):void {
			closeDropDown();
		}
		
		protected function dropDownButton_buttonDownHandler (event:Event):void {
			if (_isOpen) 
			{
				closeDropDown();
			} 
			else 
			{
				openDropDown();
			}
		}
		
		protected function dropDownButton_buttonOverHandler (event:Event):void {
			_isOver = true;
			invalidateSkinState();
		}
		
		protected function dropDownButton_buttonOutHandler (event:Event):void {
			_isOver = false;
			invalidateSkinState();
		}
	}
}
