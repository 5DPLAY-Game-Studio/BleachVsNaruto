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

package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.GameQuailty;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.StateCtrl;
	import net.play5d.game.bvn.ctrl.game_ctrls.TrainingCtrler;
	import net.play5d.game.bvn.ctrl.game_stage_loader.GameStageLoadCtrl;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.GameMode;
	import net.play5d.game.bvn.data.SelectVO;
	import net.play5d.game.bvn.debug.Debugger;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.bvn.test.GameInterfaceManager;
	import net.play5d.game.bvn.test.SwfLib;
	import net.play5d.game.bvn.utils.AssetLoader;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.KyoSharedObject;
	import net.play5d.kyo.display.ui.KyoSimpButton;
	import net.play5d.game.bvn.stage.LoadingState;

	[SWF(width="1000", height="600", frameRate="30", backgroundColor="#000000")]
	public class FighterTester extends Sprite
	{
		private var _mainGame:MainGame;
		private var _testUI:Sprite;
		private var _p1InputId:TextField;
		private var _p2InputId:TextField;
		private var _p1FzInputId:TextField;
		private var _p2FzInputId:TextField;
		private var _autoReceiveHp:TextField;
		private var _mapInputId:TextField;
		private var _fpsInput:TextField;
		private var _debugText:TextField;
		private var _gameSprite:Sprite;

//		[Embed(source="/assets/font/font1.png")]
//		private var _font1:Class;
//
//		[Embed(source="/assets/font/font1.xml", mimeType="application/octet-stream"))]
//		private var _font1XML:Class;

		private var _assetLoader:AssetLoader = new AssetLoader();

		public function FighterTester() {
//			trace("98098098098");

			GameStageLoadCtrl.IGORE_OLD_FIGHTER = true;

			if(stage){
				initlize();
			}else{
				addEventListener(Event.ADDED_TO_STAGE,initlize);
			}
		}

		private function initlize(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE,initlize);

//			ResUtils.I.createDisplayObject(ResUtils.I.title , 'stg_title');

			initMosouFighters();

			_gameSprite = new Sprite();
			addChild(_gameSprite);
			_gameSprite.scrollRect = new Rectangle(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);


			ResUtils.swfLib = new SwfLib();
			AssetManager.I.setAssetLoader(_assetLoader);
			GameInterface.instance = new GameInterfaceManager();

			trace("AssetManager.I.setAssetLoader");

			GameData.I.config.AI_level = 1;
			GameData.I.config.quality = GameQuailty.LOW;
			GameData.I.config.keyInputMode = 1;

			_mainGame = new MainGame();
			_mainGame.initlize(_gameSprite,stage,function ():void {
				_mainGame.goLanguage(function ():void {
					GameData.I.saveData();
					_mainGame.initalizeLoad(initBackHandler,initFailHandler);
				});

			},initFailHandler);

			StateCtrl.I.transEnabled = false;//跳过黑屏遮盖

			Debugger.initDebug(stage);
			Debugger.onErrorMsgCall = onDebugLog;
		}

		private function initBackHandler():void{
			buildTestUI();
		}

		private function initFailHandler(msg:String):void{

		}

		private function buildTestUI():void{
			_testUI = new Sprite();
			_testUI.x = 810;
			_testUI.graphics.beginFill(0x333333,1);
			_testUI.graphics.drawRect(-10,0,200,600);
			_testUI.graphics.endFill();
			addChild(_testUI);

			var yy:Number = 20;

			addLabel("P1",yy);
			yy += 40;

			addLabel("角色ID:",yy);
			_p1InputId = addInput("ichigo",yy,60);
			yy += 40;

			addLabel("辅助ID:",yy);
			_p1FzInputId = addInput("kon",yy,60);
			yy += 80;

			addLabel("P2",yy);
			yy += 40;

			addLabel("角色ID:",yy);
			_p2InputId = addInput("ichigo",yy,60);
			yy += 40;

			addLabel("辅助ID:",yy);
			_p2FzInputId = addInput("kon",yy,60);
			yy += 40;

			addLabel("地图ID:",yy);
			_mapInputId = addInput("xianshi",yy,60);
			yy += 60;

			addLabel("游戏FPS:",yy);
			_fpsInput = addInput(GameConfig.FPS_GAME.toString(),yy,60);
			yy += 60;

			addLabel("回血:",yy);
			_autoReceiveHp = addInput("1",yy,60);
			yy += 40;

			_debugText = addLabel("",yy,0);
			_debugText.width = 190;
			_debugText.height = 200;
			_debugText.textColor = 0xff0000;
			_debugText.multiline = true;

//			addButton("改变FPS",400,50,100,30,changeFPS);
			addButton("测试",500,50,100,50,testGame);

			var saveObj:Object = KyoSharedObject.load("fighter_test_config");
			if(saveObj && saveObj.p1){
				_p1InputId.text = saveObj.p1.id;
				_p2InputId.text = saveObj.p2.id;

				if(saveObj.p1.fz) _p1FzInputId.text = saveObj.p1.fz;
				if(saveObj.p2.fz) _p2FzInputId.text = saveObj.p2.fz;
				if(saveObj.map) _mapInputId.text = saveObj.map;
			}
		}

		private function addLabel(txt:String, y:Number = 0, x:Number = 0):TextField
		{
			var label:TextField = new TextField();
			var tf:TextFormat = new TextFormat();

			tf.size = 14;
			tf.color = 0xffffff;

			label.defaultTextFormat = tf;
			label.text = txt;
			label.x = x;
			label.y = y;
			label.mouseEnabled = false;
			_testUI.addChild(label);

			return label;
		}

		private function addInput(txt:String, y:Number = 0, x:Number = 0):TextField
		{
			var label:TextField = new TextField();
			var tf:TextFormat = new TextFormat();

			tf.size = 14;
			tf.color = 0x000000;

			label.defaultTextFormat = tf;
			label.text = txt;
			label.x = x;
			label.y = y;
			label.width = 100;
			label.height = 20;
			label.backgroundColor = 0xffffff;
			label.background = true;
			label.type = TextFieldType.INPUT;
			label.condenseWhite = true;
			_testUI.addChild(label);

			return label;
		}

		private function addButton(label:String, y:Number=0, x:Number=0, width:Number=100, height:Number=50, click:Function=null):Sprite
		{
			var btn:KyoSimpButton = new KyoSimpButton(label,width,height);
			btn.x = x;
			btn.y = y;

			if(click != null) btn.onClick(click);
			_testUI.addChild(btn);

			return btn;
		}

		private function onDebugLog(msg:String):void{
			_debugText.text = msg;
		}

		private function changeFPS(... params):void
		{
			var fps:int = int(_fpsInput.text);

			GameConfig.setGameFps(fps);
			stage.frameRate = fps;
		}

		/**
		 * 点击测试游戏
		 */
		private function testGame(... params):void
		{
			_debugText.text = "";

			KyoSharedObject.save('fighter_test_config',{
				p1:{id:_p1InputId.text,fz:_p1FzInputId.text},
				p2:{id:_p2InputId.text,fz:_p2FzInputId.text},

				map:_mapInputId.text
			});

			changeFPS();

			GameMode.currentMode = GameMode.TRAINING;
//			GameMode.currentMode = GameMode.SINGLE_VS_CPU;

			TrainingCtrler.RECOVER_HP = _autoReceiveHp.text != "0";

			GameData.I.p1Select = new SelectVO();
			GameData.I.p2Select = new SelectVO();
			GameData.I.p1Select.fighter1 = _p1InputId.text;
			GameData.I.p2Select.fighter1 = _p2InputId.text;
			GameData.I.p1Select.fuzhu = _p1FzInputId.text;
			GameData.I.p2Select.fuzhu = _p2FzInputId.text;
			GameData.I.selectMap = _mapInputId.text;

			loadGame();
		}

		private function loadGame():void
		{
			var ls:LoadingState = new LoadingState();
//			var ls:TestLoadingStage = new TestLoadingStage();
			MainGame.stageCtrl.goStage(ls,true);
		}

		private function initMosouFighters():void{

		}
	}
}
