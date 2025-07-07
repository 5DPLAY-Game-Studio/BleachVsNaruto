// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.transitions.easing
{

/**
 * The Elastic class defines three easing functions to implement 
 * motion with ActionScript animation, where the motion is defined by 
 * an exponentially decaying sine wave. 
 *
 * @playerversion Flash 9.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
* @keyword Ease, Transition    
 * @see fl.transitions.TransitionManager  
 */  
public class Elastic
{


	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

    /**
     * The <code>easeIn()</code> method starts motion slowly 
     * and then accelerates motion as it executes. 
     *
     * @param t Specifies the current time, between 0 and duration inclusive.
     *
     * @param b Specifies the initial value of the animation property.
     *
     * @param c Specifies the total change in the animation property.
     *
     * @param d Specifies the duration of the motion.
     *
     * @param a Specifies the amplitude of the sine wave.
     *
     * @param p Specifies the period of the sine wave.
     *
     * @return The value of the interpolated property at the specified time.
     *
     * @includeExample examples/Elastic.easeIn.1.as -noswf
     *
     * @playerversion Flash 9.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
* @keyword Ease, Transition    
     * @see fl.transitions.TransitionManager      
     */
	public static function easeIn(t:Number, b:Number,
								  c:Number, d:Number,
								  a:Number = 0, p:Number = 0):Number
	{
		if (t == 0)
			return b;
		
		if ((t /= d) == 1)
			return b + c;
		
		if (!p)
			p = d * 0.3;
		
		var s:Number;
		if (!a || a < Math.abs(c))
		{
			a = c;
			s = p / 4;
		}
		else
		{
			s = p / (2 * Math.PI) * Math.asin(c / a);
		}

		return -(a * Math.pow(2, 10 * (t -= 1)) *
				 Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
	}

    /**
     * The <code>easeOut()</code> method starts motion fast 
     * and then decelerates motion as it executes. 
     *
     * @param t Specifies the current time, between 0 and duration inclusive.
     *
     * @param b Specifies the initial value of the animation property.
     *
     * @param c Specifies the total change in the animation property.
     *
     * @param d Specifies the duration of the motion.
     *
     * @param a Specifies the amplitude of the sine wave.
     *
     * @param p Specifies the period of the sine wave.
     *
     * @return The value of the interpolated property at the specified time.
     *
     * @includeExample examples/Elastic.easeOut.1.as -noswf
     *
     * @playerversion Flash 9.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
* @keyword Ease, Transition    
     * @see fl.transitions.TransitionManager      
     */
	public static function easeOut(t:Number, b:Number,
								   c:Number, d:Number,
								   a:Number = 0, p:Number = 0):Number
	{
		if (t == 0)
			return b;
			
		if ((t /= d) == 1)
			return b + c;
		
		if (!p)
			p = d * 0.3;

		var s:Number;
		if (!a || a < Math.abs(c))
		{
			a = c;
			s = p / 4;
		}
		else
		{
			s = p / (2 * Math.PI) * Math.asin(c / a);
		}

		return a * Math.pow(2, -10 * t) *
			   Math.sin((t * d - s) * (2 * Math.PI) / p) + c + b;
	}

    /**
     * The <code>easeInOut()</code> method combines the motion
     * of the <code>easeIn()</code> and <code>easeOut()</code> methods
     * to start the motion slowly, accelerate motion, then decelerate. 
     *
     * @param t Specifies the current time, between 0 and duration inclusive.
     *
     * @param b Specifies the initial value of the animation property.
     *
     * @param c Specifies the total change in the animation property.
     *
     * @param d Specifies the duration of the motion.
     *
     * @param a Specifies the amplitude of the sine wave.
     *
     * @param p Specifies the period of the sine wave.
     *
     * @return The value of the interpolated property at the specified time.
     *
     * @see fl.transitions.TransitionManager  
     *
     * @includeExample examples/Elastic.easeInOut.1.as -noswf
     *
     * @playerversion Flash 9.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
* @keyword Ease, Transition    
     */
	public static function easeInOut(t:Number, b:Number,
									 c:Number, d:Number,
									 a:Number = 0, p:Number = 0):Number
	{
		if (t == 0)
			return b;
			
		if ((t /= d / 2) == 2)
			return b + c;
			
		if (!p)
			p = d * (0.3 * 1.5);

		var s:Number;
		if (!a || a < Math.abs(c))
		{
			a = c;
			s = p / 4;
		}
		else
		{
			s = p / (2 * Math.PI) * Math.asin(c / a);
		}

		if (t < 1)
		{
			return -0.5 * (a * Math.pow(2, 10 * (t -= 1)) *
				   Math.sin((t * d - s) * (2 * Math.PI) /p)) + b;
		}
		
		return a * Math.pow(2, -10 * (t -= 1)) *
			   Math.sin((t * d - s) * (2 * Math.PI) / p ) * 0.5 + c + b;
	}
}

}
