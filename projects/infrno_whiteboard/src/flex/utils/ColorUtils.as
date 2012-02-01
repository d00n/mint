package flex.utils
{
	import mx.utils.ColorUtil;
	
	
	/**
	 * Utility methods for working with color uints.
	 * 
	 * @author Chris Callendar 
	 */
	public final class ColorUtils extends ColorUtil
	{
		
		private static const FACTOR:Number = 0.7;
		
		/**
		 * Returns a color value with the given red, green, blue, and alpha
		 * components
		 * @param r the red component (0-255)
		 * @param g the green component (0-255)
		 * @param b the blue component (0-255)
		 * @param a the alpha component (0-255, 255 by default)
		 * @return the color value
		 * 
		 */
		public static function rgba(r:uint, g:uint, b:uint, a:uint=255):uint {
			return ((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) <<  8) |  (b & 0xFF);
		}
		
		/**
		 * Returns a color value by updating the alpha component of another color value.
		 * @param c a color value
		 * @param a the desired alpha component (0-255)
		 * @return a color value with adjusted alpha component
		 */
		public static function setAlpha(c:uint, a:uint):uint {
			return ((a & 0xFF) << 24) | (c & 0x00FFFFFF);
		}
		
		/**
		 * Returns the alpha component of a color value
		 * @param c the color value
		 * @return the alpha component
		 */
		public static function getAlpha(c:uint):uint {
			return (c >> 24) & 0xFF;
		}
		
		
		public static function getRed(rgb:uint):uint {
			return ((rgb >> 16) & 0xFF);
		}
		
		public static function getGreen(rgb:uint):uint {
			return ((rgb >> 8) & 0xFF);
		}
		
		public static function getBlue(rgb:uint):uint {
			return (rgb & 0xFF);
		}
		
		/**
		 * Combines the red, green, and blue color components into one 24 bit uint.
		 */
		public static function combine(r:uint, g:uint, b:uint):uint {
			return (Math.min(Math.max(0, r), 255) << 16) | 
				(Math.min(Math.max(0, g), 255) << 8) | 
				Math.min(Math.max(0, b), 255);
		} 
		
		/**
		 * Combines the color value and the alpha value into a 32 bit uint like #AARRGGBB.
		 */
		public static function combineColorAndAlpha(color:uint, alpha:Number):uint {
			// make sure the alpha is a valid number [0-1]
			if (isNaN(alpha)) {
				alpha = 1;
			} else {
				alpha = Math.max(0, Math.min(1, alpha));
			}
			
			// convert the [0-1] alpha value into [0-255]
			var alphaColor:uint = alpha * 255;
			// bitshift it to come before the color
			alphaColor = alphaColor << 24;
			// combine the two values: #AARRGGBB
			var combined:uint = alphaColor | color;
			return combined;  
		}
		
		/**
		 * Returns the average of the two colors.  Doesn't look at alpha values. */
		public static function average(c1:uint, c2:uint):uint {
			var r:uint = (getRed(c1) + getRed(c2)) / 2;
			var g:uint = (getGreen(c1) + getGreen(c2)) / 2;
			var b:uint = (getBlue(c1) + getBlue(c2)) / 2;
			return combine(r, g, b);
		}
		
		// copied from java
		public static function brighter(rgb:uint):uint {
			var r:uint = getRed(rgb);
			var g:uint = getGreen(rgb);
			var b:uint = getBlue(rgb);
			var factor:Number = 0.7;
			/* 
			* 1. black.brighter() should return grey
			* 2. applying brighter to blue will always return blue, brighter
			* 3. non pure color (non zero rgb) will eventually return white
			*/
			var i:int = int(1.0/(1.0-FACTOR));
			if (r == 0 && g == 0 && b == 0) {
				return combine(i, i, i);
			}
			if (r  > 0 && r < i) {
				r = i;
			}
			if (g > 0 && g < i) { 
				g = i;
			}
			if (b > 0 && b < i ) {
				b = i;
			}
			var newRGB:uint = combine(uint(r/FACTOR), uint(g/FACTOR), uint(b/FACTOR));
			return newRGB;
		}
		
		// copied from Java
		public static function darker(rgb:uint):uint {
			var r:uint = getRed(rgb) * FACTOR;
			var g:uint = getGreen(rgb) * FACTOR;
			var b:uint = getBlue(rgb) * FACTOR;
			var newRGB:uint = combine(r, g, b);
			return newRGB;
		}
		
		public static function invert(rgb:uint):uint {
			var r:uint = getRed(rgb);
			var g:uint = getGreen(rgb);
			var b:uint = getBlue(rgb);
			var newRGB:uint = combine(255 - r, 255 - g, 255 - b);
			return newRGB;
		}
		
		/**
		 * See mx.utils.ColorUtil.adjustBrightness2
		 */
		public static function brightness(rgb:uint, brite:Number):uint {
			return adjustBrightness2(rgb, brite);
		}
		
		/**
		 * Returns either black or white depending on the bgColor to ensure
		 * that the text will contrast on the background color.
		 */
		public static function getTextColor(bgColor:uint):uint {
			var textColor:uint = 0;        // black
			var r:uint = getRed(bgColor);
			var g:uint = getGreen(bgColor);
			var b:uint = getBlue(bgColor);
			var rgb:uint = r + g + b;
			if (rgb < 400) {
				textColor = 0xffffff;    // white
			}
			return textColor;
		}
		
		public static function toHex(rgb:uint):String {
			return "#" + rgb.toString(16);
		}
		
		public static function toRGB(rgb:uint):String {
			return getRed(rgb) + "," + getGreen(rgb) + "," + getBlue(rgb);
		}
		
	}
}