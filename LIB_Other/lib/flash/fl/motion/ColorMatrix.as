package fl.motion
{

    /**
     * The ColorMatrix class calculates and stores color matrixes based on given values. 
     * This class extends the DynamicMatrix class and also supports the ColorMatrixFilter class.
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @see fl.motion.DynamicMatrix
     * @see flash.filters.ColorMatrixFilter 
     */
	public class ColorMatrix extends DynamicMatrix
	{
		// Luminance values
		
		
		/**
		* @private
		*/
		protected static const LUMINANCER:Number = 0.3086;
		
		/**
		* @private
		*/
		protected static const LUMINANCEG:Number = 0.6094;
		
		/**
		* @private
		*/
		protected static const LUMINANCEB:Number = 0.0820;
		
		
		
    /**
     * Calculates and stores color matrixes based on given values.
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @see DynamicMatrix 
     */
		public function ColorMatrix()
		{
			super(5, 5);
			LoadIdentity();
		}
		
		
		
	    /**
	     * Calculates and stores a brightness matrix based on the given value.
	     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @param value 0-255
     	    */
		public function SetBrightnessMatrix(value:Number):void
		{
			if (!m_matrix)
				return;
		
			m_matrix[0][4] = value;
			m_matrix[1][4] = value;
			m_matrix[2][4] = value;
		}
		
		
	    /**
	     * Calculates and stores a contrast matrix based on the given value.
	     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @param value 0-255
     	    */
		public function SetContrastMatrix(value:Number):void
		{
			if(!m_matrix)
				return;
				
			var brightness:Number = 0.5 * (127.0 - value);
			value = value / 127.0;
			
			m_matrix[0][0] = value;
			m_matrix[1][1] = value;
			m_matrix[2][2] = value;
		
			m_matrix[0][4] = brightness;
			m_matrix[1][4] = brightness;
			m_matrix[2][4] = brightness;
		}


	    /**
	     * Calculates and stores a saturation matrix based on the given value.
	     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @param value 0-255
     	    */
		public function SetSaturationMatrix(value:Number):void
		{
			if(!m_matrix)
				return;
				
			var subVal:Number = 1.0 - value;
			
			var mulVal:Number = subVal * LUMINANCER;
			m_matrix[0][0] = mulVal + value;
			m_matrix[1][0] = mulVal;
			m_matrix[2][0] = mulVal;

			mulVal = subVal * LUMINANCEG;
			m_matrix[0][1] = mulVal;
			m_matrix[1][1] = mulVal + value;
			m_matrix[2][1] = mulVal;

			mulVal = subVal * LUMINANCEB;
			m_matrix[0][2] = mulVal;
			m_matrix[1][2] = mulVal;
			m_matrix[2][2] = mulVal + value;
		}		

		// SVG implementation of Hue Rotation
		// See http://www.w3.org/TR/SVG/filters.html#feColorMatrix
		/*
		W3C® SOFTWARE NOTICE AND LICENSE
		http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231
		
		This work (and included software, documentation such as READMEs, or other related items) is being provided by the copyright holders under the following license. By obtaining, using and/or copying this work, you (the licensee) agree that you have read, understood, and will comply with the following terms and conditions.
		
		Permission to copy, modify, and distribute this software and its documentation, with or without modification, for any purpose and without fee or royalty is hereby granted, provided that you include the following on ALL copies of the software and documentation or portions thereof, including modifications:
		
		   1. The full text of this NOTICE in a location viewable to users of the redistributed or derivative work.
		   2. Any pre-existing intellectual property disclaimers, notices, or terms and conditions. If none exist, the W3C Software Short Notice should be included (hypertext is preferred, text is permitted) within the body of any redistributed or derivative code.
		   3. Notice of any changes or modifications to the files, including the date changes were made. (We recommend you provide URIs to the location from which the code is derived.)
		
		THIS SOFTWARE AND DOCUMENTATION IS PROVIDED "AS IS," AND COPYRIGHT HOLDERS MAKE NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO, WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE SOFTWARE OR DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
		
		COPYRIGHT HOLDERS WILL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF ANY USE OF THE SOFTWARE OR DOCUMENTATION.
		
		The name and trademarks of copyright holders may NOT be used in advertising or publicity pertaining to the software without specific, written prior permission. Title to copyright in this software and any associated documentation will at all times remain with copyright holders.
		*/
		
	    /**
	     * Calculates and stores a hue matrix based on the given value.
	     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @param value 0-255
     	    */
		public function SetHueMatrix(angle:Number):void
		{
			if(!m_matrix)
				return;
				
			LoadIdentity();
			
			var baseMat:DynamicMatrix = new DynamicMatrix(3, 3);
			var cosBaseMat:DynamicMatrix = new DynamicMatrix(3, 3);
			var sinBaseMat:DynamicMatrix = new DynamicMatrix(3, 3);
			
			var cosValue:Number = Math.cos(angle);
			var sinValue:Number = Math.sin(angle);
			
			// slightly smaller luminance values from SVG
			var lumR:Number = 0.213;
			var lumG:Number = 0.715;
			var lumB:Number = 0.072;
					
			baseMat.SetValue(0, 0, lumR);
			baseMat.SetValue(1, 0, lumR);
			baseMat.SetValue(2, 0, lumR);
		
			baseMat.SetValue(0, 1, lumG);
			baseMat.SetValue(1, 1, lumG);
			baseMat.SetValue(2, 1, lumG);
		
			baseMat.SetValue(0, 2, lumB);
			baseMat.SetValue(1, 2, lumB);
			baseMat.SetValue(2, 2, lumB);
		
			cosBaseMat.SetValue(0, 0, (1 - lumR));
			cosBaseMat.SetValue(1, 0, -lumR);
			cosBaseMat.SetValue(2, 0, -lumR);
		
			cosBaseMat.SetValue(0, 1, -lumG);
			cosBaseMat.SetValue(1, 1, (1 - lumG));
			cosBaseMat.SetValue(2, 1, -lumG);
		
			cosBaseMat.SetValue(0, 2, -lumB);
			cosBaseMat.SetValue(1, 2, -lumB);
			cosBaseMat.SetValue(2, 2, (1 - lumB));
		
			cosBaseMat.MultiplyNumber(cosValue);
		
			sinBaseMat.SetValue(0, 0, -lumR);
			sinBaseMat.SetValue(1, 0, 0.143);			// not sure how this value is computed
			sinBaseMat.SetValue(2, 0, -(1 - lumR));
		
			sinBaseMat.SetValue(0, 1, -lumG);
			sinBaseMat.SetValue(1, 1, 0.140);			// not sure how this value is computed
			sinBaseMat.SetValue(2, 1, lumG);
		
			sinBaseMat.SetValue(0, 2, (1 - lumB));
			sinBaseMat.SetValue(1, 2, -0.283);			// not sure how this value is computed
			sinBaseMat.SetValue(2, 2, lumB);
		
			sinBaseMat.MultiplyNumber(sinValue);
			
			baseMat.Add(cosBaseMat);
			baseMat.Add(sinBaseMat);
			
			for(var i:int = 0; i < 3; i++)
			{
				for(var j:int = 0; j < 3; j++)
				{
					m_matrix[i][j] = baseMat.GetValue(i, j);
				}
			}
		}


	    /**
	     * Calculates and returns a flat array of 20 numerical values representing the four matrixes set in this object.
	     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @return An array of 20 items.
     	    */
		public function GetFlatArray():Array
		{
			if(!m_matrix)
				return null;
				
			var ptr:Array = new Array();
			var index:int = 0;
			for(var i:int = 0; i < 4; i++)
			{
				for(var j:int = 0; j < 5; j++)
				{
					ptr[index] = m_matrix[i][j];
					index++;
				}
			}
			
			return ptr;
		}
	}
}

class XFormData {
	public var ox:Number;
	public var oy:Number;
	public var oz:Number;
}