// ActionScript file
package fl.motion
{

    /**
     * The DynamicMatrix class calculates and stores a matrix based on given values. 
     * This class supports the ColorMatrixFilter and can be extended by the ColorMatrix class.
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @see fl.motion.ColorMatrix
     * @see flash.filters.ColorMatrixFilter 
     */
	public class DynamicMatrix {
		
		
    /**
     * Specifies that a matrix is prepended for concatenation. 
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public static const MATRIX_ORDER_PREPEND:int = 0;
		
		
    /**
     * Specifies that a matrix is appended for concatenation. 
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public static const MATRIX_ORDER_APPEND:int = 1;

     /**
     * @private
     */
		protected var m_width:int;
     /**
     * @private
     */
		protected var m_height:int;
     /**
     * @private
     */
		protected var m_matrix:Array;
		
		
    /**
     * Constructs a matrix with the given number of rows and columns. 
     * @param width Number of columns.
     * @param height Number of rows.
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public function DynamicMatrix(width:int, height:int)
		{
			Create(width, height);
		}


		/**
		* @private
		*/
		protected function Create(width:int, height:int):void
		{
			if(width > 0 && height > 0) 
			{
				m_width = width;
				m_height = height;
				
				m_matrix = new Array(height);
				for(var i:int = 0; i < height; i++)
				{
					m_matrix[i] = new Array(width);
					for(var j:int = 0; j < height; j++)
					{
						m_matrix[i][j] = 0;
					}
				}
			}
		}
		
		
		/**
		* @private
		*/
		protected function Destroy():void
		{
			m_matrix = null;
		}
		
		
    /**
     * Returns the number of columns in the current matrix. 
     * @return The number of columns.
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @see #GetHeight
    */
		public function GetWidth():Number 
		{
			return m_width;
		}
	    
	    
    /**
     * Returns the number of rows in the current matrix. 
     * @return The number of rows.
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public function GetHeight():Number
		{
			return m_height;
		}
		
		
    /**
     * Returns the value at the specified zero-based row and column in the current matrix. 
     * @param row The row containing the value you want.
     * @param col The column containing the value you want.
     * @return Number The value at the specified row and column location.
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public function GetValue(row:int, col:int):Number
		{
			var value:Number = 0;
			if(row >= 0 && row < m_height && col >= 0 && col <= m_width)
			{
				value = m_matrix[row][col];
			}
			
			return value;
		}


    /**
     * Sets the value at a specified zero-based row and column in the current matrix. 
     * @param row The row containing the value you want to set.
     * @param col The column containing the value you want to set.
     * @param value The number to insert into the matrix.
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public function SetValue(row:int, col:int, value:Number):void
		{
			if(row >= 0 && row < m_height && col >= 0 && col <= m_width)
			{
				m_matrix[row][col] = value;
			}
		}


    /**
     * Sets the current matrix to an identity matrix. 
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @see flash.geom.Matrix#identity()
    */
		public function LoadIdentity():void
		{
			if(m_matrix) 
			{
				for(var i:int = 0; i < m_height; i++)
				{
					for(var j:int = 0; j < m_width; j++)
					{
						if(i == j) {
							m_matrix[i][j] = 1;
						}
						else {
							m_matrix[i][j] = 0;
						}
					}
				}
			}
		}


    /**
     * Sets all values in the current matrix to zero. 
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public function LoadZeros():void
		{
			if(m_matrix)
			{
				for(var i:int = 0; i < m_height; i++)
				{
					for(var j:int = 0; j < m_width; j++)
					{
						m_matrix[i][j] = 0;
					}
				}
			}
		}


    /**
     * Multiplies the current matrix with a specified matrix; and either
     * appends or prepends the specified matrix. Use the
     * second parameter of the <code>DynamicMatrix.Multiply()</code> method to 
     * append or prepend the specified matrix.
     * @param inMatrix The matrix to add to the current matrix.
     * @param order Specifies whether to append or prepend the matrix from the
     * <code>inMatrix</code> parameter; either <code>MATRIX_ORDER_APPEND</code>
     * or <code>MATRIX_ORDER_PREPEND</code>.
     * @return  A Boolean value indicating whether the multiplication succeeded (<code>true</code>) or 
     * failed (<code>false</code>). The value is <code>false</code> if either the current matrix or
     * specified matrix (the <code>inMatrix</code> parameter) is null, or if the order is to append and the
     * current matrix's width is not the same as the supplied matrix's height; or if the order is to prepend
     * and the current matrix's height is not equal to the supplied matrix's width.
	 *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @see #MATRIX_ORDER_PREPEND
     * @see #MATRIX_ORDER_APPEND
    */
		public function Multiply(inMatrix:DynamicMatrix, order:int = MATRIX_ORDER_PREPEND):Boolean
		{
			if(!m_matrix || !inMatrix)
				return false;
				
			var inHeight:int = inMatrix.GetHeight();
			var inWidth:int = inMatrix.GetWidth();
			
			if(order == MATRIX_ORDER_APPEND)
			{
				//inMatrix on the left
				if(m_width != inHeight)
					return false;
					
				var result:DynamicMatrix = new DynamicMatrix(inWidth, m_height);
				for(var i:int = 0; i < m_height; i++)
				{
					for(var j:int = 0; j < inWidth; j++)
					{
						var total:Number = 0;
						for(var k:int = 0, m:int = 0; k < Math.max(m_height, inHeight) && m < Math.max(m_width, inWidth); k++, m++)
						{
							total = total + (inMatrix.GetValue(k, j) * m_matrix[i][m]);
						}
						
						result.SetValue(i, j, total);
					}
				}

				// destroy self and recreate with a new dimension
				Destroy();
				Create(inWidth, m_height);
				
				// assign result back to self
				for(i = 0; i < inHeight; i++)
				{
					for(j = 0; j < m_width; j++) 
					{
						m_matrix[i][j] = result.GetValue(i, j);
					}
				}
			}
			
			else {
				// inMatrix on the right
				if(m_height != inWidth)
					return false;
					
				result = new DynamicMatrix(m_width, inHeight);
				for(i = 0; i < inHeight; i++)
				{
					for(j = 0; j < m_width; j++)
					{
						total = 0;
						for(k = 0, m = 0; k < Math.max(inHeight, m_height) && m < Math.max(inWidth, m_width); k++, m++)
						{
							total = total + (m_matrix[k][j] * inMatrix.GetValue(i, m));
						}
						result.SetValue(i, j, total);
					}
				}
				
				// destroy self and recreate with a new dimension
				Destroy();
				Create(m_width, inHeight);
				
				// assign result back to self
				for(i = 0; i < inHeight; i++)
				{
					for(j = 0; j < m_width; j++)
					{
						m_matrix[i][j] = result.GetValue(i, j);
					}
				}
			}
			
			return true;
		}
		
		
		
		// Multiply matrix with a value
    /**
     * Multiplies a number with each item in the matrix and stores the results in
     * the current matrix.
     * @param value A number to multiply by each item in the matrix.
     * @return A Boolean value indicating whether the multiplication succeeded (<code>true</code>)
     * or failed (<code>false</code>).
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public function MultiplyNumber(value:Number):Boolean
		{
			if(!m_matrix)
				return false;
			
			for(var i:int = 0; i < m_height; i++)
			{
				for(var j:int = 0; j < m_width; j++)
				{
					var total:Number = 0;
					total = m_matrix[i][j] * value;
					m_matrix[i][j] = total;
				}
			}
			
			return true;
		}



		// Add two matrices
    /**
     * Adds the current matrix with a specified matrix. The 
     * current matrix becomes the result of the addition (in other
     * words the <code>DynamicMatrix.Add()</code> method does
     * not create a new matrix to contain the result).
     * @param inMatrix The matrix to add to the current matrix.
     * @return A Boolean value indicating whether the addition succeeded (<code>true</code>)
     * or failed (<code>false</code>). If the dimensions of the matrices are not
     * the same, <code>DynamicMatrix.Add()</code> returns <code>false</code>.
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     */
		public function Add(inMatrix:DynamicMatrix):Boolean
		{
			if(!m_matrix || !inMatrix)
				return false;
			
			var inHeight:int = inMatrix.GetHeight();
			var inWidth:int = inMatrix.GetWidth();
			
			if(m_width != inWidth || m_height != inHeight)
				return false;
				
			for(var i:int = 0; i < m_height; i++)
			{
				for(var j:int = 0; j < m_width; j++)
				{
					var total:Number = 0;
					total = m_matrix[i][j] + inMatrix.GetValue(i, j);
					m_matrix[i][j] = total;
				}
			}
			
			return true;
		}
	}
}