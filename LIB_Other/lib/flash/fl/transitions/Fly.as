// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.transitions 
{ 
import flash.display.*;
import flash.geom.*;

/**
 * The Fly class slides the movie clip object in from a specified direction. This effect requires the
 * following parameters:
 * <ul><li><code>startPoint</code>: An integer indicating a starting position; the range
 * is 1 to 9: Top Left:<code>1</code>; Top Center:<code>2</code>, Top Right:<code>3</code>; Left Center:<code>4</code>; Center:<code>5</code>; Right Center:<code>6</code>; Bottom Left:<code>7</code>; Bottom Center:<code>8</code>, Bottom Right:<code>9</code>.</li></ul>
 * <p>For example, the following code uses the Fly transition for the movie clip 
 * instance <code>img1_mc</code>:</p>
 * <listing>
 * import fl.transitions.~~;
 * import fl.transitions.easing.~~;
 *  
 * TransitionManager.start(img1_mc, {type:Fly, direction:Transition.IN, duration:3, easing:Elastic.easeOut, startPoint:9}); 
 * </listing>
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Fly, Transitions
 * @see fl.transitions.TransitionManager
 */     
public class Fly extends Transition 
{

    /**
     * @private
     */ 
	override public function get type():Class
	{
		return Fly;
	}
	
    /**
     * @private
     */     
	public var className:String = "Fly";

    /**
     * @private
     */     
	protected var _startPoint:Number = 4;

    /**
     * @private
     */     
	protected var _xFinal:Number;

    /**
     * @private
     */ 
	protected var _yFinal:Number;

    /**
     * @private
     */ 
	protected var _xInitial:Number;

    /**
     * @private
     */ 
    protected var _yInitial:Number;

    /**
     * @private
     */ 
	protected var _stagePoints:Object;

    /**
     * @private
     */ 
	function Fly (content:MovieClip, transParams:Object, manager:TransitionManager) 
	{
		super(content, transParams, manager);

		if (transParams.startPoint) this._startPoint = transParams.startPoint;
		
		this._xFinal = this.manager.contentAppearance.x;
		this._yFinal = this.manager.contentAppearance.y;
		var stage:Stage = content.stage;
		// we need to temporarily switch the Stage to "showAll" mode, so store old Stage mode
		var oldStageScaleMode:String = stage.scaleMode;
		stage.scaleMode = StageScaleMode.SHOW_ALL;
		
		// define cardinal points like telephone keypad:
		// 1 2 3
		// 4 5 6
		// 7 8 9
		var sp:Object = this._stagePoints = {};
		sp[1] = new Point(0, 0);
		sp[2] = new Point(0, 0);
		sp[3] = new Point(stage.stageWidth, 0);
		sp[4] = new Point(0, 0);
		sp[5] = new Point(stage.stageWidth/2, stage.stageHeight/2);
		sp[6] = new Point(stage.stageWidth, 0);
		sp[7] = new Point(0, stage.stageHeight);
		sp[8] = new Point(0, stage.stageHeight);
		sp[9] = new Point(stage.stageWidth, stage.stageHeight);
		
		// map coordinates from global space to content's parent's space
		for (var i:String in sp) 
		{
			this._content.parent.globalToLocal(sp[i]);
		}
		
		// shift values to adjust for symbols with registration points not at top-left
		var ib:Rectangle = this._innerBounds; // _innerBounds comes from Transition superclass
		sp[1].x -= ib.right;
		sp[1].y -= ib.bottom;
		
		sp[2].x = this.manager.contentAppearance.x;
		sp[2].y -= ib.bottom;
		
		sp[3].x -= ib.left;
		sp[3].y -= ib.bottom;
		
		sp[4].x -= ib.right;
		sp[4].y = this.manager.contentAppearance.y;
		
		sp[5].x -= (ib.right+ib.left)/2; // center x
		sp[5].y -= (ib.bottom+ib.top)/2; // center y
		
		sp[6].x -= ib.left;
		sp[6].y = this.manager.contentAppearance.y;
		
		sp[7].x -= ib.right;
		sp[7].y -= ib.top;
		
		sp[8].x = this.manager.contentAppearance.x;
		sp[8].y -= ib.top;
		
		sp[9].x -= ib.left;
		sp[9].y -= ib.top;
		
		this._xInitial = this._stagePoints[this._startPoint].x;
		this._yInitial = this._stagePoints[this._startPoint].y;
		// restore Stage to original scale mode
		stage.scaleMode = oldStageScaleMode;
	}

    /**
     * @private
     */     
	override protected function _render(p:Number):void 
	{
		this._content.x = this._xFinal + (this._xInitial-this._xFinal) * (1-p);
		this._content.y = this._yFinal + (this._yInitial-this._yFinal) * (1-p);
	}

}

	
	
}