package net.play5d.game.bvn.stage
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.GameRender;
	//import net.play5d.game.bvn.ctrl.KeyBoardCtrl;
	import net.play5d.game.bvn.ctrl.KeyEvent;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.ctrl.StateCtrl;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.KeyConfigVO;
	import net.play5d.game.bvn.input.GameInputType;
	import net.play5d.game.bvn.input.GameInputer;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.input.KyoKeyCode;
	import net.play5d.kyo.stage.Istage;

	public class HowToPlayState implements Istage
	{
		private var _ui:movie_howtoplay;
		public function HowToPlayState()
		{
		}

		public function get display():DisplayObject
		{
			return _ui;
		}

		public function build():void
		{
			_ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.howtoplay , 'movie_howtoplay');
			_ui.addEventListener(Event.COMPLETE,uiComplete);
			_ui.gotoAndPlay(2);

			_ui.mouseChildren = false;

			_ui.graphics.beginFill(0,1);
			_ui.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);
			_ui.graphics.endFill();

			SoundCtrl.I.BGM(AssetManager.I.getSound('back'));


			var kc:KeyConfigVO = GameData.I.config.key_p1;

			setKeyText(_ui.txt_up , kc.up);
			setKeyText(_ui.txt_down , kc.down);
			setKeyText(_ui.txt_left , kc.left);
			setKeyText(_ui.txt_right , kc.right);

			setKeyText(_ui.txt_attack , kc.attack);
			setKeyText(_ui.txt_jump , kc.jump);
			setKeyText(_ui.txt_dash , kc.dash);
			setKeyText(_ui.txt_skill , kc.skill);
			setKeyText(_ui.txt_bisha , kc.superKill);
			setKeyText(_ui.txt_special , kc.beckons);

			setTimeout(function():void{
				GameRender.add(render);
				GameInputer.focus();
				GameInputer.enabled = true;

				_ui.buttonMode = true;
				_ui.addEventListener(MouseEvent.CLICK, skipBtnHandler);
			},100);
//				_ui.skip_btn.addEventListener(MouseEvent.CLICK, skipBtnHandler);
//			},1000);

		}

		private function render():void{
			if(GameInputer.back(1) || GameInputer.select(GameInputType.MENU,1)){
				GameRender.remove(render);
				_ui.gotoAndPlay("skip");
			}
		}

		private function skipBtnHandler(e:MouseEvent):void{
			if(_ui) _ui.removeEventListener(MouseEvent.CLICK, skipBtnHandler);
			if(_ui.skip_btn) _ui.skip_btn.removeEventListener(MouseEvent.CLICK, skipBtnHandler);

			GameRender.remove(render);
			_ui.gotoAndPlay("skip");
		}

		private function uiComplete(e:Event):void{
			_ui.removeEventListener(Event.COMPLETE,uiComplete);
			MainGame.I.goSelect();
		}

		private function setKeyText(text:TextField , code:int):void{
			var name:String = KyoKeyCode.code2name(code);
			if(name) text.text = name;
		}

		public function afterBuild():void
		{
		}

		public function destory(back:Function=null):void
		{
			SoundCtrl.I.BGM(null);
			GameRender.remove(render);
			_ui.removeEventListener(Event.COMPLETE,uiComplete);
			_ui.gotoAndStop('destory');
		}
	}
}