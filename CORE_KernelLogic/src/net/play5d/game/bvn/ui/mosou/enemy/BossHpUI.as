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

package net.play5d.game.bvn.ui.mosou.enemy
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.fighter.FighterActionState;
	import net.play5d.game.bvn.fighter.FighterMain;

	public class BossHpUI
	{
		include '../../../../../../../../include/_INCLUDE_.as';

		private var _ui:Sprite;

		private var _bar:DisplayObject;
		private var _bar2:DisplayObject;
		private var _faceCt:Sprite;
		private var _fighter:FighterMain;

		private var _redBarMoving:Boolean;
		private var _redBarMoveDelay:int;
		private var _justHurtFly:Boolean;

		private var _hprate:Number = 1;

		private var _enabled:Boolean = true;

		public function BossHpUI(mc:Sprite)
		{
			_ui = mc;

			_bar = mc.getChildByName('bar');
			_bar2 = mc.getChildByName('redbar');
			_faceCt = mc.getChildByName('ct_face') as Sprite;
		}

		public function isEnabled():Boolean{
			return _ui.visible;
		}

		public function enabled(v:Boolean):void{
			_ui.visible = v;
		}

		public function setFighter(f:FighterMain):void{
			if(!f){
				_fighter = null;
				enabled(false);
				return;
			}
			_fighter = f;
			enabled(true);
			updateFace();
		}

		private function updateFace():void{
			if(!_faceCt || !_fighter) return;
			_faceCt.removeChildren();

			if(!_fighter || !_fighter.data) return;

			var faceImg:DisplayObject = AssetManager.I.getFighterFace(_fighter.data, new Point(37, 37));
			if(faceImg) _faceCt.addChild(faceImg);

		}

		public function render():void{
			if(!_enabled || !_fighter) return;

			var rate:Number = _fighter.hp / _fighter.hpMax;

			if(_redBarMoving && rate != _hprate){
				_bar2.scaleX = _hprate;
				_redBarMoving = false;
			}

			_hprate = rate;
			var diff:Number = _hprate - _bar.scaleX;
			var addRate:Number = diff < 0 ? 0.4 : 0.04;

			if(Math.abs(diff) < 0.01){
				_bar.scaleX = _hprate;
			}else{
				_bar.scaleX += diff * addRate;//0.4;
			}

			switch(_fighter.actionState){
				case FighterActionState.HURT_ING:
					_redBarMoveDelay = 100; //持续不减
					break;
				case FighterActionState.HURT_FLYING:
				case FighterActionState.HURT_DOWN:
					if(_redBarMoveDelay > 0){
						if(!_justHurtFly){
							_redBarMoveDelay = 1.5 * GameConfig.FPS_GAME;
							_justHurtFly = true;
						}else{
							if(_redBarMoveDelay > 0) _redBarMoveDelay--; //延时恢复
						}
					}
					break;
				default:
					_redBarMoveDelay = 0;
					_justHurtFly = false;
			}

			if(_redBarMoveDelay <= 0){
				var diff2:Number = _hprate - _bar2.scaleX;
				var addRate2:Number = diff2 < 0 ? 0.1 : 0.02;
				if(Math.abs(diff2) < 0.01){
					_bar2.scaleX = _hprate;
					_redBarMoving = false;
				}else{
					_bar2.scaleX += diff2 * addRate2;
					_redBarMoving = true;
				}
			}
		}

	}
}
