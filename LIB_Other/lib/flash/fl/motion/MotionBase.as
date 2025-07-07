// Copyright ? 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.motion
{
	
import flash.filters.*;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.*;

/**
 * The MotionBase class stores a keyframe animation sequence that can be applied to a visual object.
 * The animation data includes position, scale, rotation, skew, color, filters, and easing.
 * The MotionBase class has methods for retrieving data at specific keyframe points. To get
 * interpolated values between keyframes, use the Motion class. 
 * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript  
 * @includeExample examples\MotionBaseExample.as -noswf
 * @see fl.motion.Motion Motion class
 * @see ../../motionXSD.html Motion XML Elements   
 */
public class MotionBase
{
    /**
     * An array of keyframes that define the motion's behavior over time.
     * This property is a sparse array, where a keyframe is placed at an index in the array
     * that matches its own index. A motion object with keyframes at 0 and 5 has 
     * a keyframes array with a length of 6.  
     * Indices 0 and 5 in the array each contain a keyframe, 
     * and indices 1 through 4 have null values.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript      
     */    
	public var keyframes:Array;

    /**
     * Constructor for MotionBase instances.
     * By default, one initial keyframe is created automatically, with default transform properties.
     *
     * @param xml Optional E4X XML object defining a Motion instance.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript      
     */
	function MotionBase(xml:XML=null)
	{
		this.keyframes = [];
			
		// ensure there is at least one keyframe
		if (this.duration == 0)
		{
			var kf:KeyframeBase = getNewKeyframe();
			kf.index = 0;
			this.addKeyframe(kf);
		}
		
		this._overrideScale = false;
		this._overrideSkew = false;
		this._overrideRotate = false;
	}
	
    /**
     * @private
     */
	private var _spanStart:int;

	/**
	 * Used when an array of MotionBase instances are passed into a AnimatorBase subclass.
	 */
	motion_internal function set spanStart(v:int):void
	{
		_spanStart = v;
	}
    /**
     * @private
     */
	motion_internal function get spanStart():int
	{
		return _spanStart;
	}

    /**
     * @private
     */
	private var _transformationPoint:Point;

	/**
	 * Used when an array of MotionBase instances are passed into a AnimatorBase subclass.
	 */
	motion_internal function set transformationPoint(v:Point):void
	{
		_transformationPoint = v;
	}
    /**
     * @private
     */
	motion_internal function get transformationPoint():Point
	{
		return _transformationPoint;
	}

    /**
     * @private
     */
	private var _transformationPointZ:int;

	/**
	 * Used when an array of MotionBase instances are passed into a AnimatorBase subclass.
	 */
	motion_internal function set transformationPointZ(v:int):void
	{
		_transformationPointZ = v;
	}
    /**
     * @private
     */
	motion_internal function get transformationPointZ():int
	{
		return _transformationPointZ;
	}

    /**
     * @private
     */
	private var _initialPosition:Array;

	/**
	 * Used when an array of MotionBase instances are passed into a AnimatorBase subclass.
	 */
	motion_internal function set initialPosition(v:Array):void
	{
		_initialPosition = v;
	}
    /**
     * @private
     */
	motion_internal function get initialPosition():Array
	{
		return _initialPosition;
	}

    /**
     * @private
     */
	private var _initialMatrix:Matrix;

	/**
	 * Used when an array of MotionBase instances are passed into a AnimatorBase subclass.
	 */
	motion_internal function set initialMatrix(v:Matrix):void
	{
		_initialMatrix = v;
	}
    /**
     * @private
     */
	motion_internal function get initialMatrix():Matrix
	{
		return _initialMatrix;
	}

    /**
     * @private
     */
	private var _duration:int = 0;

    /**
     * Controls the Motion instance's length of time, measured in frames.
     * The duration cannot be less than the time occupied by the Motion instance's keyframes.
     * @default 0
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript      
     */
	public function get duration():int
	{
		// check again on the getter because the keyframes array may have changed after the setter was called
		if (this._duration < this.keyframes.length)
			this._duration = this.keyframes.length;
		return this._duration;
	}

    /**
     * @private (setter)
     */
	public function set duration(value:int):void
	{
		if (value < this.keyframes.length)
			value = this.keyframes.length;
		this._duration = value;
	}


	private var _is3D:Boolean = false;

    /**
     * Specifies whether the motion contains 3D property changes. If <code>true</code>, the 
     * motion contains 3D property changes. 
     * @default false
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript  
     */ 
	public function get is3D():Boolean 
	{
		return _is3D;
	}
	

    /**
     * Sets flag that indicates whether the motion contains 3D properties. 
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript  
     */ 
	public function set is3D(enable:Boolean):void
	{
		_is3D = enable;
	}

	/**
	 * Indicates whether property values for scale, skew, and rotate added in subsequent
	 * calls to addPropertyArray should be made relative to the first value, or used as-is,
	 * such that they override the target object's initial target transform.
	 */
	private var _overrideScale:Boolean;
	private var _overrideSkew:Boolean;
	private var _overrideRotate:Boolean;
	
	public function overrideTargetTransform(scale:Boolean = true, skew:Boolean = true, rotate:Boolean = true):void
	{
		_overrideScale = scale;
		_overrideSkew = skew;
		_overrideRotate = rotate;
	}
	
    /**
     * @private
     */
	private function indexOutOfRange(index:int):Boolean
	{
		return (isNaN(index) || index < 0 || index > this.duration-1);
	}


	
	/**
	 * Retrieves the keyframe that is currently active at a specific frame in the Motion instance.
	 * A frame that is not a keyframe derives its values from the keyframe that preceded it.  
	 * 
	 * <p>This method can also filter values by the name of a specific tweenables property.
	 * You can find the currently active keyframe for <code>x</code>, which may not be
	 * the same as the currently active keyframe in general.</p>
	 * 
	 * @param index The index of a frame in the Motion instance, as an integer greater than or equal to zero.
	 * 
     * @param tweenableName Optional name of a tweenable's property (like <code>"x"</code> or <code>"rotation"</code>).
	 * 
	 * @return The closest matching keyframe at or before the supplied frame index.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript      
     * @see fl.motion.Tweenables
	 */
	public function getCurrentKeyframe(index:int, tweenableName:String=''):KeyframeBase
	{
		// catch out-of-range frame values
		if ((isNaN(index) || index < 0 || index > this.duration-1))
			return null;
		// start at the given time and go backward until we hit a keyframe that matches
		for (var i:int=index; i>0; i--) 
		{
			var kf:KeyframeBase = this.keyframes[i];
			// if a keyframe exists, return it if the name matches or no name was given, 
			// or if it's tweening all properties
			if (kf && kf.affectsTweenable(tweenableName))
			{
				return kf;
			}
		}
		// return the first keyframe if no other match
		return this.keyframes[0];
	}


	/**
	 * Retrieves the next keyframe after a specific frame in the Motion instance.
	 * If a frame is not a keyframe, and is in the middle of a tween, 
	 * this method derives its values from both the preceding keyframe and the following keyframe.
	 * 
	 * <p>This method also allows you to filter by the name of a specific tweenables property
     * to find the next keyframe for a property, which might not be
	 * the same as the next keyframe in general.</p>
	 * 
	 * @param index The index of a frame in the Motion instance, as an integer greater than or equal to zero.
	 * 
     * @param tweenableName Optional name of a tweenable's property (like <code>"x"</code> or <code>"rotation"</code>).
	 * 
	 * @return The closest matching keyframe after the supplied frame index.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript      
     * @see fl.motion.Tweenables     
	 */
	public function getNextKeyframe(index:int, tweenableName:String=''):KeyframeBase
	{
		// catch out-of-range frame values 
		if ((isNaN(index) || index < 0 || index > this.duration-1))
			return null;
		
		// start just after the given time and go forward until we hit a keyframe that matches
		for (var i:int=index+1; i<this.keyframes.length; i++) 
		{
			var kf:KeyframeBase = this.keyframes[i];
			// if a keyframe exists, return it if no name was given or the name matches or there's a keyframe tween
			if (kf && kf.affectsTweenable(tweenableName))
			{
				return kf;
			}
		}
		return null;
	}

	

    /**
     * Sets the value of a specific tweenables property at a given time index in the Motion instance.
     * If a keyframe doesn't exist at the index, one is created automatically.
     *
	 * @param index The time index of a frame in the Motion instance, as an integer greater than zero.
	 * If the index is zero, no change is made. 
	 * Transformation properties are relative to the starting transformation values of the target object,
	 * the values for the first frame (zero index value) are always default values and should not be changed.
     *
     * @param tweenableName The name of a tweenable's property as a string (like <code>"x"</code> or <code>"rotation"</code>).
     *
     * @param value The new value of the tweenable property.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript      
     * @see fl.motion.Tweenables         
     */
	public function setValue(index:int, tweenableName:String, value:Number):void
	{
		if (index==0) return;
		
		var kf:KeyframeBase = this.keyframes[index];
		if (!kf)
		{
			kf = getNewKeyframe();
			kf.index = index;
			this.addKeyframe(kf);
		}
 		
		kf.setValue(tweenableName, value);
	}

    /**
     * Retrieves an interpolated ColorTransform object at a specific time index in the Motion instance.
     *
	 * @param index The time index of a frame in the Motion instance, as an integer greater than or equal to zero.
     *
     * @return The interpolated ColorTransform object.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript  
     * @see flash.geom.ColorTransform
     */
 	public function getColorTransform(index:int):ColorTransform
	{
		var result:ColorTransform = null;
		var curKeyframe:KeyframeBase = this.getCurrentKeyframe(index, 'color');	
		if (!curKeyframe || !curKeyframe.color) 
			return null;
		
		var begin:ColorTransform = curKeyframe.color;
		var timeFromKeyframe:Number = index - curKeyframe.index;

		if (timeFromKeyframe == 0)
		{
			result = begin;
		}

		return result;
	} 

    /**
     * Returns the Matrix3D object for the specified index position of
     * the frame of animation. 
     * @param index The zero-based index position of the frame of animation containing the 3D matrix.
     * @return The Matrix3D object, or null value. This method can return a null value even if 
     * <code>MotionBase.is3D</code> is <code>true</code>, because other 3D motion tween property changes can be used
     * without a Matrix3D object.
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript 
     * @see flash.geom.Matrix3D
     */ 
	public function getMatrix3D(index:int):Object
	{
		var curKeyframe:KeyframeBase = this.getCurrentKeyframe(index, 'matrix3D');
		return curKeyframe ? curKeyframe.matrix3D : null;
	}
	
    /**
     * Returns the Matrix object for the specified index position of
     * the frame of animation. 
     * @param index The zero-based index position of the frame of animation containing the matrix.
     * @return The Matrix object, or null value. This method can return a null value even if 
     * <code>MotionBase.is3D</code> is <code>false</code>, because other motion tween property changes can be used
     * without a Matrix object.
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript 
     * @see flash.geom.Matrix
     */ 
	public function getMatrix(index:int):Matrix
	{
		var curKeyframe:KeyframeBase = this.getCurrentKeyframe(index, 'matrix');
		return curKeyframe ? curKeyframe.matrix : null;
	}
	
   /**
     * Rotates the target object when data for the motion is supplied by the <code>addPropertyArray()</code> method.
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @param index The index position of the frame of animation.
     * @return Indicates whether the target object will rotate using the stored property from 
     * <code>KeyframeBase.rotationConcat</code>.
     * @keyword Motion, Copy Motion as ActionScript 
     * @see #addPropertyArray()
     * @see fl.motion.KeyframeBase#rotationConcat
     */ 
	public function useRotationConcat(index:int):Boolean
	{
		var curKeyframe:KeyframeBase = this.getCurrentKeyframe(index, 'rotationConcat');
		return curKeyframe ? curKeyframe.useRotationConcat : false;
	}

    /**
     * Retrieves an interpolated array of filters at a specific time index in the Motion instance.
     *
	 * @param index The time index of a frame in the Motion, as an integer greater than or equal to zero.
     *
     * @return The interpolated array of filters. 
     * If there are no applicable filters, returns an empty array.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript  
     * @see flash.filters
     */
 	public function getFilters(index:Number):Array
	{
		var result:Array = null;
		var curKeyframe:KeyframeBase = this.getCurrentKeyframe(index, 'filters');	
		if (!curKeyframe || (curKeyframe.filters && !curKeyframe.filters.length)) 
			return [];
		
		var begin:Array = curKeyframe.filters;
		var timeFromKeyframe:Number = index - curKeyframe.index;

		if (timeFromKeyframe == 0)
		{
			result = begin;
		}

		return result;
	} 


     /**
     * @private
     */
	protected function findTweenedValue(index:Number, tweenableName:String, curKeyframeBase:KeyframeBase, timeFromKeyframe:Number, begin:Number):Number
	{
		return NaN;
	}

    /**
     * Retrieves the value for an animation property at a point in time.
     *
	 * @param index The time index of a frame in the Motion instance, as an integer greater than or equal to zero.
     *
     * @param tweenableName The name of a tweenable's property (like <code>"x"</code> or <code>"rotation"</code>).
     * @return The number value for the property specified in the <code>tweenableName</code> parameter.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript  
     * @see fl.motion.Tweenables     
     */
	public function getValue(index:Number, tweenableName:String):Number
	{
		var result:Number = NaN;
		
		// range checking is done in getCurrentKeyindex()
		var curKeyframe:KeyframeBase = this.getCurrentKeyframe(index, tweenableName);
		if (!curKeyframe || curKeyframe.blank) return NaN;
		
		var begin:Number = curKeyframe.getValue(tweenableName);
		
		// If the property isn't defined at this keyframe, 
		// we have to figure out what it should be at this time, 
		// so grab the value from the previous keyframe--works recursively.
		if (isNaN(begin) && curKeyframe.index > 0)
		{
			//var prevKeyframe:KeyframeBase = this.getCurrentKeyframe(curKeyframe.index-1, tweenableName);
			begin = this.getValue(curKeyframe.index-1, tweenableName);
		}
		
		if (isNaN(begin)) return NaN;
		
		var timeFromKeyframe:Number = index - curKeyframe.index;
		// if we're right on the first keyframe, use the value defined on it 
		if (timeFromKeyframe == 0) 
			return begin;
		
		result = findTweenedValue(index, tweenableName, curKeyframe, timeFromKeyframe, begin);
			
		return result;
	}


    /**
     * Adds a keyframe object to the Motion instance. 
     *
     * @param newKeyframe A keyframe object with an index property already set.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript  
     * @see fl.motion.Keyframe       
     */
	public function addKeyframe(newKeyframe:KeyframeBase):void
	{ 
		this.keyframes[newKeyframe.index] = newKeyframe;
		if (this.duration < this.keyframes.length)
			this.duration = this.keyframes.length;
	}

    /**
     * Stores an array of values in corresponding keyframes for a declared property of the Motion class.
     * The order of the values in the array determines the assignment of each value to a keyframe. For each
     * non-null value in the given <code>values</code> array, this method finds the keyframe 
     * corresponding to the value's index position in the array, or creates a new keyframe for that index
     * position, and stores the property name/value pair in the keyframe. 
     * 
     * @param name The name of the Motion class property to store in each keyframe.
     *
     * @param values The array of values for the property specified in the <code>name</code>
     * parameter. Each non-null value is assigned to a keyframe that corresponds to the value's 
     * order in the array.
     * 
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript  
     * @see fl.motion.Motion      
     */
	public function addPropertyArray(name:String, values:Array, startFrame:int = -1, endFrame:int = -1):void
	{
		var numValues:int = values.length;
		
		var lastValue:* = null;
		var useLastValue:Boolean = true;
		var startNumValue:Number = 0;
		if(numValues > 0) 
		{
			if(values[0] is Number)
			{
				useLastValue = false;
				
				if(values[0] is Number)
				{
					startNumValue = Number(values[0]);
				}
			}
		}
		
		// this should never be the case for motion code created by Flash authoring
		// it sets the duration property before calling this API
		if(this.duration < numValues) {
			this.duration = numValues;
		}
		
		if(startFrame == -1 || endFrame == -1)
		{
			startFrame = 0;
			endFrame = this.duration;
		}
		
		for(var i:int = startFrame; i < endFrame; i++) 
		{
			// add a Keyframe for every changed value, since we're working
			// with frame-by-frame data
			var kf:KeyframeBase = KeyframeBase(this.keyframes[i]);
			if(kf == null) {
				kf = getNewKeyframe();
				kf.index = i;
				this.addKeyframe(kf);			
			}
			
			if(kf.filters && kf.filters.length == 0)
			{
				// Keyframes created using the property array APIs (as opposed to
				// the XML) should default to having a null filters property. it
				// will get set if initFilters/addFilterPropertyArray are called.
				kf.filters = null; 
			}
			
			// use the last non-null value
			var curValue:* = lastValue;
			var valueIndex:int = i-startFrame;
			if(valueIndex < values.length) {
				if(values[valueIndex] || !useLastValue) {
					curValue = values[valueIndex];
				}
			}
			
			switch(name) {
				case "blendMode":
				case "matrix3D":
				case "matrix":
				case "cacheAsBitmap":
				case "opaqueBackground":
				case "visible":
				{
					kf[name] = curValue;
					break;
				}
				case "rotationConcat":
				{
					// special case for rotation, in order to be
					// backwards-compatible with old rotation -
					// since the Matrix math needed to concat the
					// rotation requires radians, do the conversion here
					kf.useRotationConcat = true;
					if(!this._overrideRotate && !useLastValue)
					{
						kf.setValue(name, (curValue-startNumValue)*Math.PI/180);
					}
					else
					{
						kf.setValue(name, curValue*Math.PI/180);
					}
					break;
				}
				case "brightness":
				case "tintMultiplier":
				case "tintColor":
				case "alphaMultiplier":
				case "alphaOffset":
				case "redMultiplier":
				case "redOffset":
				case "greenMultiplier":
				case "greenOffset":
				case "blueMultiplier":
				case "blueOffset":
				{
					// color transform values can be set directly on 
					// the keyframe's Color object (the names map to
					// property setters
					if(kf.color == null) {
						kf.color = new Color();
					}
					
					kf.color[name] = curValue;
					break;
				}
				case "rotationZ":
				{
					kf.useRotationConcat = true;
					this._is3D = true;
					if(!this._overrideRotate && !useLastValue)
					{
						kf.setValue("rotationConcat", curValue - startNumValue);
					}
					else
					{
						kf.setValue("rotationConcat", curValue);
					}
					break;
				}
				case "rotationX":
				case "rotationY":
				case "z":
				{
					// remember if any of the 3d properties get set
					// (aside from the special case matrix3D, which
					// will trump all the others
					this._is3D = true;
					
					// allow to fall through to default case
				}
				default:
				{
					var newValue:* = curValue;
					if(!useLastValue)
					{
						switch(name)
						{
							case "scaleX":
							case "scaleY":
							{
								if(!this._overrideScale)
								{
									if(startNumValue == 0)
									{
										newValue = curValue + 1;
									}
									else
									{
										newValue = curValue/startNumValue;
									}
								}
								break;
							}
							case "skewX":
							case "skewY":
							{
								if(!this._overrideSkew)
								{
									newValue = curValue - startNumValue;
								}
								break;
							}
							case "rotationX":
							case "rotationY":
							{
								if(!this._overrideRotate)
								{
									newValue = curValue - startNumValue;
								}
								break;
							}
						}
					}
					
					kf.setValue(name, newValue);
					break;
				}
			}
			
			lastValue = curValue;
		}
	}

    /**
     * Initializes the filters list for the target object and copies the list of filters to each Keyframe
     * instance of the Motion object. 
     * 
     * @param filterClasses An array of filter classes. Each item in the array is the fully qualified 
     * class name (in String form) for the filter type occupying that index.
     *
     * @param gradientSubarrayLengths An array of numbers containing a value for every filter that will be in the filters 
     * list for the motion (every class name in the <code>filterClasses</code> array). A value in the 
     * <code>gradientSubarrayLengths</code> array is only used if the filter class entry at the same index position in the 
     * <code>filterClasses</code> array is GradientGlowFilter or GradientBevelFilter.
     * The corresponding value in the <code>gradientSubarrayLengths</code> array is a number that determines the length for the arrays 
     * that initialize the <code>colors</code>, <code>alphas</code>, and <code>ratios</code> parameters for the 
     * GradientGlowFilter and GradientBevelFilter constructor functions.
     *
     * 
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript  
     * @see flash.filters      
     * @see flash.filters.GradientGlowFilter
     * @see flash.filters.GradientBevelFilter
     */ 
	public function initFilters(filterClasses:Array, gradientSubarrayLengths:Array, startFrame:int = -1, endFrame:int = -1):void 
	{
		// create the filters arrays based on the filter class names that
		// we are given
		if(startFrame == -1 || endFrame == -1)
		{
			startFrame = 0;
			endFrame = this.duration;
		}
		
		for(var j:int = 0; j < filterClasses.length; j++)
		{
			var filterClass:Class = flash.utils.getDefinitionByName(filterClasses[j]) as Class;
			
			for(var i:int = startFrame; i < endFrame; i++)
			{
				var kf:KeyframeBase = KeyframeBase(this.keyframes[i]);
				if(kf == null) {
					kf = getNewKeyframe();
					kf.index = i;
					this.addKeyframe(kf);			
				}
				
				if(kf && kf.filters == null)
				{
					kf.filters = new Array;
				}
				
				if(kf && kf.filters) {
					var filter:BitmapFilter = null;
					switch(filterClasses[j])
					{
						case "flash.filters.GradientBevelFilter":
						case "flash.filters.GradientGlowFilter":
						{
							var subarrayLength:int = gradientSubarrayLengths[j];
							filter = BitmapFilter(new filterClass(4, 45, new Array(subarrayLength), new Array(subarrayLength), new Array(subarrayLength)));
							break;
						}
						default:
						{
							filter = BitmapFilter(new filterClass());
							break;
						}
					}
					if(filter)
					{
						kf.filters.push(filter);
					}
				}
			}
		}	
	}

    /**
     * Modifies a filter property in all corresponding keyframes for a Motion object. Call <code>initFilters()</code> before
     * using this method. The order of the values in the array determines the assignment of each value
     * to the filter property for all keyframes. For each non-null value in the specified <code>values</code>
     * array, this method finds the keyframe corresponding to the value's index position in the array,
     * and stores the property name/value pair for the filter in the keyframe. 
     * 
     * @param index The zero-based index position in the array of filters.
     *
     * @param name The name of the filter property to store in each keyframe.
     *
     * @param values The array of values for the property specified in the <code>name</code>
     * parameter. Each non-null value is assigned to the filter in a keyframe that corresponds to 
     * the value's index in the array.
     * 
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript 
     * @see #initFilters()
     * @see flash.filters     
     */ 
	public function addFilterPropertyArray(index:int, name:String, values:Array, startFrame:int = -1, endFrame:int = -1):void
	{
		var numValues:int = values.length;
		
		var lastValue:* = null;
		var useLastValue:Boolean = true;
		if(numValues > 0) 
		{
			if(values[0] is Number)
			{
				useLastValue = false;
			}
		}
		
		// this should never be the case for motion code created by Flash authoring
		// it sets the duration property before calling this API
		if(this.duration < numValues) {
			this.duration = numValues;
		}
		
		if(startFrame == -1 || endFrame == -1)
		{
			startFrame = 0;
			endFrame = this.duration;
		}
		
		for(var i:int = startFrame; i < endFrame; i++) 
		{
			// add a Keyframe for every changed value, since we're working
			// with frame-by-frame data
			var kf:KeyframeBase = KeyframeBase(this.keyframes[i]);
			if(kf == null) {
				kf = getNewKeyframe();
				kf.index = i;
				this.addKeyframe(kf);			
			}
			
			// use the last non-null value
			var curValue:* = lastValue;
			var valueIndex:int = i-startFrame;
			if(valueIndex < values.length) {
				if(values[valueIndex] || !useLastValue) {
					curValue = values[valueIndex];
				}
			}
			
			switch(name)
			{
				case "adjustColorBrightness":
				case "adjustColorContrast":
				case "adjustColorSaturation":
				case "adjustColorHue":
				{
					kf.setAdjustColorProperty(index, name, curValue);
					break;
				}
				default:
				{
					// get the filters Array
					if(index < kf.filters.length) 
					{
						kf.filters[index][name] = curValue;
					}
					break;
				}
			}
			
			lastValue = curValue;
		}
	}
	
	
	/**
	* @private
        */
	protected function getNewKeyframe(xml:XML = null):KeyframeBase
	{
		return new KeyframeBase(xml);
	}
}
}
