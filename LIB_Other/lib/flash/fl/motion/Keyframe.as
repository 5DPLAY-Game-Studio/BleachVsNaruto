// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.motion
{
import flash.display.BlendMode;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;
import flash.utils.*;

/**
 * The Keyframe class defines the visual state at a specific time in a motion tween.
 * The primary animation properties are <code>position</code>, <code>scale</code>, <code>rotation</code>, <code>skew</code>, and <code>color</code>.
 * A keyframe can, optionally, define one or more of these properties.
 * For instance, one keyframe may affect only position, 
 * while another keyframe at a different point in time may affect only scale.
 * Yet another keyframe may affect all properties at the same time.
 * Within a motion tween, each time index can have only one keyframe. 
 * A keyframe also has other properties like <code>blend mode</code>, <code>filters</code>, and <code>cacheAsBitmap</code>,
 * which are always available. For example, a keyframe always has a blend mode. 
 * <p><strong>Note:</strong> In Flash CS3, many of the properties and methods supported by this class were members of this class, exclusively.
 * Flash CS4 introduced a base class, KeyframeBase, for those
 * properties and methods of this class, and they are now shared by other classes through the inheritance chain. If you have been working in Flash CS3,
 * notice that these properties and methods are still supported by the Keyframe class, but are members of the KeyframeBase class in releases 
 * of Flash Professional after Flash CS3. As with any other class in this reference, select Show Inherited Public Properties and Show Inherited Public Methods
 * to see all of the properties and methods supported by this class. </p> 
 * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript    
 * @see ../../motionXSD.html Motion XML Elements
 * @see fl.motion.KeyframeBase
 */
public class Keyframe extends KeyframeBase
{
	[ArrayElementType("fl.motion.ITween")]
    /**
     * An array that contains each tween object to be applied to the target object at a particular keyframe.
     * One tween can target all animation properties (as with standard tweens on the Flash authoring tool's timeline),
     * or multiple tweens can target individual properties (as with separate custom easing curves).
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript         
     */    
	public var tweens:Array;

    /**
     * A flag that controls whether scale will be interpolated during a tween.
     * If <code>false</code>, the display object will stay the same size during the tween, until the next keyframe.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
     */
    public var tweenScale:Boolean = true;
    
    
    /**
     * Stores the value of the Snap checkbox for motion tweens, which snaps the object to a motion guide. 
     * This property is used in the Copy and Paste Motion feature in Flash CS4 
     * but does not affect motion tweens defined using ActionScript. 
     * It is included here for compatibility with the Flex 2 compiler.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript       
     */
    public var tweenSnap:Boolean = false;


    /**
     * Stores the value of the Sync checkbox for motion tweens, which affects graphic symbols only. 
     * This property is used in the Copy and Paste Motion feature in Flash CS4 
     * but does not affect motion tweens defined using ActionScript. 
     * It is included here for compatibility with the Flex 2 compiler.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript      
     */
    public var tweenSync:Boolean = false;

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
	function Keyframe(xml:XML=null)
	{
		super(xml);
		this.tweens = [];
		this.parseXML(xml);
	}

    /**
     * @private
     */
	private function parseXML(xml:XML=null):KeyframeBase
	{
		if (!xml) return this;
 
 
		//// ATTRIBUTES

 		var indexString:String = xml.@index.toXMLString();
		var indexValue:int = parseInt(indexString);
		if (indexString)
		{
			this.index = indexValue;
		}
		else
			throw new Error('<Keyframe> is missing the required attribute "index".');
		
		if (xml.@label.length())
			this.label = xml.@label;
			
		if (xml.@tweenScale.length())
			this.tweenScale = xml.@tweenScale.toString() == 'true';

		if (xml.@tweenSnap.length())
			this.tweenSnap = xml.@tweenSnap.toString() == 'true';

		if (xml.@tweenSync.length())
			this.tweenSync = xml.@tweenSync.toString() == 'true';

		if (xml.@blendMode.length())
			this.blendMode = xml.@blendMode;
			
		if (xml.@cacheAsBitmap.length())
			this.cacheAsBitmap = xml.@cacheAsBitmap.toString() == 'true';
			
		if (xml.@opaqueBackground.length()) {
			var bgColorStr:String = xml.@opaqueBackground.toString();
			if (bgColorStr == 'null') {
				this.opaqueBackground = null;
			} else {
				this.opaqueBackground = parseInt(bgColorStr);
			}
		}
			
		if (xml.@visible.length())
			this.visible = xml.@visible.toString() == 'true';
			
		if (xml.@rotateDirection.length())
			this.rotateDirection = xml.@rotateDirection;

		if (xml.@rotateTimes.length())
			this.rotateTimes = parseInt(xml.@rotateTimes);
		
		if (xml.@orientToPath.length())
			this.orientToPath = xml.@orientToPath.toString() == 'true';
		
		if (xml.@blank.length())
			this.blank = xml.@blank.toString() == 'true';
			
		// need to set rotation first in the order because skewX and skewY override it
		var tweenableNames:Array = ['x', 'y', 'scaleX', 'scaleY', 'rotation', 'skewX', 'skewY'];
		for each (var tweenableName:String in tweenableNames)
		{
			var attribute:XML = xml.attribute(tweenableName)[0];
			if (!attribute) continue;
			
			var attributeValue:String = attribute.toString();
			if (attributeValue)
			{
				this[tweenableName] = Number(attributeValue);
			}
		}

		//// CHILD ELEMENTS
		var elements:XMLList = xml.elements();
		var filtersArray:Array = [];

		for each (var child:XML in elements)
		{
			var name:String = child.localName();
			if (name == 'tweens')
			{
				var tweenChildren:XMLList = child.elements();
				for each (var tweenChild:XML in tweenChildren)
				{
					var tweenName:String = tweenChild.localName();
					if (tweenName == 'SimpleEase')
						this.tweens.push(new SimpleEase(tweenChild));
					else if (tweenName == 'CustomEase')
						this.tweens.push(new CustomEase(tweenChild));
					else if (tweenName == 'BezierEase')
						this.tweens.push(new BezierEase(tweenChild));
					else if (tweenName == 'FunctionEase')
						this.tweens.push(new FunctionEase(tweenChild));
				} 
			}
			else if (name == 'filters')
			{
				var filtersChildren:XMLList = child.elements();
				for each (var filterXML:XML in filtersChildren)
				{
					var filterName:String = filterXML.localName();
					var filterClassName:String = 'flash.filters.' + filterName;
					if (filterName == 'AdjustColorFilter')
					{
						continue;
					}
					
					var filterClass:Object = flash.utils.getDefinitionByName(filterClassName);
					var filterInstance:BitmapFilter = new filterClass();
					var filterTypeInfo:XML = describeType(filterInstance);			
					var accessorList:XMLList = filterTypeInfo.accessor; 
					var ratios:Array = [];
					
					// loop through filter properties
					for each (var attrib:XML in filterXML.attributes())
					{
						var attribName:String = attrib.localName();
						var accessor:XML = accessorList.(@name==attribName)[0];
						var attribType:String = accessor.@type;
						var attribValue:String = attrib.toString();
						 
						if (attribType == 'int') 
							filterInstance[attribName] = parseInt(attribValue);
						else if (attribType == 'uint') 
						{
							filterInstance[attribName] = parseInt(attribValue) as uint; 
							var uintValue:uint = parseInt(attribValue) as uint;
						}
						else if (attribType == 'Number') 
							filterInstance[attribName] = Number(attribValue);
						else if (attribType == 'Boolean') 
							filterInstance[attribName] = (attribValue == 'true');
						else if (attribType == 'Array') 
						{
							// remove the brackets at either end of the string
							attribValue = attribValue.substring(1, attribValue.length-1);
							var valuesArray:Array = null;  
							if (attribName == 'ratios' || attribName == 'colors')
							{
								valuesArray = splitUint(attribValue);
							}
							else if (attribName == 'alphas')
							{
								valuesArray = splitNumber(attribValue);
							}

							if (attribName == 'ratios')
								ratios = valuesArray;
							else if (valuesArray)
								filterInstance[attribName] = valuesArray;
								
						}
						else if (attribType == 'String')
						{
							filterInstance[attribName] = attribValue;
						}
					}// end attributes loop
					
					// force ratios array to be set after colors and alphas arrays, otherwise it won't work correctly
					if (ratios.length)
					{
						filterInstance['ratios'] = ratios;
					}
					filtersArray.push(filterInstance);
				}//end filters loop
				
			}
			else if (name == 'color')
			{
				this.color = Color.fromXML(child);
 			}
 			
 			this.filters = filtersArray;
		}
		
		return this;
	}
	 
	/**
	 * @private
	 */
	private static function splitNumber(valuesString:String):Array
	{
		var valuesArray:Array = valuesString.split(','); 
		for (var vi:int=0; vi<valuesArray.length; vi++)
		{
			valuesArray[vi] = Number(valuesArray[vi]);
		}
		return valuesArray;		
	}


	/**
	 * @private
	 */
	private static function splitUint(valuesString:String):Array
	{
		var valuesArray:Array = valuesString.split(','); 
		for (var vi:int=0; vi<valuesArray.length; vi++)
		{
			valuesArray[vi] = parseInt(valuesArray[vi]) as uint;
		}		
		return valuesArray;		
	}


	/**
	 * @private
	 */
	private static function splitInt(valuesString:String):Array
	{
		var valuesArray:Array = valuesString.split(','); 
		for (var vi:int=0; vi<valuesArray.length; vi++)
		{
			valuesArray[vi] = parseInt(valuesArray[vi]) as int;
		}		
		return valuesArray;		
	}
	
    /**
     * Retrieves an ITween object for a specific animation property.
     *
     * @param target The name of the property being tweened.
     * @see fl.motion.ITween#target
     *
     * @return An object that implements the ITween interface.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
     */
	public function getTween(target:String=''):ITween
	{
		for each (var tween:ITween in this.tweens)
		{
			if (tween.target == target
				// If we're looking for a skew tween and there isn't one, use rotation if available.
				|| (tween.target == 'rotation' 
					&& (target == 'skewX' || target == 'skewY'))

				|| (tween.target == 'position' 
					&& (target == 'x' || target == 'y'))

				|| (tween.target == 'scale' 
					&& (target == 'scaleX' || target == 'scaleY'))
				)
				return tween;
		}
		return null;
	}
	
	/**
	 * @private
	 */
	protected override function hasTween():Boolean
	{
		return this.getTween() != null;
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
	public override function get tweensLength():int
	{
		return this.tweens.length;
	}
}
}
