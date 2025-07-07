// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.transitions 
{ 
import flash.display.MovieClip;
import flash.geom.*;
/**
 * The Iris class reveals the movie clip object by using an animated mask of a square shape or a 
 * circle shape that zooms in or out. This effect requires the
 * following parameters:
 * <ul><li><code>startPoint</code>: An integer indicating a starting position; the range
 * is 1 to 9: Top Left:<code>1</code>; Top Center:<code>2</code>, Top Right:<code>3</code>; Left Center:<code>4</code>; Center:<code>5</code>; Right Center:<code>6</code>; Bottom Left:<code>7</code>; Bottom Center:<code>8</code>, Bottom Right:<code>9</code>.</li>
 * <li><code>shape</code>: A mask shape of either <code>fl.transitions.Iris.SQUARE</code> (a square) or <code>fl.transitions.Iris.CIRCLE</code> (a circle).
</li></ul>
 * <p>For example, the following code uses a circle-shaped animated mask transition for the movie clip 
 * instance <code>img1_mc</code>:</p>
 * <listing>
 * import fl.transitions.~~;
 * import fl.transitions.easing.~~;
 * 
 * TransitionManager.start(img1_mc, {type:Iris, direction:Transition.IN, duration:2, easing:Strong.easeOut, startPoint:5, shape:Iris.CIRCLE}); 
 * </listing>
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Iris, Transitions
 * @see fl.transitions.TransitionManager
 */     
public class Iris extends Transition 
{

    /**
     * @private
     */ 
	override public function get type():Class
	{
		return Iris;
	}

    /**
     * Used to specify a square mask shape for the transition effect.
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Iris, Transitions
     */ 
	public static const SQUARE:String = "SQUARE";
    
    /**
     * Used to specify a circle mask shape for the transition effect.
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Iris, Transitions
     */     
	public static const CIRCLE:String = "CIRCLE";

    /**
     * @private
     */ 
	protected var _mask:MovieClip;

    /**
     * @private
     */ 
    protected var _startPoint:uint = 5;
    
    /**
     * @private
     */    
	protected var _cornerMode:Boolean = false;
    
    /**
     * @private
     */ 
	protected var _shape:String = SQUARE;

    /**
     * @private
     */
	protected var _maxDimension:Number = NaN;

    /**
     * @private
     */
	protected var _minDimension:Number = NaN;

    /**
     * @private
     */
	protected var _renderFunction:Function;

    /**
     * @private
     */
	function Iris(content:MovieClip, transParams:Object, manager:TransitionManager) 
	{
		super(content, transParams, manager);
		if (transParams.startPoint) 
			this._startPoint = transParams.startPoint;
		if (transParams.shape) 
			this._shape = transParams.shape;
		this._maxDimension = Math.max(this._width, this._height);
		this._minDimension = Math.min(this._width, this._height);
		
		// if _startPoint is an odd number, it's a corner
		if (this._startPoint % 2)
			this._cornerMode = true;
		// assign the render function dynamically based on shape choice
		if (this._shape == SQUARE) 
		{
			if (this._cornerMode)
				this._renderFunction = this._renderSquareCorner;
			else
				this._renderFunction = this._renderSquareEdge;
		} 
		else if (this._shape == CIRCLE) 
		{
			this._renderFunction = this._renderCircle;
		}

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
		var mask:MovieClip = this._mask = new MovieClip(); 
		mask.visible = false;
		this._content.addChild(mask);
		var ib:Rectangle = this._innerBounds;
		
		switch (this._startPoint) 
		{
			case 1:
			// top left
				mask.x = ib.left;
				mask.y = ib.top;
				break;
			case 4: 
			// left
				mask.x = ib.left;
				mask.y = (ib.top + ib.bottom) * .5;
				break;
			case 3:
			// top right
				mask.rotation = 90;
				mask.x = ib.right;
				mask.y = ib.top;
				break;
			case 2:
			// top center
				mask.rotation = 90;
				mask.x = (ib.left + ib.right) * .5;
				mask.y = ib.top;
				break;
			case 9:
			// bottom right
				mask.rotation = 180;
				mask.x = ib.right;
				mask.y = ib.bottom;
				break;
			case 6: 
			// right
				mask.rotation = 180;
				mask.x = ib.right;
				mask.y = (ib.top + ib.bottom) * .5;
				break;
			case 7:
			// bottom left
				mask.rotation = -90;
				mask.x = ib.left;
				mask.y = ib.bottom;
				break;
			case 8: 
			// bottom center
				mask.rotation = -90;
				mask.x = (ib.left + ib.right) * .5;
				mask.y = ib.bottom;
				break;
			case 5:
			// center
				mask.x = (ib.left + ib.right) * .5;
				mask.y = (ib.top + ib.bottom) * .5;
				break;
		}
	}

    /**
     * @private stub--dynamically overwritten by one of the other render methods
     */
	override protected function _render(p:Number):void 
	{
		this._renderFunction(p);
	}
	
    /**
     * @private
     */ 
	protected function _renderCircle(p:Number):void 
	{
		//trace('_renderCircle(): ' + p);
		var mask:MovieClip = this._mask;
		mask.graphics.clear();
		mask.graphics.beginFill(0xFF0000);
		var maxRadius:Number = 0;
		
		if (this._startPoint == 5) 
		{
			// iris from center
			maxRadius = .5 * Math.sqrt(this._width*this._width + this._height*this._height);
			this.drawCircle(mask, 0, 0, p*maxRadius);
		} 
		else if (this._cornerMode) 
		{
			// iris from corner
			maxRadius = Math.sqrt(this._width*this._width + this._height*this._height);
			this._drawQuarterCircle(mask, p*maxRadius);
		} 
		else 
		{
			// iris from edge
			if (this._startPoint == 4 || this._startPoint == 6) 
			{
				// half-circle from left or right edge
				maxRadius = Math.sqrt(this._width*this._width + .25*this._height*this._height);
			} 
			else if (this._startPoint == 2 || this._startPoint == 8) 
			{
				// half-circle from top or bottom edge
				maxRadius = Math.sqrt(.25*this._width*this._width + this._height*this._height);
			}
			this._drawHalfCircle(mask, p*maxRadius);  
		}
		mask.graphics.endFill();
	}

    /**
     * @private
     */ 
	protected function _drawQuarterCircle(mc:MovieClip, r:Number):void  
	{
		var x:Number = 0;
		var y:Number = 0;
		mc.graphics.lineTo(r, 0);
		mc.graphics.curveTo(r+x, Math.tan(Math.PI/8)*r+y, Math.sin(Math.PI/4)*r+x, Math.sin(Math.PI/4)*r+y);
		mc.graphics.curveTo(Math.tan(Math.PI/8)*r+x, r+y, x, r+y);
	}

    /**
     * @private
     */     
	protected function _drawHalfCircle(mc:MovieClip, r:Number):void 
	{
		var x:Number = 0;
		var y:Number = 0;
		mc.graphics.lineTo (0, -r);
		mc.graphics.curveTo (Math.tan(Math.PI/8)*r+x, -r+y, Math.sin(Math.PI/4)*r+x, -Math.sin(Math.PI/4)*r+y);
		mc.graphics.curveTo (r+x, -Math.tan(Math.PI/8)*r+y, r+x, y);
		mc.graphics.curveTo (r+x, Math.tan(Math.PI/8)*r+y, Math.sin(Math.PI/4)*r+x, Math.sin(Math.PI/4)*r+y);
		mc.graphics.curveTo (Math.tan(Math.PI/8)*r+x, r+y, x, r+y);
		mc.graphics.lineTo (0, 0);
	}

    /**
     * @private
     */     
	protected function _renderSquareEdge (p:Number):void 
	{
		var mask:MovieClip = this._mask;
		mask.graphics.clear();
		mask.graphics.beginFill(0xFF0000);
		var s:uint = this._startPoint;
		var w:Number = p*this._width;
		var h:Number = p*this._height;
		var z:Number = p*this._maxDimension;
		if (s == 4 || s == 6)
			this.drawBox(mask, 0, -.5*h, w, h);
		else if (this._height < this._width)
		  	this.drawBox(mask, 0, -.5*z, h, w); 
		else
		  	this.drawBox(mask, 0, -.5*z, z, z);
		mask.graphics.endFill();
	}
	
    /**
     * @private
     */     
	protected function _renderSquareCorner(p:Number):void 
	{
		var mask:MovieClip = this._mask;
		mask.graphics.clear();
		mask.graphics.beginFill(0xFF0000);
		var s:uint = this._startPoint;
		var w:Number = p*this._width;
		var h:Number = p*this._height;
		if (s == 5) 
			this.drawBox(mask, -.5*w, -.5*h, w, h);
		else if (s == 3 || s == 7)
			this.drawBox(mask, 0, 0, h, w);
		else
			this.drawBox(mask, 0, 0, w, h);
		mask.graphics.endFill();
	}
}
}