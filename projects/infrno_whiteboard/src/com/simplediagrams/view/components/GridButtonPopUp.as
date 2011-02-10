package com.simplediagrams.view.components
{
	
	import com.simplediagrams.events.AlignEvent;
	import com.simplediagrams.events.GridEvent;
	
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
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.HSlider;
	import spark.components.HGroup;
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
	
	
	public class GridButtonPopUp extends SkinnableComponent
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
		public var buttonGroup:HGroup;		
		
		
		[SkinPart(required="true")]
		public var showGridCheckBox:CheckBox
		
		[SkinPart(required="true")]
		public var cellWidthSlider:HSlider
		
		[SkinPart(required="true")]
		public var alphaSlider:HSlider
		
		
		
		public function GridButtonPopUp()
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
		
		
		private var _isOpen:Boolean = false;
		private var _isOver:Boolean = false;
		private var _isOverPopup:Boolean = false;
		private var gap:Number = 0;
		
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
				
				cellWidthSlider.addEventListener(Event.CHANGE, onCellWidthSliderChange);
				alphaSlider.addEventListener(Event.CHANGE, onAlphaSliderChange);						
			}			
			
			
			if (instance == showGridCheckBox)
			{
				showGridCheckBox.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)
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
				
				cellWidthSlider.removeEventListener(Event.CHANGE, onCellWidthSliderChange);
				alphaSlider.removeEventListener(Event.CHANGE, onAlphaSliderChange);					
			}
			
			
			if (instance == showGridCheckBox)
			{
				showGridCheckBox.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)
			}
//			if (instance == cellWidthSlider)
//			{
//				cellWidthSlider.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)
//			}
			//			if (instance == alphaSlider)
			//			{
			//				alphaSlider.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)
			//			}
			
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
		
		public function onCellWidthSliderChange(event:Event):void {
			var evt:GridEvent;
			evt = new GridEvent(GridEvent.CELL_WIDTH);
			evt.cell_width = cellWidthSlider.value;
			dispatcher.dispatchEvent(evt)				
		}
		
		public function onAlphaSliderChange(event:Event):void {
			var evt:GridEvent;
			evt = new GridEvent(GridEvent.ALPHA);
			evt.alpha = alphaSlider.value;
			dispatcher.dispatchEvent(evt)				
		}
		
		
		public function onMouseDown(event:MouseEvent):void
		{			
			if (event.target==showGridCheckBox)
			{
				var evt:GridEvent;
				evt = new GridEvent(GridEvent.TOGGLE_GRID, true)
				dispatcher.dispatchEvent(evt)	
			}
		}
		
		public function openDropDown():void
		{
			_isOpen = true;
			addMoveHandlers();
			buttonGroup.addEventListener(MouseEvent.MOUSE_OVER, buttonHolder_mouseOverHandler);
			buttonGroup.addEventListener(MouseEvent.MOUSE_OUT, buttonHolder_mouseOutHandler);
			invalidateSkinState();
			this.dispatchEvent(new DropDownEvent(DropDownEvent.OPEN));
		}
		
		public function closeDropDown():void
		{
			_isOpen = false;
			_isOver = false;
			removeMoveHandlers();
			buttonGroup.removeEventListener(MouseEvent.MOUSE_OVER, buttonHolder_mouseOverHandler);
			buttonGroup.removeEventListener(MouseEvent.MOUSE_OUT, buttonHolder_mouseOutHandler);			
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
			trace("systemManager_mouseUpHandler, _isOverPopup:"+_isOverPopup);
			if (!_isOverPopup) {
					closeDropDown();
			}
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
		
		protected function buttonHolder_mouseOverHandler (event:Event):void {
			trace("buttonHolder_mouseOverHandler");			
			_isOverPopup = true;
			invalidateSkinState();
		}
		
		protected function buttonHolder_mouseOutHandler (event:Event):void {
			trace("buttonHolder_mouseOutHandler");			
			_isOverPopup = false;
			invalidateSkinState();
		}		
		
	}
}
