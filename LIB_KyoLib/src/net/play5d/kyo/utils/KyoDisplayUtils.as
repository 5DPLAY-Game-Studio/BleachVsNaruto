package net.play5d.kyo.utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class KyoDisplayUtils
	{
		/*   
		*   深度拷贝，最好用于普通对象上，不要用于自定义类上
		*   obj: 要拷贝的对象
		*   return ：返回obj的深度拷贝
		*/
		public static function clone(object:Object):DisplayObject{  
			var qClassName:String = getQualifiedClassName(object);
			var objectType:Class = getDefinitionByName(qClassName) as Class;
			registerClassAlias(qClassName, objectType);
			var copier : ByteArray = new ByteArray();
			copier.writeObject(object);
			copier.position = 0;
			return copier.readObject() as DisplayObject;
		}
		
		/*
		*    影片剪辑的复制，只要是DisplayObject都可以
		*    target ：要复制的影片剪辑
		*    autoAdd: 如果为true就表示重复的天骄显示列表中
		*    
		*/
		public static function duplicateDisplayObject(target:DisplayObject, autoAdd:Boolean = false):DisplayObject {
			var targetClass:Class = Object(target).constructor;
			var duplicate:DisplayObject = new targetClass();
			
			duplicate.transform = target.transform;
			duplicate.filters = target.filters;
			duplicate.cacheAsBitmap = target.cacheAsBitmap;
			duplicate.opaqueBackground = target.opaqueBackground;
			
			if (target.scale9Grid) {
				var rect:Rectangle = target.scale9Grid;
				// Flash 9 bug where returned scale9Grid is 20x larger than assigned
				rect.x /= 20;
				rect.y /= 20;
				rect.width /= 20;
				rect.height /= 20;
				duplicate.scale9Grid = rect;
			}
			
			if (autoAdd && target.parent){
				target.parent.addChild(duplicate);
			}
			return duplicate;
		}
		
		
//		public static var output:Sprite = new Sprite();
//		public static var output2:Sprite = new Sprite();
		
		/**
		 * 用来判断两个矩形是否碰撞 [支持旋转以后的矩形]
		 * @param obj1 包含{x(必填),y(必填),width(必填),height(必填),scaleX(选填),rotation(选填),radian(选填：孤度),orginX(选填，注册点x),orginY(选填，注册点y)}
		 * @param obj2 同obj1
		 */
		public static function rorationRectCollide(obj1:Object , obj2:Object):Boolean {
			if(obj1 == null || obj2 == null) return false;
			
			var cosobj:Object = {};
			var sinobj:Object = {};
			
			/*
			*   设置一个点旋转一定角度后的新坐标
			*/
			function rodatePoint(origin:Point, p:Point, ro:Number , radian:Number):void {
				if(isNaN(radian) || radian == 0) radian = ro * 3.14 / 180;
				
				var cos:Number = cosobj[ro] ? cosobj[ro] : Math.cos(radian);
				var sin:Number = sinobj[ro] ? sinobj[ro] : Math.sin(radian);
				
				cosobj[ro] = cos;
				sinobj[ro] = sin;
				
				var x0:Number = (p.x - origin.x) * cos - (p.y - origin.y) * sin;
				var y0:Number = (p.y - origin.y) * cos + (p.x - origin.x) * sin;
				
				p.x = x0 + origin.x;
				p.y = y0 + origin.y;
			}
			
			/*
			*   获取矩形的每个点，保存在Array中并返回
			*   dis:显示对象，获取其矩形坐标
			*   globalPoint :以将dis坐标转化为舞台全局坐标了
			*/
			function getRectEachPoint(dis:Rectangle, orgin:Point , angle:int , radian:Number = 0):Array {
				/*  
				#   b                     c
				*   |---------------------|
				*   |                     |
				*   |         注册点             |
				*   |                     | 
				*   |---------------------|
				*   a                     d
				*/
				var fourPointArr:Array = [];
				
				var tx:int = int(dis.x - orgin.x);
				var ty:int = int(dis.y - orgin.y);
				var tw:int = int(tx + dis.width);
				var th:int = int(ty + dis.height);
				
				fourPointArr[0] = new Point(tx , th);
				fourPointArr[1] = new Point(tx , ty);
				fourPointArr[2] = new Point(tw , ty);
				fourPointArr[3] = new Point(tw , th);
				
				var ro:Point = new Point(dis.x , dis.y);
				
				for (var i:int = 0; i < 4;++i) {
					rodatePoint(ro, fourPointArr[i],angle,radian);
				}
				
				return fourPointArr;
			}
			
			var projPoint:Point = new Point();
			function getProjectPoint(axsi:Point, p:Point):Point {
				var pplus:int = int(p.x * axsi.x + p.y * axsi.y);
				
				var axsi2x:int = int(axsi.x * axsi.x);
				var axsi2y:int = int(axsi.y * axsi.y);
				var axsiplus:int = axsi2x + axsi2y;
				
				projPoint.x = pplus / axsiplus * axsi.x;
				projPoint.y = pplus / axsiplus * axsi.y;
				
				return projPoint;
			}
			
			function getScalarValue(arr:Array, axsi:Point):Array {
				var minMaxArr:Array = [];
				var tempArray:Array = [];
				var len:int = arr.length;
				for (var i:int = 0; i < 4;++i) {
					var pp:Point = getProjectPoint(axsi,arr[i]);
					tempArray[i] = pp.x * axsi.x + pp.y * axsi.y;
				}
				tempArray.sort(Array.NUMERIC);
				minMaxArr[0] = tempArray[0];
				minMaxArr[1] = tempArray[3];
				tempArray = null;
				return minMaxArr;
			}
			
			function projectOverlap(Ax:Point, rectArr1:Array, rectArr2:Array):Boolean {
				var rect1MinMax:Array = getScalarValue(rectArr1, Ax);
				var rect2MinMax:Array = getScalarValue(rectArr2, Ax);
				if (rect2MinMax[0] > rect1MinMax[1] || rect2MinMax[1] < rect1MinMax[0]) return true;
				return false;
			}
			
			function maybeCollide(p00:Point,p01:Point,p10:Point,p11:Point):Boolean {
				var r1:int = getTowPointDistance(p00, p01);
				var r2:int = getTowPointDistance(p10, p11);
				var abDistance:int = getTowPointDistance(p00,p10);
				if (abDistance > r1 + r2) {
					return false;
				}
				return true;
			}
			
			function getTowPointDistance(p1:Point, p2:Point):int{
				var ax:int = int(p1.x - p2.x);
				var ay:int = int(p1.y - p2.y);
				return Math.sqrt(ax*ax + ay * ay);
			}
			
			if(isNaN(obj1.x + obj1.y + obj1.width + obj1.height)) throw new Error('在obj1中未找到 x/y/width/height');
			if(isNaN(obj2.x + obj2.y + obj2.width + obj2.height)) throw new Error('在obj2中未找到 x/y/width/height');
			
			var rect1:Rectangle = new Rectangle(obj1.x , obj1.y , obj1.width , obj1.height);
			var rotation1:int = int(obj1.rotation);
			var scaleX1:Number = obj1.scaleX != undefined ? obj1.scaleX : 1;
			var orgin1:Point = new Point(
				obj1.orginX != undefined ? obj1.orginX : 0 ,
				obj1.orginY != undefined ? obj1.orginY : 0);
			var radian1:Number = obj1.radian;
			
			var rect2:Rectangle = new Rectangle(obj2.x , obj2.y , obj2.width , obj2.height);
			var rotation2:int = int(obj2.rotation);
			var scaleX2:Number = obj2.scaleX != undefined ? obj2.scaleX : 1;
			var orgin2:Point = new Point(
				obj2.orginX != undefined ? obj2.orginX : 0 ,
				obj2.orginY != undefined ? obj2.orginY : 0);
			var radian2:Number = obj2.radian;
			
			if(scaleX1 < 0){
				orgin1.x = rect1.width - orgin1.x;
				rect1.x = rect1.x - rect1.width + obj1.orginX + orgin1.x;
			}
			
			if(scaleX2 < 0){
				orgin2.x = rect2.width - orgin2.x;
				rect2.x = rect2.x - rect2.width + obj2.orginX + orgin2.x;
			}
			
//			output.x = rect1.x;
//			output.y = rect1.y;
//			output.graphics.clear();
//			output.graphics.beginFill(0xfff000,0.5);
//			output.graphics.drawRect(-orgin1.x , -orgin1.y , rect1.width , rect1.height);
//			output.graphics.endFill();
//			output.graphics.beginFill(0xffffff,1);
//			output.graphics.drawRect(0 , 0 , 2 , 2);
//			output.graphics.endFill();
//			output.rotation = rotation1;
//			output2.x = rect2.x;
//			output2.y = rect2.y;
//			output2.graphics.clear();
//			output2.graphics.beginFill(0xfff000,0.5);
//			output2.graphics.drawRect(-orgin2.x , -orgin2.y , rect2.width , rect2.height);
//			output2.graphics.endFill();
//			output2.graphics.beginFill(0xffffff,1);
//			output2.graphics.drawRect(0 , 0 , 2 , 2);
//			output2.graphics.endFill();
//			output2.rotation = rotation2;
			
			var arr1:Array = getRectEachPoint(rect1, orgin1, rotation1 , radian1);
			var arr2:Array = getRectEachPoint(rect2, orgin2, rotation2 , radian2);
			
			if (maybeCollide(orgin1, arr1[0], orgin2, arr2[0]) == false) return false;
			
			var AsisArr:Array = [
				new Point(arr1[2].x - arr1[1].x, arr1[2].y - arr1[1].y),
				new Point(arr1[2].x - arr1[3].x, arr1[2].y - arr1[3].y),
				new Point(arr2[1].x - arr2[0].x, arr2[1].y - arr2[0].y),
				new Point(arr2[1].x - arr2[2].x, arr2[1].y - arr2[2].y)
			];
			
			for (var i:int = 0; i < 4;++i) {
				if (projectOverlap(AsisArr[i], arr1, arr2)) {
					return false;
				}
			}
			
			return true;
		}
		
		
	}
}