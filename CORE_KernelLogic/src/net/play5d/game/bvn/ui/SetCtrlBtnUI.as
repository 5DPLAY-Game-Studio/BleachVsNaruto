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

package net.play5d.game.bvn.ui
{
	import com.greensock.TweenLite;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.KeyConfigVO;
	import net.play5d.game.bvn.events.SetBtnEvent;
	import net.play5d.game.bvn.interfaces.IInnerSetUI;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.input.KyoKeyCode;

	public class SetCtrlBtnUI extends EventDispatcher implements IInnerSetUI
	{
		include "_INCLUDE_.as";

		public var ui:keyset_mc;

		private var _keyMappings:Array;
		private var _keyMap:Object;
		private var _keyConfig:KeyConfigVO;
		private var _btnGroup:SetBtnGroup;
		private var _dialog:SetBtnDialog;
		private var _tmpKeyConfig:KeyConfigVO;

		private var _setKeyIndex:int;

		public function SetCtrlBtnUI()
		{

			ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.setting , 'keyset_mc');

			_btnGroup = new SetBtnGroup();
			_btnGroup.startY = 30;
			_btnGroup.initKeySet();
			_btnGroup.addEventListener(SetBtnEvent.SELECT,onBtnSelect);

			ui.addChild(_btnGroup);

			_dialog = new SetBtnDialog();
			ui.addChild(_dialog.ui);

			initKeyMapping();
		}

		public function destory():void{
			 if(_btnGroup){
				 try{
					 ui.removeChild(_btnGroup);
				 }catch(e:Error){}
				 _btnGroup.removeEventListener(SetBtnEvent.SELECT,onBtnSelect);
				 _btnGroup.destory();
				 _btnGroup = null;
			 }
		}

		public function getUI():DisplayObject{
			return ui;
		}

		public function setKey(v:KeyConfigVO):void{
			_keyConfig = v;
			_tmpKeyConfig = v.clone();
			updateKeyMapping();
		}

		private function updateKeyMapping():void{
			_keyMap['up'].setKey(_tmpKeyConfig.up);
			_keyMap['down'].setKey(_tmpKeyConfig.down);
			_keyMap['left'].setKey(_tmpKeyConfig.left);
			_keyMap['right'].setKey(_tmpKeyConfig.right);
			_keyMap['attack'].setKey(_tmpKeyConfig.attack);
			_keyMap['jump'].setKey(_tmpKeyConfig.jump);
			_keyMap['dash'].setKey(_tmpKeyConfig.dash);
			_keyMap['skill'].setKey(_tmpKeyConfig.skill);
			_keyMap['superKill'].setKey(_tmpKeyConfig.superKill);
			_keyMap['beckons'].setKey(_tmpKeyConfig.beckons);
		}

		private function initKeyMapping():void{
			var kmc:MovieClip = ui.keysmc;
			var keys:Array = [
				{id:'up',name:'UP',cn:'上'},
				{id:'down',name:'DOWN',cn:'下'},
				{id:'left',name:'LEFT',cn:'左'},
				{id:'right',name:'RIGHT',cn:'右'},
				{id:'attack',name:'ATTACK',cn:'攻击'},
				{id:'jump',name:'JUMP',cn:'跳跃'},
				{id:'dash',name:'DASH',cn:'冲刺'},
				{id:'skill',name:'SKILL',cn:'技能'},
				{id:'superKill',name:'SUPER SKILL',cn:'大招'},
				{id:'beckons',name:'SPECIAL',cn:'特殊'}
			];

			_keyMappings = [];
			_keyMap = {};

			for(var i:int ; i < keys.length ; i++){
				var kui:Sprite = kmc.getChildByName('k'+i) as Sprite;
				var o:Object = keys[i];
				if(!kui){
					trace('mc[k'+i+']不存在！');
					continue;
				}
				var km:KeyMapping = new KeyMapping(kui,o.id,o.name,o.cn);
				_keyMappings.push(km);
				_keyMap[km.keyId] = km;
			}

		}

		private function onBtnSelect(e:SetBtnEvent):void{
			switch(e.selectedLabel){
				case 'SET ALL':

					MainGame.I.stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
					MainGame.I.stage.focus = MainGame.I.stage;

					_setKeyIndex = -1;
					_btnGroup.keyEnable = false;
					setNextKey();
					break;
				case 'SET DEFAULT':
					GameData.I.config.setDefaultConfig(_tmpKeyConfig);
					updateKeyMapping();
					break;
				case 'APPLY':
					_keyConfig.readSaveObj(_tmpKeyConfig.toSaveObj());
					dispatchEvent(new SetBtnEvent(SetBtnEvent.APPLY_SET));
					break;
				case 'CANCEL':
					dispatchEvent(new SetBtnEvent(SetBtnEvent.CANCEL_SET));
					break;
			}
		}

		private function setNextKey():void{
			_setKeyIndex++;
			var km:KeyMapping = _keyMappings[_setKeyIndex];
			if(km){
				_dialog.show(km.name,km.cn);
			}else{
				MainGame.I.stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
				_btnGroup.keyEnable = true;
			}
		}

		private function onKeyDown(e:KeyboardEvent):void{
			if(!_dialog.isShow) return;

			var km:KeyMapping = _keyMappings[_setKeyIndex];
			if(!km) return;

			var keyId:String = km.keyId;
			if(!keyId) return;

			var keyName:String = KyoKeyCode.code2name(e.keyCode);
			if(!keyName) return;

			_tmpKeyConfig[keyId] = e.keyCode;
			km.setKey(e.keyCode , keyName);

			_dialog.hide();

			setNextKey();

		}

		public function fadIn():void{
			var duration:Number = 0.3;
			ui.y = GameConfig.GAME_SIZE.y;
			TweenLite.to(ui,duration,{y:0,onComplete:function():void{
				_btnGroup.keyEnable = true;
			}});
			_btnGroup.setArrowIndex(0);
			ui.visible = true;
		}

		public function fadOut():void{
			var duration:Number = 0.3;
			_btnGroup.keyEnable = false;
			TweenLite.to(ui,duration,{y:GameConfig.GAME_SIZE.y,onComplete:function():void{
				ui.visible = false;
			}});
		}

	}
}
