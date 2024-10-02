package net.play5d.game.bvn.ui
{
	import flash.events.Event;
	
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.GameRender;
	import net.play5d.game.bvn.utils.ResUtils;

	public class TransUI
	{
		
		public var ui:trans_mc;
		
		private var _renderAnimateGap:int = 0; //刷新动画间隔
		private var _renderAnimateFrame:int = 0;
		
		private var _fadInBack:Function;
		private var _fadOutBack:Function;
		
//		private var _justRender:Boolean;
		
		private var _rendering:Boolean = true;
		
		public function TransUI()
		{
			ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui , 'trans_mc');
		}
		
		public function destory():void{
			GameRender.remove(render);
		}
		
		private function startRender():void{
			_renderAnimateGap = Math.ceil(MainGame.I.getFPS() / GameConfig.FPS_UI) - 1;
			_renderAnimateFrame = 0;
			
			_rendering = true;
			
			GameRender.add(render);
			
		}
		private function stopRender():void{
			_rendering = false;
			GameRender.remove(render);
		}
		
		private function render():void{
			
			if(!_rendering) return;
			
			if(_renderAnimateGap > 0){
				if(_renderAnimateFrame++ >= _renderAnimateGap){
					_renderAnimateFrame = 0;
					renderAnimate();
				}
			}else{
				renderAnimate();
			}
		}
		
		private function renderAnimate():void{
			
//			trace('TrainsUI.renderAnimate',ui.currentFrame,ui.currentFrameLabel);
			
			if(ui.currentFrameLabel == 'stop'){
				
				//这里要处理在fadinback中定义了fadoutback的情况，所以只能这样写
				
				if(_fadInBack != null){
					_fadInBack();
					_fadInBack = null;
					return;
				}
				if(_fadOutBack != null){
					_fadOutBack();
					_fadOutBack = null;
					return;
				}
				
				stopRender();
				
				return;
			}
			ui.nextFrame();
		}
		
		
		public function fadIn(back:Function = null):void{
//			trace('fadIn');
			_fadOutBack = null;
			
			_fadInBack = back;
			ui.gotoAndStop('fadin');
			startRender();
		}
		
		public function fadOut(back:Function = null):void{
			_fadInBack = null;
			
//			trace('fadOut');
			_fadOutBack = back;
			ui.gotoAndStop('fadout');
			startRender();
		}
		
	}
}