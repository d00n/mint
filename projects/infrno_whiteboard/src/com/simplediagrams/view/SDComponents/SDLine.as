package com.simplediagrams.view.SDComponents
{
	
	import com.simplediagrams.events.DragCircleEvent;
	import com.simplediagrams.model.SDLineModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.util.Logger;
	import com.simplediagrams.view.SDComponents.lineEndings.ArrowLine;
	import com.simplediagrams.view.SDComponents.lineEndings.EmptyArrowLine;
	import com.simplediagrams.view.SDComponents.lineEndings.EmptyCircle;
	import com.simplediagrams.view.SDComponents.lineEndings.EmptyDiamond;
	import com.simplediagrams.view.SDComponents.lineEndings.EmptyHalfCircleArc;
	import com.simplediagrams.view.SDComponents.lineEndings.HalfCircleArc;
	import com.simplediagrams.view.SDComponents.lineEndings.LineEnding;
	import com.simplediagrams.view.SDComponents.lineEndings.SolidCircle;
	import com.simplediagrams.view.SDComponents.lineEndings.SolidDiamond;
	import com.simplediagrams.view.SDComponents.lineEndings.StopLine;
	
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import flex.utils.GraphicsUtils;
	
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Label;
	import spark.core.SpriteVisualElement;
	import spark.primitives.Graphic;

	[Bindable]
	public class SDLine extends SDBase implements ISDComponent
	{				
		[SkinPart(required="true")]		
		public var contentGraphic:Graphic	
		
		private var _model:SDLineModel;

		private var currentStartLineStyle:int = -1;
		private var currentEndLineStyle:int = -1;
		private var currentStartMask:Graphic;
		private var currentStartShape:LineEnding;
		private var currentEndMask:Graphic;
		private var currentEndShape:LineEnding;
		public var startAngle:Number;
		public var endAngle:Number;
		
		
		public function SDLine()
		{
			super();
			this.setStyle("skinClass",Class(SDLineSkin))
			this.mouseChildren = true
		}
		
		public function getLineEndingMask(style:int):Graphic
		{
			var result:Graphic;
			switch (style)
			{
				case SDLineModel.LINE_ENDING_SOLID_ARROW:
					var emptyArrow:EmptyArrowLine = new EmptyArrowLine();
					emptyArrow.backgroundAlpha = 1;
					result = emptyArrow;
					break
				
				case SDLineModel.LINE_ENDING_EMPTY_DIAMOND:
					var emptyDiamond:EmptyDiamond = new EmptyDiamond();
					emptyDiamond.backgroundAlpha = 1;
					result = emptyDiamond;
					break
				
				case SDLineModel.LINE_ENDING_CIRCLE:
					var emptyCircle:EmptyCircle = new EmptyCircle();
					emptyCircle.backgroundAlpha = 1;
					result = emptyCircle;
					break
				
				case SDLineModel.LINE_ENDING_HALF_CIRCLE:
					var emptyHanfCircle:EmptyHalfCircleArc = new EmptyHalfCircleArc();
					emptyHanfCircle.backgroundAlpha = 1;
					result = emptyHanfCircle;
					break
			}
			if(result)
				result.blendMode = BlendMode.ERASE;
			return result;
		}
		
		public function getLineEndingShape(style:int):LineEnding
		{
			var result:LineEnding;
			switch (style)
			{
				case SDLineModel.LINE_ENDING_NONE:
					result = new LineEnding;			
					break
				
				case SDLineModel.LINE_ENDING_ARROW:
					result = new ArrowLine();
					break
				
				case SDLineModel.LINE_ENDING_STOP:					
					result = new StopLine();
					break
				
				case SDLineModel.LINE_ENDING_SOLID_ARROW:
					result = new EmptyArrowLine();
					break
				
				case SDLineModel.LINE_ENDING_SOLID_DIAMOND:
					result = new SolidDiamond();
					break
				
				case SDLineModel.LINE_ENDING_EMPTY_DIAMOND:
					result = new EmptyDiamond();
					break
				
				case SDLineModel.LINE_ENDING_CIRCLE:
					result = new EmptyCircle();
					break
				
				case SDLineModel.LINE_ENDING_SOLID_CIRCLE:
					result = new SolidCircle();
					break
				
				case SDLineModel.LINE_ENDING_HALF_CIRCLE:
					result = new HalfCircleArc();
					break
			}

			return result;
		}
			
		public function set objectModel(objectModel:SDObjectModel):void
		{     
			if(_model)
				_model.removeEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );	
			_model = SDLineModel(objectModel)		
			if(_model)
				_model.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onModelChange );	
			this.invalidateProperties();
		}
		
		public override function get objectModel():SDObjectModel
		{
			return _model;
		}
		
		
		override protected function onModelChange(event:PropertyChangeEvent):void
		{
			super.onModelChange(event);
			this.invalidateProperties();
		}     
		
	
		
		protected override function commitProperties():void
		{
			super.commitProperties();
			if(_model)
			{
				depth = _model.depth;
				calculateAngles();
				if(currentStartLineStyle != _model.startLineStyle)
				{
					if(currentStartShape)
					{
						currentStartLineStyle = -1;
						contentGraphic.removeElement(currentStartShape);
						currentStartShape = null;
						if(currentStartMask)
						{
							contentGraphic.removeElement(currentStartMask);
							currentStartMask = null;
						}
					}
					currentStartLineStyle = _model.startLineStyle;
					currentStartShape = getLineEndingShape(currentStartLineStyle);
					contentGraphic.addElement(currentStartShape);
					currentStartMask = getLineEndingMask(currentStartLineStyle);
					if(currentStartMask)
						contentGraphic.addElementAt(currentStartMask, 0);
				}
				if(currentEndLineStyle != _model.endLineStyle)
				{
					if(currentEndShape)
					{
						currentEndLineStyle = -1;
						contentGraphic.removeElement(currentEndShape);
						currentEndShape = null;
						if(currentEndMask)
						{
							contentGraphic.removeElement(currentEndMask);
							currentEndMask = null;
						}
					}
					currentEndLineStyle = _model.endLineStyle;
					currentEndShape = getLineEndingShape(currentEndLineStyle);
					contentGraphic.addElement(currentEndShape);
					currentEndMask = getLineEndingMask(currentEndLineStyle);
					if(currentEndMask)
						contentGraphic.addElementAt(currentEndMask, 0);
				}
			}
			else
			{
				if(currentStartShape)
				{
					currentStartLineStyle = -1;
					contentGraphic.removeElement(currentStartShape);
					currentStartShape = null;
					if(currentStartMask)
					{
						contentGraphic.removeElement(currentStartMask);
						currentStartMask = null;
					}
				}
				if(currentEndShape)
				{
					currentEndLineStyle = -1;
					contentGraphic.removeElement(currentEndShape);
					currentEndShape = null;
					if(currentEndMask)
					{
						contentGraphic.removeElement(currentEndMask);
						currentEndMask = null;
					}
				}
			}
			invalidateDisplayList();
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			contentGraphic.graphics.clear();
			if(contentGraphic && _model)
			{				
				if(currentStartShape)
				{
					currentStartShape.x = _model.startX;
					currentStartShape.y = _model.startY;
					currentStartShape.rotation = startAngle;
					currentStartShape.lineWeight = _model.lineWeight;
					currentStartShape.lineColor = _model.color;
					if(currentStartMask)
					{
						currentStartMask.x = _model.startX;
						currentStartMask.y = _model.startY;
						currentStartMask.rotation = startAngle;
					}
				}
				if(currentEndShape)
				{
					currentEndShape.x = _model.endX;
					currentEndShape.y = _model.endY;
					currentEndShape.rotation = endAngle;
					currentEndShape.lineWeight = _model.lineWeight;
					currentEndShape.lineColor = _model.color;
					if(currentEndMask)
					{
						currentEndMask.x = _model.endX;
						currentEndMask.y = _model.endY;
						currentEndMask.rotation = endAngle;
					}
				}
				contentGraphic.graphics.lineStyle(10, 0, 0.01);
				contentGraphic.graphics.moveTo(_model.startX, _model.startY);
				contentGraphic.graphics.curveTo(_model.bendX, _model.bendY, _model.endX, _model.endY);
				
				if(_model.lineStyle == SDLineModel.LINE_STYLE_DASHED)
				{
					contentGraphic.graphics.lineStyle(_model.lineWeight, _model.color);
					GraphicsUtils.drawQuadCurve(contentGraphic.graphics, new Point(_model.startX,  _model.startY),  new Point(_model.bendX,  _model.bendY)
						, new Point(_model.endX,  _model.endY), true, 10);					
				}
				else //it's a solid line
				{
					contentGraphic.graphics.lineStyle(_model.lineWeight, _model.color);
					contentGraphic.graphics.moveTo(_model.startX, _model.startY);
					contentGraphic.graphics.curveTo(_model.bendX, _model.bendY, _model.endX, _model.endY);	
				}
			}
		}
		
		protected function calculateAngles():void
		{	
			var a:Number = (Math.atan(  (_model.bendY - _model.startY) / (_model.bendX - _model.startX) )) * 180 / Math.PI 
			if (_model.bendX < _model.startX) a = 180 + a 
			startAngle = a
			
			a = (Math.atan(  (_model.endY - _model.bendY) / (_model.endX - _model.bendX) )) * 180 / Math.PI 
			if (_model.bendX > _model.endX) a = 180 + a;
			endAngle = a + 180
		}
				
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);		 
            if(instance == contentGraphic)
				invalidateDisplayList();
		}
		
		public override function destroy():void
		{
			super.destroy();
			_model = null;
		}
																						
																									
																							
	}
}