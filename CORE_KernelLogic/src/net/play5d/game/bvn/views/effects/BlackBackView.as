package net.play5d.game.bvn.views.effects
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	
	public class BlackBackView extends Sprite
	{
		private var _bishaFace:BishaFaceEffectView;
		private var isRenderFadIn:Boolean;
		private var isRenderFadOut:Boolean;
		
		private var _bg:Bitmap;
		
		public function BlackBackView()
		{
			super();
			
			var bd:BitmapData = new BitmapData(GameConfig.GAME_SIZE.x/10 , GameConfig.GAME_SIZE.y/10 , false , 0);
			_bg = new Bitmap(bd);
			_bg.width = GameConfig.GAME_SIZE.x;
			_bg.height = GameConfig.GAME_SIZE.y;
			
			addChild(_bg);
		}
		
		public function destory():void{
			if(_bg){
				try{
					removeChild(_bg);
				}catch(e:Error){}
				_bg.bitmapData.dispose();
				_bg = null;
			}
			removeBishaFace();
		}
		
//		public function render():void{
//			
//		}
		
		public function renderAnimate():void{
//			if(isRenderFadIn) renderFadIn();
//			if(isRenderFadOut) renderFadOut();
		}
		
		public function fadIn():void{
//			isRenderFadIn = true;
//			this.alpha = 0;
//			this.visible = true;
		}
		
		public function fadOut():void{
//			isRenderFadOut = true;
//			this.alpha = 1;
//			this.visible = false;
			removeBishaFace();
			try{
				parent.removeChild(this);
			}catch(e:Error){}
		}
		
//		private function renderFadIn():void{
//			this.alpha += 0.1;
//			if(alpha >= 1){
//				isRenderFadIn = false;
//			}
//		}
//		
//		private function renderFadOut():void{
//			this.alpha -= 0.1;
//			if(alpha <= 0){
//				isRenderFadOut = false;
//				
//				removeBishaFace();
//				
//			}
//		}
		
		
		public function showBishaFace(faceid:int , face:DisplayObject):void{
			if(!_bishaFace){
				_bishaFace = new BishaFaceEffectView();
				var zoom:Number = 1;
				if(GameCtrl.I && GameCtrl.I.gameState && GameCtrl.I.gameState.camera){
					zoom = GameCtrl.I.gameState.camera.getZoom();
				}
				_bishaFace.mc.y = 100 + (100 / zoom);
				addChild(_bishaFace.mc);
			}
			
			_bishaFace.setFace(faceid , face);
			_bishaFace.fadIn();
		}
		
		private function removeBishaFace():void{
			if(_bishaFace){
				_bishaFace.destory();
				_bishaFace = null;
			}
		}
		
		
	}
}