// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.transitions 
{ 
import flash.display.MovieClip;
import flash.geom.*;

/**
 * The Wipe class reveals or hides the movie clip object by using an animated mask of a shape that moves 
 * horizontally. This effect requires the
 * following parameter:
 * <ul><li><code>startPoint</code>: An integer indicating a starting position; the range
 * is 1 to 9: Top Left:<code>1</code>; Top Center:<code>2</code>, Top Right:<code>3</code>; Left Center:<code>4</code>; Center:<code>5</code>; Right Center:<code>6</code>; Bottom Left:<code>7</code>; Bottom Center:<code>8</code>, Bottom Right:<code>9</code>.</li></ul>
 * <p>For example, the following code uses the Wipe transition for the movie clip 
 * instance <code>img1_mc</code>:</p>
 * <listing>
 * import fl.transitions.~~;
 * import fl.transitions.easing.~~;
 *     
 * TransitionManager.start(img1_mc, {type:Wipe, direction:Transition.IN, duration:2, easing:None.easeNone, startPoint:1}); 
 * </listing>
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Wipe, Transitions
 * @see fl.transitions.TransitionManager
 */     
public class Wipe extends Transition 
{

    /**
     * @private
     */ 
	override public function get type():Class
	{
		return Wipe;
	}

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
	protected var _startPoint:uint = 4;

    /**
     * @private
     */ 
	protected var _cornerMode:Boolean = false;

    /**
     * @private
     */ 
	function Wipe(content:MovieClip, transParams:Object, manager:TransitionManager) 
	{
		super(content, transParams, manager);
		if (transParams.startPoint) 
			this._startPoint = transParams.startPoint;
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
		this._innerMask.graphics.beginFill(0xFF0000);
		this.drawBox(this._innerMask, -50, -50, 100, 100);
		this._innerMask.graphics.endFill();
		
		switch (this._startPoint) 
		{
			case 3:
			case 2: 
				this._innerMask.rotation = 90;
				break;
			case 1:
			case 4: 
			case 5: // 5 doesn't really make sense for this effect, so just do the same as 1
				this._innerMask.rotation = 0;
				break;
			case 9:
			case 6: 
				this._innerMask.rotation = 180;
				break;
			case 7:
			case 8: 
				this._innerMask.rotation = -90;
				break;
		}
		
		// if _startPoint is an odd number, it's a corner
		if (this._startPoint % 2) 
		{
			this._cornerMode = true;
		}

		
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
		//trace ("Wipe.render(): " + p);
		this._innerMask.graphics.clear();
		this._innerMask.graphics.beginFill (0xFF0000);
		if (this._cornerMode) 
		{
			this._drawSlant(this._innerMask, p);
		} 
		else 
		{
			this.drawBox(this._innerMask, -50, -50, p*100, 100);
		}
		this._innerMask.graphics.endFill();
	}
	
    /**
     * @private
     */     
	protected function _drawSlant(mc:MovieClip, p:Number):void 
	{
		mc.graphics.moveTo (-50, -50);
		if (p <= .5) 
		{
			mc.graphics.lineTo(200*(p-.25), -50);
			mc.graphics.lineTo(-50, 200*(p-.25));
		} 
		else 
		{
			mc.graphics.lineTo(50, -50);
			mc.graphics.lineTo(50, 200*(p-.75));
			mc.graphics.lineTo(200*(p-.75), 50);
			mc.graphics.lineTo(-50, 50);
		}
		mc.graphics.lineTo(-50, -50);
	}

}
}