package net.play5d.game.bvn.stage
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.GameLogic;
	import net.play5d.game.bvn.ctrl.GameRender;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.ctrl.StateCtrl;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.input.GameInputType;
	import net.play5d.game.bvn.input.GameInputer;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.bitmap.BitmapFontText;
	import net.play5d.kyo.stage.Istage;
	import net.play5d.kyo.utils.KyoTimeout;

	public class GameOverState implements Istage
	{
		private var _ui:stg_gameover_mc;
		private var _arrow:select_arrow_mc;
		private var _arrowSelected:String;
		private var _keyInited:Boolean;
		private var _keyEnabled:Boolean = true;
		private var _char:FighterMain;
		private var _btns:Array = [];

		public function GameOverState()
		{
			StateCtrl.I.clearTrans();
			_ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.gameover , ResUtils.GAME_OVER);
			_ui.gotoAndStop(1);
		}

		public function showContinue():void{
			_ui.addEventListener(Event.COMPLETE,showContinueComplete,false,0,true);
			_ui.gotoAndPlay("continue");
			addChar();

			SoundCtrl.I.BGM(AssetManager.I.getSound("continue"));
		}
		private function showContinueComplete(e:Event):void{
			_ui.removeEventListener(Event.COMPLETE,showContinueComplete);
//			var yesbtn:DisplayObject = _ui.getChildByName('btn_yes');
//			var nobtn:DisplayObject = _ui.getChildByName('btn_no');

			initBtn('btn_yes');
			initBtn('btn_no');

			initArrow('btn_yes');
		}

		private function initBtn(name:String):void{
			var btn:Sprite = _ui.getChildByName(name) as Sprite;
			if(!btn) return;
			btn.buttonMode = true;
			btn.addEventListener(MouseEvent.MOUSE_OVER, btnMouseHandler);
			btn.addEventListener(MouseEvent.CLICK, btnMouseHandler);
			_btns.push(btn);
		}

		private function btnMouseHandler(e:MouseEvent):void{
			var target:DisplayObject = e.currentTarget as DisplayObject;
			switch(e.type){
				case MouseEvent.MOUSE_OVER:
					setArrow(target.name);
					break;
				case MouseEvent.CLICK:
					_arrowSelected = target.name;
					selectHandler();
					break;
			}
		}

		private function render():void{
			if(!_keyEnabled) return;

			if(GameInputer.left(GameInputType.MENU,1)){
				setArrow('btn_yes');
			}
			if(GameInputer.right(GameInputType.MENU,1)){
				setArrow('btn_no');
			}
			if(GameInputer.select(GameInputType.MENU,1)){
				selectHandler();
			}

		}

		private function selectHandler():void{
			switch(_arrowSelected){
				case 'btn_yes':
					showContYes();
					break;
				case 'btn_no':
					showContNo();
					break;
				case 'btn_back':
					MainGame.I.goLogo();
					break;
			}
			SoundCtrl.I.sndConfrim();
		}

		private function initArrow(defaultId:String = null):void{
			if(!_arrow){
				_arrow = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui , 'select_arrow_mc');
				_ui.addChild(_arrow);
			}

			if(defaultId) setArrow(defaultId);

//			if(!_keyInited){
//				KeyBoardCtrl.I.addEventListener(KeyEvent.KEY_DOWN,onKeyDown);
//				KeyBoardCtrl.I.setFocus();
//			}

			GameRender.add(render);
			GameInputer.focus();

			_keyEnabled = true;

		}

		private function removeArrow():void{
			if(_arrow){
				try{
					_ui.removeChild(_arrow);
				}catch(e:Error){}
				_arrow = null;
			}
			_keyEnabled = false;
		}

		private function setArrow(name:String):void{
			_arrowSelected = name;
			var btn:DisplayObject = _ui.getChildByName(name);
			if(btn){
				_arrow.x = btn.x;
				_arrow.y = btn.y;
				SoundCtrl.I.sndSelect();
			}
		}

		private function addChar():void{
			var ct:Sprite = _ui.getChildByName('ct_char') as Sprite;
			if(ct){
				try{
					var fighter:FighterMain = GameCtrl.I.gameRunData.continueLoser;
					if(fighter){
						fighter.scale = 3;
						fighter.x = 0;
						fighter.y = 0;
						fighter.setVelocity(0,0);
						fighter.setVec2(0,0);
						fighter.renderSelf();
						fighter.lose();
						ct.addChild(fighter.mc);
						_char = fighter;
					}
				}catch(e:Error){
					trace(e);
				}

			}else{
				KyoTimeout.setFrameout(addChar,2);
			}
		}

		private function showContYes():void{
			_ui.addEventListener(Event.COMPLETE,showContYesComplete,false,0,true);
			_ui.gotoAndPlay("continue_yes");
			_keyEnabled = false;
			try{
				_char.idle();
			}catch(e:Error){
				trace(e);
			}
			removeArrow();
		}
		private function showContYesComplete(e:Event):void{
			_ui.removeEventListener(Event.COMPLETE,showContYesComplete);
			GameLogic.loseScoreByContinue();
			MainGame.I.goSelect();
		}

		private function showContNo():void{
			_ui.addEventListener(Event.COMPLETE,showContNoComplete,false,0,true);
			_ui.gotoAndPlay("continue_no");
			removeArrow();
		}
		private function showContNoComplete(e:Event):void{
			_ui.removeEventListener(Event.COMPLETE,showContNoComplete);
			showGameOver();
		}

		public function showGameOver():void{
			_ui.addEventListener(Event.COMPLETE,gameOverComplete,false,0,true);
			_ui.gotoAndPlay("gameover");
			SoundCtrl.I.playSwcSound(snd_gameover);
			SoundCtrl.I.BGM(null);

			addScore();
		}

		private function addScore():void{
			var ct:Sprite = _ui.getChildByName('ct_score') as Sprite;
			if(ct){
				var scoreTxt:BitmapFontText = new BitmapFontText(AssetManager.I.getFont('font1'));
				scoreTxt.text = 'SCORE '+GameData.I.score;
				scoreTxt.x = -scoreTxt.width/2;
				ct.addChild(scoreTxt);
			}else{
				KyoTimeout.setFrameout(addScore,1);
			}
		}

		private function gameOverComplete(e:Event):void{
			_ui.removeEventListener(Event.COMPLETE,gameOverComplete);

			GameEvent.dispatchEvent(GameEvent.GAME_OVER);

			initBtn('btn_back');
			initArrow('btn_back');
		}

		public function get display():DisplayObject
		{
			return _ui;
		}

		public function build():void
		{
		}

		public function afterBuild():void
		{
			GameEvent.dispatchEvent(GameEvent.GAME_OVER_CONTINUE);
		}

		public function destory(back:Function=null):void
		{
			GameRender.remove(render);

			if(_btns){
				for each(var b:DisplayObject in _btns){
					b.removeEventListener(MouseEvent.MOUSE_OVER, btnMouseHandler);
					b.removeEventListener(MouseEvent.CLICK, btnMouseHandler);
				}
				_btns = null;
			}

			if(_char){
				try{
					_char.mc.parent.removeChild(_char.mc);
				}catch(e:Error){}
				_char = null;
			}

			GameCtrl.I.gameRunData.continueLoser = null;
			GameCtrl.I.destory();

		}
	}
}
