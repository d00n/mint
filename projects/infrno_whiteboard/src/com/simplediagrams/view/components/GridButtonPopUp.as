package com.simplediagrams.view.components
{
	
	import com.simplediagrams.events.AlignEvent;
	import com.simplediagrams.events.GridEvent;
	import com.simplediagrams.events.RemoteSharedObjectEvent;
	import com.simplediagrams.model.DrawingBoardGridModel;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	import flashx.textLayout.formats.VerticalAlign;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.events.FlexEvent;
	import mx.events.SandboxMouseEvent;
	import mx.events.StateChangeEvent;
	import mx.graphics.SolidColor;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.HSlider;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.DropDownEvent;
	import spark.primitives.Rect;
	import spark.primitives.supportClasses.FilledElement;
	import com.simplediagrams.view.drawingBoard.DrawingBoardGrid;
	
	
	[SkinState("open")]
	[SkinState("over")]

	public class GridButtonPopUp extends SkinnableComponent
	{		
		[Dispatcher]
		public var dispatcher:IEventDispatcher
		
		[Inject]
		public var drawingBoardGridModel:DrawingBoardGridModel;
		
		[Inject]
		public var drawingBoardGrid:DrawingBoardGrid;
		
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
		
		override protected function getCurrentSkinState():String
		{
			return !enabled ? "disabled" : _isOpen ? "open" : _isOver ? "over" : "normal";
		}   
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == openButton)			{				
				openButton.addEventListener(MouseEvent.MOUSE_DOWN, dropDownButton_buttonDownHandler);
				openButton.addEventListener(MouseEvent.MOUSE_OVER, dropDownButton_buttonOverHandler);
				openButton.addEventListener(MouseEvent.MOUSE_OUT, dropDownButton_buttonOutHandler);									
			}			
						
			if (instance == alphaSlider)
				alphaSlider.addEventListener(Event.CHANGE, onAlphaSliderChange);
			
			if (instance == cellWidthSlider)
				cellWidthSlider.addEventListener(Event.CHANGE, onCellWidthSliderChange);
						
			if (instance == showGridCheckBox)
				showGridCheckBox.addEventListener(FlexEvent.VALUE_COMMIT, showGridCheckBox_onValueCommit);
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if (instance == openButton) 			{
				openButton.removeEventListener(FlexEvent.BUTTON_DOWN, dropDownButton_buttonDownHandler);
				openButton.removeEventListener(MouseEvent.MOUSE_OVER, dropDownButton_buttonOverHandler);
				openButton.removeEventListener(MouseEvent.MOUSE_OUT, dropDownButton_buttonOutHandler);
			}		
			
			if (instance == alphaSlider)
				alphaSlider.removeEventListener(Event.CHANGE, onAlphaSliderChange);		
			
			if (instance == cellWidthSlider)
				cellWidthSlider.removeEventListener(Event.CHANGE, onCellWidthSliderChange);
			
			if (instance == showGridCheckBox)
				showGridCheckBox.removeEventListener(FlexEvent.VALUE_COMMIT, showGridCheckBox_onValueCommit);
			
			super.partRemoved(partName, instance);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
		} 
				
		public function onCellWidthSliderChange(evt:Event):void {
			var event:GridEvent = new GridEvent(GridEvent.CELL_WIDTH);
			event.show_grid = showGridCheckBox.selected;
			event.alpha = alphaSlider.value;
			event.cell_width = cellWidthSlider.value;
			this.dispatcher.dispatchEvent(event);				
		}
		
		public function onAlphaSliderChange(evt:Event):void {
			var event:GridEvent = new GridEvent(GridEvent.ALPHA);
			event.show_grid = showGridCheckBox.selected;
			event.alpha = alphaSlider.value;
			event.cell_width = cellWidthSlider.value;
			this.dispatcher.dispatchEvent(event);				
		}
				
		public function showGridCheckBox_onValueCommit(evt:FlexEvent):void
		{			
			var event:GridEvent = new GridEvent(GridEvent.SHOW_GRID);
			event.show_grid = showGridCheckBox.selected;
			event.alpha = alphaSlider.value;
			event.cell_width = cellWidthSlider.value;
			this.dispatcher.dispatchEvent(event);	
		}	

		
		public function openDropDown():void
		{
			_isOpen = true;
			
			showGridCheckBox.selected = drawingBoardGridModel.showGrid;
			cellWidthSlider.value 		= drawingBoardGridModel.gridInterval;
			alphaSlider.value 				= drawingBoardGridModel.gridAlpha;
			
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
			
			// Now that we're done previewing settings, broadcast the final values
			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.GRID);
			rsoEvent.show_grid = showGridCheckBox.selected;
			rsoEvent.cell_width = cellWidthSlider.value;
			rsoEvent.alpha = alphaSlider.value;
			dispatcher.dispatchEvent(rsoEvent)	
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
			_isOverPopup = true;
			invalidateSkinState();
		}
		
		protected function buttonHolder_mouseOutHandler (event:Event):void {		
			_isOverPopup = false;
			invalidateSkinState();
		}		
		
	}
}
