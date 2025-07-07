// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.transitions 
{ 
import flash.display.MovieClip;

/**
 * The Squeeze class scales the movie clip object horizontally or vertically. This effect requires the
 * following parameters:
 * <ul><li><code>dimension</code>: An integer that indicates whether the Squeeze effect should be horizontal (0) or vertical (1). </li></ul>
 * <p>For example, the following code uses the Squeeze transition for the movie clip 
 * instance <code>img1_mc</code>:</p>
 * <listing>
 * import fl.transitions.~~;
 * import fl.transitions.easing.~~;
 *    
 * TransitionManager.start(img1_mc, {type:Squeeze, direction:Transition.IN, duration:2, easing:Elastic.easeOut, dimension:1});
 * </listing>
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Squeeze, Transitions
 * @see fl.transitions.TransitionManager
 */  
public class Squeeze extends Transition 
{
    /**
     * @private
     */  
	override public function get type():Class
	{
		return Squeeze;
	}

    /**
     * @private
     */     
	protected var _scaleProp:String = 'scaleX';

    /**
     * @private
     */  
	protected var _scaleFinal:Number = 1;

    /**
     * @private
     */  
	function Squeeze(content:MovieClip, transParams:Object, manager:TransitionManager) 
	{
		super(content, transParams, manager);
		if (transParams.dimension) 
		{
			this._scaleProp = "scaleY";
			this._scaleFinal = this.manager.contentAppearance.scaleY;
		} 
		else 
		{
			this._scaleProp = "scaleX";
			this._scaleFinal = this.manager.contentAppearance.scaleX;
		}
	}

    /**
     * @private
     */     
	override protected function _render(p:Number):void 
	{
		if (p <= 0)
		{ 
			p = 0;
		 	//this._content.visible = false;
		 	//this._content.alpha = 0;
		}
		else
		{
			//this._content.visible = true;
			// may have to do this, but it would interfere with Fade transition
			//this._content.alpha = this.manager.contentAppearance;
		}
		this._content[this._scaleProp] = p * this._scaleFinal;
	}

}
}