// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.motion.easing
{

/**
 *  The Exponential class defines three easing functions to implement 
 *  motion with ActionScript animation. It produces
 *  an effect similar to the popular 
 *  "Zeno's paradox" style of scripted easing,
 *  where each interval of time decreases the remaining
 *  distance by a constant proportion. 
 *  
 * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Ease, Copy Motion as ActionScript    
 * @see ../../../motionXSD.html Motion XML Elements 
 * @see fl.motion.FunctionEase  
 */  
public class Exponential
{


	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

    /**
     *  The <code>easeIn()</code> method starts motion slowly 
     *  and then accelerates motion as it executes. 
     *
     *  @param t Specifies the current time, between 0 and duration inclusive.
	 *
     *  @param b Specifies the initial position of a component.
	 *
     *  @param c Specifies the total change in position of the component.
	 *
     *  @param d Specifies the duration of the effect, in milliseconds.
     *
     *  @return Number corresponding to the position of the component.
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
		return t == 0 ? b : c * Math.pow(2, 10 * (t / d - 1)) + b;
	}

    /**
     *  The <code>easeOut()</code> method starts motion fast 
     *  and then decelerates motion to a zero velocity as it executes. 
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
		return t == d ? b + c : c * (-Math.pow(2, -10 * t / d) + 1) + b;
	}

    /**
     *  The <code>easeInOut()</code> method combines the motion
     *  of the <code>easeIn()</code> and <code>easeOut()</code> methods
	 *  to start the motion from a zero velocity, accelerate motion, 
	 *  then decelerate to a zero velocity. 
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
		if (t == 0)
			return b;

		if (t == d)
			return b + c;

		if ((t /= d / 2) < 1)
			return c / 2 * Math.pow(2, 10 * (t - 1)) + b;

		return c / 2 * (-Math.pow(2, -10 * --t) + 2) + b;
	}
}

}
