// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.transitions
{
import flash.events.EventDispatcher;
import flash.display.*;
import flash.geom.Rectangle;
import flash.events.Event;

/**
 * The TransitionManager class defines animation effects. It allows you to apply one of ten 
 * animation effects to movie clips. When creating custom components, you can use the 
 * TransitionManager class to apply animation effects to movie clips in your component's 
 * visual interface. The transition effects in fl.transitions.easing are defined as a set of
 * transition classes that all extend the base class fl.transitions.Transition. You apply 
 * transitions through an instance of a TransitionManager only; you do not instantiate them 
 * directly. The TransitionManager class implements animation events. 
 * <p>You can create a TransitionManager instance in two ways:</p>
 * <ul><li>Call the <code>TransitionManager.start()</code> method. This is the simplest and recommended way to create a TransitionManager instance.</li>
 * <li>Use the <code>new</code> operator. You then designate the transition properties 
 * and start the transition effect in a second step by calling the 
 * <code>TransitionManager.startTransition()</code> method.</li></ul>
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Transition    
 * @see #start() TransitionManager.start()
 * @see #TransitionManager() TransitionManager constructor function
 * @see #startTransition() TransitionManager.startTransition()
 * @see fl.transitions.Tween
 * @see fl.transitions.easing
 * @includeExample TransitionManager_example.as -noswf
 */
public class TransitionManager extends EventDispatcher
{

    /**
     * @private
     */
	private static var IDCount:int = 0;

    /**
     * @private
     */ 
	public var type:Object = TransitionManager;

    /**
     * @private
     */
	public var className:String = "TransitionManager";

    /**
     * @private
     */ 
	private var _content:MovieClip;

    /**
     * @private
     */
	private var _transitions:Object; // indexed by ID

    /**
     * @private
     */
	public var _innerBounds:Rectangle;

    /**
     * @private
     */
	public var _outerBounds:Rectangle;

    /**
     * @private
     */
	public var _width:Number = NaN;

    /**
     * @private
     */
	public var _height:Number = NaN;

    /**
     * @private
     */
	private var _contentAppearance:Object;

    /**
     * @private
     */
	private var _visualPropList:Object = 
	{
		x:null,
		y:null,
		scaleX:null,
		scaleY:null,
		alpha:null,
		rotation:null	
	}
    
    /**
     * @private
     */    
	private var _triggerEvent:String;
	
	
	//////////// GETTERS/SETTERS

/**
 * The movie clip instance to which TransitionManager is to apply a transition.
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword content, Transition    
 */
	public function get content():MovieClip 
	{
		return this._content;
	}

	public function set content(c:MovieClip):void 
	{
		this._content = c;
		this.saveContentAppearance();
	}

    /**
     * @private this was changed from get transitions() to get transitionsList() because hitting compile error
     */  	
	public function get transitionsList():Object 
	{
		return this._transitions;
	}

    /**
     * @private
     */
	public function get numTransitions():Number 
	{
		var n:Number = 0;
		for each (var t:Transition in this._transitions) n++;
		return n;
	}

    /**
     * @private
     */ 
	public function get numInTransitions():Number 
	{
		var n:Number = 0;
		var ts:Object = this._transitions;
		for each (var t:Transition in ts) if (!t.direction) n++;
		return n;
	}


    /**
     * @private
     */
	public function get numOutTransitions():Number 
	{
		var n:Number = 0;
		var ts:Object = this._transitions;
		for each (var t:Transition in ts) if (t.direction) n++;
		return n;
	}

/**
 * An object that contains the saved visual properties of the content (target movie clip) 
 * to which the transitions will be applied. 
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword contentAppearance, Transition    
 */
	public function get contentAppearance():Object 
	{
		return this._contentAppearance;
	}

	////////// STATIC METHODS
 /**
  * Creates a new TransitionManager instance, designates the target object, applies a transition, and starts the transition. Specifically, calling this method creates an instance of the TransitionManager class if one does not already exist, creates an instance of the specified transition class designated in the <code>transParams</code> parameter, and then starts the transition. The transition is applied to the movie clip that is designated in the <code>content</code> parameter.
  * <p>For example:</p>
  * <listing>
  * import fl.transitions.~~;
  * import fl.transitions.easing.~~;
  *   
  * TransitionManager.start(myMovieClip, {type:Zoom, direction:Transition.IN, duration:1, easing:Bounce.easeOut});
  * </listing>
  * @param content The MovieClip object to which to apply the transition effect.
  * @param transParams A collection of parameters that are passed within an object. The 
  * <code>transParams</code> object should contain a <code>type</code> parameter that indicates
  * the transition effect class to be applied, followed by <code>direction</code>, <code>duration</code>,
  * and <code>easing</code> parameters. In addition, you must include any parameters required by that 
  * transition effect class. For example, the fl.transitions.Iris transition effect class requires additional
  * <code>startPoint</code> and <code>shape</code> parameters. So, in addition to the
  * <code>type</code>, <code>duration</code>, and <code>easing</code> parameters that every
  * transition requires, you would also add (to the <code>transParams</code> object) the 
  * <code>startPoint</code> and <code>shape</code> parameters that the fl.transitions.Iris 
  * effect requires. 
  * @return The Transition instance.
  * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Transition 
  */
	public static function start(content:MovieClip, transParams:Object):Transition 
	{
		// create a transition manager as needed
		if (!content.__transitionManager) 
		{
			content.__transitionManager = new TransitionManager(content);
		}
		// Make some assumptions about the event that is trigging this
		// transition.  Behavior/actionscript can override this by
		// setting _triggerEvent after calling start().
		if (transParams.direction == 1)
			content.__transitionManager._triggerEvent = "hide";
		else
			content.__transitionManager._triggerEvent = "reveal";
		return content.__transitionManager.startTransition(transParams);
	}	
	
	
	///////// CONSTRUCTOR

 /**
  * Constructor function for creating a new TransitionManager instance. However, the <code>TransitionManager.start()</code> method is a more efficient way of creating and implementing a TransitionManager instance. If you do use the TransitionManager constructor function to create an instance, use the <code>new</code> operator then designate the transition properties and start the transition effect in a second step by calling the <code>TransitionManager.startTransition()</code> method.
  * <p>For example:</p>
  * <listing>
  * import fl.transitions.~~;
  * import fl.transitions.easing.~~;
  *     
  * var myTransitionManager:TransitionManager = new TransitionManager(myMovieClip);
  * myTransitionManager.startTransition({type:Zoom, direction:Transition.IN, duration:1, easing:Bounce.easeOut});
  * </listing>
  * @param content The MovieClip object to which to apply the transition effect.
  * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Transition 
  * @see #start() TransitionManager.start()
  * @see #startTransition() TransitionManager.startTransition()
  */
	function TransitionManager(content:MovieClip) {
		this.content = content;
		this._transitions = {};
	}	

	///////// PUBLIC METHODS
    
/**
  * Creates a transition instance and starts it. If a matching transition already exists,
  * the existing transition is removed and a new transition is created and started. This method
  * is used in conjunction with the constructor function.
  * <p>For example:</p>
  * <listing>
  * import fl.transitions.~~;
  * import fl.transitions.easing.~~;
  *       
  * var myTransitionManager:TransitionManager = new TransitionManager(myMovieClip);
  * myTransitionManager.startTransition({type:Zoom, direction:Transition.IN, duration:1, easing:Bounce.easeOut});
  * </listing>
  * <p>Alternatively, you can use the <code>TransitionManager.start()</code> method, which is
  * a more efficient way of implementing a transition effect. </p>
  * @param transParams A collection of parameters that are passed within an object. The 
  * <code>transParams</code> object should contain a <code>type</code> parameter that indicates
  * the transition effect class to be applied, followed by direction, duration, and easing 
  * parameters. In addition, you must include any parameters required by that transition effect 
  * class. For example, the fl.transitions.Iris transition effect class requires additional
  * <code>startPoint</code> and <code>shape</code> parameters. So, in addition to the
  * <code>type</code>, <code>duration</code>, and <code>easing</code> parameters that every
  * transition requires, you would also add (to the <code>transParams</code> object) the 
  * <code>startPoint</code> and <code>shape</code> parameters that the fl.transitions.Iris 
  * effect requires. 
  * @return The Transition instance.
  * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Transition 
  * @see #start() TransitionManager.start()
  * @see #TransitionManager() TransitionManager constructor function
  */    
	// start a transition specified by the parameters
	// 
	public function startTransition(transParams:Object):Transition 
	{
		// look for an existing transition that matches the supplied params
		// remove the transition that matches
		this.removeTransition(this.findTransition(transParams));
		var theClass:Class = transParams.type;
		var t:Transition = new theClass(this._content, transParams, this);
		this.addTransition(t);
		t.start();
		return t;
	}

    /**
     * @private
     */
	public function addTransition(trans:Transition):Transition 
	{
		trans.ID = ++TransitionManager.IDCount;
		this._transitions[trans.ID] = trans;
		return trans;
	}

    /**
     * @private
     */ 
	public function removeTransition(trans:Transition):Boolean  
	{
 		if (!trans || !this._transitions || !this._transitions[trans.ID]) 
			return false;
		trans.cleanUp();
		return delete this._transitions[trans.ID];
	}

    /**
     * @private
     */ 
	public function findTransition(transParams:Object):Transition 
	{
		// go through the params and find the corresponding transition if it exists
		for each (var t:Transition in this._transitions) 
		{
			if (t.type == transParams.type) 
				return t;
		}
		return null;
	}

    /**
     * @private
     */
	public function removeAllTransitions():void 
	{
		for each (var t:Transition in this._transitions) 
		{
			t.cleanUp();
			this.removeTransition(t);
		}
	}

    /**
     * @private
     */ 
	public function saveContentAppearance():void 
	{
		var c:MovieClip = this._content;
		if (!this._contentAppearance) 
		{
			var a:Object = this._contentAppearance = {};
			for (var i:String in this._visualPropList)  
			{
				//trace('i: ' + i);
				a[i] = c[i];
				//trace('c[i]: ' + c[i]);			
			}
			a.colorTransform = c.transform.colorTransform;
		}
		this._innerBounds = c.getBounds(c);
		this._outerBounds = c.getBounds(c.parent);
		this._width = c.width;
		this._height = c.height;
		
	}

    /**
     * @private
     */
	public function restoreContentAppearance():void 
	{
		var c:MovieClip = this._content;
		var a:Object = this._contentAppearance;
		for (var i:String in this._visualPropList) {
			c[i] = a[i];			
		}
		c.transform.colorTransform = a.colorTransform;
	}

	///////// EVENT HANDLERS

    /**
     * @private
     */
	internal function transitionInDone (e:Object):void 
	{
		this.removeTransition (e.target);
		if (this.numInTransitions == 0) {
			var wasVisible:Boolean = this._content.visible;

			if (this._triggerEvent == "hide" || this._triggerEvent == "hideChild") 
			{
				this._content.visible = false;
			}
			if (wasVisible) 
			{
				// Fix bug 58135
				// Don't send allTransitionsInDone if content was
				// hidden before the transitions actually finished.
				this.dispatchEvent(new Event("allTransitionsInDone"));
			}
		}
	}

    /**
     * @private
     */
    internal function transitionOutDone(e:Object):void 
	{
		this.removeTransition(e.target);
		if (this.numOutTransitions == 0) 
		{
			// return content to its original x, scaleX, rotation, etc.
			this.restoreContentAppearance();

			var wasVisible:Boolean = this._content.visible;
			// hide the content when all out transitions are done
			if (wasVisible && 
				(_triggerEvent == "hide" || _triggerEvent == "hideChild")) 
			{
				this._content.visible = false;
			}

			if (wasVisible)  {
				// Fix bug 58135
				// Don't send allTransitionsOutDone if content was
				// hidden before the transitions actually finished.
				this.dispatchEvent(new Event("allTransitionsOutDone"));
			}
		}
	}
	
}
}
