// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.motion.easing
{

/**
 *  The Bounce class defines three easing functions to implement 
 *  bouncing motion with ActionScript animation, similar to a ball
 *  falling and bouncing on a floor with several decaying rebounds.
 *
 * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Ease, Copy Motion as ActionScript    
 * @see ../../../motionXSD.html Motion XML Elements 
 * @see fl.motion.FunctionEase 
 */  
public class Bounce
{


	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

    /**
     *  The <code>easeOut()</code> method starts the bounce motion fast 
     *  and then decelerates motion as it executes. 
     *
     *  @param t Specifies the current time, between 0 and duration inclusive.
	 *
     *  @param b Specifies the initial value of the animation property.
	 *
     *  @param c Specifies the total change in the animation property.
	 *
     *  @param d Specifies the duration of the motion.
     *
     *  @return The value of the interpolated property at the specified time.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Ease, Copy Motion as ActionScript    
     * @see fl.motion.FunctionEase      
     */  
	public static function easeOut(t:Number, b:Number,
								   c:Number, d:Number):Number
	{
		if ((t /= d) < (1 / 2.75))
			return c * (7.5625 * t * t) + b;
		
		else if (t < (2 / 2.75))
			return c * (7.5625 * (t -= (1.5 / 2.75)) * t + 0.75) + b;
		
		else if (t < (2.5 / 2.75))
			return c * (7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375) + b;
		
		else
			return c * (7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375) + b;
	}

    /**
     *  The <code>easeIn()</code> method starts the bounce motion slowly 
     *  and then accelerates motion as it executes. 
     *
     *  @param t Specifies the current time, between 0 and duration inclusive.
	 *
     *  @param b Specifies the initial value of the animation property.
	 *
     *  @param c Specifies the total change in the animation property.
	 *
     *  @param d Specifies the duration of the motion.
     *
     *  @return The value of the interpolated property at the specified time.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Ease, Copy Motion as ActionScript    
     * @see fl.motion.FunctionEase      
     */  
	public static function easeIn(t:Number, b:Number,
								  c:Number, d:Number):Number
	{
		return c - easeOut(d - t, 0, c, d) + b;
	}

    /**
     *  The <code>easeInOut()</code> method combines the motion
     *  of the <code>easeIn()</code> and <code>easeOut()</code> methods
	 *  to start the bounce motion slowly, accelerate motion, then decelerate. 
     *
     *  @param t Specifies the current time, between 0 and duration inclusive.
	 *
     *  @param b Specifies the initial value of the animation property.
	 *
     *  @param c Specifies the total change in the animation property.
	 *
     *  @param d Specifies the duration of the motion.
     *
     *  @return The value of the interpolated property at the specified time.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Ease, Copy Motion as ActionScript    
     * @see fl.motion.FunctionEase      
     */  
	public static function easeInOut(t:Number, b:Number,
									 c:Number, d:Number):Number
	{
		if (t < d/2)
			return easeIn(t * 2, 0, c, d) * 0.5 + b;
		else
			return easeOut(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b;
	}
}

}
