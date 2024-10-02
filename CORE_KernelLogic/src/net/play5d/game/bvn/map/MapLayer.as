package net.play5d.game.bvn.map
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.GameQuailty;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.interfaces.IGameSprite;
	import net.play5d.kyo.utils.KyoUtils;

	public class MapLayer extends Sprite
	{
		public var enabled:Boolean = false;
		private var _view:DisplayObject;
		private var _blurBitmaps:Object = {};
		private var _smoothing:Boolean;
		
		public function MapLayer(view:DisplayObject)
		{
			if(!view) return;
			
			enabled = true;
			
			initView(view);
		}
		
		private function initView(view:DisplayObject):void{
			_view = view;
			show(_view);
			
			this.x = view.x;
			this.y = view.y;
			
			view.x = view.y = 0;
		}
		
		private function getBlurBitmap(blurX:int = 5, blurY:int = 0):Bitmap{
			var id:String = blurX+'|'+blurY;
			if(_blurBitmaps[id]) return _blurBitmaps[id];
			
			var bp:Bitmap = drawBitmap(true, 0);
			trace('addBlurBitmap', id);
			
			var filter:BlurFilter = new BlurFilter(blurX, blurY, 1);
			bp.bitmapData.applyFilter(bp.bitmapData, bp.bitmapData.rect, new Point(), filter);
			
			_blurBitmaps[id] = bp;
			
//			bp.visible = false;
//			addChild(bp);
			
			return bp;
		}
		
		public function normalize():void{
			
			if(!_view) return;
			
			if(_view is Bitmap){
				(_view as Bitmap).smoothing = GameData.I.config.quality == GameQuailty.BEST;
			}
			
			if(_view is Sprite){
				var sp:Sprite = _view as Sprite;
				for(var i:int ; i < sp.numChildren ; i++){
					var d:DisplayObject = sp.getChildAt(i);
					if(d is Bitmap){
						(d as Bitmap).smoothing = GameData.I.config.quality == GameQuailty.BEST;
					}
				}
				
				var logo1:DisplayObject = sp.getChildByName("logo4399");
				var logo2:DisplayObject = sp.getChildByName("logo_mine");
				
//				trace(sp.name + "======================== 9,M");
				trace('logos', logo1, logo2);

				if(logo1) logo1.visible = false;
				if(logo2) logo2.visible = false;
				
				switch(GameConfig.MAP_LOGO_STATE){
					case 1:
						if(logo1) logo1.visible = true;
						break;
					case 2:
						if(logo2) logo2.visible = true;
						break;
				}
				
			}
			
			
		}
		
		public function renderOptical(gameSps:Vector.<IGameSprite>):void{
			if(!_view) return;
			if(_smoothing) return;
			
			var sp:Sprite = _view as Sprite;
			if(!sp) return;
			
			var spLength:int = sp.numChildren;
			if(spLength < 1) return;
			
			var r:Rectangle;
			var d:DisplayObject;
			
			for(var i:int ; i < spLength ; i++){
				d = sp.getChildAt(i);
				
				if(d is MovieClip == false) continue;
				
				r = d.getBounds(sp);
				r.x += sp.x + this.x;
				r.y += sp.y + this.y;
				d.alpha = checkHitGameSprite(r,gameSps) ? 0.5 : 1;
				
			}
		}
		
		private var _currentShow:DisplayObject;
		private function show(v:DisplayObject):void{
//			for(var i:String in _blurBitmaps){
//				if(_blurBitmaps[i] == v) continue;
//				try{
//					removeChild(_blurBitmaps[i]);
//				}catch(e:Error){
//					trace(e);
//				}
//			}
			
//			if(_view != v){
//				try{
//					removeChild(_currentShow);
//				}catch(e:Error){
//					trace(e);
//				}
//			}
			
//			addChild(v);
			
			if(_currentShow == v) return;
			
			if(_currentShow){
				try{
					removeChild(_currentShow);
				}catch(e:Error){
					trace(e);
				}
			}
			
			addChild(v);
			_currentShow = v;
			
		}
		
		private function checkHitGameSprite(rect:Rectangle , gameSps:Vector.<IGameSprite>):Boolean{
			
			var isHit:Boolean = false;
			var rect2:Rectangle = null;
			
			for(var j:int ; j < gameSps.length ; j++){
				var gp:IGameSprite = gameSps[j];
				if(gp){
					//					rect2 = gp.getBodyArea();
					rect2 = gp.getArea();
					if(rect2){
						isHit = rect.intersects(rect2);
						if(isHit) return true;
					}
				}
			}
			
			return false;
			
		}
		
		private function drawBitmap(transparent:Boolean = true , fillColor:uint = 0):Bitmap{
			if(_view){
				var bp:Bitmap = new Bitmap(new BitmapData(_view.width/2, _view.height/2, transparent, fillColor));
				var bds:Rectangle = _view.getBounds(_view);
				var matrix:Matrix = new Matrix(1,0,0,1,-bds.x,-bds.y);
				matrix.scale(0.5, 0.5);
				bp.bitmapData.draw(_view, matrix);
				
				bp.x = bds.x;
				bp.y = bds.y;
				bp.scaleX = bp.scaleY = 2;
				return bp;
			}
			return null;
		}
		
		public function destory():void{
			if(_view is Bitmap){
				(_view as Bitmap).bitmapData.dispose();
			}
		}
		
		public function setSmoothing(blurX:Number = 0, blurY:Number = 0):void{
			if(!_view) return;
			
			try{
				
				if(blurX <= 0 && blurY <= 0){
					show(_view);
					return;
				}
				
				var bp:Bitmap = getBlurBitmap(blurX, blurY);
				show(bp);
				
			}catch(e:Error){
				trace('MapLayer.setSmoothing error ::', e);
			}
			
		}
	}
}