// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.transitions 
{ 
import flash.display.MovieClip;
import flash.geom.*;

/**
 * Makes the movie clip object appear or disappear like a photographic flash.
 * This effect requires no additional parameters.
 * <p>For example, the following code uses the Photo transition for the movie clip 
 * instance <code>img1_mc</code>:</p>
 * <listing>
 * import fl.transitions.~~;
 * import fl.transitions.easing.~~;
 *  
 * TransitionManager.start (img1_mc, {type:Photo, direction:Transition.IN, duration:1, easing:None.easeNone});
 * </listing>
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Photo, Transitions
 * @see fl.transitions.TransitionManager
 */ 
public class Photo extends Transition 
{

    /**
     * @private
     */ 
	override public function get type():Class
	{
		return Photo;
	}

    /**
     * @private
     */ 
	protected var _alphaFinal:Number = 1;

    /**
     * @private
     */ 
	protected var _colorControl:ColorTransform;
	
    /**
     * @private
     */ 
	function Photo(content:MovieClip, transParams:Object, manager:TransitionManager) 
	{
		super(content, transParams, manager);
		this._alphaFinal = this.manager.contentAppearance.alpha;
		this._colorControl = new ColorTransform(); 
	}
	
    /**
     * @private
     */ 
	override protected function _render(p:Number):void 
	{
		var s1:Number = .8;
		var s2:Number = .9;
		var t:Object = {};
		var bright:Number = 0;
		if (p <= s1) 
		{
			this._colorControl.alphaMultiplier = this._alphaFinal * (p/s1);
		}
		else 
		{
			this._colorControl.alphaMultiplier = this._alphaFinal;
			if (p <= s2) 
				bright = (p-s1)/(s2-s1) * 256;
			else
				bright = (1-(p-s2)/(1-s2)) * 256;
		}
		t.rb = t.gb = t.bb = bright;
		this._colorControl.redOffset = this._colorControl.greenOffset = this._colorControl.blueOffset = bright;
		this._content.transform.colorTransform = this._colorControl; 
	}

}

}