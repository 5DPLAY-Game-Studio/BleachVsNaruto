package fl.motion
{

/**
 * The AdjustColor class defines various color properties, such as brightness, contrast, hue, and saturation, to support the ColorMatrixFilter class. 
 * You can apply the AdjustColor filter to any display object, 
 * and also generate a flat array representing all four color properties to use with the ColorMatrixFilter class.
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @keyword AdjustColor
 * @see flash.filters.ColorMatrixFilter
 */
	public class AdjustColor
	{
		// table of number of Deltas for a specific contrast setting
		private static var s_arrayOfDeltaIndex:Array = [
//      0     1     2     3     4     5     6     7     8     9                                        
/*0*/   0,    0.01, 0.02, 0.04, 0.05, 0.06, 0.07, 0.08, 0.1,  0.11,
/*1*/   0.12, 0.14, 0.15, 0.16, 0.17, 0.18, 0.20, 0.21, 0.22, 0.24,
/*2*/   0.25, 0.27, 0.28, 0.30, 0.32, 0.34, 0.36, 0.38, 0.40, 0.42,
/*3*/   0.44, 0.46, 0.48, 0.5,  0.53, 0.56, 0.59, 0.62, 0.65, 0.68, 
/*4*/   0.71, 0.74, 0.77, 0.80, 0.83, 0.86, 0.89, 0.92, 0.95, 0.98,
/*5*/   1.0,  1.06, 1.12, 1.18, 1.24, 1.30, 1.36, 1.42, 1.48, 1.54,
/*6*/   1.60, 1.66, 1.72, 1.78, 1.84, 1.90, 1.96, 2.0,  2.12, 2.25, 
/*7*/   2.37, 2.50, 2.62, 2.75, 2.87, 3.0,  3.2,  3.4,  3.6,  3.8,
/*8*/   4.0,  4.3,  4.7,  4.9,  5.0,  5.5,  6.0,  6.5,  6.8,  7.0,
/*9*/   7.3,  7.5,  7.8,  8.0,  8.4,  8.7,  9.0,  9.4,  9.6,  9.8, 
/*10*/  10.0  ];

		private var m_brightnessMatrix:ColorMatrix;
		private var m_contrastMatrix:ColorMatrix;
		private var m_saturationMatrix:ColorMatrix;
		private var m_hueMatrix:ColorMatrix;
		private var m_finalMatrix:ColorMatrix;
		
	
    /**
     * The AdjustColor class defines various color properties to support the ColorMatrixFilter.
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @see flash.filters.ColorMatrixFilter
     */
		public function AdjustColor()
		{
		}
		
		
		
	    /**
	     * Sets the brightness of the AdjustColor filter. The range of valid values is <code>-100</code> to <code>100</code>.
	     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public function set brightness(value:Number):void
		{
			if(m_brightnessMatrix == null)
			{
				m_brightnessMatrix = new ColorMatrix();
			}
			
			if(value != 0)
			{
				// brightness does not need to be denormalized
				m_brightnessMatrix.SetBrightnessMatrix(value);
			}
		}
		
		
	    /**
	     * Sets the contrast of the AdjustColor filter. The range of valid values is <code>-100</code> to <code>100</code>.
	     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public function set contrast(value:Number):void
		{	
			// denormalized contrast value
			var deNormVal:Number = value;
			if(value == 0) {
				deNormVal = 127;
			}
			else if(value > 0) {
				deNormVal = s_arrayOfDeltaIndex[int(value)] * 127 + 127;
			}
			else {
				deNormVal = (value / 100 * 127) + 127;
			}
		
			if(m_contrastMatrix == null)
			{
				m_contrastMatrix = new ColorMatrix();
			}
			m_contrastMatrix.SetContrastMatrix(deNormVal);
		}
		
		
	    /**
	     * Sets the saturation of the AdjustColor filter. The range of valid values is <code>-100</code> to <code>100</code>.
	     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public function set saturation(value:Number):void
		{
			// denormalized saturation value
			var deNormVal:Number = value;
			if (value == 0) {
				deNormVal = 1;
			} else if (value > 0) {
				deNormVal = 1.0 + (3 * value / 100); // max value is 4
			} else {
				deNormVal = value / 100 + 1;
			}
		
			if(m_saturationMatrix == null)
			{
				m_saturationMatrix = new ColorMatrix();
			}
			m_saturationMatrix.SetSaturationMatrix(deNormVal);
		}
		
		
	    /**
	     * Sets the hue of the AdjustColor filter. The range of valid values is <code>-180</code> to <code>180</code>.
	     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public function set hue(value:Number):void
		{
			// hue value does not need to be denormalized
			if(m_hueMatrix == null)
			{
				m_hueMatrix = new ColorMatrix();
			}

			if(value != 0)
			{		
				// Convert to radian
				m_hueMatrix.SetHueMatrix(value * Math.PI / 180.0);
			}
		}
		
		
	    /**
	     * Verifies if all four AdjustColor properties are set. 
	     * @return A Boolean value that is <code>true</code> if all four AdjustColor properties have been set, <code>false</code> otherwise.
	     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public function AllValuesAreSet():Boolean
		{
			return (m_brightnessMatrix && m_contrastMatrix && m_saturationMatrix && m_hueMatrix);
		}


	    /**
	     * Returns the flat array of values for all four properties.
	     * @return An array of 20 numerical values representing all four AdjustColor properties
	     * to use with the <code>flash.filters.ColorMatrixFilter</code> class.
	     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @see flash.filters.ColorMatrixFilter
     	    */
		public function CalculateFinalFlatArray():Array
		{
			if(CalculateFinalMatrix())
			{
				return m_finalMatrix.GetFlatArray();
			}
			
			return null;
		}
		
		private function CalculateFinalMatrix():Boolean
		{
			if(!AllValuesAreSet()) 
				return false;
			
			m_finalMatrix = new ColorMatrix();
			m_finalMatrix.Multiply(m_brightnessMatrix);
			m_finalMatrix.Multiply(m_contrastMatrix);
			m_finalMatrix.Multiply(m_saturationMatrix);
			m_finalMatrix.Multiply(m_hueMatrix);
			
			return true;
		}
	}
}