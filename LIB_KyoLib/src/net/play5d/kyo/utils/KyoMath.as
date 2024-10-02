package net.play5d.kyo.utils
{
	import flash.geom.Point;
	
	public class KyoMath
	{	
		private static const DEGTORAD:Number = Math.PI / 180;
		/**
		 * 将数字保持在范围之内 
		 */
		public static function fixRange(number:Number , min:Number , max:Number):Number{
			if(number < min) return min;
			if(number > max) return max;
			return number;
		}
		
		/**
		 * 将数字限制在指定范围内 
		 * @param number 原数
		 * @param min 最小值
		 * @param max 最大值
		 */
		public static function inRange(number:Number , min:Number , max:Number):Boolean{
			return number >= min && number <= max;
		}
		
		/**
		 * 保留小数XX位 
		 * @param num 原数字
		 * @param n 小数位数
		 */
		public static function decimal(num:Number,n:int,mathFun:Function = null):Number{
			mathFun ||= Math.round;
			var tn:int = Math.pow(10 , n);
			return mathFun(num * tn) / tn;
		}
		
		/**
		 * 平均值 
		 * @param params 一个数组 或 多个数字
		 */
		public static function average(...params):Number{
			var array:Array = params[0] is Array ? params[0] : params;
			var num:Number = sum(array);
			return num / array.length;
		}
		
		/**
		 * 总和 
		 * @param params 一个数组 或 多个数字
		 */
		public static function sum(...params):Number{
			var array:Array = params[0] is Array ? params[0] : params;
			var num:Number = 0;
			for each(var i:Number in array)num += i;
			return num;
		}
		
		/**
		 * 计算两点间的角度 
		 */
		public static function getAngleByPoints(A:Point , B:Point):int{
			var xx:Number = B.x - A.x;
			var yy:Number = B.y - A.y;
			var hypotenuse:Number = Math.sqrt(xx*xx + yy*yy);
			var radian:Number = Math.acos(xx/hypotenuse);
			var angle:Number = 180/(Math.PI/radian);
			if(yy < 0) return -angle;
			return angle;
		}
		
		/**
		 * 计算两点间的距离 
		 */
		public static function getDistanceByPoints(A:Point , B:Point):Number{
			var xx:Number = A.x - B.x;
			var yy:Number = A.y - B.y;
			return Math.sqrt(xx*xx + yy*yy);
		}
		
		public static function getPointByRadians(point:Point , radious:Number , scale:Number = 1):Point{
			var rp:Point = new Point();
			rp.x = point.x * Math.cos(radious) - point.y * Math.sin(radious) * scale;
			rp.y = point.x * Math.sin(radious) + point.y * Math.cos(radious) * scale;
			return rp;
		}
		
		/**
		 * 角度转弧度 
		 */
		public static function asRadians(degrees:Number):Number
		{
			return degrees * DEGTORAD;
		}
		
		/**
		 *  由角度计算速度
		 */
		public static function velocityFromAngle(angle:int, speed:int , isDegree:Boolean = true):Point
		{
			var a:Number = isDegree ? asRadians(angle) : angle;
			
			var result:Point = new Point();
			
			result.x = int(Math.cos(a) * speed);
			result.y = int(Math.sin(a) * speed);
			
			return result;
		}
		
	}
}