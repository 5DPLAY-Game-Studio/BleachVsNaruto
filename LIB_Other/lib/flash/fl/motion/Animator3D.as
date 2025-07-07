package fl.motion
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import __AS3__.vec.Vector;
	import flash.geom.Point;

/**
 * The Animator3D class applies an XML description of a three-dimensional motion tween to a display object.
 * The properties and methods of the Animator3D class control the playback of the motion,
 * and Flash Player broadcasts events in response to changes in the motion's status.
 * If there isn't any three-dimensional content in the motion tween, the Copy Motion as ActionScript command in
 * Flash CS4 uses the Animator class. For three-dimensional content, the Animator3D class is used, instead, which shares the 
 * same base class as the Animator class but is specifically for three-dimensional content. 
 * You can then edit the ActionScript using the application programming interface
 * (API) or construct your own custom animation.
 * <p>If you plan to call methods of the Animator3D class within a function, declare the Animator3D 
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
	public class Animator3D extends AnimatorBase
	{
		private var _initialPosition:Vector3D;
		private var _initialMatrixOfTarget:Matrix3D;
		static private var IDENTITY_MATRIX:Matrix = new Matrix();

	/**
     * Creates an Animator3D object to apply the XML-based motion tween description in three dimensions to a display object.
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
		public function Animator3D(xml:XML=null, target:DisplayObject=null)
		{
			super(xml, target);
			this.transformationPoint = new Point(0,0); // AnimatorBase uses .5,.5 for 2d
			this._initialPosition = null; 
			this._initialMatrixOfTarget = null;
			this._isAnimator3D = true;
		}

	/**
     * Establishes, the x-, y-, and z- coordinates of the display object.
     *
     * @param xml An array containing the x, y, and z coordinates of the object, in order, of the display
     * object at the start of the motion.
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
		public override function set initialPosition(initPos:Array):void
		{
			if(initPos.length == 3)
			{
				this._initialPosition = new Vector3D();
				this._initialPosition.x = initPos[0];
				this._initialPosition.y = initPos[1];
				this._initialPosition.z = initPos[2];
			}
		}
		
		/**
		* @private 
	 	*/
		protected override function setTargetState():void
		{
			if(!motionArray && this._target.transform.matrix != null)
			{
				this._initialMatrixOfTarget = convertMatrixToMatrix3D(this._target.transform.matrix);
			}
		}
		
		/**
		* @private 
	 	*/		
		protected override function setTime3D(newTime:int, thisMotion:MotionBase):Boolean
		{
			var matrix3D:Matrix3D = thisMotion.getMatrix3D(newTime) as Matrix3D;

			// grab info from current Motion, needed when we have a motionArray
			if (motionArray && thisMotion != _lastMotionUsed)
			{
				this.transformationPoint = (thisMotion.motion_internal::transformationPoint) ? thisMotion.motion_internal::transformationPoint : new Point(0, 0);
				if (thisMotion.motion_internal::initialPosition)
				{
					this.initialPosition = thisMotion.motion_internal::initialPosition;
				}
				else
				{
					this._initialPosition = null;
				}
				_lastMotionUsed = thisMotion;
			}

			if (matrix3D) {
				if (!motionArray || !_lastMatrix3DApplied || !matrices3DEqual(matrix3D, Matrix3D(_lastMatrix3DApplied)))
				{
					// if we're using the matrix as opposed to the property
					// setters (like z, rotationX, rotationY), then the other
					// properties are being set via SWF tags and we want
					// to do this the fastest way possible
					var newMat3D:Matrix3D = matrix3D.clone();
					if(this._initialMatrixOfTarget)
						{
							newMat3D.append(this._initialMatrixOfTarget);
						}

					this._target.transform.matrix3D = newMat3D;
					_lastMatrix3DApplied = matrix3D;
				}
				return true;
			}
			else {
				if(thisMotion.is3D)
				{
					var frameMat3D:Matrix3D = new Matrix3D();
					var rotX:Number = (thisMotion.getValue(newTime, Tweenables.ROTATION_X)*Math.PI/180.0);
					var rotY:Number = (thisMotion.getValue(newTime, Tweenables.ROTATION_Y)*Math.PI/180.0);
					var rotZ:Number = (thisMotion.getValue(newTime, Tweenables.ROTATION_CONCAT)*Math.PI/180.0);
					
					frameMat3D.prepend(MatrixTransformer3D.rotateAboutAxis(rotZ, MatrixTransformer3D.AXIS_Z));
					frameMat3D.prepend(MatrixTransformer3D.rotateAboutAxis(rotY, MatrixTransformer3D.AXIS_Y));
					frameMat3D.prepend(MatrixTransformer3D.rotateAboutAxis(rotX, MatrixTransformer3D.AXIS_X));
					
					var transX:Number = thisMotion.getValue(newTime, Tweenables.X);
					var transY:Number = thisMotion.getValue(newTime, Tweenables.Y);
					var transZ:Number = thisMotion.getValue(newTime, Tweenables.Z);
					if((getSign(transX) != 0) || (getSign(transY) != 0) || (getSign(transZ) != 0))
					{
						frameMat3D.appendTranslation(transX, transY, transZ);
					}
					
					frameMat3D.prependTranslation(-this.transformationPoint.x, -this.transformationPoint.y, -this.transformationPointZ);
					if(this._initialPosition)
					{
						frameMat3D.appendTranslation(this._initialPosition.x, this._initialPosition.y, this._initialPosition.z);
					}
					
					// set up 2d scale and skew
					var scaleSkewMat2D:Matrix = this.getScaleSkewMatrix(thisMotion, newTime, this.transformationPoint.x, this.transformationPoint.y);
					var scaleSkewMat:Matrix3D = convertMatrixToMatrix3D(scaleSkewMat2D);
					frameMat3D.prepend(scaleSkewMat);
					
					if(this._initialMatrixOfTarget)
					{
						frameMat3D.append(this._initialMatrixOfTarget);
					}

					if (!motionArray || !_lastMatrix3DApplied || !matrices3DEqual(frameMat3D, Matrix3D(_lastMatrix3DApplied)))
					{
						this._target.transform.matrix3D = frameMat3D;
						_lastMatrix3DApplied = frameMat3D;
					}
				}
			}
			
			return false;
		}

		/**
		 * @private
		 */
		protected override function removeChildTarget(parent:MovieClip, child:DisplayObject, childName:String):void
		{
			super.removeChildTarget(parent, child, childName);
			// work around bug for TLF where linked 3D TLF taken off stage and later put back on stage
			// can stop rendering correctly
			if (child.transform.matrix3D != null) {
				child.transform.matrix = IDENTITY_MATRIX;
			}
		}

		/**
		* @private 
	 	*/		
		private function getScaleSkewMatrix(thisMotion:MotionBase, newTime:int, positionX:Number, positionY:Number):Matrix
		{
			var scaleX:Number = thisMotion.getValue(newTime, Tweenables.SCALE_X); 
			var scaleY:Number = thisMotion.getValue(newTime, Tweenables.SCALE_Y); 	
			var skewX:Number = thisMotion.getValue(newTime, Tweenables.SKEW_X);
			var skewY:Number = thisMotion.getValue(newTime, Tweenables.SKEW_Y);  
	
			var targetMatrix:Matrix = new Matrix();
			targetMatrix.translate(-positionX, -positionY);
			
			var scaleMat:Matrix = new Matrix();
			scaleMat.scale(scaleX, scaleY);
			targetMatrix.concat(scaleMat);
			
			var skewMat:Matrix = new Matrix();
			skewMat.a = Math.cos(skewY*(Math.PI/180));
			skewMat.b = Math.sin(skewY*(Math.PI/180));
			skewMat.c = -Math.sin(skewX*(Math.PI/180));
			skewMat.d = Math.cos(skewX*(Math.PI/180));
			targetMatrix.concat(skewMat);
			
			targetMatrix.translate(positionX, positionY);
				
			return targetMatrix;
		}
		/**
		* @private 
	 	*/		
		protected static const EPSILON:Number = 0.00000001;
		/**
		* @private 
	 	*/
	 	protected static function getSign(n:Number):int
		{
			return (n < -EPSILON) ? -1 : ((n > EPSILON) ? 1 : 0);
		}
		
		protected static function convertMatrixToMatrix3D(mat2D:Matrix):Matrix3D
		{
			var vec3D:Vector.<Number> = new Vector.<Number>(16);
			vec3D[0] = mat2D.a;
			vec3D[1] = mat2D.b;
			vec3D[2] = 0;
			vec3D[3] = 0;
			vec3D[4] = mat2D.c;
			vec3D[5] = mat2D.d;
			vec3D[6] = 0;
			vec3D[7] = 0;
			vec3D[8] = 0;
			vec3D[9] = 0;
			vec3D[10] = 1;
			vec3D[11] = 0;
			vec3D[12] = mat2D.tx;
			vec3D[13] = mat2D.ty;
			vec3D[14] = 0;
			vec3D[15] = 1;
			
			return new Matrix3D(vec3D);
		}

		protected static function matrices3DEqual(a:Matrix3D, b:Matrix3D):Boolean
		{
			var aRaw:Vector.<Number> = a.rawData;
			var bRaw:Vector.<Number> = b.rawData;
			if (aRaw == null || aRaw.length != 16 || bRaw == null || bRaw.length != 16) return false;
			for (var i:int = 0; i < 16; i++) {
				if (aRaw[i] != bRaw[i]) return false;
			}
			return true;
		}

	}
}