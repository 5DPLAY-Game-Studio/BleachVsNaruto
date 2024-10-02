package net.play5d.kyo.utils
{
	public class KyoRandom
	{
		/**
		 * 从数组中随机取出一个元素 
		 */
		public static function getRandomInArray(array:Object,deleteSelect:Boolean = false):*{
			if(array == null || array.length < 1) return null;
			var r:int = Math.random() * array.length << 0;
			var item:* = array[r];
			if(deleteSelect) array.splice(r,1);
			return item;
		}
		
		/**
		 * 随机从数组中取出多个元素 
		 * @param array 
		 * @param amount 数量
		 * @param repeat 是否允许重复
		 */
		public static function getRandomSomeInArray(array:Array ,amount:int, repeat:Boolean = false):Array{
			var a:Array = array.concat();
			var r:Array = [];
			for(var i:int ; i < amount ; i++){
				var d:int = Math.random() * a.length << 0;
				var m:* = a[d];
				r.push(m);
				if(!repeat) a.splice(d,1);
			}
			return r;
		}
		
		/**
		 * 从参数中随机取出一个元素 
		 */
		public static function getRandomOne(...params):*{
			return getRandomInArray(params);
		}
		
		/**
		 * 在两个Number范围中随机 
		 */
		public static function between(A:Number,B:Number):Number{
			var s:Number;
			var e:Number;
			if(A < B){
				s = A;
				e = B;
			}else{
				s = B;
				e = A;
			}
			var r:Number = s + Math.random() * (e - s);
			if(r < s) r = s;
			if(r > e) r = e;
			return r;
		}
		
		/**
		 * 按机率随机 必会选出一个
		 * @param attributeName 数组元素中机率属性(Number)的名称
		 */
		public static function getRandomByRate(array:Array,attributeName:String):*{
			var max:Number = 0;
			array.sortOn(attributeName , Array.NUMERIC);
			for(var i:int = 0 ; i < array.length ; i++) max += Number(array[i][attributeName]);
			var rad:Number = Math.random() * max;
			if(rad > max - 1) rad = max - 1;
			var rate:Number = 0;
			for(i = 0 ; i < array.length ; i++){
				var newRate:Number = rate + Number(array[i][attributeName]);
				if(rad >= rate && rad < newRate){
					return array[i];
				}
				rate = newRate;
			}
			throw Error('无法按机率选择，请检查数据');
		}
		
		/**
		 * 按机率随机 轻量级，有可能是NULL
		 * @param attributeName 数组元素中机率属性(Number)的名称 [ 0~1之间的Number ]
		 */
		public static function getRandomByRateLite(array:Array,attributeName:String,randMx:Number = 1):*{
			array.sortOn(attributeName , Array.NUMERIC);
			
			var rad:Number = Math.random() * randMx;
			var rate:Number = 0;
			var a:Array = [];
			for(var i:int = 0 ; i < array.length ; i++){
				var m:* = array[i];
				var n:Number = m[attributeName];
				if(rate == 0){
					if(rad <= n){
						rate = n;
						a.push(m);
					}
				}else{
					if(n == rate) a.push(m);
				}
			}
			return getRandomInArray(a);
		}
		
		/**
		 * 在一定范围中随机取一个随机的整数队列
		 * @param from 小的数字
		 * @param to 大的数字
		 */
		public static function getRandomInts(from:int , to:int):Array{
			var a:Array = [];
			for(var i:int = from ; i < to ; i++){
				a.push(i);
			}
			arraySortRandom(a);
			return a;
		}
		
		/**
		 * 将一个数组随机排序 
		 * @param array
		 * 
		 */
		public static function arraySortRandom(array:Array):void{
			function taxis(element1:*,element2:*):int{
				var num:Number=Math.random();
				if(num<0.5){
					return -1;
				}else{
					return 1;
				}
			}
			array.sort(taxis);
		}
		
		/**
		 * 随机的颜色 
		 * @param from
		 * @param to
		 */
		public static function getRandomColor(from:uint = 0 , to:uint = 0xffffff):uint{
			return from + (to - from) * Math.random();
		}
		
	}
}