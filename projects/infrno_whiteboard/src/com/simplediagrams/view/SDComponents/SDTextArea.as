package com.simplediagrams.view.SDComponents
{
	import com.simplediagrams.controllers.RemoteSharedObjectController;
	import com.simplediagrams.events.EditSDComponentTextEvent;
	import com.simplediagrams.events.RemoteSharedObjectEvent;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDTextAreaModel;
	import com.simplediagrams.util.Logger;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.binding.utils.*;
	import mx.controls.SWFLoader;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Group;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.RichEditableText;
	import spark.components.TextArea;
	import spark.events.TextOperationEvent;
	
	[SkinState("normal")] 
	[SkinState("selected")] 
	[Bindable]
	public class SDTextArea extends SDBase implements ISDComponent
	{
		
		[SkinPart(required="true")]		
		public var mainText:RichEditableText;
		
		[SkinPart(required="false")]		
		public var backgroundImage:SWFLoader;
		
		[SkinPart(required="false")]		
		public var grpClickMsg:Group;
		
		public var text:String
		public var fontColor:Number
		public var fontWeight:String
		public var fontSize:Number
		public var textAlign:String
		public var fontFamily:String
		public var backgroundColor:uint 
		public var showTape:Boolean = true
		
		public var textAreaEnabled:Boolean = false
		
		protected var _cwTextArea:ChangeWatcher
		protected var _model:SDTextAreaModel;
		
		public function SDTextArea()
		{
			this.setStyle("skinClass", Class(SDTextAreaBasicSkin))  
		}
		
		
		
		public function set objectModel( objectModel:SDObjectModel ) : void
		{     
			_model = SDTextAreaModel(objectModel) 
			
			x = _model.x;
			y = _model.y;            
			
			width= _model.width;
			height= _model.height;
			text = _model.text			
			fontColor = _model.color
			fontWeight = _model.fontWeight
			fontFamily = _model.fontFamily
			fontSize = _model.fontSize
			textAlign = _model.textAlign
			rotation = _model.rotation
			depth = _model.depth;				
			backgroundColor = _model.backgroundColor
			showTape = _model.showTape
			setSkinStyle()
			
			_model.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
			
			
		}
		
		protected override function getCurrentSkinState():String
		{
			return "normal";
			/*
			if (_model && _model.selected)
			{
			return "selected"
			}
			else
			{
			return "normal"
			}*/
		}
		
		override public function get objectModel():SDObjectModel
		{
			return _model
		}
		
		
		
		override protected function onModelChange(event:PropertyChangeEvent):void
		{
			Logger.info("onModelChange",this);
			super.onModelChange(event)
			
			switch(event.property)
			{    
				
				case "selected":    			
					
					
					if (event.newValue==false)
					{
					} 
					
					invalidateSkinState()
					break
				
				case "fontSize":
					fontSize = Number(event.newValue)
					break
				
				case "color":
					fontColor = Number(event.newValue)
					break
				
				case "textAlign":
					textAlign = String(event.newValue)
					break
				
				case "fontWeight":
					fontWeight = String(event.newValue)
					break
				
				case "fontFamily":
					fontFamily = String(event.newValue)
					break
				
				case "skinStyle":
					setSkinStyle()    				
					break
				
				case "backgroundColor":
					backgroundColor = uint(event.newValue)
					break
				
				case "showTape":
					showTape = event.newValue
					break
				
				case "text":
					text = String(event.newValue)
					this.invalidateProperties()
					
			}
			
		}
		
		
		/* Set a skin based on the style defined in the model */
		protected function setSkinStyle():void
		{
			switch(_model.styleName)
			{
				case SDTextAreaModel.NO_BACKGROUND:
					this.setStyle("skinClass", Class(SDTextAreaBasicSkin))
					break
				
				case SDTextAreaModel.PAPER_WITH_TAPE:
					this.setStyle("skinClass", Class(SDTextAreaPaperWithTapeSkin))
					break
				
				case SDTextAreaModel.STICKY_NOTE:
					this.setStyle("skinClass", Class(SDTextAreaStickyNoteSkin))
					break
				
				case SDTextAreaModel.INDEX_CARD:
					this.setStyle("skinClass", Class(SDTextAreaIndexCardSkin))
					break
				
				default:
					Logger.warn("setSkinStyle() unrecognized style :  " + _model.styleName, this)
			}
			this.invalidateSkinState()
			this.invalidateDisplayList()        	
			
		}      
		
		
		
		
		public function onDoubleClick():void
		{
			setTextFocus()
		}
		
		public function setTextFocus():void
		{
			textAreaEnabled = true
			mainText.selectAll()
			mainText.setFocus()
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);		 
			
			if(instance == mainText)
			{				
				
				mainText.addEventListener(FlexEvent.UPDATE_COMPLETE, onTextAreaChange)
				mainText.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)				
				mainText.addEventListener(FocusEvent.FOCUS_OUT, onTextAreaFocusOut)
				//var t:Timer = new Timer(100)
				//t.addEventListener(TimerEvent.TIMER, setFirstTextFocus, false, 0, true)
				//t.start()
			}
			
		}
		
		
		protected function setFirstTextFocus(event:TimerEvent):void
		{
			Timer(event.target).stop()
			event.target.removeEventListener(TimerEvent.TIMER, setFirstTextFocus)
			setTextFocus()
			
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);		 
			
			if(instance == mainText)
			{				
				mainText.removeEventListener(FlexEvent.UPDATE_COMPLETE, onTextAreaChange)
				mainText.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)			
				mainText.removeEventListener(FocusEvent.FOCUS_OUT, onTextAreaFocusOut)
			}
			
		}
		
		protected function onTextAreaChange(event:Event):void
		{
			Logger.info("onTextAreaChange",this);
			
			// XXX causes a model update, which makes the RichTextEditor lose focus
//			var rsoEvent:RemoteSharedObjectEvent = new RemoteSharedObjectEvent(RemoteSharedObjectEvent.TEXT_CHANGED, true);	
//			rsoEvent.sdObjects.addItem(_model);
//			rsoEvent.text = mainText.text;
//			dispatchEvent(rsoEvent);				
		}
		
		public function onMouseDown(event:MouseEvent):void
		{
			if (mainText.enabled)
			{
				//don't propagate mouse events because ObjectHandles will pick them up. If you want to click and drag over text you won't be able to.
				event.stopPropagation()
			}			
		}
		
		protected function onTextAreaFocusOut(event:FocusEvent):void
		{
			textAreaEnabled = false
			_model.text = mainText.text
		}
		
		
		protected function onBackgroundClick(event:Event):void
		{
			Logger.debug("onBackgroundClick!", this)
		}
		
		
		
		public override function destroy():void
		{
			super.destroy()			
			_model.removeEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );
			mainText.removeEventListener(FocusEvent.FOCUS_OUT, onTextAreaFocusOut)
			_model = null
		}
	}
}