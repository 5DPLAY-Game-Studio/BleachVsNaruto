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

package net.play5d.game.bvn.fighter.ctrler.ai
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.play5d.game.bvn.fighter.FighterAction;
	import net.play5d.game.bvn.fighter.FighterActionState;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.fighter.models.HitVO;
	import net.play5d.game.bvn.interfaces.IGameSprite;

	public class FighterAILogicBase
	{
		protected var AILevel:int;
		protected var _fighter:FighterMain;
		protected var _fighterAction:FighterAction;
		protected var _target:IGameSprite;
		protected var _targetFighter:FighterMain;
		protected var _isConting:Boolean;
		private var _breakActCache:Object = {};
		private var _hitDownActCache:Object = {};

		//连招优先级
		private var _contOrder:Array = [];

		public function FighterAILogicBase(AILevel:int , fighter:FighterMain)
		{
			this.AILevel = AILevel;
			_fighter = fighter;
		}

		public function destory():void{
			_fighter = null;
			_fighterAction = null;
			_target = null;
			_targetFighter = null;
			_breakActCache = null;
			_hitDownActCache = null;
		}

		protected function addContOrder(id:String , order:int):void{
			var index:int = _contOrder.indexOf(id);
			if(index != -1){
				_contOrder[index].order = order;
			}else{
				_contOrder.push({id:id,order:order});
			}
		}

//		public final function updateAI(target:IGameSprite):void{
//			_target = target;
//			_targetFighter = _target as FighterMain;
//
//			updateConting();
//
//			_fighterAction ||= _fighter.getCtrler().getMcCtrl().getAction();
//
//			updateActionAI();
//
//			updateContOrder();
//
//		}

		protected function updateConting():void{
			_isConting = _fighter.actionState == FighterActionState.ATTACK_ING || _fighter.actionState == FighterActionState.SKILL_ING ||
				_fighter.actionState == FighterActionState.BISHA_ING || _fighter.actionState == FighterActionState.BISHA_SUPER_ING;
		}

		public function render():void{
			_target = _fighter.getCurrentTarget();
			_targetFighter = _target as FighterMain;
			updateConting();
			_fighterAction ||= _fighter.getCtrler().getMcCtrl().getAction();
			updateActionAI();
			updateContOrder();
		}

//		public function onDoAction():void{
//			updateConting();
//		}

		/**
		 * 处理优先级
		 */
		private function updateContOrder():void{
			if(_contOrder.length < 1) return;

			_contOrder.sortOn('order',Array.DESCENDING);

//			trace('updateContOrder',JSON.stringify(_contOrder));

			for(var i:int = 1 ; i < _contOrder.length ; i++){
				var id:String = _contOrder[i].id;
				this[id] = false;
			}

			_contOrder = [];
		}

		protected function updateActionAI():void{

		}

		protected function getAIByFighterState(stateObj:Object):Boolean{
			var defult:Array = stateObj.defult;
			var arr:Array;
			var targetState:int = _targetFighter ? _targetFighter.actionState : -1;
			arr = stateObj && stateObj[targetState] ? stateObj[targetState] : defult;
			return getAIResult(arr[0],arr[1],arr[2],arr[3],arr[4],arr[5]);
		}

		protected function getAIResult(a1:Number , a2:Number , a3:Number , a4:Number , a5:Number , a6:Number):Boolean{

			var rand:Number = Math.random() * 10;

			switch(AILevel){
				case 0:
				case 1:
					return rand < a1;
				case 2:
					return rand < a2;
				case 3:
					return rand < a3;
				case 4:
					return rand < a4;
				case 5:
					return rand < a5;
				default:
					return rand < a6;
			}
		}

		protected function getTargetDistance(target:IGameSprite):Point{
			var xDis:Number = Math.abs(target.x - _fighter.x);
			var yDis:Number = Math.abs(target.y - _fighter.y);
			return new Point(xDis,yDis);
		}

		public final function targetInDistance(target:IGameSprite , disX:Number , disY:Number):Boolean{
			var dis:Point = getTargetDistance(target);
			return dis.x <= disX && dis.y <= disY;
		}

		public final function targetInRange(id:String):Boolean{
			var area:Rectangle = _target.getBodyArea();
			if(!area) return false;
			var hr:Rectangle = _fighter.getHitRange(id);
			if(!hr) return false;
			return area.intersection(hr).isEmpty() == false;
		}

		protected function mergeRateObject(oldObj:Object , newObj:Object):void{
			for(var i:String in newObj){
				if(oldObj[i] == undefined){
					oldObj[i] = newObj[i];
				}else{
					for(var j:int ; j < newObj[i].length ; j++){
						if(oldObj[i][j] < newObj[i][j]){
							oldObj[i][j] = newObj[i][j];
						}
					}
				}
			}
		}

		protected function isBreakAct(hitId:String):Boolean{

			if(_breakActCache[hitId] != undefined) return _breakActCache[hitId];

			var breakHitVOs:Vector.<HitVO> = _fighter.getCtrler().hitModel.getHitVOLike(hitId);
			for each(var i:HitVO in breakHitVOs){
				if(i.isBreakDef){
					_breakActCache[hitId] = true;
					return true;
				}
			}
			_breakActCache[hitId] = false;
			return false;
		}

		protected function isHitDownAct(hitId:String):Boolean{
			if(_hitDownActCache[hitId] != undefined) return _hitDownActCache[hitId];

			var breakHitVOs:Vector.<HitVO> = _fighter.getCtrler().hitModel.getHitVOLike(hitId);
			for each(var i:HitVO in breakHitVOs){
				if(i.hurtType == 1){
					_breakActCache[hitId] = true;
					return true;
				}
			}
			_breakActCache[hitId] = false;
			return false;
		}

		protected function targetCanBeHit():Boolean{
			if(!_target) return false;
			if(_targetFighter){
				return _targetFighter.isAllowBeHit;
			}
			return _target.getBodyArea() != null;
		}

	}
}
