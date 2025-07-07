// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.transitions 
{ 
import flash.display.MovieClip;

/**
 * The Zoom class zooms the movie clip object in or out by scaling it in proportion.
 * This effect requires no additional parameters:
 * <p>For example, the following code uses the Zoom transition for the movie clip 
 * instance <code>img1_mc</code>:</p>
 * <listing>
 * import fl.transitions.~~;
 * import fl.transitions.easing.~~;
 *      
 * TransitionManager.start(img1_mc, {type:Zoom, direction:Transition.IN, duration:2, easing:Elastic.easeOut});
 * </listing>
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Zoom, Transitions
 * @see fl.transitions.TransitionManager
 */         
public class Zoom extends Transition 
{

    /**
     * @private
     */
	override public function get type():Class
	{
		return Zoom;
	}

    /**
     * @private
     */ 
	protected var _scaleXFinal:Number = 1;

    /**
     * @private
     */
	protected var _scaleYFinal:Number = 1;

    /**
     * @private
     */ 
	function Zoom(content:MovieClip, transParams:Object, manager:TransitionManager)  
	{
		super(content, transParams, manager);
		this._scaleXFinal = this.manager.contentAppearance.scaleX;
		this._scaleYFinal = this.manager.contentAppearance.scaleY;
	}

    /**
     * @private
     */ 
	override protected function _render(p:Number):void 
	{
		if (p < 0) p = 0;
		this._content.scaleX = p * this._scaleXFinal;
		this._content.scaleY = p * this._scaleYFinal;
	}

}
	
}