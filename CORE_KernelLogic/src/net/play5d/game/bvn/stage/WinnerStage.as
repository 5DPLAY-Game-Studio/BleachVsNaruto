/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package net.play5d.game.bvn.stage
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;

	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.GameRender;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.ctrl.StateCtrl;
	import net.play5d.game.bvn.data.FighterModel;
	import net.play5d.game.bvn.data.FighterVO;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.MessionModel;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.input.GameInputType;
	import net.play5d.game.bvn.input.GameInputer;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.ui.UIUtils;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.bitmap.BitmapFontText;
	import net.play5d.kyo.stage.IStage1;

	public class WinnerStage implements IStage1
	{
		private var _ui:MovieClip;
		private var _scoreText:BitmapFontText;
		private var _winnerFaces:Array;
		private var _winSay:String;
		private var _bgmDelay:int;

		public function WinnerStage()
		{
		}

		public function get display():DisplayObject
		{
			return _ui;
		}

		private function buildData():void{

			var winner:FighterVO = FighterModel.I.getFighter(GameData.I.winnerId);
			var winFighters:Vector.<FighterVO> = new Vector.<FighterVO>();

			var fs:Array = GameData.I.p1Select.getSelectFighters();
			for(var i:int ; i < fs.length ; i++){
				winFighters.push( FighterModel.I.getFighter(fs[i]) );
			}

			_winSay = winner.getRandSay();

			if(winFighters.length == 1){
				_winnerFaces = [AssetManager.I.getFighterFaceWin(winFighters[0])];
			}else{
				_winnerFaces = [];
				var index:int = winFighters.indexOf(winner);
				_winnerFaces.push( AssetManager.I.getFighterFaceWin(winFighters[index]) );
				winFighters.splice(index,1);
				for(var j:int ; j < winFighters.length ; j++){
					_winnerFaces.push( AssetManager.I.getFighterFaceWin(winFighters[j]) );
				}
			}
		}

		private function initText():void{
			var txtmc:MovieClip = _ui.getChildByName('txtmc') as MovieClip;
			if(txtmc){
				txtmc.addEventListener(Event.COMPLETE, txtCompleteHandler);
			}

			function txtCompleteHandler(e:Event):void{

				txtmc.removeEventListener(Event.COMPLETE, txtCompleteHandler);

				var txt:TextField = new TextField();
				txt.x = 33;
				txt.width = 548;
				txt.height = 66;
				txt.multiline = true;
				txt.wordWrap = true;
				txt.mouseEnabled = false;

				var tf:TextFormat = new TextFormat();
				tf.font = "黑体";
				tf.color = 0;
				tf.size = 18;
				tf.align = TextFormatAlign.CENTER;
				tf.leading = 5;
				txt.defaultTextFormat = tf;

				setText(txt, _winSay);
				txtmc.addChild(txt);

//				testFighterSays(txt);

			}
		}

		private function testFighterSays(txt:TextField):void{

			var winner:FighterVO = FighterModel.I.getFighter(GameData.I.winnerId);

			var sayIndex:int = 0;
			var says:Array = [];

			for each(var k:String in winner.says){
				says.push({ id:winner.id, say:k });
			}

			for each(var i:FighterVO in FighterModel.I.getAllFighters()){
				for each(var j:String in i.says){
					says.push({ id:i.id, say:j });
				}
			}

			MainGame.I.stage.addEventListener(KeyboardEvent.KEY_DOWN , keyHandler);

			function keyHandler(e:KeyboardEvent):void{
				switch(e.keyCode){
					case Keyboard.LEFT:
						sayIndex--;
						if(sayIndex < 0) sayIndex = 0;
						break;
					case Keyboard.RIGHT:
						sayIndex++;
						if(sayIndex > says.length-1) sayIndex = says.length-1;
						break;
					default:
						return;
				}
				setText(txt, says[sayIndex].say);
				trace(says[sayIndex].id);
			}

		}

		private function setText(txt:TextField , str:String):void{
			txt.text = str.split('|').join("\n");
			txt.height = txt.textHeight + 5;
			txt.y = 10 + (90 - txt.height) / 2;
		}



		public function build():void
		{

			buildData();

			_scoreText = new BitmapFontText(AssetManager.I.getFont('font1'));
			_scoreText.text = 'SCORE '+ GameData.I.score;
			_scoreText.x = -_scoreText.width/2;
			_scoreText.y = -_scoreText.height/2;

			_ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.loading , ResUtils.WINNER);
			_ui.addEventListener(Event.COMPLETE, onUIPlayComplete);

			_ui.scoremc.addChild(_scoreText);

			if(_winnerFaces[0]){
				_ui.f0.addChildAt(_winnerFaces[0], 0);
			}else{
				_ui.f0.visible = false;
			}

			if(_winnerFaces[1]){
				_ui.f1.addChildAt(_winnerFaces[1], 0);
			}else{
				_ui.f1.visible = false;
			}

			if(_winnerFaces[2]){
				_ui.f2.addChildAt(_winnerFaces[2], 0);
			}else{
				_ui.f2.visible = false;
			}

			SoundCtrl.I.BGM(null);
			SoundCtrl.I.playAssetSound('win');

			GameInputer.enabled = false;

			initText();

			_bgmDelay = setTimeout(function():void{
				SoundCtrl.I.BGM(AssetManager.I.getSound('winloop'));
			} , 6500);

		}

		private function onUIPlayComplete(e:Event):void{
			_ui.removeEventListener(Event.COMPLETE, onUIPlayComplete);
			GameEvent.dispatchEvent(GameEvent.WINNER_SHOW);


			var btns:MovieClip = _ui.getChildByName('btns') as MovieClip;
			btns.btn_more.addEventListener(MouseEvent.CLICK , btnHandler);
			btns.btn_cont.addEventListener(MouseEvent.CLICK , btnHandler);
			btns.btn_exit.addEventListener(MouseEvent.CLICK , btnHandler);

			btns.btn_more.addEventListener(MouseEvent.MOUSE_OVER , btnHandler);
			btns.btn_cont.addEventListener(MouseEvent.MOUSE_OVER , btnHandler);
			btns.btn_exit.addEventListener(MouseEvent.MOUSE_OVER , btnHandler);



			GameRender.add(render);
			GameInputer.enabled = true;
		}

		private function render():void{
			if(GameInputer.select(GameInputType.MENU)){
				goNext();
			}
		}

		private function btnHandler(e:MouseEvent):void{

			if(e.type == MouseEvent.MOUSE_OVER){
				SoundCtrl.I.sndSelect();
				return;
			}

			var btns:MovieClip = _ui.getChildByName('btns') as MovieClip;
			switch(e.currentTarget){
				case btns.btn_more:
					GameEvent.dispatchEvent(GameEvent.MORE_GAMES);
					GameInterface.instance.moreGames();
					break;
				case btns.btn_cont:
					goNext();
					break;
				case btns.btn_exit:
					GameUI.confrim('BACK TITLE?',"返回到主菜单？",MainGame.I.goMenu);
					GameEvent.dispatchEvent(GameEvent.CONFRIM_BACK_MENU);
					break;
			}

			SoundCtrl.I.sndConfrim();
		}

		private function goNext():void{
			GameInputer.enabled = false;

			StateCtrl.I.transIn(function():void{
				MessionModel.I.messionComplete();
				MainGame.I.loadGame();
			});
		}

		public function afterBuild():void
		{
		}

		public function destory(back:Function=null):void
		{
			GameRender.remove(render);
			GameInputer.enabled = false;
			clearTimeout(_bgmDelay);
			GameEvent.dispatchEvent(GameEvent.WINNER_END);
			if(_ui){
				_ui.gotoAndStop("destory");
				_ui = null;
			}
		}
	}
}
