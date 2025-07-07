// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.transitions 
{ 
import flash.display.MovieClip;
import flash.geom.*;

/**
 * The PixelDissolve class reveals reveals the movie clip object by using randomly appearing or disappearing rectangles
 * in a checkerboard pattern.  This effect requires the following parameters:
 * <ul><li><code>xSections</code>: An integer that indicates the number of masking 
 * rectangle sections along the horizontal axis. The recommended range is 1 to 50.</li>
 * <li><code>ySections</code>: An integer that indicates the number of masking rectangle
 * sections along the vertical axis. The recommended range is 1 to 50.</li></ul>
 * <p>For example, the following code uses the PixelDissolve transition for the movie clip 
 * instance <code>img1_mc</code>:</p>
 * <listing>
 * import fl.transitions.~~;
 * import fl.transitions.easing.~~;
 *   
 * TransitionManager.start(img1_mc, {type:PixelDissolve, direction:Transition.IN, duration:2, easing:Regular.easeIn, xSections:10, ySections:10}); 
 * </listing>
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword PixelDissolve, Transitions
 * @see fl.transitions.TransitionManager
 */ 
public class PixelDissolve extends Transition 
{
    /**
     * @private
     */  
	override public function get type():Class
	{
		return PixelDissolve;
	}
    /**
     * @private
     */     
	protected var _xSections:Number = 10;

    /**
     * @private
     */  
	protected var _ySections:Number = 10;

    /**
     * @private
     */  
	protected var _numSections:uint = 1;

    /**
     * @private
     */  
	protected var _indices:Array;

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
	function PixelDissolve(content:MovieClip, transParams:Object, manager:TransitionManager) 
	{
		super(content, transParams, manager);
		if (transParams.xSections) this._xSections = transParams.xSections;
		if (transParams.ySections) this._ySections = transParams.ySections;
		this._numSections = this._xSections * this._ySections;
		this._indices = new Array();
		var y:int = this._ySections;
		while (y--) 
		{
			var x:int = this._xSections;
			while (x--) 
			{
				this._indices[y*this._xSections+x] = {x:x, y:y};
			}
		}
		this._shuffleArray(this._indices);
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
		
		// draw initial standard 100x100 box
		this._innerMask.graphics.beginFill(0xFF0000);
		this.drawBox(this._innerMask, 0, 0, 100, 100);
		this._innerMask.graphics.endFill();
		
		var ib:Rectangle = this._innerBounds;
		this._mask.x = ib.left;
		this._mask.y = ib.top;
		this._mask.width = ib.right - ib.left;
		this._mask.height = ib.bottom - ib.top;

	}
	
    /**
     * @private
     */  
	protected function _shuffleArray(a:Array):void  
	{
		for (var i:int=a.length-1; i>0; --i) 
		{
		   var p:int = Math.floor(Math.random()*(i+1));
		   if (p == i) continue;
		   var tmp:Object = a[i];
		   a[i] = a[p];
		   a[p] = tmp;
		}
	}
	
    /**
     * @private
     */  
	override protected function _render(p:Number):void 
	{
		if (p < 0) p = 0;
		if (p > 1) p = 1;
		var w:Number = 100/this._xSections;
		var h:Number = 100/this._ySections;
		var ind:Array = this._indices;
		var mask:MovieClip = this._innerMask;
		mask.graphics.clear();
		mask.graphics.beginFill(0xFF0000);
		var i:Number = Math.floor(p * this._numSections);
		while (i--) 
		{
			this.drawBox(mask, ind[i].x*w, ind[i].y*h, w, h);
		}
		mask.graphics.endFill();
	}

}
}