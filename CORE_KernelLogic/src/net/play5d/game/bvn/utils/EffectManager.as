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

package net.play5d.game.bvn.utils
{
	import flash.display.MovieClip;
	import flash.utils.Dictionary;

	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.data.EffectModel;
	import net.play5d.game.bvn.data.EffectVO;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.fighter.models.HitVO;
	import net.play5d.game.bvn.interfaces.IGameSprite;
	import net.play5d.game.bvn.views.effects.BuffEffectView;
	import net.play5d.game.bvn.views.effects.EffectView;
	import net.play5d.game.bvn.views.effects.ShineEffectView;
	import net.play5d.game.bvn.views.effects.SpecialEffectView;
	import net.play5d.game.bvn.views.effects.SteelHitEffect;

	public class EffectManager
	{
		include "_INCLUDE_.as";

		private var _viewCache:Dictionary = new Dictionary();
		private var _hitCache:Dictionary = new Dictionary();
		private var _defCache:Dictionary = new Dictionary();
		private var _shineCache:Vector.<ShineEffectView> = new Vector.<ShineEffectView>();
		public function EffectManager()
		{
		}

		public function destory():void{
			for each(var i:Vector.<EffectView> in _viewCache){
				for each(var j:EffectView in i){
					j.destory();
				}
			}
			for each(var k:ShineEffectView in _shineCache){
				k.destory();
			}

			_viewCache = null;
			_hitCache = null;
			_defCache = null;
			_shineCache = null;
		}

		public function getHitEffectVOByHitVO(hitvo:HitVO, target:IGameSprite = null):EffectVO{
			var cacheVO:EffectCacheVO = _hitCache[hitvo];

			// 增加小兵的打击效果判断
			var isMosouEnemy:Boolean = false;
			if(target && target is FighterMain){
				var f:FighterMain = (target as FighterMain)
				isMosouEnemy = f.isMosouEnemy();
			}

			if(cacheVO){
				if(isMosouEnemy && cacheVO.mosouEnemy) return cacheVO.mosouEnemy;
				if(!isMosouEnemy && cacheVO.normal) return cacheVO.normal;
			}


			var effect:EffectVO = isMosouEnemy ? EffectModel.I.getMosouEnemyHitEffect(hitvo.hitType) : EffectModel.I.getHitEffect(hitvo.hitType);
			if(!effect){
				_hitCache[hitvo] = null;
				return null;
			}

			effect = effect.clone();

			if(effect.shake){
				if(effect.shake.pow != undefined && effect.shake.pow != 0){
					effect.shake.y = effect.shake.pow;
				}
				if(effect.shake.x == 0 && effect.shake.y == 0) effect.shake.x = 3;

			}

			cacheVO = new EffectCacheVO();
			if(isMosouEnemy){
				cacheVO.mosouEnemy = effect;
			}else{
				cacheVO.normal = effect;
			}

			_hitCache[hitvo] = cacheVO;


			return effect;
		}

		public function getDefenseEffectVOByHitVO(hitvo:HitVO, defenseType:int, target:IGameSprite = null):EffectVO{
			var cacheVO:EffectCacheVO = _defCache[hitvo];

			// 增加小兵的打击效果判断
			var isMosouEnemy:Boolean = false;
			if(target && target is FighterMain){
				var f:FighterMain = (target as FighterMain)
				isMosouEnemy = f.isMosouEnemy();
			}

			if(cacheVO){
				if(isMosouEnemy && cacheVO.mosouEnemy) return cacheVO.mosouEnemy;
				if(!isMosouEnemy && cacheVO.normal) return cacheVO.normal;
			}


			var effect:EffectVO = isMosouEnemy ? EffectModel.I.getMosouEnemyDefenseEffect(hitvo.hitType, defenseType) : EffectModel.I.getDefenseEffect(hitvo.hitType, defenseType);
			if(!effect){
				_defCache[hitvo] = null;
				return null;
			}

			effect = effect.clone();

			cacheVO = new EffectCacheVO();
			if(isMosouEnemy){
				cacheVO.mosouEnemy = effect;
			}else{
				cacheVO.normal = effect;
			}

			_defCache[hitvo] = cacheVO;

			return effect;
		}



		public function getEffectView(data:EffectVO):EffectView{
			var evs:Vector.<EffectView> = _viewCache[data];
			if(evs){
				var l:int = evs.length;
				for(var i:int ; i < l ; i++){
					if(!evs[i].isActive){
						return evs[i];
					}
				}
			}else{
				evs = new Vector.<EffectView>();
				_viewCache[data] = evs;
			}

			var effectView:EffectView;

			if(data.isSpecial){
				effectView = new SpecialEffectView(data);
			}else if(data.isBuff){
				effectView = new BuffEffectView(data);
			}else if(data.isSteelHit){
				effectView = new SteelHitEffect(data);
			}else{
				effectView = new EffectView(data);
			}

			evs.push(effectView);

			return effectView;
		}

		public function getShine():ShineEffectView{
			var l:int = _shineCache.length;
			for(var i:int ; i < l ; i++){
				if(!_shineCache[i].isActive) return _shineCache[i];
			}

			var se:ShineEffectView = new ShineEffectView();
			_shineCache.push(se);

			return se;
		}

	}
}
