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
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.setTimeout;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.GameRender;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.input.GameInputer;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.ui.MenuBtnGroup;
	import net.play5d.game.bvn.ui.UIUtils;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.shapes.Box;
	import net.play5d.kyo.stage.IStage;

	public class MenuStage extends Sprite implements IStage
	{
		private var _ui:stg_title;
		private var _btnGroup:MenuBtnGroup;
		private var _versionTxt:TextField;

		public static var MenuPosition:Point = new Point(470, 100);
		public static var MenuGap:Point = new Point(-40, 5);

		public function MenuStage()
		{
		}

		public function get display():DisplayObject
		{
			return _ui;
		}

		public function build():void
		{
			_ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.title , ResUtils.TITLE);
			_ui.gotoAndStop(1);
			GameInterface.instance.initTitleUI(_ui);
			GameInputer.enabled = false;

			SoundCtrl.I.BGM(AssetManager.I.getSound('op'));
		}

		public function afterBuild():void
		{
			_ui.gotoAndPlay(2);

			setTimeout(function():void{
				_ui.buttonMode = true;
				_ui.useHandCursor = true;
				if(GameConfig.TOUCH_MODE){
					_ui.addEventListener(TouchEvent.TOUCH_TAP,showBtns);
				}else{
					_ui.addEventListener(MouseEvent.CLICK,showBtns);
				}

				GameRender.add(render);
				GameInputer.focus();
				GameInputer.enabled = true;

			},500);

			_versionTxt = new TextField();
			UIUtils.formatText(_versionTxt , {color:0,size:18});

			_versionTxt.text = MainGame.VERSION_LABEL;
			_versionTxt.autoSize = TextFieldAutoSize.LEFT;
			_versionTxt.x = GameConfig.GAME_SIZE.x - _versionTxt.width - 15;
			_versionTxt.y = GameConfig.GAME_SIZE.y - _versionTxt.height - 10;
			_ui.addChild(_versionTxt);

			var b:Box = new Box(_versionTxt.width + 10, _versionTxt.height + 10, 0xffffff, 0);
			b.x = _versionTxt.x - 5;
			b.y = _versionTxt.y - 5;
			b.buttonMode = true;
			b.addEventListener(MouseEvent.CLICK, versionClickHandler);
			_ui.addChild(b);

//			if(GameData.I.isFristRun && MainGame.UPDATE_INFO){
//				GameData.I.isFristRun = false;
//				GameUI.alert('UPDATE',MainGame.UPDATE_INFO);
//			}
		}

		private function versionClickHandler(e:MouseEvent):void{
			if(MainGame.UPDATE_INFO) GameUI.alert('UPDATE', MainGame.UPDATE_INFO);
		}

		private function render():void{
			if(GameInputer.anyKey(1)){
				showBtns();
			}
		}

		private function showBtns(...params):void{
			_ui.removeEventListener(MouseEvent.CLICK, showBtns);
			_ui.removeEventListener(TouchEvent.TOUCH_TAP, showBtns);

			GameRender.remove(render);

			_ui.buttonMode = false;
			_ui.useHandCursor = false;

			_ui.gotoAndPlay("menu");

			SoundCtrl.I.playSwcSound(snd_menu5);

			_btnGroup = new MenuBtnGroup();
			_btnGroup.enabled = false;
			_btnGroup.x = MenuPosition.x;
			_btnGroup.y = MenuPosition.y;
			_btnGroup.setGap(MenuGap.x, MenuGap.y);
			var ct:Sprite = _ui.getChildByName('btnct') as Sprite;
			if(ct){
				ct.addChild(_btnGroup);
			}else{
				_ui.addChild(_btnGroup);
			}

			_btnGroup.build();
			_btnGroup.fadIn(0.2,0.04);
			setTimeout(function():void{
				_btnGroup.enabled = true;
			},400);
		}

//		private function btnCom(e:Event):void{
//			_ui.removeEventListener(Event.COMPLETE,btnCom);
//
//		}

		public function destory(back:Function=null):void
		{
			if(_btnGroup){
				try{
					_btnGroup.parent.removeChild(_btnGroup);
				}catch(e:Error){}
				_btnGroup.destory();
				_btnGroup = null;
			}
			GameInputer.enabled = false;
		}
	}
}
