// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.motion
{
import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Point;

/**
 * The Animator class applies an XML description of a motion tween to a display object.
 * The properties and methods of the Animator class control the playback of the motion,
 * and Flash Player broadcasts events in response to changes in the motion's status.
 * If there isn't any three-dimensional content, the Copy Motion as ActionScript command in
 * Flash CS4 uses the Animator class. For three-dimensional content, the Animator3D class is used, instead, which shares the 
 * same base class as the Animator class but is specifically for three-dimensional content.
 * You can then edit the ActionScript using the application programming interface
 * (API) or construct your own custom animation.
 * <p>If you plan to call methods of the Animator class within a function, declare the Animator 
 * instance outside of the function so the scope of the object is not restricted to the 
 * function itself. If you declare the instance within a function, Flash Player deletes the 
 * Animator instance at the end of the function as part of Flash Player's routine "garbage collection"
 * and the target object will not animate.</p>
 * <p><strong>Note:</strong> In Flash CS3, some properties and methods supported by this class 
 * were members of this class, exclusively. Flash CS4 introduced a base class, AnimatorBase, for those
 * properties and methods of this class, and they are now shared by other classes through the inheritance chain. If you have been working in Flash CS3,
 * notice that these properties and methods are still supported by the Animator class, but are members of the AnimatorBase class in releases 
 * of Flash Professional after Flash CS3. As with any other class in this reference, select Show Inherited Public Properties and Show Inherited Public Methods
 * to see all of the properties and methods supported by this class. </p>
 * 
 * @internal <p><strong>Note:</strong> If you're not using Flash CS4 to compile your SWF file, you need the
 * fl.motion classes in your classpath at compile time to apply the motion to the display object.</p>
 *
 * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Animator, Copy Motion as ActionScript
 * @see ../../motionXSD.html Motion XML Elements
 */
public class Animator extends AnimatorBase
{	
	/**
     * @private (setter)
     */
	public override function set motion(value:MotionBase):void
	{
		super.motion = value;
		var classicMotion:Motion = value as Motion;
		if (classicMotion && classicMotion.source 
				&& classicMotion.source.transformationPoint)
			this.transformationPoint = classicMotion.source.transformationPoint.clone();
	}

     /**
     * @private
     */
	protected override function setTargetState():void
	{
 		this.targetState.scaleX = this._target.scaleX;
		this.targetState.scaleY = this._target.scaleY;
		this.targetState.skewX = MatrixTransformer.getSkewX(this._target.transform.matrix);
		this.targetState.skewY = MatrixTransformer.getSkewY(this._target.transform.matrix);
		
		this.targetState.bounds = this._target.getBounds(this._target);	
		initTransformPointInternal(this._target.transform.matrix);

		this.targetState.z = 0;
		this.targetState.rotationX = this.targetState.rotationY = 0;
	}

	private function initTransformPointInternal(mat:Matrix):void
	{
		var bounds:Object = this.targetState.bounds;
		if (this.transformationPoint)
		{
			// find the position of the transform point proportional to the bounding box of the target
			var transformX:Number = this.transformationPoint.x*bounds.width + bounds.left;
			var transformY:Number = this.transformationPoint.y*bounds.height + bounds.top;
			this.targetState.transformPointInternal = new Point(transformX, transformY);
		
			var transformPointExternal:Point = 
				mat.transformPoint(this.targetState.transformPointInternal);
				
		 	this.targetState.x = transformPointExternal.x;
			this.targetState.y = transformPointExternal.y;
		}
		else
		{
			// Use the origin as the transformation point if not supplied.
			this.targetState.transformPointInternal = new Point(0, 0);
	 		this.targetState.x = this._target.x;
			this.targetState.y = this._target.y;
		}
	}

     /**
     * @private
     */
	protected override function setTimeClassic(newTime:int, thisMotion:MotionBase, curKeyframe:KeyframeBase):Boolean
	{
		var thisMotionClassic:Motion = thisMotion as Motion;
		if(!thisMotionClassic) return false;

		var matrix:Matrix = thisMotionClassic.getMatrix(newTime);
		if (matrix)
		{
			if (!motionArray || !_lastMatrixApplied || !matricesEqual(matrix, _lastMatrixApplied))
			{
				this._target.transform.matrix = matrix;
				_lastMatrixApplied = matrix;
			}
		}
		else
		{
			// grab info from current Motion, needed when we have a motionArray
			if (motionArray && thisMotionClassic != _lastMotionUsed)
			{
				this.transformationPoint = (thisMotionClassic.motion_internal::transformationPoint) ? thisMotionClassic.motion_internal::transformationPoint : new Point(.5, .5);
				initTransformPointInternal(thisMotionClassic.motion_internal::initialMatrix);
				_lastMotionUsed = thisMotionClassic;
			}

			var positionX:Number = thisMotionClassic.getValue(newTime, Tweenables.X);
			var positionY:Number = thisMotionClassic.getValue(newTime, Tweenables.Y);
			var position:flash.geom.Point = new flash.geom.Point(positionX, positionY);
			// apply matrix transformation to path--e.g. stretch or rotate the whole motion path
			if (this.positionMatrix)
				position = this.positionMatrix.transformPoint(position); 
			// add position to target's initial position, so motion is relative
			position.x += this.targetState.x;
			position.y += this.targetState.y;
		
			var scaleX:Number = thisMotionClassic.getValue(newTime, Tweenables.SCALE_X) * this.targetState.scaleX; 
			var scaleY:Number = thisMotionClassic.getValue(newTime, Tweenables.SCALE_Y) * this.targetState.scaleY; 	
			var skewX:Number = 0
			var skewY:Number = 0; 

			// override the rotation and skew in the XML if orienting to path
			if (this.orientToPath)
			{
				var positionX2:Number = thisMotionClassic.getValue(newTime+1, Tweenables.X);
				var positionY2:Number = thisMotionClassic.getValue(newTime+1, Tweenables.Y);
				var pathAngle:Number = Math.atan2(positionY2-positionY, positionX2-positionX) * (180 / Math.PI);
				if (!isNaN(pathAngle))
				{
					skewX = pathAngle + this.targetState.skewX;
					skewY = pathAngle + this.targetState.skewY;
				}
			}
			else
			{
				skewX = thisMotionClassic.getValue(newTime, Tweenables.SKEW_X) + this.targetState.skewX; 
				skewY = thisMotionClassic.getValue(newTime, Tweenables.SKEW_Y) + this.targetState.skewY; 
			}

			// need to incorporate the rotation matrix before position if we are doing both
			// rotation and skew, so set tx and ty after
			var targetMatrix:Matrix = new Matrix(
				scaleX*Math.cos(skewY*(Math.PI/180)), 
				scaleX*Math.sin(skewY*(Math.PI/180)), 
			   -scaleY*Math.sin(skewX*(Math.PI/180)),
				scaleY*Math.cos(skewX*(Math.PI/180)), 
				0,
				0);
		
			// the new version of motion tweens in Flash 10 supply rotation values 
			// that are separate from skewY
			var useRotationConcat:Boolean = false;
			if(thisMotionClassic.useRotationConcat(newTime))
			{
				var rotMat:Matrix = new Matrix();
				var rotConcat:Number = thisMotionClassic.getValue(newTime, Tweenables.ROTATION_CONCAT);
				rotMat.rotate(rotConcat);
				targetMatrix.concat(rotMat);
				useRotationConcat = true;
			}
			 
			targetMatrix.tx = position.x;
			targetMatrix.ty = position.y;

			// Shift the object so its transformation point (not registration point) 
			// lines up with the x and y values from the Keyframe.
			var transformationPointLocation:Point = targetMatrix.transformPoint(this.targetState.transformPointInternal);
			var dx:Number = targetMatrix.tx - transformationPointLocation.x;
			var dy:Number = targetMatrix.ty - transformationPointLocation.y;
			targetMatrix.tx += dx;
			targetMatrix.ty += dy;

			if (!motionArray || !_lastMatrixApplied || !matricesEqual(targetMatrix, _lastMatrixApplied))
			{
				if(!useRotationConcat) 
				{
					// This otherwise redundant step is necessary for Player 9r16 
					// where setting the matrix doesn't produce rotation.
					// Unfortunately, there doesn't seem to be a way to render skew in 9r16. 
					this._target.rotation = skewY;
				}

				// At long last, apply the transformations to the display object.
				// Note that we have to assign the matrix each time because 
				// if one frame has skew and the next has just rotation, we can't remove
				// the skew by just setting the rotation property. We have to clear the skew with the matrix.
				this._target.transform.matrix = targetMatrix;

				// workaround for a Player 9r28 bug, where setting the matrix causes scaleX or scaleY to go to 0
				if(useRotationConcat && this._target.scaleX == 0 && this._target.scaleY == 0)
				{
					this._target.scaleX = scaleX;
					this._target.scaleY = scaleY; 
				}

				_lastMatrixApplied = targetMatrix;
			}
		} // else if (matrix)

		// TODO! workaround for player bug - should be able to set cacheAsBitmap for a 3d object
		if (_lastCacheAsBitmapApplied != curKeyframe.cacheAsBitmap || !_cacheAsBitmapHasBeenApplied) {
			this._target.cacheAsBitmap = curKeyframe.cacheAsBitmap;	
			_cacheAsBitmapHasBeenApplied = true;
			_lastCacheAsBitmapApplied = curKeyframe.cacheAsBitmap;
		}

		return true;
	}
	
	/**
     * Creates an Animator object to apply the XML-based motion tween description to a display object.
     *
     * @param xml An E4X object containing an XML-based motion tween description.
     *
     * @param target The display object using the motion tween.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword AnimatorBase
     * @see ../../motionXSD.html Motion XML Elements
     */
	function Animator(xml:XML=null, target:DisplayObject=null)
	{
		this.motion = new Motion(xml);
		super(xml, target);
	}
	
	
   /**
     * Creates an Animator object from a string of XML. 
     * This method is an alternative to using the Animator constructor, which accepts an E4X object instead.
     *
     * @param xmlString A string of XML describing the motion tween.
     *
     * @param target The display object using the motion tween.
     *
     * @return An Animator instance that applies the specified <code>xmlString</code> to the specified <code>target</code>.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword createFromXMLString, Animator
     * @see ../../motionXSD.html Motion XML Elements     
     */
	public static function fromXMLString(xmlString:String, target:DisplayObject=null):Animator
	{
		return new Animator(new XML(xmlString), target);
	}
   /**
     * Compares two matrices specified as parameters and returns <code>true</code> if they are equal to one another.
     * @param a The first Matrix object instance for comparison.
     * @param b The second Matrix object instance for comparison.
     * @return A Boolean value; <code>true</code> if the two matrices are equal to one another, otherwise <code>false</code>.
     * @playerversion Flash 10.1
     * @playerversion AIR 2
     * @productversion Flash CS5
     * @langversion 3.0
     * @tiptext Compares two matrices specified as parameters and returns <code>true</code> if they are equal to one another.
     */
	public static function matricesEqual(a:Matrix, b:Matrix):Boolean
	{
		return ( a.a == b.a &&
		         a.b == b.b &&
		         a.c == b.c &&
		         a.d == b.d &&
		         a.tx == b.tx &&
		         a.ty == b.ty );
	}
	
}
}