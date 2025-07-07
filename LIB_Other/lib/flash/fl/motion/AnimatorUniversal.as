package fl.motion
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import __AS3__.vec.Vector;
	import flash.geom.Point;

	/**
	 * The AnimatorUniversal class applies an ActionScript description of a two and three-dimensional motion to a display object.
	 * The properties and methods of the AnimatorUniversal class control the playback of the motion,
	 * and Flash Player broadcasts events in response to changes in the motion's status.
	 * <p>If you plan to call methods of the AnimatorUniversal class within a function, declare the AnimatorUniversal 
	 * instance outside of the function so the scope of the object is not restricted to the 
	 * function itself. If you declare the instance within a function, Flash Player deletes the 
	 * Animator instance at the end of the function as part of Flash Player's routine "garbage collection"
	 * and the target object will not animate.</p>
	 * 
	 * @internal <p><strong>Note:</strong> If you're not using Flash CS4 to compile your SWF file, you need the
	 * fl.motion classes in your classpath at compile time to apply the motion to the display object.</p>
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Animator, Copy Motion as ActionScript
	 * @see ../../motionXSD.html Motion XML Elements
	 */
	public class AnimatorUniversal extends Animator3D
	{
		/**
		 * Creates an AnimatorUniversal object motion to a display object.
		 *
		 * @param xml An E4X object containing an XML-based motion tween description.
		 *
		 * @param target The display object using the motion tween.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword AnimatorBase
		 * @see ../../motionXSD.html Motion XML Elements
		 */
		public function AnimatorUniversal()
		{
			super(null, null);
			this._isAnimator3D = false;
		}

		protected override function setTargetState():void
		{
			// init 3d stuff
			super.setTargetState();

			// init 2d stuff
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
			// do 3d if it is 3d
			if (thisMotion.is3D) {
				_lastMatrixApplied = null
				return setTime3D(newTime, thisMotion);
			}

			// do 2d
			var matrix:Matrix = thisMotion.getMatrix(newTime);
			if (matrix)
			{
				if (!motionArray || !_lastMatrixApplied || !Animator.matricesEqual(matrix, _lastMatrixApplied))
				{
					this._target.transform.matrix = matrix;
					_lastMatrixApplied = matrix;
				}
			}
			else
			{
				// grab info from current Motion, needed when we have a motionArray
				if (motionArray && thisMotion != _lastMotionUsed)
				{
					this.transformationPoint = (thisMotion.motion_internal::transformationPoint) ? thisMotion.motion_internal::transformationPoint : new Point(.5, .5);
					initTransformPointInternal(thisMotion.motion_internal::initialMatrix);
					_lastMotionUsed = thisMotion;
				}

				var positionX:Number = thisMotion.getValue(newTime, Tweenables.X);
				var positionY:Number = thisMotion.getValue(newTime, Tweenables.Y);
				var position:flash.geom.Point = new flash.geom.Point(positionX, positionY);
				// apply matrix transformation to path--e.g. stretch or rotate the whole motion path
				if (this.positionMatrix)
					position = this.positionMatrix.transformPoint(position); 
				// add position to target's initial position, so motion is relative
				position.x += this.targetState.x;
				position.y += this.targetState.y;
		
				var scaleX:Number = thisMotion.getValue(newTime, Tweenables.SCALE_X) * this.targetState.scaleX; 
				var scaleY:Number = thisMotion.getValue(newTime, Tweenables.SCALE_Y) * this.targetState.scaleY; 	
				var skewX:Number = 0
				var skewY:Number = 0; 

				// override the rotation and skew in the XML if orienting to path
				if (this.orientToPath)
				{
					var positionX2:Number = thisMotion.getValue(newTime+1, Tweenables.X);
					var positionY2:Number = thisMotion.getValue(newTime+1, Tweenables.Y);
					var pathAngle:Number = Math.atan2(positionY2-positionY, positionX2-positionX) * (180 / Math.PI);
					if (!isNaN(pathAngle))
					{
						skewX = pathAngle + this.targetState.skewX;
						skewY = pathAngle + this.targetState.skewY;
					}
				}
				else
				{
					skewX = thisMotion.getValue(newTime, Tweenables.SKEW_X) + this.targetState.skewX; 
					skewY = thisMotion.getValue(newTime, Tweenables.SKEW_Y) + this.targetState.skewY; 
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
				if(thisMotion.useRotationConcat(newTime))
				{
					var rotMat:Matrix = new Matrix();
					var rotConcat:Number = thisMotion.getValue(newTime, Tweenables.ROTATION_CONCAT);
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

				if (!motionArray || !_lastMatrixApplied || !Animator.matricesEqual(targetMatrix, _lastMatrixApplied))
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

	}
}
