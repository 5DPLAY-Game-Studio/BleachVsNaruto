package net.play5d.kyo.effect
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.play5d.kyo.utils.KyoUtils;
	
	public class DisplayEffect
	{
		public function DisplayEffect()
		{
		}
		
		/**
		 * 残影效果 
		 * @param d 图形
		 * @param alphaLose 每帧减少残影的透明数
		 * @param startAlpha 初始的残影透明度
		 * @param colorTransFrom 残影的颜色效果
		 */
		public static function ghostShadow(d:DisplayObject , alphaLose:Number = 0.1 , startAlpha:Number = 1 , colorTransFrom:ColorTransform = null):void{
			var pt:DisplayObjectContainer = d.parent;
			if(!pt) return;
			
			var oo:Object = {'parent':pt , 'alphaLose':alphaLose};
			var po:Object = {'alpha':startAlpha};
			
			var bp:InsShadow = createInsShadow(d,oo,po);
			if(!bp) return;
			if(colorTransFrom){
				bp.bitmap.transform.colorTransform = colorTransFrom;
			}
			
			pt.addChild(bp.bitmap);
			pt.addChild(d);
			
			bp.initlize();
		}
		
		/**
		 * 缩放影子效果 
		 * @param d
		 * @param scaleAdd 尺寸比例每帧增加数
		 * @param alphaLose
		 * @param startAlpha
		 * @param colorTransFrom
		 * 
		 */
		public static function zoomShadow(d:DisplayObject , scaleAdd:Number = .1 , alphaLose:Number = 0.05 , startAlpha:Number = 1 , colorTransFrom:ColorTransform = null , parent:DisplayObjectContainer = null , size:Point = null):DisplayObject{
			parent ||= d.parent;
			if(!parent) return null;
			
			var oo:Object = {'parent':parent , 'alphaLose':alphaLose , 'scaleAdd':scaleAdd};
			var po:Object = {'alpha':startAlpha};
			
			var bp:InsShadow = createInsShadow(d,oo,po,size);
			if(!bp) return null;
			if(colorTransFrom){
				bp.bitmap.transform.colorTransform = colorTransFrom;
			}
			
			parent.addChild(bp.bitmap);
			bp.initlize();
			
			return bp.bitmap;
		}
		
		private static function createInsShadow(d:DisplayObject , prams:Object = null , bpPrams:Object = null , size:Point = null):InsShadow{
			var bmp:Bitmap = KyoUtils.drawDisplay(d);
			if(!bmp) return null;
			
			var bp:InsShadow = new InsShadow();
			bp.bitmap = bmp;
			bp.bitmap.scaleX = d.scaleX;
			bp.bitmap.scaleY = d.scaleY;
			
			var bds:Rectangle = d.getBounds(d);
			bp.bitmap.x = d.x + bds.x * d.scaleX;
			bp.bitmap.y = d.y + bds.y * d.scaleY;
			
			bp.size = size;
			
			var i:String;
			if(prams){
				for(i in prams){
					bp[i] = prams[i];
				}
			}
			if(bpPrams){
				for(i in bpPrams){
					bp.bitmap[i] = bpPrams[i];
				}
			}
			
			return bp;
		}
		
		/**
		 * 在场景中加入MC元件效果 
		 * @param child
		 * @param effect
		 * @param pos
		 * @return 
		 * 
		 */
		public static function mcEffect(child:DisplayObjectContainer , effect:Class , pos:Point = null):MovieClip{
			var mc:MovieClip = new effect();
			mc.mouseEnabled = mc.mouseChildren = false;
			if(pos){
				mc.x = pos.x;
				mc.y = pos.y;
			}
			mc.addFrameScript(mc.totalFrames-1,function():void{
				mc.stop();
				mc.parent.removeChild(mc);
				mc = null;
			});
			mc.gotoAndPlay(1);
			child.addChild(mc);
			return mc;
		}
		
		public static function shake(stage:DisplayObject,frames:int = 1,strange:int = 2):void{
			stage.removeEventListener(Event.ENTER_FRAME,enterframe);
			
			stage.addEventListener(Event.ENTER_FRAME,enterframe);
			var frame:int;
			function enterframe(e:Event):void{
				frame++;
				if(frame > frames){
					stage.x = 0;
					stage.y = 0;
					stage.removeEventListener(Event.ENTER_FRAME,enterframe);
					return;
				}
				var ii:int = frame % 2 == 0 ? 1 : -1;
				stage.x += strange * ii;
				stage.y += strange * ii;
			}
		}
		
	}
}


import flash.display.Bitmap;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Point;

internal class InsShadow{
	public var bitmap:Bitmap;
	public var alphaLose:Number = 0.1;
	public var parent:DisplayObjectContainer;
	public var scaleAdd:Number = 0;
	public var size:Point;
	
	private var _scaleAddP:Point;
	private var _poLose:Point;
	public function InsShadow(){
	}
	public function initlize():void{
		_scaleAddP = new Point(scaleAdd,scaleAdd);
		size ||= new Point(bitmap.width , bitmap.height);
		_poLose = new Point(size.x * scaleAdd / 2 , size.y * scaleAdd / 2);
		
		if(bitmap.scaleX < 0){
			_scaleAddP.x *= -1;
			_poLose.x *= -1;
		}
		
		bitmap.addEventListener(Event.ENTER_FRAME,enterFrame);
	}
	
	private function enterFrame(e:Event):void{
		bitmap.alpha -= alphaLose;
		if(scaleAdd != 0){
			bitmap.scaleX += _scaleAddP.x;
			bitmap.scaleY += _scaleAddP.y;
			bitmap.x -= _poLose.x;
			bitmap.y -= _poLose.y;
		}
		
		if(bitmap.alpha <= 0){
			bitmap.removeEventListener(Event.ENTER_FRAME,enterFrame);
			parent.removeChild(bitmap);
			bitmap.bitmapData.dispose();
			bitmap = null;
		}
	}
}