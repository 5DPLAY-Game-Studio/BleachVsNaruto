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

package net.play5d.game.bvn.ctrl.game_ctrls
{
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.ctrl.StateCtrl;
	import net.play5d.game.bvn.fighter.FighterActionState;
	import net.play5d.game.bvn.fighter.FighterMain;

	/**
	 * 练习模式控制类
	 */
	public class TrainingCtrler
	{
		include "_INCLUDE_.as";

		public static var RECOVER_HP:Boolean = true;
		public static var RECOVER_QI:Boolean = true;
		public static var RECOVER_FZ_QI:Boolean = true;

		private var _trainAddDelay:Object;

		public function TrainingCtrler()
		{
		}

		private var _fighters:Array;
		public function initlize(fighters:Array):void{
			_fighters = fighters;

			for each(var i:FighterMain in _fighters){
				i.qi = i.qiMax;
			}

			_trainAddDelay = {};

			StateCtrl.I.transOut(null,true);
		}

		public function destory():void{
			_fighters = null;
			_trainAddDelay = null;
		}

		public function render():void{
			for each(var i:FighterMain in _fighters){
				var hpid:String = i.id+"_hp";
				if(i.actionState == FighterActionState.HURT_ING || i.actionState == FighterActionState.HURT_FLYING){
					_trainAddDelay[hpid] = 1 * GameConfig.FPS_GAME;
				}else{
					if(_trainAddDelay[hpid] != undefined && _trainAddDelay[hpid] > 0){
						_trainAddDelay[hpid]--;
						if(_trainAddDelay[hpid] <= 0 && RECOVER_HP) i.hp = i.hpMax;
					}else{
						if(i.hp == i.hpMax){
							_trainAddDelay[hpid] = 0;
						}else{
							_trainAddDelay[hpid] = 2 * GameConfig.FPS_GAME;
						}
					}
				}

				var qiid:String = i.id+"_qi";
				if(_trainAddDelay[qiid] != undefined && _trainAddDelay[qiid] > 0){
					_trainAddDelay[qiid]--;
					if(_trainAddDelay[qiid] <= 0 && RECOVER_QI) i.qi = i.qiMax;
				}else{
					if(i.qi == i.qiMax){
						_trainAddDelay[qiid] = 0;
					}else{
						_trainAddDelay[qiid] = 2 * GameConfig.FPS_GAME;
					}
				}

				var fzid:String = i.id+"fz";
				if(_trainAddDelay[fzid] != undefined && _trainAddDelay[fzid] > 0){
					_trainAddDelay[fzid]--;
					if(_trainAddDelay[fzid] <= 0 && RECOVER_FZ_QI) i.fzqi = i.fzqiMax;
				}else{
					if(i.fzqi == i.fzqiMax){
						_trainAddDelay[fzid] = 0;
					}else{
						_trainAddDelay[fzid] = 2 * GameConfig.FPS_GAME;
					}
				}

			}
		}


	}
}
