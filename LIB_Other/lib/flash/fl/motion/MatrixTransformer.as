// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.motion
{
import flash.geom.*;

/**
 * The MatrixTransformer class contains methods for modifying individual properties of a transformation matrix:
 * horizontal and vertical scale, horizontal and vertical skew, and rotation.
 * This class also has methods for rotating around a given transformation point rather than the typical (0, 0) point.
 * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword MatrixTransformer, Copy Motion as ActionScript    
 * @see ../../motionXSD.html Motion XML Elements   
 * @see flash.geom
 */
public class MatrixTransformer
{	
    /**
     * Calculates the horizontal scale present in a matrix.
     *
     * @param m A Matrix instance.
     *
     * @return The horizontal scale.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix
     */
	public static function getScaleX(m:Matrix):Number
	{
		return Math.sqrt(m.a*m.a + m.b*m.b);
	}



    /**
     * Changes the horizontal scale in a matrix.
     *
     * @param m A Matrix instance to be modified.
     *
     * @param scaleX The new horizontal scale.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix   
     */
	public static function setScaleX(m:Matrix, scaleX:Number):void
	{
		var oldValue:Number = getScaleX(m);
		// avoid division by zero 
		if (oldValue)
		{
			var ratio:Number = scaleX / oldValue;
			m.a *= ratio;
			m.b *= ratio;
		}
		else
		{
			var skewYRad:Number = getSkewYRadians(m);
			m.a = Math.cos(skewYRad) * scaleX;
			m.b = Math.sin(skewYRad) * scaleX;
		}
	}



    /**
     * Calculates the vertical scale present in a matrix.
     *
     * @param m A Matrix instance.
     *
     * @return The vertical scale.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix        
     */
   	public static function getScaleY(m:Matrix):Number
	{
		return Math.sqrt(m.c*m.c + m.d*m.d);
	}



    /**
     * Changes the vertical scale in a matrix.
     *
     * @param m A Matrix instance to be modified.
     *
     * @param scaleY The new vertical scale.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix       
     */
	public static function setScaleY(m:Matrix, scaleY:Number):void
	{
		var oldValue:Number = getScaleY(m);
		// avoid division by zero 
		if (oldValue)
		{
			var ratio:Number = scaleY / oldValue;
			m.c *= ratio;
			m.d *= ratio;
		}
		else
		{
			var skewXRad:Number = getSkewXRadians(m);
			m.c = -Math.sin(skewXRad) * scaleY;
			m.d =  Math.cos(skewXRad) * scaleY;
		}
	}



    /**
     * Calculates the angle of horizontal skew present in a matrix, in radians.
     *
     * @param m A Matrix instance.
     *
     * @return The angle of horizontal skew, in radians.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix       
     */
	public static function getSkewXRadians(m:Matrix):Number
	{
		return Math.atan2(-m.c, m.d);
	}



    /**
     * Changes the horizontal skew in a matrix.
     *
     * @param m A Matrix instance to be modified.
     *
     * @param skewX The new horizontal skew, in radians.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix       
     */
	public static function setSkewXRadians(m:Matrix, skewX:Number):void
	{
		var scaleY:Number = getScaleY(m);
		m.c = -scaleY * Math.sin(skewX);
		m.d =  scaleY * Math.cos(skewX);
	}



    /**
     * Calculates the angle of vertical skew present in a matrix, in radians.
     *
     * @param m A Matrix instance.
     *
     * @return The angle of vertical skew, in radians.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix       
     */
	public static function getSkewYRadians(m:Matrix):Number
	{
		return Math.atan2(m.b, m.a);
	} 



    /**
     * Changes the vertical skew in a matrix.
     *
     * @param m A Matrix instance to be modified.
     *
     * @param skewY The new vertical skew, in radians.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix           
     */
	public static function setSkewYRadians(m:Matrix, skewY:Number):void
	{
		var scaleX:Number = getScaleX(m);
		m.a = scaleX * Math.cos(skewY);
		m.b = scaleX * Math.sin(skewY);
	}



    /**
     * Calculates the angle of horizontal skew present in a matrix, in degrees.
     *
     * @param m A Matrix instance.
     *
     * @return The angle of horizontal skew, in degrees.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix           
     */
	public static function getSkewX(m:Matrix):Number
	{
		return Math.atan2(-m.c, m.d) * (180/Math.PI);
	}



    /**
     * Changes the horizontal skew in a matrix.
     *
     * @param m A Matrix instance to be modified.
     *
     * @param skewX The new horizontal skew, in degrees.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix           
     */
   	public static function setSkewX(m:Matrix, skewX:Number):void
	{
		setSkewXRadians(m, skewX*(Math.PI/180));
	}



    /**
     * Calculates the angle of vertical skew present in a matrix, in degrees.
     *
     * @param m A Matrix instance.
     *
     * @return The angle of vertical skew, in degrees.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix           
     */
	public static function getSkewY(m:Matrix):Number
	{
		return Math.atan2(m.b, m.a) * (180/Math.PI);
	}



    /**
     * Changes the vertical skew in a matrix.
     *
     * @param m A Matrix instance to be modified.
     *
     * @param skewX The new vertical skew, in degrees.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix           
     */
	public static function setSkewY(m:Matrix, skewY:Number):void
	{
		setSkewYRadians(m, skewY*(Math.PI/180));
	}	



    /**
     * Calculates the angle of rotation present in a matrix, in radians.
     * If the horizontal and vertical skews are not equal, 
     * the vertical skew value is used.
     *
     * @param m A Matrix instance.
     *
     * @return The angle of rotation, in radians.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix           
     */
   	public static function getRotationRadians(m:Matrix):Number
	{
		return getSkewYRadians(m);
	}


    /**
     * Changes the angle of rotation in a matrix.
     * If the horizontal and vertical skews are not equal,
     * the vertical skew is set to the rotation value
     * and the horizontal skew is increased by the difference between the 
     * old rotation and the new rotation.
     * This matches the rotation behavior in Flash Player.
     *
     * @param m A Matrix instance.
     *
     * @param rotation The angle of rotation, in radians.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix           
     */
	public static function setRotationRadians(m:Matrix, rotation:Number):void
	{
		var oldRotation:Number = getRotationRadians(m);
		var oldSkewX:Number = getSkewXRadians(m);
		setSkewXRadians(m, oldSkewX + rotation-oldRotation);
		setSkewYRadians(m, rotation);		
	}



    /**
     * Calculates the angle of rotation present in a matrix, in degrees.
     * If the horizontal and vertical skews are not equal, 
     * the vertical skew value is used.
     * This matches the rotation behavior in Flash Player.
     *
     * @param m A Matrix instance.
     *
     * @return The angle of rotation, in degrees.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix         
     */
	public static function getRotation(m:Matrix):Number
	{
		return getRotationRadians(m)*(180/Math.PI);
	}



    /**
     * Changes the angle of rotation in a matrix.
     * If the horizontal and vertical skews are not equal,
     * the vertical skew is set to the rotation value
     * and the horizontal skew is increased by the difference between the 
     * old rotation and the new rotation.
     * This matches the rotation behavior in Flash Player.
     *
     * @param m A Matrix instance.
     *
     * @param rotation The angle of rotation, in degrees.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix         
     */
	public static function setRotation(m:Matrix, rotation:Number):void
	{
		setRotationRadians(m, rotation*(Math.PI/180));
	}



    /**
     * Rotates a matrix about a point defined inside the matrix's transformation space.
     * This can be used to rotate a movie clip around a transformation point inside itself. 
     *
     * @param m A Matrix instance.
     *
     * @param x The x coordinate of the point.
     *
     * @param y The y coordinate of the point.
     *
     * @param angleDegrees The angle of rotation in degrees.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix         
     */
	public static function rotateAroundInternalPoint(m:Matrix, x:Number, y:Number, angleDegrees:Number):void
	{
		var point:Point = new Point(x, y);
		point = m.transformPoint(point);
		m.tx -= point.x;
		m.ty -= point.y;
		m.rotate(angleDegrees*(Math.PI/180));
		m.tx += point.x;
		m.ty += point.y;
	}



    /**
     * Rotates a matrix about a point defined outside the matrix's transformation space.
     * This can be used to rotate a movie clip around a transformation point in its parent. 
     *
     * @param m A Matrix instance.
     *
     * @param x The x coordinate of the point.
     *
     * @param y The y coordinate of the point.
     *
     * @param angleDegrees The angle of rotation in degrees.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix       
     */
	public static function rotateAroundExternalPoint(m:Matrix, x:Number, y:Number, angleDegrees:Number):void
	{
		m.tx -= x;
		m.ty -= y;
		m.rotate(angleDegrees*(Math.PI/180));
		m.tx += x;
		m.ty += y;
	}


    /**
     * Moves a matrix as necessary to align an internal point with an external point.
     * This can be used to match a point in a transformed movie clip with one in its parent.
     *
     * @param m A Matrix instance.
     *
     * @param internalPoint A Point instance defining a position within the matrix's transformation space.
     *
     * @param externalPoint A Point instance defining a reference position outside the matrix's transformation space.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Matrix, Copy Motion as ActionScript    
     * @see flash.geom.Matrix       
     */	
    public static function matchInternalPointWithExternal(m:Matrix, internalPoint:Point, externalPoint:Point):void
	{
		var internalPointTransformed:Point = m.transformPoint(internalPoint);
		var dx:Number = externalPoint.x - internalPointTransformed.x;
		var dy:Number = externalPoint.y - internalPointTransformed.y;	
		m.tx += dx;
		m.ty += dy;
	}
}
}