// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.transitions
{
import flash.events.*;
import flash.display.*;
import flash.utils.*;

/**
 * @eventType fl.transitions.TweenEvent.MOTION_CHANGE
 *
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
[Event(name="motionChange", type="fl.transitions.TweenEvent")]

/**
 * @eventType fl.transitions.TweenEvent.MOTION_FINISH
 *
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
[Event(name="motionFinish", type="fl.transitions.TweenEvent")]

/**
 * @eventType fl.transitions.TweenEvent.MOTION_LOOP
 *
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
[Event(name="motionLoop", type="fl.transitions.TweenEvent")]

/**
 * @eventType fl.transitions.TweenEvent.MOTION_RESUME
 *
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
[Event(name="motionResume", type="fl.transitions.TweenEvent")]

/**
 * @eventType fl.transitions.TweenEvent.MOTION_START
 *
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
[Event(name="motionStart", type="fl.transitions.TweenEvent")]

/**
 * @eventType fl.transitions.TweenEvent.MOTION_STOP
 *
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
[Event(name="motionStop", type="fl.transitions.TweenEvent")]

/**
 * The Tween class lets you use ActionScript to move, resize, and fade movie clips 
 * by specifying a property of the target movie clip to animate over a number
 * of frames or seconds.
 *
 * <p>The Tween class also lets you specify a variety of easing methods. "Easing" refers to 
 * gradual acceleration or deceleration during an animation, which helps your animations appear
 * more realistic. The fl.transitions.easing package provides many easing methods that contain 
 * equations for this acceleration and deceleration, which change the easing animation
 * accordingly.</p>
 *
 * <p>To use the methods and properties of the Tween class, you use the <code>new</code>
 * operator with the constructor function to create an instance of the class, and you specify an easing 
 * method as a parameter. For example:</p>
 * <listing>
 * import fl.transitions.Tween;
 * import fl.transitions.easing.~~;
 * var myTween:Tween = new Tween(myObject, "x", Elastic.easeOut, 0, 300, 3, true);
 * </listing>
 *
 * @keyword Tween, Transition
 * @includeExample examples/Tween_class.as -noswf
 * @includeExample examples/Tween_class2.as -noswf 
 * @see fl.transitions.TransitionManager
 * @see fl.transitions.easing
 * @see #Tween()
 *
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
public class Tween extends EventDispatcher
{
    /**
     * @private
     */
 	protected static var _mc:MovieClip = new MovieClip();

    /**
     * Indicates whether the tween is currently playing.
     * 
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public var isPlaying:Boolean = false;

    /**
     * The target object that is being tweened.
     * 
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */  
 	public var obj:Object = null;

    /**
     * The name of the property affected by the tween of the target object.
     * 
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public var prop:String = "";

    /**
     * The easing function which is used with the tween.
     * 
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public var func:Function = function (t:Number, b:Number, c:Number, d:Number):Number { return c*t/d + b; }

    /**
     * The initial value of the target object's designated property before the tween starts.
     * 
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public var begin:Number = NaN;

    /**
     * @private
     */
	public var change:Number = NaN;

    /**
     * Indicates whether the tween plays over a period of frames or seconds. A value of <code>true</code> will
     * cause the tween to animate over a period of seconds specified by the <code>duration</code> property. A
     * value of <code>false</code> will cause the tween to animate over a period of frames.
     * 
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public var useSeconds:Boolean = false;

    /**
     * @private
     */
	public var prevTime:Number = NaN;

    /**
     * @private
     */
	public var prevPos:Number = NaN;

    /**
     * Indicates whether the tween will loop. If the value is <code>true</code>, the tween will restart 
     * indefinitely each time the tween has completed. If the value is <code>false</code>, the tween
     * will play only once.
     * 
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public var looping:Boolean = false;

    /**
     * @private
     */ 
	private var _duration:Number = NaN;

    /**
     * @private
     */
	private var _time:Number = NaN;

    /**
     * @private
     */
	private var _fps:Number = NaN;

    /**
     * @private
     */
	private var _position:Number = NaN;

    /**
     * @private
     */
	private var _startTime:Number = NaN;

    /**
     * @private
     */
	private var _intervalID:uint = 0;

    /**
     * @private
     */
	private var _finish:Number = NaN;

    /**
     * @private
     */
	private var _timer:Timer = null;

    /**
     * The current time within the duration of the animation.
     *
     * @param t The current number of seconds that have passed within the duration of the 
     * animation if the <code>useSeconds</code> parameter was set to <code>true</code> when 
     * creating the Tween instance. If the <code>useSeconds</code> parameter of the animation 
     * was set to <code>false</code>, <code>Tween.time</code> returns the current number of 
     * frames that have passed in the Tween object animation.
     *
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
    public function get time():Number 
    {
        return this._time;
    }

    /**
     * @private (setter)
     */
	public function set time(t:Number):void 
	{
		this.prevTime = this._time;
		if (t > this.duration) {
			if (this.looping) {
				this.rewind (t - this._duration);
				this.update();
				this.dispatchEvent(new TweenEvent(TweenEvent.MOTION_LOOP, this._time, this._position));
			} else {
				if (this.useSeconds) {
					this._time = this._duration;
					this.update();
				}
				this.stop();
				this.dispatchEvent(new TweenEvent(TweenEvent.MOTION_FINISH, this._time, this._position));
			}
		} else if (t < 0) {
			this.rewind();
			this.update();
		} else {
			this._time = t;
			this.update();
		}
	}


	
    /**
     * The duration of the tweened animation in frames or seconds. This property is set as
     * a parameter when creating a new Tween instance or when calling the 
     * <code>Tween.yoyo()</code> method.
     *
     * @param d A number indicating the duration of the tweened animation in frames or seconds.
     * 
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
    public function get duration():Number 
    {
        return this._duration;
    }
    
    /**
     * @private (setter)
     */
	public function set duration(d:Number):void 
	{
		this._duration = (d <= 0) ? Infinity : d;
	}

    /**
     * The number of frames per second calculated into the tweened animation. By default the
     * current Stage frame rate is used to calculate the tweened animation. Setting this property
     * recalculates the number of increments in the animated property that is displayed each second
     * to the <code>Tween.FPS</code> property rather than the current Stage frame rate. Setting the
     * Tween.FPS property does not change the actual frame rate of the Stage.
     * <p><strong>Note:</strong> The <code>Tween.FPS</code> property returns undefined unless it 
     * is first set explicitly.</p>
     *
     * @param fps The number of frames per second of the tweened animation.
     *
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @includeExample examples\Tween_FPS.as -noswf
     */
    public function get FPS():Number 
    {
        return this._fps;
    }
    
    /**
     * @private (setter)
     */
	public function set FPS(fps:Number):void 
	{
		var oldIsPlaying:Boolean = this.isPlaying;
		this.stopEnterFrame();
		this._fps = fps;
		if (oldIsPlaying) 
		{
			this.startEnterFrame();
		}
	}


    /**
     * The current value of the target object property being tweened. This value updates 
     * with each drawn frame of the tweened animation.
     *
     * @param p The current value of the target movie clip's property being tweened.
     *
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
    public function get position():Number 
    {
        return this.getPosition(this._time);
    }
    
    /**
     * @private (setter)
     */
	public function set position(p:Number):void 
	{
		this.setPosition (p);
	}

    
    /**
     * @private
     */     
    public function getPosition(t:Number=NaN):Number 
    {
        if (isNaN(t)) t = this._time;
        return this.func (t, this.begin, this.change, this._duration);
    }

    /**
     * @private
     */ 
	public function setPosition(p:Number):void 
	{
		this.prevPos = this._position;
		if (this.prop.length)
			this.obj[this.prop] = this._position = p;
		this.dispatchEvent(new TweenEvent(TweenEvent.MOTION_CHANGE, this._time, this._position));	
	}


    /**
     * A number indicating the ending value of the target object property that is to be tweened. 
     * This property is set as a parameter when creating a new Tween instance or when calling the
     * <code>Tween.yoyo()</code> method.
     *
     * @keyword Tween
     *
     * @see #yoyo()
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */    
    public function get finish():Number 
    {
        return this.begin + this.change;
    }
    
    /**
     * @private (setter)
     */
	public function set finish(value:Number):void 
	{
		this.change = value - this.begin;
	}
	
/////////////////////////////////////////////////////////////////////////

    /**
     * Creates an instance of the Tween class. Use the constructor function with the <code>new</code> operator: <code>var myTween:Tween = new Tween()</code>.
     *
     * @param obj Object that the Tween targets.
     * @param prop Name of the property (<code>obj</code> parameter value) that will be affected.
     * @param func Name of the easing function to use.
     * @param begin Starting value of the <code>prop</code> parameter.
     * @param finish A number indicating the ending value of <code>prop</code> parameter (the target object property to be tweened).
     * @param duration Length of time of the motion; set to <code>infinity</code> if negative or omitted.
     * @param useSeconds A flag specifying whether to use seconds instead of frames. The function uses seconds if <code>true</code> or frames in relation to the value specified in the <code>duration</code> parameter if <code>false</code>.
     *
     * @keyword Transitions
     *
     * @see fl.transitions.easing
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	function Tween(obj:Object, prop:String, func:Function, begin:Number, finish:Number, duration:Number, useSeconds:Boolean=false) 
	{
		if (!arguments.length) return;
		this.obj = obj;
		this.prop = prop;
		this.begin = begin;
		this.position = begin;
		this.duration = duration;
		this.useSeconds = useSeconds;
		if (func is Function) this.func = func;
		this.finish = finish;
		this._timer = new Timer(100);
		this.start();
	}

    /**
     * Instructs the tweened animation to continue tweening from its current animation point to
     * a new finish and duration point.
     *
     * @param finish A number indicating the ending value of the target object property that is
     * to be tweened.
     *
     * @param duration A number indicating the length of time or number of frames for the tween 
     * motion; duration is measured in length of time if the <code>Tween.start()</code> 
     * <code>useSeconds</code> parameter is set to <code>true</code>, or measured in frames if
     * it is set to <code>false</code>.
     *
     * @keyword Tween
     *
     * @see #start()
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */  
	public function continueTo(finish:Number, duration:Number):void {
		this.begin = this.position;
		this.finish = finish;
		if (!isNaN(duration))
			this.duration = duration;
		this.start();
	}
	
    /**
     * Instructs the tweened animation to play in reverse from its last direction of tweened 
     * property increments. If this method is called before a Tween object's animation is complete, 
     * the animation abruptly jumps to the end of its play and then plays in a reverse direction
     * from that point. You can achieve an effect of an animation completing its entire play and 
     * then reversing its entire play by calling the <code>Tween.yoyo()</code> method within a
     * <code>TweenEvent.MOTION_FINISH</code> event handler. This process ensures that the reverse 
     * effect of the <code>Tween.yoyo()</code> method does not begin until the current tweened 
     * animation is complete.
     *
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public function yoyo():void 
	{
		this.continueTo(this.begin, this.time);
	}

    /**
     * @private
     */
	protected function startEnterFrame():void 
	{
		if (isNaN(this._fps)) 
		{
			// original frame rate dependent way
			_mc.addEventListener(Event.ENTER_FRAME, this.onEnterFrame, false, 0, true);
		} 
		else 
		{
			// custom frame rate
			var milliseconds:Number = 1000 / this._fps;
			this._timer.delay = milliseconds;
            this._timer.addEventListener(TimerEvent.TIMER, this.timerHandler, false, 0, true);
            this._timer.start();
		}
		this.isPlaying = true;
	}

    /**
     * @private
     */ 
	protected function stopEnterFrame():void 
	{
		if (isNaN(this._fps)) 
		{
			// original frame rate dependent way:
			_mc.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		} 
		else 
		{
			// custom frame rate
			this._timer.stop();
		}
		this.isPlaying = false;
	}

    /**
     * Starts the play of a tweened animation from its starting point. This method is used for 
     * restarting a Tween from the beginning of its animation after it stops or has completed 
     * its animation.
     *
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */     
	public function start():void 
	{
		this.rewind();
		this.startEnterFrame();
		this.dispatchEvent(new TweenEvent(TweenEvent.MOTION_START, this._time, this._position));
	}

    /**
     * Stops the play of a tweened animation at its current value.
     *
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */     
	public function stop():void 
	{
		this.stopEnterFrame();
		this.dispatchEvent(new TweenEvent(TweenEvent.MOTION_STOP, this._time, this._position));
	}

    /**
     * Resumes the play of a tweened animation that has been stopped. Use this method to continue
     * a tweened animation after you have stopped it by using the <code>Tween.stop()</code> method.
     *
     * <p><strong>Note:</strong> Use this method on frame-based tweens only. A tween is set 
     * to be frame based at its creation by setting the <code>useSeconds</code> parameter to false.</p>
     *
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public function resume():void 
	{
		this.fixTime();
		this.startEnterFrame();
		this.dispatchEvent(new TweenEvent(TweenEvent.MOTION_RESUME, this._time, this._position));
	}

    /**
     * Moves the play of a tweened animation back to its starting value. If 
     * <code>Tween.rewind()</code> is called while the tweened animation is still playing, the 
     * animation rewinds to its starting value and continues playing. If 
     * <code>Tween.rewind()</code> is called while the tweened animation has been stopped or has
     * finished its animation, the tweened animation rewinds to its starting value and remains 
     * stopped. Use this method to rewind a tweened animation to its starting point after you have
     * stopped it by using the <code>Tween.stop()</code> method or to rewind a tweened animation 
     * during its play.
     *
     * @param t Starting value.
     *
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */     
	public function rewind(t:Number=0):void 
	{
		this._time = t;
		this.fixTime();
		this.update(); 
	}

    /**
     * Forwards the tweened animation directly to the final value of the tweened animation.
     *
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */     
	public function fforward():void 
	{
		this.time = this._duration;
		this.fixTime();
	}

    /**
     * Forwards the tweened animation to the next frame of an animation that was stopped. Use this
     * method to forward a frame at a time of a tweened animation after you use the 
     * <code>Tween.stop()</code> method to stop it.
     *
     * <p><strong>Note:</strong> Use this method on frame-based tweens only. A tween is
     * set to frame based at its creation by setting the <code>useSeconds</code> parameter to 
     * <code>false</code>.</p>
     *
     * @keyword Tween
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */     
	public function nextFrame():void 
	{
		if (this.useSeconds) 
			this.time = (getTimer() - this._startTime) / 1000;
		else 
			this.time = this._time + 1;
	}

    /**
     * @private
     */
	protected function onEnterFrame(event:Event):void 
	{
		this.nextFrame();
	}

    /**
     * @private
     */
	protected function timerHandler(timerEvent:TimerEvent):void 
	{
		this.nextFrame();
		timerEvent.updateAfterEvent();
	}

    /**
     * Plays the previous frame of the tweened animation from the current stopping point of an 
     * animation that was stopped. Use this method to play a tweened animation backwards one frame 
     * at a time after you use the <code>Tween.stop()</code> method to stop it.
     *
     * <p><strong>Note:</strong> Use this method on frame-based tweens only. A tween is set
     * to frame based at its creation by setting the <code>Tween.start()</code> 
     * <code>useSeconds</code> parameter to <code>false</code>.</p>
     *
     * @keyword Tween
     *
     * @see #start()
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */ 
	public function prevFrame():void 
	{
		if (!this.useSeconds) this.time = this._time - 1;
	}
	
 
	///////// PRIVATE METHODS
    /**
     * @private
     */
	private function fixTime():void 
	{
		if (this.useSeconds) 
			this._startTime = getTimer() - this._time*1000;
	}

    /**
     * @private
     */ 
	private function update():void 
	{
		this.setPosition(this.getPosition(this._time));
	}
	
	
}
}