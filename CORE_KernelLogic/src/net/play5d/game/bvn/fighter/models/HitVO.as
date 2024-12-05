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

package net.play5d.game.bvn.fighter.models
{
	import flash.geom.Rectangle;

	import net.play5d.game.bvn.fighter.Bullet;
	import net.play5d.game.bvn.fighter.FighterAttacker;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.interfaces.IInstanceVO;
import net.play5d.kyo.utils.KyoUtils;

	public class HitVO implements IInstanceVO {
		include '../../../../../../../include/_INCLUDE_.as';
		include '../../../../../../../include/Clone.as';

		public var id:String;

		/**
		 * 所有者
		 */
		public var owner:IGameSprite;

		public var power:Number = 0; //攻击力

		public var powerAdd:Number = 0; //叠加攻击力

		public var powerRate:Number = 1; //攻击力比例

		/**
		 *  攻击类型：1-砍,2-拳,3拳(重),4-魔法,5-魔法(重),6-砍(重),7-火,8-冰,9-电,10-石化
		 */
		public var hitType:int = 1;
		/**
		 *  是否破防
		 */
		public var isBreakDef:Boolean = false;

		/**
		 * 打击后，敌人受力X变化
		 */
		public var hitx:Number = 0;
		/**
		 * 打击后，敌人受力Y变化
		 */
		public var hity:Number = 0;

		/**
		 *  敌人硬直时间（毫秒）
		 */
		public var hurtTime:Number = 300;
		/**
		 *  被打击的类型 0=被打，1=击飞
		 */
		public var hurtType:int = 0;

		/**
		 * 被打击后的慢放时间
		 */
		public var slowDown:Number = 0;

		/**
		 * 是否进行方向判断，true时，当攻击方与防御方的方向同向时，防御无效
		 */
		public var checkDirect:Boolean = true;

		/**
		 *  当前的攻击范围
		 */
		public var currentArea:Rectangle;
//		private var _hitAreaCache:Object = {}; //攻击范围缓存

		/**
		 *  攻击到对方时，设置对方为焦点
		 */
		public var focusTarget:Boolean;

		private var _cloneKey:Array = ['id','owner','power','powerAdd','powerRate','hitType','isBreakDef','hitx','hity','hurtTime','hurtType','currentArea','checkDirect','slowDown','focusTarget'];

		public function HitVO(o:Object = null)
		{
			if(o) KyoUtils.setValueByObject(this,o);
			if(hitType == 1){
				if(hurtTime < 100) hurtTime = 100;
			}
		}

//		public function clone():HitVO{
//			var hv:HitVO = new HitVO();
//			KyoUtils.cloneValue(hv,this,_cloneKey);
//			return hv;
//		}

		public function isBisha():Boolean{
			if(id == null) return false;
			return id.indexOf('bs') != -1 ||
					id.indexOf('sbs') != -1 ||
					id.indexOf('cbs') != -1 ||
					id.indexOf('kbs') != -1;

		}

		public function isSkill():Boolean{
			if(id == null) return false;
			return id.indexOf('tz') != -1 ||
				id.indexOf('kj') != -1 ||
				id.indexOf('zh') != -1 ||
				id.indexOf('sh') != -1;
		}

		public function isCatch():Boolean{
			return hitType == 11 && isBreakDef;
		}

		/**
		 * 伤害值
		 */
		public function getDamage():int{
			var powAdd:Number = power * (powerAdd / 100);
			return (power + powAdd) * powerRate;
		}

		public function isWeakHit():Boolean{
			if(!owner) return false;

			if(( hitType == 1 || hitType == 2 || hitType == 4 ) && hurtType == 0){
				if(owner is FighterMain){
					return checkEnemyFighter(owner as FighterMain);
				}
				if(owner is Bullet){
					return checkEnemyFighter( (owner as Bullet).owner as FighterMain );
				}
				if(owner is FighterAttacker){
					return checkEnemyFighter( (owner as FighterAttacker).getOwner() as FighterMain )
				}
			}
			return false;
		}

		private function checkEnemyFighter(f:FighterMain):Boolean{
			return f && f.mosouEnemyData && !f.mosouEnemyData.isBoss;
		}

	}
}
