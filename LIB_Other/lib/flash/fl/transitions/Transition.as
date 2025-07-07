// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
/*
example of transition code:

import mx.transitions.*;

TransitionManager.start( this, { type:fl.transitions.Iris,
                                 direction:Transition.IN,
                                 duration:2,
                                 easing:Strong.easeInOut,
                                 startPoint:5,
                                 shape:Iris.SQUARE } ); 
*/

package fl.transitions
{
import flash.events.EventDispatcher;
import flash.display.*;
import flash.geom.*;
import flash.events.Event;

/**
 * The Transition class is the base class for all transition classes. You do not use or access this class directly. It allows transition-based classes to share some common behaviors and properties that are accessed by an instance of the TransitionManager class.    
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Transition    
 * @see fl.transitions.TransitionManager
 * @see fl.transitions.Tween
 * @see fl.transitions.easing
 * @includeExample examples\Transition_example.as -noswf
 */
public class Transition extends EventDispatcher
{

/**
 * Constant for the <code>direction</code> property that determines the type of easing.
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Transition
 */     
    public static const IN:uint = 0;
    
/**
 * Constant for the direction property that determines the type of easing.
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Transition
 */      
	public static const OUT:uint = 1;


    /**
     * @private
     */ 
	public function get type():Class
	{
		return Transition;
	}
	//public var type:Object = Transition;
	//public var className:String = "Transition";

    /**
     * @private
     */
	public var ID:int;

    /**
     * @private
     */ 
	protected var _content:MovieClip;

    /**
     * @private
     */
	protected var _manager:TransitionManager;

    /**
     * @private
     */
	protected var _direction:uint = 0;

    /**
     * @private
     */
	protected var _duration:Number = 2;

    /**
     * @private
     */
	protected var _easing:Function;

    /**
     * @private
     */
	protected var _progress:Number;

    /**
     * @private
     */
	protected var _innerBounds:Rectangle;

    /**
     * @private
     */
	protected var _outerBounds:Rectangle;

    /**
     * @private
     */
	protected var _width:Number = NaN;

    /**
     * @private
     */
	protected var _height:Number = NaN;

    /**
     * @private
     */
	protected var _twn:Tween;
	

	/////////// GETTER/SETTER PROPERTIES
    /**
     * @private
     */
	public function set manager (mgr:TransitionManager):void 
	{
		if (this._manager) {
			this.removeEventListener ("transitionInDone", this._manager.transitionInDone);
			this.removeEventListener ("transitionOutDone", this._manager.transitionOutDone);
		}
		this._manager = mgr;
		this.addEventListener ("transitionInDone", this._manager.transitionInDone);
		this.addEventListener ("transitionOutDone", this._manager.transitionOutDone);
	}

    /**
     * @private
     */
	public function get manager():TransitionManager 
	{
		return this._manager;
	}

    /**
     * @private
     */
	public function set content(c:MovieClip):void 
	{
		if (c) 
		{
			this._content = c;
			if (this._twn)
				this._twn.obj = c;
		}
	}
	
    /**
     * @private
     */    
	public function get content():MovieClip 
	{
		return this._content;
	}

/**
 * Determines the easing direction for the Tween instance. Use one of the constants from
 * the Transition class: <code>Transition.IN</code> or <code>Transition.OUT</code>.
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Transition
 */     
	public function get direction():Number 
	{
		return this._direction;
	}

	public function set direction(direction:Number):void 
	{
		// direction is 0 for IN or 1 for OUT 
		this._direction = direction ? 1 : 0;
	}
	
/**
 * Determines the length of time for the Tween instance. 
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Transition
 */         
	public function get duration():Number 
	{
		return this._duration;
	}

	public function set duration (d:Number):void 
	{
		if (d) 
		{
			this._duration = d;
			if (this._twn)			
				this._twn.duration = d;
		}
	}
	 
/**
 * Sets the tweening effect for the animation. Use one of the effects in the fl.transitions or
 * fl.transitions.easing packages. 
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Transition
 */     
	public function get easing():Function 
	{
		return this._easing;
	}

	public function set easing(e:Function):void 
	{
		// if the function is the string name, evaluate to a reference
		this._easing = e;
		if (this._twn)
			this._twn.func = e;
	}
	
    /**
     * @private
     */ 
	// p is a number between 0 and 1 representing the state of the transition
	public function set progress(p:Number):void  
	{
		//trace('Transition progress: ' + p);
		// if the incoming progress is the same as the current progress, do nothing
		if (this._progress == p) return;
		this._progress = p;
		// transition-in goes from 0 to 1
		// transition-out goes from 1 to 0
		if (this._direction) 
			this._render (1-p);
		else
			this._render (p);
		this.dispatchEvent(new Event("transitionProgress"));
	}

    /**
     * @private
     */ 
	public function get progress():Number {
		return this._progress;
	}




	///////// CONSTRUCTOR
	/*
	transParams:
	- direction (0 or 1)
	- duration (seconds)
	- easing (an easing function)
	- additional parameters can be defined for individual transitions
	*/	
    
    /**
     * @private
     */ 
	function Transition(content:MovieClip, transParams:Object, manager:TransitionManager) 
	{
		//this.init(content, transParams, manager);
		this.content = content;
		this.direction = transParams.direction;
		this.duration = transParams.duration;
		this.easing = transParams.easing;
		this.manager = manager;
		this._innerBounds = this.manager._innerBounds;
		this._outerBounds = this.manager._outerBounds;
		this._width = this.manager._width;
		this._height = this.manager._height;
		this._resetTween();
	}

    /**
     * @private
     */
	public function start():void 
	{
		this.content.visible = true;
		this._twn.start();
	}
	
    /**
     * @private
     */
	public function stop():void  
	{
		this._twn.fforward();
		this._twn.stop();
	}

    /**
     * @private remove any movie clips, masks, etc. created by this transition
     */ 
	public function cleanUp():void 
	{
		this.removeEventListener("transitionInDone", this._manager.transitionInDone);
		this.removeEventListener("transitionOutDone", this._manager.transitionOutDone);
		//this.removeEventListener("transitionProgress", this._manager);
		this.stop();
	}

    /**
     * @private
     */ 
	public function drawBox(mc:MovieClip, x:Number, y:Number, w:Number, h:Number):void 
	{
		mc.graphics.moveTo(x, y);
		mc.graphics.lineTo(x+w, y);
		mc.graphics.lineTo(x+w, y+h);
		mc.graphics.lineTo(x, y+h);
		mc.graphics.lineTo(x, y);
	}

    /**
     * @private
     */
	public function drawCircle(mc:MovieClip, x:Number, y:Number, r:Number):void 
	{
		mc.graphics.moveTo(x+r, y);
		mc.graphics.curveTo(r+x, Math.tan(Math.PI/8)*r+y, Math.sin(Math.PI/4)*r+x, Math.sin(Math.PI/4)*r+y);
		mc.graphics.curveTo(Math.tan(Math.PI/8)*r+x, r+y, x, r+y);
		mc.graphics.curveTo(-Math.tan(Math.PI/8)*r+x, r+y, -Math.sin(Math.PI/4)*r+x, Math.sin(Math.PI/4)*r+y);
		mc.graphics.curveTo(-r+x, Math.tan(Math.PI/8)*r+y, -r+x, y);
		mc.graphics.curveTo(-r+x, -Math.tan(Math.PI/8)*r+y, -Math.sin(Math.PI/4)*r+x, -Math.sin(Math.PI/4)*r+y);
		mc.graphics.curveTo(-Math.tan(Math.PI/8)*r+x, -r+y, x, -r+y);
		mc.graphics.curveTo(Math.tan(Math.PI/8)*r+x, -r+y, Math.sin(Math.PI/4)*r+x, -Math.sin(Math.PI/4)*r+y);
		mc.graphics.curveTo(r+x, -Math.tan(Math.PI/8)*r+y, r+x, y);
	}
	
	
	/////////// PRIVATE METHODS

    /**
     * @private abstract method - to be overridden in subclasses
     */ 
	protected function _render(p:Number):void {}

    /**
     * @private
     */   
	private function _resetTween():void 
	{
		// do clean-up of possibly existing tween
		if (this._twn)
		{
			this._twn.stop();
			this._twn.removeEventListener(TweenEvent.MOTION_FINISH, this.onMotionFinished);
		}
		this._twn = new Tween (this,
							   '', 
							   this.easing, 
							   0, 
							   1, 
							   this.duration,
							   true);
		// need to first stop the tween and THEN set the prop to avoid rendering glitches
		this._twn.stop();
		this._twn.prop = "progress";
		this._twn.addEventListener(TweenEvent.MOTION_FINISH, this.onMotionFinished, false, 0, true);	
	}

    /**
     * @private
     */ 
	private function _noEase (t:Number, b:Number, c:Number, d:Number):Number {
		return c*t/d + b; 
	}
	
	
	/////////// EVENT HANDLERS

    /**
     * @private event that comes from an instance of fl.transitions.Tween
     */ 
	public function onMotionFinished(src:Object):void 
	{
		if (this.direction==Transition.OUT) 
			this.dispatchEvent(new Event("transitionOutDone"));
		else
			this.dispatchEvent(new Event("transitionInDone"));
	}


}
}
