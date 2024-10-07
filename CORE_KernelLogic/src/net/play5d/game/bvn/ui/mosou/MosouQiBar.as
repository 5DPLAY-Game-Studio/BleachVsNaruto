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

package net.play5d.game.bvn.ui.mosou
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.fighter.Assister;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.kyo.utils.KyoUtils;

	public class MosouQiBar
	{
		private var _ui:Sprite;
		private var _fighter:FighterMain;

		private var _qiRate:Number = 0;

		private var _orgPose:Point;
		private var _tweenSpd:Number = 0.5;
		private var _moveFin:Boolean = true;
		private var _moveType:int = 0;

		private var _isFadIn:Boolean;

		private var _isRenderAnimate:Boolean;

		private var _faceBp:Bitmap;

		private var _bar1:DisplayObject;
		private var _bar2:DisplayObject;
		private var _bar3:DisplayObject;

		private var _maxBar:MovieClip;

		private var _maxPlaying:Boolean;

		private var _process:Number = 0;

		public function MosouQiBar(ui:Sprite)
		{
			_ui = ui;

			_bar1 = _ui.getChildByName('bar1');
			_bar2 = _ui.getChildByName('bar2');
			_bar3 = _ui.getChildByName('bar3');

			_maxBar = _ui.getChildByName('maxmc') as MovieClip;
			_maxBar.gotoAndStop(1);
			_maxBar.visible = false;
		}

		public function setFighter(fighter:FighterMain):void{
			_fighter = fighter;
		}

		public function render():void{
			_qiRate = _fighter.qi / 100;
			if(_qiRate > 3) _qiRate = 3;

			var per:Number = _process;
			var diff:Number = _qiRate - per;
			if(Math.abs(diff) < 0.01){
				per = _qiRate;
			}else{
				per  += (diff * 0.4);
			}
			if(per < 0.0001) per = 0.0001;
			setProcess(per);
		}

		//0-3
		public function setProcess(v:Number):void{
			_process = v;
			_maxBar.visible = v >= 3;
			if(_maxBar.visible){
				_bar1.visible = _bar2.visible = _bar3.visible = false;
				if(!_maxPlaying){
					_maxBar.gotoAndPlay(2);
					_maxPlaying = true;
				}
			}else{
				if(_maxPlaying){
					_maxBar.gotoAndPlay(1);
					_maxPlaying = false;
				}
				_bar1.visible = v > 0;
				_bar2.visible = v > 1;
				_bar3.visible = v > 2;
			}

			if(v > 2){
				_bar1.scaleX = _bar2.scaleX = 1;
				_bar3.scaleX = v-2;
			}else if(v > 1){
				_bar1.scaleX = 1;
				_bar2.scaleX = v-1;
			}else{
				_bar1.scaleX = v;
			}
		}

	}
}
