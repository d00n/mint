package flex.utils
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.utils.ColorUtil;
	import mx.utils.GraphicsUtil;
	
	/**
	 * Contains some useful functions for working with Graphics.
	 * 
	 * @author Chris Callendar.
	 */
	public class GraphicsUtils extends GraphicsUtil
	{
		
		/**
		 * Calculates the point along the linear line at the given "time" t (between 0 and 1).
		 * Formula came from
		 * http://en.wikipedia.org/wiki/B%C3%A9zier_curve#Linear_B.C3.A9zier_curves
		 * @param t the position along the line [0, 1]
		 * @param start the starting point
		 * @param end the end point
		 */
		public static function getLinearValue(t:Number, start:Point, end:Point):Point {
			t = Math.max(Math.min(t, 1), 0);
			var x:Number = start.x + (t * (end.x - start.x));
			var y:Number = start.y + (t * (end.y - start.y));
			return new Point(x, y);    
		}
		
		/**
		 * Calculates the point along the quadratic curve at the given "time" t (between 0 and 1).
		 * Formula came from
		 * http://en.wikipedia.org/wiki/B%C3%A9zier_curve#Linear_B.C3.A9zier_curves
		 * @param t the position along the line [0, 1]
		 * @param start the starting point
		 * @param cp the control point
		 * @param end the end point
		 */
		public static function getQuadraticValue(t:Number, start:Point, cp:Point, end:Point):Point {
			t = Math.max(Math.min(t, 1), 0);
			var tp:Number = 1 - t;
			var t2:Number = t * t;
			var tp2:Number = tp * tp;
			var x:Number = (tp2*start.x) + (2*tp*t*cp.x) + (t2*end.x);
			var y:Number = (tp2*start.y) + (2*tp*t*cp.y) + (t2*end.y);
			return new Point(x, y);    
		}
		
		/**
		 * Calculates the point along the cubic curve at the given "time" t (between 0 and 1).
		 * Formula came from
		 * http://en.wikipedia.org/wiki/B%C3%A9zier_curve#Linear_B.C3.A9zier_curves
		 * It is also very similar to the fl.motion.BezierSegment.getValue() function.
		 * @param start the starting point
		 * @param cp1 the first control point
		 * @param cp2 the second control point
		 * @param end the end point
		 */
		public static function getCubicValue(t:Number, start:Point, cp1:Point, cp2:Point, end:Point):Point {
			t = Math.max(Math.min(t, 1), 0);
			var tp:Number = 1 - t;
			var t2:Number = t * t;
			var t3:Number = t2 * t;
			var tp2:Number = tp * tp;
			var tp3:Number = tp2 * tp;
			var x:Number = (tp3*start.x) + (3*tp2*t*cp1.x) + (3*tp*t2*cp2.x) + (t3*end.x);
			var y:Number = (tp3*start.y) + (3*tp2*t*cp1.y) + (3*tp*t2*cp2.y) + (t3*end.y);
			return new Point(x, y);
		}
		
		/**
		 * Draws a circle position around the center point at the given radius.
		 * The line defaults to a solid line, but can also be a dashed line.
		 * If dashed is false then the Graphics.drawCircle() function is used.
		 * @param center the center of the circle
		 * @param radius the radius of the circle
		 * @param dashed if true then the line will be dashed
		 * @param dashLength the length of the dash (only applies if dashed is true)
		 * @param segments the number of segments to divide the circle into,
		 *  more segments means a smoother line.  Only used for dashed lines.
		 */
		public static function drawCircle(g:Graphics, center:Point, radius:Number, 
										  dashed:Boolean = false, dashLength:Number = 10, segments:int = 360):void {
			if (dashed) {
				const twoPI:Number = 2 * Math.PI;
				var circumference:Number = twoPI * radius;
				if (circumference <= dashLength) {
					g.drawCircle(center.x, center.y, radius);
				} else {
					var angleStep:Number = twoPI / segments;    // in radians
					var angle:Number = 0;
					var x:Number = center.x + Math.cos(angle) * radius;
					var y:Number = center.y + Math.sin(angle) * radius;
					g.moveTo(x, y);
					
					var distance:Number;
					var dashNum:Number;
					for (angle = angleStep; angle < twoPI; angle += angleStep) {
						x = center.x + Math.cos(angle) * radius;
						y = center.y + Math.sin(angle) * radius;
						distance = angle * radius;
						dashNum = Math.floor((distance / dashLength) % 2); 
						// determine whether to draw the dashed line or move ahead
						if (dashNum == 0) {
							// approximate the circle with a line (step size is small)
							g.lineTo(x, y);
						} else {
							g.moveTo(x, y);
						}
					}
				}
			} else {
				g.drawCircle(center.x, center.y, radius);
			}
		}
		
		/**
		 * Draws an arc around the center point at the given radius, going from the 
		 * start angle to the end angle.  Both angles must be between 0 and 360.
		 * The arc defaults to a solid line, but can also be a dashed line.
		 * @param center the center of the arc
		 * @param radius the radius of the arc
		 * @param dashed if true then the arc will be dashed
		 * @param dashLength the length of the dash (only applies if dashed is true)
		 * @param segments the number of segments to divide the arc into,
		 *  more segments means a smoother arc.
		 */
		public static function drawArc(g:Graphics, center:Point, radius:Number,
									   startAngle:Number = 0, endAngle:Number = 90, 
									   dashed:Boolean = false, dashLength:Number = 10, segments:int = 360):void {
			if ((startAngle < 0) || (startAngle > 360) || 
				(endAngle < 0) || (endAngle > 360) || (startAngle == endAngle)) {
				trace("Invalid angles, must be between 0 and 360")
				return;
			}
			
			const twoPI:Number = 2 * Math.PI;
			var angleDiff:Number = (endAngle - startAngle);
			if (angleDiff < 0) {
				angleDiff += 360;
			}
			// convert to radians
			angleDiff = angleDiff * twoPI / 360;
			var angleStep:Number = angleDiff / segments;    // in radians
			var startAngleRadians:Number = startAngle * twoPI / 360;
			var angle:Number = startAngleRadians;
			var maxAngle:Number = angle + angleDiff;
			// Move to the start of the arc
			var x:Number = center.x + Math.cos(angle) * radius;
			var y:Number = center.y + Math.sin(angle) * radius;
			g.moveTo(x, y);
			
			var distance:Number = 0;
			var dashNum:Number;
			for (angle = startAngleRadians + angleStep; angle < maxAngle; angle += angleStep) {
				x = center.x + Math.cos(angle) * radius;
				y = center.y + Math.sin(angle) * radius;
				if (dashed) {
					distance = (angle - startAngleRadians) * radius;
					dashNum = Math.floor((distance / dashLength) % 2); 
					// determine whether to draw the dashed line or move ahead
					if (dashNum == 0) {
						// approximate the circle with a line (step size is small)
						g.lineTo(x, y);
					} else {
						g.moveTo(x, y);
					}
				} else {
					g.lineTo(x, y);
				}
			}
		}
		
		/**
		 * Draws a straight line between the starting and ending points.  
		 * The line defaults to a solid line, but can also be a dashed line.
		 * If dashed is false then the Graphics.lineTo() function is used.
		 * @param start the starting point
		 * @param end the end point
		 * @param dashed if true then the line will be dashed
		 * @param dashLength the length of the dash (only applies if dashed is true)
		 */
		public static function drawLine(g:Graphics, start:Point, end:Point, 
										dashed:Boolean = false, dashLength:Number = 10):void {
			g.moveTo(start.x, start.y);
			if (dashed) {
				// the distance between the two points
				var total:Number = Point.distance(start, end);
				// divide the distance into segments
				if (total <= dashLength) {
					// just draw a solid line since the dashes won't show up
					g.lineTo(end.x, end.y);
				} else {
					// divide the line into segments of length dashLength 
					var step:Number = dashLength / total;
					var dashOn:Boolean = false;
					var p:Point;
					for (var t:Number = step; t <= 1; t += step) {
						p = getLinearValue(t, start, end);
						dashOn = !dashOn;
						if (dashOn) {
							g.lineTo(p.x, p.y);
						} else {
							g.moveTo(p.x, p.y);
						}
					}
					// finish the line if necessary
					dashOn = !dashOn;
					if (dashOn && !end.equals(p)) {
						g.lineTo(end.x, end.y);
					}
				}
			} else {
				// use the built-in lineTo function
				g.lineTo(end.x, end.y);
			}
		}
		
		/**
		 * Draws a quadratic curved line between the starting and ending points.  
		 * The line defaults to a solid line, but can also be a dashed line.
		 * If dashed is false then the Graphics.curveTo() function is used.
		 * @param start the starting point
		 * @param cp the control point
		 * @param end the end point
		 * @param dashed if true then the line will be dashed
		 * @param dashLength the length of the dash (only applies if dashed is true)
		 * @param segments the number of segments to divide the curve into,
		 *  more segments means smoother line.  Only used for dashed lines. 
		 */
		public static function drawQuadCurve(g:Graphics, start:Point, cp:Point, end:Point, 
											 dashed:Boolean = false, dashLength:Number = 10, segments:Number = 200):void {
			g.moveTo(start.x, start.y);
			
			if (dashed) {
				// draw portions of the curve
				var step:Number = 1 / segments;
				var dist:Number = 0;    // approx distance from the start
				var dashNum:Number;  
				var last:Point = start;
				var p:Point;
				for (var t:Number = step; t <= 1; t += step) {
					// calculates the next point on the quadratic curve
					p = getQuadraticValue(t, start, cp, end);
					// keep track of the total distance from start along the curve
					dist += Point.distance(p, last);
					dashNum = Math.floor((dist / dashLength) % 2); 
					// determine whether to draw the dashed line or move ahead
					if (dashNum == 0) {
						// approximate the curve with a line (step size is small)
						g.lineTo(p.x, p.y);
					} else {
						g.moveTo(p.x, p.y);
					}
					last = p;
				}
			} else {
				// use the build-in quadractic curve function
				g.curveTo(cp.x, cp.y, end.x, end.y);
			}
		}
		
		/**
		 * Draws an approximation of a cubic curved line between the starting and ending points.
		 * The curve is actually drawn using very small straight lines to approximate the curve.  
		 * The line defaults to a solid line, but can also be a dashed line.
		 * @param start the starting point
		 * @param cp1 the first control point
		 * @param cp2 the second control point
		 * @param end the end point
		 * @param dashed if true then the line will be dashed
		 * @param dashLength the length of the dash
		 * @param segments the number of segments to divide the curve into,
		 *  more segments means smoother line. 
		 */
		public static function drawCubicCurve(g:Graphics, start:Point, cp1:Point, cp2:Point, end:Point, 
											  dashed:Boolean = false, dashLength:Number = 10, segments:Number = 200):void {
			// move to the starting point
			g.moveTo(start.x, start.y);
			
			var step:Number = 1 / segments;
			var dist:Number = 0;    // approx distance from the start
			var seg:Number;
			var last:Point = start;
			var p:Point;
			// this loop draws each segment of the curve
			for (var t:Number = step; t <= 1; t += step) { 
				p = getCubicValue(t, start, cp1, cp2, end);
				if (dashed) {
					dist += Point.distance(p, last);
					seg = Math.floor((dist / dashLength) % 2); 
					if (seg == 0) {
						g.lineTo(p.x, p.y);
					} else {
						g.moveTo(p.x, p.y);
					}
					last = p;
				} else {
					g.lineTo(p.x, p.y);
				}
			} 
			
			// As a final step, make sure the curve ends on the second anchor
			if (!dashed) {
				g.lineTo(end.x, end.y);
			}
		}
		
		/**
		 * Draws an outset border with the given width, height, thickness, and alpha.
		 * The highlight and shadow colors are derived from the given color.
		 */
		public static function drawOutsetBorder(g:Graphics, w:Number, h:Number, 
												color:uint = 0x0, thickness:Number = 1, alpha:Number = 1):void {
			
			var c:uint = color;
			var t:Number = Math.max(0, thickness);
			var a:Number = Math.min(1, alpha);
			if ((t > 0) && (a > 0)) {
				for (var i:int = 0; i < t; i++) {
					g.lineStyle(1, getHighlightInnerColor(c), a);
					g.moveTo(i, i);
					g.lineTo(i, h-1-i);
					g.moveTo(i+1, i);
					g.lineTo(w-1-i, i);
					
					g.lineStyle(1, getShadowInnerColor(c), a);
					g.moveTo(i, h-1-i);
					g.lineTo(w-i, h-1-i);
					g.moveTo(w-1-i, i);
					g.lineTo(w-1-i, h-1-i);
				}                
			}                        
		}
		
		/**
		 * Draws an inset border with the given width, height, thickness, and alpha.
		 * The highlight and shadow colors are derived from the given color.
		 */
		public static function drawInsetBorder(g:Graphics, w:Number, h:Number, 
											   color:uint = 0x0, thickness:Number = 1, alpha:Number = 1):void {
			
			var c:uint = color;
			var t:Number = Math.max(0, thickness);
			var a:Number = Math.min(1, alpha);
			if ((t > 0) && (a > 0)) {
				for (var i:int = 0; i < t; i++) {
					g.lineStyle(1, getShadowInnerColor(c), a);
					g.moveTo(i, i);
					g.lineTo(i, h-i);
					g.moveTo(i+1, i);
					g.lineTo(w-i, i);
					
					g.lineStyle(1, getHighlightInnerColor(c), a);
					g.moveTo(i+1, h-1-i);
					g.lineTo(w-i, h-1-i);
					g.moveTo(w-1-i, i+1);
					g.lineTo(w-1-i, h-1-i);
				}
			}                        
		}
		
		public static function getHighlightOuterColor(c:uint):uint   {
			return ColorUtils.brighter(ColorUtils.brighter(c));
		}
		
		public static function getHighlightInnerColor(c:uint):uint   {
			return ColorUtils.brighter(c);
		}
		
		public static function getShadowInnerColor(c:uint):uint   {
			return ColorUtils.darker(c);
		}
		
		public static function getShadowOuterColor(c:uint):uint   {
			return ColorUtils.darker(ColorUtils.darker(c));
		}
		
		/**
		 * Draws a rectangle at the given x, y, width, and height coordinates.
		 * You can also specify the corner radii for the rectangle.  If the cornerRadii contains a single
		 * Number then that radius is doubled and used as the ellipse width and height to make rounded corners.
		 * If the cornerRadii has two numbers then those numbers are doubled and used as the ellipse width/height.
		 * If the cornerRadii has four numbers then those are used as the four corner radii.
		 * Otherwise a rectangle is drawn with no corner radius.
		 */
		public static function drawRect(g:Graphics, x:Number, y:Number, w:Number, h:Number, cornerRadii:Array = null):void {
			var noCorner:Boolean = (cornerRadii == null) || (cornerRadii.length == 0);
			var drawn:Boolean = false;
			if (!noCorner) {
				if (cornerRadii.length == 1) {
					var diam:Number = 2 * Number(cornerRadii[0]);
					if (!isNaN(diam) && (diam > 0)) {
						g.drawRoundRect(x, y, w, h, diam, diam);
						drawn = true;
					}
				} else if (cornerRadii.length == 2) {
					var ellipseW:Number = 2 * Number(cornerRadii[0]);
					var ellipseH:Number = 2 * Number(cornerRadii[1]);
					if (!isNaN(ellipseW) && !isNaN(ellipseH)) {
						g.drawRoundRect(x, y, w, h, ellipseW, ellipseH);
						drawn = true;
					}
				} else if (cornerRadii.length == 4) {
					var tl:Number = cornerRadii[0];
					var tr:Number = cornerRadii[1];
					var bl:Number = cornerRadii[2];
					var br:Number = cornerRadii[3];
					if (!isNaN(tl) && !isNaN(tr) && !isNaN(bl) && !isNaN(br)) {
						g.drawRoundRectComplex(x, y, w, h, tl, tr, bl, br);
						drawn = true;
					}
				}
			}
			if (!drawn) {
				g.drawRect(x, y, w, h);
			}
		}
		
		/**
		 * Creates a BitmapData that is used to renderer a horizontal or vertical dotted line.
		 * If the vertical parameter is true, then it creates a rectangle bitmap that is 
		 * twice as long as it is wide (lineThickness).  Otherwise it creates a rectangle
		 * that is twice as wide as it is long.
		 * The first half of the rectangle is filled with the line color (and alpha value),
		 * then second half is transparent.
		 */
		public static function createDottedLineBitmap(lineColor:uint, lineAlpha:Number, 
													  lineThickness:Number, vertical:Boolean = true):BitmapData {
			var w:Number = (vertical ? lineThickness : 2 * lineThickness);
			var h:Number = (vertical ? 2 * lineThickness : lineThickness);
			var color32:uint = ColorUtils.combineColorAndAlpha(lineColor, lineAlpha);
			var dottedLine:BitmapData = new BitmapData(w, h, true);
			// create a dotted bitmap
			for (var i:int = 0; i < lineThickness; i++) {
				for (var j:int = 0; j < lineThickness; j++) {
					dottedLine.setPixel32(i, j, color32);
				}
			}
			return dottedLine;
		}
		
		/**
		 * Begins filling using the Graphics object.
		 * If more than one color is specified in the array, then a gradient fill is used.
		 */
		public static function beginFill(g:Graphics, w:Number, h:Number, colors:Array, alphas:Array = null, 
										 gradientType:String = "linear", gradientRotation:Number = Math.PI/2, spreadMethod:String = "pad"):void {            
			if ((colors == null) || (colors.length == 0)) {
				colors = [ 0xffffff ];
			}
			if ((alphas == null) || (alphas.length == 0)) {
				alphas = [ 1 ];
			}
			var alpha:Number = alphas[0];
			
			if (colors.length > 1) {
				if (alphas.length < colors.length) {
					alphas = getAlphas(colors.length, alpha);
				}
				var ratios:Array = getRatios(colors.length);
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(w, h, gradientRotation, 0, 0);
				g.beginGradientFill(gradientType, colors, alphas, ratios, matrix, spreadMethod);
			} else {
				var color:uint = colors[0];
				g.beginFill(color, alpha);
			}
		} 
		
		/** 
		 * Returns an array of length count all with the alpha value given.
		 * The alpha value should be between 0 and 1. 
		 */
		public static function getAlphas(count:int, alpha:Number = 1):Array {
			var array:Array = new Array();
			for (var i:int = 0; i < count; i++) {
				array[i] = alpha;
			}
			return array;
		}
		
		/** 
		 * Returns an array of numbers starting at 0 and ending at 255.
		 * If count is 2: [0, 255] is returned.
		 * If count is 3: [0, 127.5, 255] is returned, etc. 
		 */
		public static function getRatios(count:int):Array {
			var array:Array = new Array();
			array[0] = 0;
			if (count >= 2) {
				if (count > 2) {
					var unit:Number = (255 / (count - 1));
					for (var i:int = 1; i < count - 1; i++) {
						array[i] = (i * unit);
					}
				}
				array[count - 1] = 0xff;
			}
			return array;
		}
		
	}
}