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

package net.play5d.game.bvn.ctrl.mosou_ctrls
{
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.ui.mosou.enemy.EnemyHpFollowUI;

	public class MosouEnemyBarCtrl
	{
		private var _barMap:Dictionary = new Dictionary();
		private var _gameLayer:Sprite;

		public function MosouEnemyBarCtrl()
		{
		}

		private function initalize():void{
		}

		public function destory():void{
			_barMap = null;
		}

		public function updateEnemyBar(f:FighterMain):void{
			if(f.mosouEnemyData.isBoss) return;

			if(_barMap[f]){
				(_barMap[f] as EnemyHpFollowUI).active();
				return;
			}

			_gameLayer ||= GameCtrl.I.gameState.gameLayer;

			var bar:EnemyHpFollowUI = new EnemyHpFollowUI(f);
			_barMap[f] = bar;

			_gameLayer.addChild(bar.getUI());
		}

		public function render():void{
			if(!_barMap) return;

			for each(var i:FighterMain in _barMap){
				var b:EnemyHpFollowUI = _barMap[i];
				if(!b.render()){
					try{
						_gameLayer.removeChild(b.getUI());
					}catch(e:Error){
						trace('remove bar error');
					}
					b.destory();
					delete _barMap[i];
				}
			}
		}

		public function renderAnimate():void{

		}

	}
}
