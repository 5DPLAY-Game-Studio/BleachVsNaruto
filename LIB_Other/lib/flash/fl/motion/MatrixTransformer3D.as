package fl.motion
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Vector3D;
	import flash.geom.Matrix3D;
	
    /**
     * @private helper functions for supporting 3D motion in the tool. Users should use Flash Player APIs in flash.geom
     */	
	public class MatrixTransformer3D
	{
		public static const AXIS_X:int = 0;
		public static const AXIS_Y:int = 1;
		public static const AXIS_Z:int = 2;

		public static function rotateAboutAxis(radians:Number, axis:int):Matrix3D
		{
			var cosa:Number = Math.cos(radians);
			var sina:Number = Math.sin(radians);
			
			var vec3D:Vector.<Number> = new Vector.<Number>();
			
			switch(axis)
			{
				case AXIS_X:
				{
					vec3D[0] = 1; vec3D[1] = 0; vec3D[2] = 0; vec3D[3] = 0;
					vec3D[4] = 0; vec3D[5] = cosa; vec3D[6] = sina; vec3D[7] = 0;
					vec3D[8] = 0; vec3D[9] = -sina; vec3D[10] = cosa; vec3D[11] = 0;
					vec3D[12] = 0; vec3D[13] = 0; vec3D[14] = 0; vec3D[15] = 1;
					break;
				}
				case AXIS_Y:
				{
					vec3D[0] = cosa; vec3D[1] = 0; vec3D[2] = -sina; vec3D[3] = 0;
					vec3D[4] = 0; vec3D[5] = 1; vec3D[6] = 0; vec3D[7] = 0;
					vec3D[8] = sina; vec3D[9] = 0; vec3D[10] = cosa; vec3D[11] = 0;
					vec3D[12] = 0; vec3D[13] = 0; vec3D[14] = 0; vec3D[15] = 1;
					break;
				}
				case AXIS_Z:
				{
					vec3D[0] = cosa; vec3D[1] = sina; vec3D[2] = 0; vec3D[3] = 0;
					vec3D[4] = -sina; vec3D[5] = cosa; vec3D[6] = 0; vec3D[7] = 0;
					vec3D[8] = 0; vec3D[9] = 0; vec3D[10] = 1; vec3D[11] = 0;
					vec3D[12] = 0; vec3D[13] = 0; vec3D[14] = 0; vec3D[15] = 1;
					break;
				}
			}
			
			return new Matrix3D(vec3D);
		}
		
		public static function getVector(mat:Matrix3D, index:int):Vector3D
		{
			switch(index)
			{
				case 0:
				{
					return new Vector3D(mat.rawData[0], mat.rawData[1], mat.rawData[2], mat.rawData[3]);
				}
				case 1:
				{
					return new Vector3D(mat.rawData[4], mat.rawData[5], mat.rawData[6], mat.rawData[7]);
				}
				case 2:
				{
					return new Vector3D(mat.rawData[8], mat.rawData[9], mat.rawData[10], mat.rawData[11]);
				}
				case 3:
				{
					return new Vector3D(mat.rawData[12], mat.rawData[13], mat.rawData[14], mat.rawData[15]);
				}
			}
			
			return new Vector3D(0,0,0,0);
		}
		
		public static function getMatrix3D(vec0:Vector3D, vec1:Vector3D, vec2:Vector3D, vec3:Vector3D):Matrix3D
		{
			var vec3D:Vector.<Number> = new Vector.<Number>();
			vec3D[0] = vec0.x;
			vec3D[1] = vec0.y;
			vec3D[2] = vec0.z;
			vec3D[3] = vec0.w;
			vec3D[4] = vec1.x;
			vec3D[5] = vec1.y;
			vec3D[6] = vec1.z;
			vec3D[7] = vec1.w;
			vec3D[8] = vec2.x;
			vec3D[9] = vec2.y;
			vec3D[10] = vec2.z;
			vec3D[11] = vec2.w;
			vec3D[12] = vec3.x;
			vec3D[13] = vec3.y;
			vec3D[14] = vec3.z;
			vec3D[15] = vec3.w;
			return new Matrix3D(vec3D);
		}
	
		public static function rotateAxis(mat:Matrix3D, radians:Number, axis:int):Matrix3D
		{
			var tempMat:Matrix3D = new Matrix3D();
			var axisVec3D:Vector3D = getVector(mat, axis);
			
			tempMat.prependRotation(radians*180/Math.PI, axisVec3D);
			
			for(var i:int = 0; i < 3; i++)
			{
				if(i != axis)
				{
					var vecI:Vector3D = getVector(mat, i);
					var n:Array = new Array(3);
					for(var j:int = 0; j < 3; j++)
					{
						var vecJ:Vector3D = getVector(tempMat, j);
						n[j] = vecI.dotProduct(vecJ);
					}
					
					vecI.x = n[0];
					vecI.y = n[1];
					vecI.z = n[2];
					vecI.w = 0;
					vecI = normalizeVector(vecI);
					
					var vec3D:Vector.<Number> = Vector.<Number>(getRawDataVector(mat));
					vec3D[(i*4)] = vecI.x;
					vec3D[(i*4)+1] = vecI.y;
					vec3D[(i*4)+2] = vecI.z;
					vec3D[(i*4)+3] = vecI.w;
					
					mat = new Matrix3D(Vector.<Number>(vec3D));
				}
			}
			
			return mat;
		}
		
		public static function normalizeVector(vec:Vector3D):Vector3D
		{
			var factor:Number = 1/vec.length;
			var newVec:Vector3D = new Vector3D();
			newVec.x = vec.x * factor;
			newVec.y = vec.y * factor;
			newVec.z = vec.z * factor;
			newVec.w = vec.w;
			
			return newVec;
		}
		
		public static function getRawDataVector(mat:Matrix3D):Vector.<Number>
		{
			var vec3D:Vector.<Number> = new Vector.<Number>();
			vec3D[0] = mat.rawData[0]; vec3D[1] = mat.rawData[1]; vec3D[2] = mat.rawData[2]; vec3D[3] = mat.rawData[3];
			vec3D[4] = mat.rawData[4]; vec3D[5] = mat.rawData[5]; vec3D[6] = mat.rawData[6]; vec3D[7] = mat.rawData[7];
			vec3D[8] = mat.rawData[8]; vec3D[9] = mat.rawData[9]; vec3D[10] = mat.rawData[10]; vec3D[11] = mat.rawData[11];
			vec3D[12] = mat.rawData[12]; vec3D[13] = mat.rawData[13]; vec3D[14] = mat.rawData[14]; vec3D[15] = mat.rawData[15];
			
			return vec3D;
		}
	}
}