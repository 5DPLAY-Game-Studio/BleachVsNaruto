// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.motion
{
/**
 * The SimpleEase class allows you to control an animation with 
 * the kind of percentage easing that is used in the Flash timeline.
 * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword SimpleEase, Copy Motion as ActionScript    
 * @see ../../motionXSD.html Motion XML Elements    
 */
public class SimpleEase implements ITween
{
    /**
     * @private
     */
	private var _ease:Number = 0;

    /**
     * A percentage between <code>-1</code> (100% ease in or acceleration) and <code>1</code> (100% ease out or deceleration). 
     * Defaults to <code>0</code>, which means that the tween animates at a constant speed, without acceleration or deceleration.
     * @default 0
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword SimpleEase, Copy Motion as ActionScript    
     */
	public function get ease():Number
	{
		return this._ease;
	}

    /**
     * @private (setter)
     */
	public function set ease(value:Number):void
	{
		this._ease = 
			  value >  1   ?  1 
			: value < -1   ? -1 
			: isNaN(value) ?  0
			: value;
	}


    /**
     * @private
     */
	private var _target:String = '';

    /**
     * The name of the animation property to target.
     * @see fl.motion.ITween#target
     * @default ""
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public function get target():String
	{
		return this._target;
	}

    /**
     * @private (setter)
     */
	public function set target(value:String):void
	{
		this._target = value;
	}



    /**
     * Constructor for SimpleEase instances.
     *
     * @param xml Optional E4X XML object defining a SimpleEase object in Motion XML format.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword SimpleEase, Copy Motion as ActionScript    
     */
	function SimpleEase(xml:XML=null)
	{
		this.parseXML(xml);
	}



    /**
     * @private
     */
	private function parseXML(xml:XML=null):SimpleEase
	{
		if (xml)
		{
			if (xml.@ease.length())
				this.ease = Number(xml.@ease);
			if (xml.@target.length())
				this.target = xml.@target;
		}
		return this;
	}
	
    /**
     * Calculates an interpolated value for a numerical property of animation, 
     * using a percentage of quadratic easing.
     * The function signature matches that of the easing functions in the fl.motion.easing package.
     *
     * @param time This value is between <code>0</code> and <code>duration</code>, inclusive.
     * You can choose any unit (for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>duration</code> unit.
	 *
     * @param begin The value of the animation property at the start of the tween, when time is <code>0</code>.
     *
     * @param change The change in the value of the animation property over the course of the tween. 
     * This value can be positive or negative. For example, if an object rotates from 90 to 60 degrees, the <code>change</code> is <code>-30</code>.
     *
     * @param duration The length of time for the tween. This value must be greater than zero.
     * You can choose any unit (for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>time</code> unit.
     *
     * @param percent A percentage between <code>-1</code> (100% ease in or acceleration) and <code>1</code> (100% ease out or deceleration). 
     * 
     * @return The interpolated value at the specified time.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword SimpleEase, Copy Motion as ActionScript     
     * @see fl.motion.easing     
     */
	public static function easeQuadPercent(time:Number, begin:Number, change:Number, duration:Number, percent:Number):Number 
	{
		if (duration <= 0) return NaN;
		if (time <= 0) return begin;
		if ((time/=duration) >= 1) return begin+change; 
		
		// linear tween if percent is 0
		if (!percent) return change*time + begin;
		if (percent > 1) percent = 1;
		else if (percent < -1) percent = -1;
		
		// ease in if percent is negative
		if (percent < 0) return change*time*(time*(-percent) + (1+percent)) + begin; 
		
		// ease out if percent is positive
		return change*time*((2-time)*percent + (1-percent)) + begin; 
	}



    /**
     * Calculates an interpolated value for a numerical property of animation, 
     * using a linear tween of constant velocity.
     * The function signature matches that of the easing functions in the fl.motion.easing package.
     *
     * @param time This value is between <code>0</code> and <code>duration</code>, inclusive.
     * You can choose any unit(for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>duration</code> unit.
	 *
     * @param begin The value of the animation property at the start of the tween, when time is <code>0</code>.
     *
     * @param change The change in the value of the animation property over the course of the tween. 
     * This value can be positive or negative. For example, if an object rotates from 90 to 60 degrees, the <code>change</code> is <code>-30</code>.
     *
     * @param duration The length of time for the tween. This value must be greater than zero.
     * You can choose any unit (for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>time</code> unit.
     *
     * @return The interpolated value at the specified time.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword SimpleEase, Copy Motion as ActionScript
     * @see fl.motion.easing    
     */
	public static function easeNone(time:Number, begin:Number, change:Number, duration:Number):Number 
	{
		if (duration <= 0) return NaN;
		if (time <= 0) return begin;
		if (time >= duration) return begin+change; 
		return change*time/duration + begin;
	}
	

    /**
     * Calculates an interpolated value for a numerical property of animation,
     * using a percentage of quadratic easing. 
     * The percent value is read from the SimpleEase instance's <code>ease</code> property
     * rather than being passed into the method.
     * Using this property allows the function signature to match the ITween interface.
     *
     * @param time This value is between <code>0</code> and <code>duration</code>, inclusive.
     * You can choose any unit (for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>duration</code> unit.
	 *
     * @param begin The value of the animation property at the start of the tween, when time is <code>0</code>.
     *
     * @param change The change in the value of the animation property over the course of the tween. 
     * This value can be positive or negative. For example, if an object rotates from 90 to 60 degrees, the <code>change</code> is <code>-30</code>.
     *
     * @param duration The length of time for the tween. This value must be greater than zero.
     * You can choose any unit (for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>time</code> unit.
     *
     * @return The interpolated value at the specified time.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword SimpleEase, Copy Motion as ActionScript
     * @see #ease      
     */
	public function getValue(time:Number, begin:Number, change:Number, duration:Number):Number
	{
		return easeQuadPercent(time, begin, change, duration, this.ease);
	}



	
	
}
}