// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.motion
{
import fl.motion.*;
import flash.display.*;
import flash.geom.ColorTransform;


/**
 * The Color class extends the Flash Player ColorTransform class,
 * adding the ability to control brightness and tint.
 * It also contains static methods for interpolating between two ColorTransform objects
 * or between two color numbers. 
 * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Color, Copy Motion as ActionScript    
 * @see flash.geom.ColorTransform ColorTransform class
 * @includeExample examples\ColorExample.as -noswf 
 * @see ../../motionXSD.html Motion XML Elements
 */
public class Color extends ColorTransform
{

    /**
     * Constructor for Color instances.
     *
     * @param redMultiplier The percentage to apply the color, as a decimal value between 0 and 1.
     * @param greenMultiplier The percentage to apply the color, as a decimal value between 0 and 1.
     * @param blueMultiplier The percentage to apply the color, as a decimal value between 0 and 1.
     * @param alphaMultiplier A decimal value that is multiplied with the alpha transparency channel value, as a decimal value between 0 and 1.
     * @param redOffset A number from -255 to 255 that is added to the red channel value after it has been multiplied by the <code>redMultiplier</code> value. 
     * @param greenOffset A number from -255 to 255 that is added to the green channel value after it has been multiplied by the <code>greenMultiplier</code> value. 
     * @param blueOffset A number from -255 to 255 that is added to the blue channel value after it has been multiplied by the <code>blueMultiplier</code> value. 
     * @param alphaOffset A number from -255 to 255 that is added to the alpha channel value after it has been multiplied by the <code>alphaMultiplier</code> value.
     *
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Color       
     */
	function Color (redMultiplier:Number=1.0, 
					greenMultiplier:Number=1.0, 
					blueMultiplier:Number=1.0, 
					alphaMultiplier:Number=1.0, 
					redOffset:Number=0, 
					greenOffset:Number=0, 
					blueOffset:Number=0, 
					alphaOffset:Number=0)
	{
		super(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
	}



    /**
     * The percentage of brightness, as a decimal between <code>-1</code> and <code>1</code>. 
     * Positive values lighten the object, and a value of <code>1</code> turns the object completely white.
     * Negative values darken the object, and a value of <code>-1</code> turns the object completely black. 
     * 
     * @default 0
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword brightness, Copy Motion as ActionScript        
     */
    public function get brightness():Number
    {
        return this.redOffset ? (1-this.redMultiplier) : (this.redMultiplier-1);
    }

    /**
     * @private (setter)
     */
	public function set brightness(value:Number):void
	{
		if (value > 1) value = 1;
		else if (value < -1) value = -1;
		var percent:Number = 1 - Math.abs(value);
		var offset:Number = 0;
		if (value > 0) offset = value * 255;
		this.redMultiplier = this.greenMultiplier = this.blueMultiplier = percent;
		this.redOffset     = this.greenOffset     = this.blueOffset     = offset;
	}



    /**
     * Sets the tint color and amount at the same time.
     *
     * @param tintColor The tinting color value in the 0xRRGGBB format.
     *
     * @param tintMultiplier The percentage to apply the tint color, as a decimal value between <code>0</code> and <code>1</code>.
     * When <code>tintMultiplier = 0</code>, the target object is its original color and no tint color is visible.
     * When <code>tintMultiplier = 1</code>, the target object is completely tinted and none of its original color is visible.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword brightness, Copy Motion as ActionScript         
     */
	public function setTint(tintColor:uint, tintMultiplier:Number):void
	{
		this._tintColor = tintColor;
		this._tintMultiplier = tintMultiplier;
		this.redMultiplier = this.greenMultiplier = this.blueMultiplier = 1 - tintMultiplier;
		var r:uint = (tintColor >> 16) & 0xFF;
		var g:uint = (tintColor >>  8) & 0xFF;
		var b:uint =  tintColor        & 0xFF;
		this.redOffset   = Math.round(r * tintMultiplier);
		this.greenOffset = Math.round(g * tintMultiplier);
		this.blueOffset  = Math.round(b * tintMultiplier);
	}	

    /**
     * @private
     */
	private var _tintColor:Number = 0x000000;


    /**
     * The tinting color value in the 0xRRGGBB format.
     * 
     * 
     * @default 0x000000 (black)
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword tint, Copy Motion as ActionScript        
     */
    public function get tintColor():uint
    {
        return this._tintColor;
    }

    /**
     * @private (setter)
     */
	public function set tintColor(value:uint):void
	{
		this.setTint(value, this.tintMultiplier);
	}


	// Capable of deriving a tint color from the color offsets,
	// but the accuracy decreases as the tint multiplier decreases (rounding issues).
    /**
     * @private 
     */
	private function deriveTintColor():uint
	{
		var ratio:Number = 1 / (this.tintMultiplier); 
		var r:uint = Math.round(this.redOffset * ratio);
		var g:uint = Math.round(this.greenOffset * ratio);
		var b:uint = Math.round(this.blueOffset * ratio);
		var colorNum:uint = r<<16 | g<<8 | b;
		return colorNum; 
	}


    /**
     * @private
     */
	private var _tintMultiplier:Number = 0;


    /**
     * The percentage to apply the tint color, as a decimal value between <code>0</code> and <code>1</code>.
     * When <code>tintMultiplier = 0</code>, the target object is its original color and no tint color is visible.
     * When <code>tintMultiplier = 1</code>, the target object is completely tinted and none of its original color is visible.
     * @default 0
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword tint, Copy Motion as ActionScript        
     */
    public function get tintMultiplier():Number
    {
        return this._tintMultiplier;
    }

    /**
     * @private (setter)
     */
	public function set tintMultiplier(value:Number):void
	{
		this.setTint(this.tintColor, value);
	}


    /**
     * Creates a Color instance from XML.
     *
     * @param xml An E4X XML object containing a <code>&lt;color&gt;</code> node from Motion XML.
     *
     * @return A Color instance that matches the XML description. 
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword color, Copy Motion as ActionScript      
     */
 	public static function fromXML(xml:XML):Color
	{
		return Color((new Color()).parseXML(xml));
	}


    /**
     * @private
     */
	private function parseXML(xml:XML=null):Color
	{
		if (!xml) return this;

		var firstChild:XML = xml.elements()[0];
		if (!firstChild) return this;
		
		//// ATTRIBUTES
		for each (var att:XML in firstChild.attributes())
		{
			var name:String = att.localName();
			if (name == 'tintColor')
			{
				var tintColorNumber:uint = Number(att.toString()) as uint;
				this.tintColor = tintColorNumber;
			}
			else
			{
				this[name] = Number(att.toString());
			}
		}

		
		return this;
	}


    /**
     * Blends smoothly from one ColorTransform object to another.
     *
     * @param fromColor The starting ColorTransform object.
     *
     * @param toColor The ending ColorTransform object.
     *
     * @param progress The percent of the transition as a decimal, where <code>0</code> is the start and <code>1</code> is the end.
     *
     * @return The interpolated ColorTransform object.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword blend, Copy Motion as ActionScript         
     */
	public static function interpolateTransform(fromColor:ColorTransform, toColor:ColorTransform, progress:Number):ColorTransform
	{
		var q:Number = 1-progress;
		var resultColor:ColorTransform = new ColorTransform
		(
			  fromColor.redMultiplier*q   + toColor.redMultiplier*progress
			, fromColor.greenMultiplier*q + toColor.greenMultiplier*progress
			, fromColor.blueMultiplier*q  + toColor.blueMultiplier*progress
			, fromColor.alphaMultiplier*q + toColor.alphaMultiplier*progress
			, fromColor.redOffset*q       + toColor.redOffset*progress
			, fromColor.greenOffset*q     + toColor.greenOffset*progress
			, fromColor.blueOffset*q      + toColor.blueOffset*progress
			, fromColor.alphaOffset*q     + toColor.alphaOffset*progress
		)
		return resultColor;		
	}
	

   /**
     * Blends smoothly from one color value to another.
     *
     * @param fromColor The starting color value, in the 0xRRGGBB or 0xAARRGGBB format.
     *
     * @param toColor The ending color value, in the 0xRRGGBB or 0xAARRGGBB format.
     *
     * @param progress The percent of the transition as a decimal, where <code>0</code> is the start and <code>1</code> is the end.
     *
     * @return The interpolated color value, in the 0xRRGGBB or 0xAARRGGBB format.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @refpath
     * @keyword blend, Copy Motion as ActionScript      
     */
	public static function interpolateColor(fromColor:uint, toColor:uint, progress:Number):uint
	{
		var q:Number = 1-progress;
		var fromA:uint = (fromColor >> 24) & 0xFF;
		var fromR:uint = (fromColor >> 16) & 0xFF;
		var fromG:uint = (fromColor >>  8) & 0xFF;
		var fromB:uint =  fromColor        & 0xFF;

		var toA:uint = (toColor >> 24) & 0xFF;
		var toR:uint = (toColor >> 16) & 0xFF;
		var toG:uint = (toColor >>  8) & 0xFF;
		var toB:uint =  toColor        & 0xFF;
		
		var resultA:uint = fromA*q + toA*progress;
		var resultR:uint = fromR*q + toR*progress;
		var resultG:uint = fromG*q + toG*progress;
		var resultB:uint = fromB*q + toB*progress;
		var resultColor:uint = resultA << 24 | resultR << 16 | resultG << 8 | resultB;
		return resultColor;		
	}

 
}
}
