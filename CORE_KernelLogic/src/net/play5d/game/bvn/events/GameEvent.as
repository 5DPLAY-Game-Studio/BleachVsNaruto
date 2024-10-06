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

package net.play5d.game.bvn.events
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class GameEvent extends Event
	{
		public static const SCORE_UPDATE:String = 'SCORE_UPDATE';

		public static const PAUSE_GAME:String = 'PAUSE_GAME';
		public static const PAUSE_GAME_MENU:String = 'PAUSE_GAME_MENU';
		public static const RESUME_GAME:String = 'RESUME_GAME';

		// 正在初始化加载
		public static const LOADING_GAME:String = 'LOADING_GAME';
		// 初始化加载完成
		public static const LOAD_GAME_START:String = 'LOAD_GAME_START';
		public static const LOAD_GAME_COMPLETE:String = 'LOAD_GAME_COMPLETE';


		public static const GAME_START:String = 'GAME_START';
		public static const ROUND_START:String = 'ROUND_START';
		public static const ROUND_END:String = 'ROUND_END';
		public static const GAME_END:String = 'GAME_END';

		public static const GAME_OVER:String = 'GAME_OVER';
		public static const GAME_OVER_CONTINUE:String = 'GAME_OVER_CONTINUE';
		public static const GAME_PASS_ALL:String = 'GAME_PASS_ALL';

		public static const SELECT_FIGHTER:String = 'SELECT_FIGHTER';
		public static const SELECT_MAP:String = 'SELECT_MAP';
		public static const SELECT_FIGHTER_STEP:String = 'SELECT_FIGHTER_STEP';
		public static const SELECT_FIGHTER_FINISH:String = 'SELECT_FIGHTER_FINISH';
		public static const SELECT_FIGHTER_INDEX:String = 'SELECT_FIGHTER_INDEX';


		public static const MONEY_UPDATE:String = 'MONEY_UPDATE';

		public static const LEVEL_UP:String = 'LEVEL_UP';
//		public static const SELECT_FIGHTER_INDEX_FINISH:String = 'SELECT_FIGHTER_INDEX_FINISH';


		public static const ENTER_MOSOU_STAGE:String = 'ENTER_MOSOU_STAGE';
		public static const ENTER_TEAM_STAGE:String = 'ENTER_TEAM_STAGE';
		public static const ENTER_SINGLE_STAGE:String = 'ENTER_SINGLE_STAGE';
		public static const ENTER_TRAIN_STAGE:String = 'ENTER_TRAIN_STAGE';

		public static const ENTER_STAGE:String = 'ENTER_STAGE';

		public static const MORE_GAMES:String = 'MORE_GAMES';

		public static const WINNER_SHOW:String = 'SHOW_WINNER';
		public static const WINNER_END:String = 'WINNER_END';

		////// MOSOU ====================

		public static const MOSOU_MAP:String = 'MOSOU_MAP';
		public static const MOSOU_BACK_MAP:String = 'MOSOU_BACK_MAP';
		public static const MOSOU_FIGHTER:String = 'MOSOU_FIGHTER';
		public static const MOSOU_FIGHTER_CLOSE:String = 'MOSOU_FIGHTER_CLOSE';

		public static const MOSOU_FIGHTER_UPDATE:String = 'MOSOU_FIGHTER_UPDATE';

		public static const MOSOU_LOADING_START:String = 'MOSOU_LOADING_START';
		public static const MOSOU_LOADING:String = 'MOSOU_LOADING';
		public static const MOSOU_LOADING_FINISH:String = 'MOSOU_LOADING_FINISH';

		public static const MOSOU_MISSION_START:String = 'MOSOU_MISSION_START';
		public static const MOSOU_MISSION_FINISH:String = 'MOSOU_MISSION_FINISH';

		////// FIGHT ====================

		public static const FIGHT_LOADING_START:String = 'FIGHT_LOADING_START';
		public static const FIGHT_LOADING:String = 'FIGHT_LOADING';
		public static const FIGHT_LOADING_FINISH:String = 'FIGHT_LOADING_FINISH';

		public static const FIGHT_START:String = 'FIGHT_START';

		////// CONFRIM ====================

		public static const CONFRIM_BACK_MENU:String = 'CONFRIM_BACK_MENU';

		public static const CONFRIM_MOSOU_NEXT_MISSION:String = 'CONFRIM_MOSOU_NEXT_MISSION';


		////////////////////////////////////////////////////////////////////////////////////

		public static const UI_CONFRIM:String = 'UI_CONFRIM';
		public static const UI_CONFRIM_CLOSE:String = 'UI_CONFRIM_CLOSE';
		public static const UI_ALERT:String = 'UI_ALERT';
		public static const UI_ALERT_CLOSE:String = 'UI_ALERT_CLOSE';

		public var param:*;

		private static var _dispatcher:EventDispatcher = new EventDispatcher();
		public function GameEvent(type:String , param:* = null , bubbles:Boolean = false , cancelable:Boolean = false)
		{
			super(type,bubbles,cancelable);
			this.param = param;
		}

		public static function dispatchEvent(type:String,param:* = null , bubbles:Boolean = false , cancelable:Boolean = false):void{
//			trace("dispatch GameEvent ::", type, param);
			_dispatcher.dispatchEvent(new GameEvent(type,param,bubbles,cancelable));
		}

		public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			_dispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference);
		}

		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void{
			_dispatcher.removeEventListener(type,listener,useCapture);
		}

	}
}
