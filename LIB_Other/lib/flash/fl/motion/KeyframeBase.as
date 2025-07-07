// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.motion
{
import flash.display.BlendMode;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.utils.*;

/**
 * The KeyframeBase class defines the visual state at a specific time in a motion tween.
 * The primary animation properties are <code>position</code>, <code>scale</code>, <code>rotation</code>, <code>skew</code>, and <code>color</code>.
 * To use KeyframeBase, all properties must have values for every KeyframeBase, 
 * and there must be a KeyframeBase defined for every frame in the motion.
 * Within a motion tween, each time index can have only one keyframe. 
 * A keyframe also has other properties like <code>blend mode</code>, <code>filters</code>, and <code>cacheAsBitmap</code>,
 * which are always available. For example, a keyframe always has a blend mode.   
 * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript    
 * @see ../../motionXSD.html Motion XML Elements  
 */
public class KeyframeBase
{

    /**
     * @private
     */
	private var _index:int = -1;


    /**
     * The keyframe's unique time value in the motion tween. The first frame in a motion tween has an index of <code>0</code>.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript    
     */
	public function get index():int
	{
		return this._index;
	}

    /**
     * @private (setter)
     */
	public function set index(value:int):void
	{
		this._index = (value < 0) ? 0 : value;
		if (this._index == 0)
		{
			this.setDefaults();
		}
	}	
	
	// We need to be able to tell whether the XML explicitly specifies
	// a value for each property at this keyframe, in order to tween correctly. 
	// Using a default of NaN allows us to check that.
    /**
     * The horizontal position of the target object's transformation point in its parent's coordinate space.
     * A value of <code>NaN</code> means that the keyframe does not affect this property.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript      
     */
	public var x:Number = NaN;


    /**
     * The vertical position of the target object's transformation point in its parent's coordinate space.
     * A value of <code>NaN</code> means that the keyframe does not affect this property.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript       
     */
	public var y:Number = NaN;


    /**
     * Indicates the horizontal scale as a percentage of the object as applied from the transformation point.
     * A value of <code>1</code> is 100% of normal size.
     * A value of <code>NaN</code> means that the keyframe does not affect this property.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript       
     */
    public var scaleX:Number = NaN;


    /**
     * Indicates the vertical scale as a percentage of the object as applied from the transformation point.
     * A value of <code>1</code> is 100% of normal size.
     * A value of <code>NaN</code> means that the keyframe does not affect this property.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
     */
    public var scaleY:Number = NaN;


    /**
     * Indicates the horizontal skew angle of the target object in degrees as applied from the transformation point.
     * A value of <code>NaN</code> means that the keyframe does not affect this property.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript           
     */
    public var skewX:Number = NaN;


    /**
     * Indicates the vertical skew angle of the target object in degrees as applied from the transformation point.
     * A value of <code>NaN</code> means that the keyframe does not affect this property.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript             
     */
	public var skewY:Number = NaN;


    /**
     * Indicates the rotation of the target object in degrees 
     * from its original orientation as applied from the transformation point.
     * A value of <code>NaN</code> means that the keyframe does not affect this property.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript       
     */
    public function get rotation():Number
    {
		return this.skewY;
    }

    
    /**
     * @private (setter)
     */
	public function set rotation(value:Number):void
	{
    	// Use Flash Player behavior: set skewY to rotation and increase skewX by the difference.
   		if (isNaN(this.skewX) || isNaN(this.skewY)) 
			this.skewX = value;
		else
			this.skewX += value - this.skewY;
		this.skewY = value;
	}



    /**
     * The rotation (z-axis) values of the target object in the motion relative to previous orientation as applied from the transformation point,
     * as opposed to absolute rotation values, and separate from <code>skewY</code> values.
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
     */    
	public var rotationConcat:Number = NaN;


    /**
     * If set to <code>true</code>, this property causes the target object to rotate when data for motion is supplied by <code>addpropertyarray</code>.
     * Also when <code>true</code>, the <code>rotationConcat</code> property is used instead of <code>rotation</code>. The default is
     * <code>false</code>.
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript
     */    
	public var useRotationConcat:Boolean = false;
	
	

	[ArrayElementType("flash.filters.BitmapFilter")]
    /**
     * An array that contains each filter object to be applied to the target object at a particular keyframe.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
     */    
	public var filters:Array;


    /**
     * A color object that adjusts the color transform in the target object.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
     */
	public var color:fl.motion.Color;


    /**
     * A string used to describe the keyframe.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
     */
    public var label:String = '';


    /**
     * Stores the value of the Loop checkbox for motion tweens, which affects graphic symbols only. 
     * This property is used in the Copy and Paste Motion feature in Flash CS4 
     * but does not affect motion tweens defined using ActionScript. 
     * It is included here for compatibility with the Flex 2 compiler.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript         
     */
    public var loop:String;


    /**
     * Stores the name of the first frame for motion tweens, which affects graphic symbols only. 
     * This property is used in the Copy and Paste Motion feature in Flash CS4 
     * but does not affect motion tweens defined using ActionScript. 
     * It is included here for compatibility with the Flex 2 compiler.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
     */
    public var firstFrame:String;


    /**
     * If set to <code>true</code>, Flash Player caches an internal bitmap representation of the display object.
     * Using this property often allows faster rendering than the default use of vectors.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript       
     */
    public var cacheAsBitmap:Boolean = false;


    /**
     * Controls whether target object has an opaque background. Value is a number describing the color
     * in the form 0xrrggbb or null for no opaque background.
     * 
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS5.5
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
     */
	public var opaqueBackground:Object = null;


    /**
     * A value from the BlendMode class that specifies how Flash Player 
     * mixes the display object's colors with graphics underneath it.
     * 
     * @see flash.display.BlendMode
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
     */
	public var blendMode:String = flash.display.BlendMode.NORMAL;


    /**
     * Controls whether target object is visible.
     * 
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS5.5
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
     */
	public var visible:Boolean = true;


    /**
     * Controls how the target object rotates during a motion tween,
     * with a value from the RotateDirection class.
	 *
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript         
     * @see fl.motion.RotateDirection
     */
    public var rotateDirection:String = RotateDirection.AUTO;


    /**
     * Adds rotation to the target object during a motion tween, in addition to any existing rotation.
     * This rotation is dependent on the value of the <code>rotateDirection</code> property,
     * which must be set to <code>RotateDirection.CW</code> or <code>RotateDirection.CCW</code>. 
     * The <code>rotateTimes</code> value must be an integer that is equal to or greater than zero.
     * 
     * <p>For example, if the object would normally rotate from 0 to 40 degrees,
     * setting <code>rotateTimes</code> to <code>1</code> and <code>rotateDirection</code> to <code>RotateDirection.CW</code>
     * will add a full turn, for a total rotation of 400 degrees.</p>
     * 
     * If <code>rotateDirection</code> is set to <code>RotateDirection.CCW</code>,
     * 360 degrees will be <i>subtracted</i> from the normal rotation,
     * resulting in a counterclockwise turn of 320 degrees.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript         
     * @see #rotateDirection    
     */
    public var rotateTimes:uint = 0;


    /**
     * If set to <code>true</code>, this property causes the target object to rotate automatically 
     * to follow the angle of its path. 
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript         
     */
	public var orientToPath:Boolean = false;


    /**
     * Indicates that the target object should not be displayed on this keyframe.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript         
     */
	public var blank:Boolean = false;
	
    /**
     * Stores <code>matrix3d</code> property if one exists for this keyframe. <code>matrix3d</code> is used for non-tween frames containing 3D.
     * You can use either the <code>matrix3d</code> property or the other 3D properties (<code>z</code>, <code>rotationX</code>, <code>rotationY</code>), but not both sets together.
     * If <code>matrix3d</code> is set to something other than null, then it is used instead of any other properties (2D properties included).
     * 
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public var matrix3D:Object = null;

    /**
     * Stores <code>matrix</code> property if one exists for this keyframe. <code>matrix</code> is used for non-tween frames that do not 3D.
     * You can use either the <code>matrix</code> property or the other position and scaling properties (<code>x</code>, <code>y</code>, <code>scaleX</code>, <code>scaleY</code>, etc), but not both sets together.
     * If <code>matrix</code> is set to something other than null, then it is used instead of any other properties (3D properties included).
     * 
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public var matrix:Matrix = null;

    /**
     * The depth (z-axis) position of the target object's transformation point in its parent's coordinate space.
     * When referring to a 3D plane, a z-axis refers to the depth of a 3D object.
     * A value of <code>NaN</code> means that the keyframe does not affect this property.     
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public var z:Number = NaN;

    /**
     * Stores <code>rotationX</code> property for this keyframe. This property is the rotation of the target object around the x-axis from its original orientation.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public var rotationX:Number = NaN;

    /**
     * Stores <code>rotationY</code> property for this keyframe. This property is the rotation of the target object around the y-axis from its original orientation.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public var rotationY:Number = NaN;

    /**
     * Stores <code>AdjustColor</code> instances mapped to their corresponding index in the filters Array for this keyframe. 
     * This is used for Flash authoring's AdjustColor filters, which correspond to ColorMatrixFilters in Flash Player.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
	public var adjustColorObjects:Dictionary = null;

    /**
     * Constructor for keyframe instances.
     *
     * @param xml Optional E4X XML object defining a keyframe in Motion XML format.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript       
     */
	function KeyframeBase(xml:XML=null)
	{
		this.filters = [];
		this.adjustColorObjects = new Dictionary();
	}


    /**
     * @private
     */
	private function setDefaults():void
	{

		if (isNaN(this.x)) this.x = 0;
		if (isNaN(this.y)) this.y = 0;
		if (isNaN(this.z)) this.z = 0;
		if (isNaN(this.scaleX)) this.scaleX = 1;
		if (isNaN(this.scaleY)) this.scaleY = 1;
		if (isNaN(this.skewX)) this.skewX = 0;
		if (isNaN(this.skewY)) this.skewY = 0;
		if (isNaN(this.rotationConcat)) this.rotationConcat = 0;
	
		if(!this.color)
			this.color = new Color();
	}




    /**
     * Retrieves the value of a specific tweenable property on the keyframe.
     *
     * @param tweenableName The name of a tweenable property, such as <code>"x"</code>
     * or <code>"rotation"</code>.
     *
     * @return The numerical value of the tweenable property.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
     */
	public function getValue(tweenableName:String):Number
	{
		return Number(this[tweenableName]);
	}



    /**
     * Changes the value of a specific tweenable property on the keyframe.
     *
     * @param tweenableName The name of a tweenable property, such as  <code>"x"</code>
     * or <code>"rotation"</code>.
     *
     * @param newValue A numerical value to assign to the tweenable property.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript       
     */
    public function setValue(tweenableName:String, newValue:Number):void
	{
		this[tweenableName] = newValue;
	}


	/**
	 * @private
	 */
	protected function hasTween():Boolean
	{
		return false;
	}

	/**
	 * Indicates whether the keyframe has an influence on a specific animation property.
	 * 
     * @param tweenableName The name of a tweenable property, such as  <code>"x"</code>
     * or <code>"rotation"</code>.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
	 */
	public function affectsTweenable(tweenableName:String=''):Boolean
	{
		return	(
			!tweenableName                                       
			|| !isNaN(this[tweenableName])                           // a valid numerical value exists for the property
			|| (tweenableName == 'color' && this.color)	           
			|| (tweenableName == 'filters' && this.filters.length)
			|| (tweenableName == 'matrix3D' && this.matrix3D)
			|| (tweenableName == 'matrix' && this.matrix)
			|| this.blank				                             // keyframe is empty
			|| this.hasTween()                                       // all properties are being tweened
		);
	}
	
    /**
     * Sets one of the four <code>AdjustColor</code> properties to the <code>AdjustColor</code> object for the given filter index. 
     * It creates the <code>AdjustColor</code> instance if one does not exist for that index yet. 
     * The four properties that can be set are: 
     * <ul><li>adjustColorBrightness</li>
     * <li>adjustColorContrast</li>
     * <li>adjustColorSaturation</li>
     * <li>adjustColorHue</li></ul>
     * All four <code>AdjustColor</code> properties must be set in order for the filter to be created. 
     * Once all four properties are set on an <code>AdjustColor</code> instance,
     * the function gets from the <code>AdjustColor</code> object a flat array of 20 values representing all four properties,
     * and creates a <code>ColorMatrixFilter</code> instance, which requires the flattened array.
     * @param filterIndex The index position of the filter in the filters array to add the
     * <code>propertyName</code> property.
     * @param propertyName One of the four allowed properties values: <code>"adjustColorBrightness"</code>,
     * <code>"adjustColorContrast"</code>, <code>"adjustColorSaturation"</code>, or <code>"adjustColorHue"</code>.
     * @param value The value to set for the specified property.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @see fl.motion.AdjustColor
     */
	public function setAdjustColorProperty(filterIndex:int, propertyName:String, value:*):void
	{
		if(filterIndex >= this.filters.length)
			return;
			
		var adjustColorObj:AdjustColor = this.adjustColorObjects[filterIndex];
		if(adjustColorObj == null)
		{
			adjustColorObj = new AdjustColor();
			this.adjustColorObjects[filterIndex] = adjustColorObj;
		}
		
		switch(propertyName)
		{
			case "adjustColorBrightness":
			{
				adjustColorObj.brightness = value;
				break;
			}
			case "adjustColorContrast":
			{
				adjustColorObj.contrast = value;
				break;
			}
			case "adjustColorSaturation":
			{
				adjustColorObj.saturation = value;
				break;
			}
			case "adjustColorHue":
			{
				adjustColorObj.hue = value;
				break;
			}
		}
		
		if(adjustColorObj.AllValuesAreSet())
		{
			// all four properties have been set, so we can now
			// get the flat array to use in the ColorMatrixFilter
			var filter:ColorMatrixFilter = this.filters[filterIndex] as ColorMatrixFilter;
			if(filter)
			{
				var flatArray:Array = adjustColorObj.CalculateFinalFlatArray();
				if(flatArray)
				{
					filter.matrix = flatArray;
				}
			}
		}
	}

    /**
     * The number of frames for the tween.
     *
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword tweensLength, Copy Motion as ActionScript       
     */	
	public function get tweensLength():int
	{
		return 0;
	}
}
}
