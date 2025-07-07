// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.transitions 
{ 
import flash.display.MovieClip;
import flash.geom.*;

/**
 * The Blinds class reveals the movie clip object by using appearing or disappearing rectangles. 
 * This effect requires the following parameters:
 * <ul><li><code>numStrips</code>: The number of masking strips in the Blinds effect.
 * The recommended range is 1 to 50.</li>
 * <li><code>dimension</code>: An integer that indicates whether the masking strips are 
 * to be vertical (<code>0</code>) or horizontal (<code>1</code>).</li></ul>
 * <p>For example, the following code uses the Blinds transition for the movie clip 
 * instance <code>img1_mc</code>:</p>
 * <listing>
 * import fl.transitions.~~;
 * import fl.transitions.easing.~~;
 *  
 * TransitionManager.start(img1_mc, {type:Blinds, direction:Transition.IN, duration:2, easing:None.easeNone, numStrips:10, dimension:0}); 
 * </listing>
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Blinds, Transitions
 * @see fl.transitions.TransitionManager
 */     
public class Blinds extends Transition  
{

    /**
     * @private
     */  
	override public function get type():Class
	{
		return Blinds;
	}

    /**
     * @private
     */   
	protected var _numStrips:uint = 10;
    
    /**
     * @private
     */   
	protected var _dimension:uint = 0;
    
    /**
     * @private
     */    
	protected var _mask:MovieClip;

    /**
     * @private
     */
	protected var _innerMask:MovieClip;

    /**
     * @private
     */
	function Blinds (content:MovieClip, transParams:Object, manager:TransitionManager) 
	{
		super(content, transParams, manager);
		this._dimension = (transParams.dimension) ? 1 : 0;
		if (transParams.numStrips) 
			this._numStrips = transParams.numStrips;
		this._initMask();
	}
	

    /**
     * @private
     */
	override public function start():void 
	{
		this._content.mask = this._mask;
		super.start();
	}

    /**
     * @private
     */ 
	override public function cleanUp():void 
	{
		this._content.removeChild(this._mask);
		this._content.mask = null;
		super.cleanUp();
	}
	
    /**
     * @private
     */
	protected function _initMask():void 
	{
		this._mask = new MovieClip();
		this._mask.visible = false;
		this._content.addChild(this._mask);
		this._innerMask = new MovieClip();  
		this._mask.addChild(this._innerMask);
		this._innerMask.x = this._innerMask.y = 50;
		if (this._dimension) this._innerMask.rotation = -90;
		
		// draw initial standard 100x100 box
		this._innerMask.graphics.beginFill(0xFF0000);
		this.drawBox(this._innerMask, 0, 0, 100, 100);
		this._innerMask.graphics.endFill();

		var ib:Rectangle = this._innerBounds;
		this._mask.x = ib.left;
		this._mask.y = ib.top;
		this._mask.width = ib.width; 
		this._mask.height = ib.height; 
	}
	
    /**
     * @private
     */
	override protected function _render(p:Number):void 
	{
		var h:Number = 100/this._numStrips;
		var s:Number = p * h;
		var mask:MovieClip = this._innerMask;
		mask.graphics.clear();
		var i:Number = this._numStrips;
		mask.graphics.beginFill(0xFF0000);
		while (i--) 
		{
			this.drawBox(mask, -50, i*h - 50, 100, s);
		}
		mask.graphics.endFill();
	}

}
}