// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.motion
{
import flash.geom.Point;

/**
 * A Bezier segment consists of four Point objects that define a single cubic Bezier curve.
 * The BezierSegment class also contains methods to find coordinate values along the curve.
 * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword BezierSegment, Copy Motion as ActionScript
 * @see ../../motionXSD.html Motion XML Elements  
 */
public class BezierSegment
{
    /**
     * The first point of the Bezier curve.
     * It is a node, which means it falls directly on the curve.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript     
     */
    public var a:Point;


    /**
     * The second point of the Bezier curve. 
     * It is a control point, which means the curve moves toward it,
     * but usually does not pass through it.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript          
     */
    public var b:Point;


    /**
     * The third point of the Bezier curve. 
     * It is a control point, which means the curve moves toward it,
     * but usually does not pass through it.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript          
     */
    public var c:Point;


    /**
     * The fourth point of the Bezier curve.
     * It is a node, which means it falls directly on the curve.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript          
     */
	public var d:Point;


    /**
     * Constructor for BezierSegment instances.
     *
     * @param a The first point of the curve, a node.
     *
     * @param b The second point of the curve, a control point.
     *
     * @param c The third point of the curve, a control point.
     *
     * @param d The fourth point of the curve, a node.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript   
     * @see #propertyDetail property details
     */
	function BezierSegment(a:Point, b:Point, c:Point, d:Point)
	{
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
	}

	
    /**
     * Calculates the location of a two-dimensional cubic Bezier curve at a specific time.
     *
     * @param t The <code>time</code> or degree of progress along the curve, as a decimal value between <code>0</code> and <code>1</code>.
     * <p><strong>Note:</strong> The <code>t</code> parameter does not necessarily move along the curve at a uniform speed. For example, a <code>t</code> value of <code>0.5</code> does not always produce a value halfway along the curve.</p>
     *
     * @return A point object containing the x and y coordinates of the Bezier curve at the specified time. 
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript        
     */
	public function getValue(t:Number):Point
	{
		var ax:Number = this.a.x;
		var x:Number = (t*t*(this.d.x-ax) + 3*(1-t)*(t*(this.c.x-ax) + (1-t)*(this.b.x-ax)))*t + ax;
		var ay:Number = this.a.y;
		var y:Number = (t*t*(this.d.y-ay) + 3*(1-t)*(t*(this.c.y-ay) + (1-t)*(this.b.y-ay)))*t + ay;
		return new Point(x, y);	
	}	
	
	
    /**
     * Calculates the value of a one-dimensional cubic Bezier equation at a specific time.
     * By contrast, a Bezier curve is usually two-dimensional 
     * and uses two of these equations, one for the x coordinate and one for the y coordinate.
     *
     * @param t The <code>time</code> or degree of progress along the curve, as a decimal value between <code>0</code> and <code>1</code>.
     * <p><strong>Note:</strong> The <code>t</code> parameter does not necessarily move along the curve at a uniform speed. For example, a <code>t</code> value of <code>0.5</code> does not always produce a value halfway along the curve.</p>
     *
     * @param a The first value of the Bezier equation.
     *
     * @param b The second value of the Bezier equation.
     *
     * @param c The third value of the Bezier equation.
     *
     * @param d The fourth value of the Bezier equation.
     *
     * @return The value of the Bezier equation at the specified time. 
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript        
     */
	public static function getSingleValue(t:Number, a:Number=0, b:Number=0, c:Number=0, d:Number=0):Number
	{
		return (t*t*(d-a) + 3*(1-t)*(t*(c-a) + (1-t)*(b-a)))*t + a;
	}	
	

    /**
     * Finds the <code>y</code> value of a cubic Bezier curve at a given x coordinate.
     * Some Bezier curves overlap themselves horizontally, 
     * resulting in more than one <code>y</code> value for a given <code>x</code> value.
     * In that case, this method will return whichever value is most logical.
     * 
     * Used by CustomEase and BezierEase interpolation.
     *
     * @param x An x coordinate that lies between the first and last point, inclusive.
     * 
     * @param coefficients An optional array of number values that represent the polynomial
     * coefficients for the Bezier. This array can be used to optimize performance by precalculating 
     * values that are the same everywhere on the curve and do not need to be recalculated for each iteration.
     * 
     * @return The <code>y</code> value of the cubic Bezier curve at the given x coordinate.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Bezier curve, Copy Motion as ActionScript        
     */
	public function getYForX(x:Number, coefficients:Array=null):Number
	{
		// Clamp to range between end points.
		// The padding with the small decimal value is necessary to avoid bugs
		// that result from reaching the limits of decimal precision in calculations.
		// We have tests that demonstrate this.
		if (this.a.x < this.d.x)
		{ 
	 		if (x <= this.a.x+0.0000000000000001) return this.a.y;
	 		if (x >= this.d.x-0.0000000000000001) return this.d.y;
	 	}
	 	else
	 	{
	 		if (x >= this.a.x+0.0000000000000001) return this.a.y;
	 		if (x <= this.d.x-0.0000000000000001) return this.d.y;
	 	}

		if (!coefficients)
		{
			coefficients = getCubicCoefficients(this.a.x, this.b.x, this.c.x, this.d.x);
		}
   		
   		// x(t) = a*t^3 + b*t^2 + c*t + d
 		var roots:Array = getCubicRoots(coefficients[0], coefficients[1], coefficients[2], coefficients[3]-x); 
 		var time:Number = NaN;
  		if (roots.length == 0)
 			time = 0;
 		else if (roots.length == 1)
 			time = roots[0];
  		else  
   		{
   			for each (var root:Number in roots)
   			{
   				if (0 <= root && root <= 1)
   				{
   					time = root;
   					break;
   				}
   			}
   		}
   		
		if (isNaN(time))
			return NaN;
		
   		var y:Number = getSingleValue(time, this.a.y, this.b.y, this.c.y, this.d.y);
   		return y;
	}




    /**
     * Calculates the coefficients for a cubic polynomial equation,
     * given the values of the corresponding cubic Bezier equation.
     *
     * @param a The first value of the Bezier equation.
     *
     * @param b The second value of the Bezier equation.
     *
     * @param c The third value of the Bezier equation.
     *
     * @param d The fourth value of the Bezier equation.
     *
     * @return An array containing four number values,
     * which are the coefficients for a cubic polynomial.
     * The coefficients are ordered from the highest degree to the lowest,
     * so the first number in the array would be multiplied by t^3, the second by t^2, and so on.
     * 
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript        
     * @see #getCubicRoots()
     */
	public static function getCubicCoefficients(a:Number, b:Number, c:Number, d:Number):Array
	{
		return [  -a + 3*b - 3*c + d,
				 3*a - 6*b + 3*c, 
				-3*a + 3*b, 
				   a];
	}	
	

    /**
     * Finds the real solutions, if they exist, to a cubic polynomial equation of the form: at^3 + bt^2 + ct + d.
     * This method is used to evaluate custom easing curves.
     *
     * @param a The first coefficient of the cubic equation, which is multiplied by the cubed variable (t^3).
     *
     * @param b The second coefficient of the cubic equation, which is multiplied by the squared variable (t^2).
     *
     * @param c The third coefficient of the cubic equation, which is multiplied by the linear variable (t).
     *
     * @param d The fourth coefficient of the cubic equation, which is the constant.
     *
     * @return An array of number values, indicating the real roots of the equation. 
     * There may be no roots, or as many as three. 
     * Imaginary or complex roots are ignored.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript             
     */
	public static function getCubicRoots(a:Number=0, b:Number=0, c:Number=0, d:Number=0):Array
	{
		// make sure we really have a cubic
		if (!a) return BezierSegment.getQuadraticRoots(b, c, d);
		
		// normalize the coefficients so the cubed term is 1 and we can ignore it hereafter
		if (a != 1)
		{
			b/=a;
			c/=a;
			d/=a;
		}

		var q:Number = (b*b - 3*c)/9;               // won't change over course of curve
		var qCubed:Number = q*q*q;                  // won't change over course of curve
		var r:Number = (2*b*b*b - 9*b*c + 27*d)/54; // will change because d changes
													// but parts with b and c won't change
		// determine if there are 1 or 3 real roots using r and q
		var diff:Number   = qCubed - r*r;           // will change
		if (diff >= 0)
		{
			// avoid division by zero
			if (!q) return [0];
			// three real roots
			var theta:Number = Math.acos(r/Math.sqrt(qCubed)); // will change because r changes
			var qSqrt:Number = Math.sqrt(q); // won't change

			var root1:Number = -2*qSqrt * Math.cos(theta/3) - b/3;
			var root2:Number = -2*qSqrt * Math.cos((theta + 2*Math.PI)/3) - b/3;
			var root3:Number = -2*qSqrt * Math.cos((theta + 4*Math.PI)/3) - b/3;
			
			return [root1, root2, root3];
		}
		else
		{
			// one real root
			var tmp:Number = Math.pow( Math.sqrt(-diff) + Math.abs(r), 1/3);
			var rSign:int = (r > 0) ?  1 : r < 0  ? -1 : 0;
			var root:Number = -rSign * (tmp + q/tmp) - b/3;
			return [root];
		}
		return [];
	}
	

    /**
     * Finds the real solutions, if they exist, to a quadratic equation of the form: at^2 + bt + c.
     *
     * @param a The first coefficient of the quadratic equation, which is multiplied by the squared variable (t^2).
     *
     * @param b The second coefficient of the quadratic equation, which is multiplied by the linear variable (t).
     *
     * @param c The third coefficient of the quadratic equation, which is the constant.
     *
     * @return An array of number values, indicating the real roots of the equation. 
     * There may be no roots, or as many as two. 
     * Imaginary or complex roots are ignored.
     * @playerversion Flash 9.0.28.0
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript             
     */
	public static function getQuadraticRoots(a:Number, b:Number, c:Number):Array
	{
		var roots:Array = [];
		// make sure we have a quadratic
		if (!a)
		{
			if (!b) return [];
			roots[0] = -c/b;
			return roots;
		}

		var q:Number = b*b - 4*a*c;
		var signQ:int = 
			   (q > 0) ?  1 
			  : q < 0  ? -1
			  : 0;
		
		if (signQ < 0)
		{
			return [];
		}
		else if (!signQ)  
		{
			roots[0] = -b/(2*a);
		}
		else  
		{
			roots[0] = roots[1] = -b/(2*a);
			var tmp:Number = Math.sqrt(q)/(2*a);
			roots[0] -= tmp;
			roots[1] += tmp;
		}
		
		return roots;
	}

	
	
}
}
