package net.play5d.game.bvn.data
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.utils.KyoUtils;

	public class EffectVO
	{
		public var className:String;
		public var shine:Object;//闪光{color,alpha}
		public var shake:Object;//震动{x,y|pow,time[毫秒，可选]} , 当设置pow时，x,y无效，根据hitvo.hitx,hity进行震动
		public var freeze:int;//暂停时间（毫秒）
		public var sound:String; //声音(暂时不用)
		public var randRotate:Boolean; //随机角度旋转
		public var followDirect:Boolean; //跟随角色朝向
		public var slowDown:Object; //慢放效果{rate[慢放倍数],time[慢放时间（毫秒）]}
		
		public var blendMode:String = BlendMode.NORMAL;
		public var bitmapDataCache:Vector.<BitmapDataCacheVO>;
		public var frameLabelCache:Object;
		
		public var specialEffectId:String;
		
		public var targetColorOffset:Array;
		
		public var isSpecial:Boolean = false;
		
		public var isBuff:Boolean = false;
		
		public var isSteelHit:Boolean = false;
		
		public function EffectVO(className:String , param:Object = null)
		{
			this.className = className;
			if(param) KyoUtils.setValueByObject(this,param);
		}
		
		public function clone():EffectVO{
			var o:Object = KyoUtils.itemToObject(this);
			delete o['className'];
			var ev:EffectVO = new EffectVO(className , o);
			return ev;
		}
		
		public function cacheBitmapData():void{
			
			bitmapDataCache = new Vector.<BitmapDataCacheVO>();
			frameLabelCache = {};
			
			var mc:MovieClip = AssetManager.I.getEffect(className);
			mc.gotoAndStop(1);
			var bounds:Rectangle;
			var cache:BitmapDataCacheVO;
			
			while(mc.currentFrame < mc.totalFrames){
				
				var frameLabel:String = mc.currentFrameLabel;
				if(frameLabel) frameLabelCache[mc.currentFrame] = frameLabel;
				
				if(mc.width < 1 || mc.height < 1){
					bitmapDataCache.push(null);
					mc.nextFrame();
					continue;
				}
				
				var bd:BitmapData = new BitmapData(mc.width,mc.height,true,0);
				bounds = mc.getBounds(mc);
				bd.draw(mc,new Matrix(1,0,0,1,-bounds.x , -bounds.y));
				
				var offsetX:Number = bounds.x;
				var offsetY:Number = bounds.y;
				
				if(cache && cache.offsetX == offsetX && cache.offsetY == offsetY && cache.bitmapData.compare(bd) == 0x00000000){
					bitmapDataCache.push(cache);
					mc.nextFrame();
					continue;
				}
				
//				trace('cache',className , mc.currentFrame);
				
				cache = new BitmapDataCacheVO();
				cache.bitmapData = bd;
				cache.offsetX = offsetX;
				cache.offsetY = offsetY;
				bitmapDataCache.push(cache);
				
				mc.nextFrame();
			}
			
			mc = null;
			bounds = null;
			cache = null;
			
		}
		
	}
}