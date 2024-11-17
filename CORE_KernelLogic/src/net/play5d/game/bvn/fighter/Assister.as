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

package net.play5d.game.bvn.fighter
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.ctrl.GameLogic;
	import net.play5d.game.bvn.data.FighterVO;
	import net.play5d.game.bvn.fighter.ctrler.AssisiterCtrler;
	import net.play5d.game.bvn.fighter.models.FighterHitModel;
	import net.play5d.game.bvn.fighter.models.HitVO;
	import net.play5d.game.bvn.fighter.utils.McAreaCacher;
	import net.play5d.game.bvn.interfaces.BaseGameSprite;
	import net.play5d.game.bvn.interfaces.IGameSprite;
	import net.play5d.kyo.utils.KyoUtils;

	public class Assister extends BaseGameSprite
	{
		include "_INCLUDE_OVERRIDE_.as";

		public var onRemove:Function;
		public var data:FighterVO;
		public var isAttacking:Boolean;

		private var _hitAreaCache:McAreaCacher = new McAreaCacher("hit");
		private var _hitCheckAreaCache:McAreaCacher = new McAreaCacher("hit_check");
		private var _rectCache:Object = {};
		private var _mcOrgPoint:Point;
		private var _owner:IGameSprite;
		private var _isRenderMainAnimate:Boolean = true;
		private var _ctrler:AssisiterCtrler;

		public function get name():String{
			return _mainMc.name;
		}

		public function getOwner():IGameSprite{
			return _owner;
		}
		public function setOwner(v:IGameSprite):void{
			_owner = v;
		}

		public function getCtrler():AssisiterCtrler{
			return _ctrler;
		}

		public function Assister(mainmc:MovieClip)
		{
			super(mainmc);

			// TODO
//			isAlive = false;

			if(_mainMc.setAssistCtrler){
				_ctrler = new AssisiterCtrler();
				_ctrler.initAssister(this);
				_mainMc.setAssistCtrler(_ctrler);
			}else{
				throw new Error(GetLang('debug.error.data.assister.init_fail', 'setAssistCtrler()'));
			}
		}

		public function goFight():void{

			isAttacking = true;
//			isAlive = true;  //暂时辅助不能被打，被打时放开
			gotoAndPlay(2);
		}

//		public function moveToTarget(offsetX:Number = NaN , offsetY:Number = NaN):void{
//			var fighter:FighterMain = _owner is FighterMain ? _owner as FighterMain : null;
//			if(!fighter) return;
//
//			var target:IGameSprite = fighter.getCurrentTarget();
//			if(!target) return;
//
//			//			var targetDisplay:DisplayObject = target.getDisplay();
//			//			if(!targetDisplay) return;
//
//			if(!isNaN(offsetX)) _x = target.x + (offsetX * direct);
//			if(!isNaN(offsetY)) _y = target.y + offsetY;
//		}

		public override function destory(dispose:Boolean = true):void{
			if(!dispose) return;

			if(_hitAreaCache){
				_hitAreaCache.destory();
				_hitAreaCache = null;
			}
			if(_hitCheckAreaCache){
				_hitCheckAreaCache.destory();
				_hitCheckAreaCache = null;
			}
			if(_ctrler){
				_ctrler.destory();
				_ctrler = null;
			}
			data = null;
			_rectCache = null;
			_mcOrgPoint = null;
			_owner = null;
			super.destory(dispose);
		}

		public function stop():void{
			_isRenderMainAnimate = false;
		}

		public function gotoAndPlay(frame:Object):void{
			_mainMc.gotoAndStop(frame);
			_isRenderMainAnimate = true;
		}

		public function gotoAndStop(frame:Object):void{
			_mainMc.gotoAndStop(frame);
			_isRenderMainAnimate = false;
		}

		public function getTargets():Vector.<IGameSprite>{
			if(! _owner is FighterMain) return null;
			return (_owner as FighterMain).getTargets();
		}

		public function removeSelf():void{
			isAttacking = false;
			isAlive = false;
			if(onRemove != null) onRemove(this);
		}

		public override function render():void
		{
			super.render();
			_ctrler.render();
		}

		public override function renderAnimate():void{
			if(!_isRenderMainAnimate) return;
			super.renderAnimate();
			renderChildren();
			mc.nextFrame();
			findHitArea();
			if(mc.currentFrame == mc.totalFrames-1){
				_ctrler.finish(true);
			}
		}

		/**
		 * 播放子MC
		 */
		private function renderChildren():void{
			for(var i:int ; i < _mainMc.numChildren ; i++){
				var mc:MovieClip = _mainMc.getChildAt(i) as MovieClip;
				if(mc){
					var mcName:String = mc.name;
					if(mcName == "bdmn" || mcName.indexOf("atm") != -1) continue;

					var totalFrames:int = mc.totalFrames;
					if(totalFrames < 2) continue;

					switch(mc.currentFrameLabel){
						case 'stop':
							break;
						default:
							if(mc.currentFrame == totalFrames){
								mc.gotoAndStop(1);
							}else{
								mc.nextFrame();
							}
					}

				}
			}
		}

		public function getHitCheckRect(name:String):Rectangle{
			var area:Rectangle = getCheckHitRect(name);
			if(area == null) return null;
			return getCurrentRect(area , "hit_check");
		}

		public function getCheckHitRect(name:String):Rectangle{
			var d:DisplayObject = _mainMc.getChildByName(name);
			if(!d) return null;

			var cacheObj:Object = _hitCheckAreaCache.getAreaByDisplay(d);

			if(cacheObj) return cacheObj.area;

			var rect:Rectangle = d.getBounds(_mainMc);

			_hitCheckAreaCache.cacheAreaByDisplay(d,rect);

			return rect;
		}

		private function getCurrentRect(rect:Rectangle , cacheId:String = null):Rectangle{
			var newRect:Rectangle;

			if(cacheId == null){
				newRect = new Rectangle();
			}else{
				if(_rectCache[cacheId]){
					newRect = _rectCache[cacheId];
				}else{
					newRect = new Rectangle();
					_rectCache[cacheId] = newRect;
				}
			}

			newRect.x = rect.x * direct + _x;
			if(direct < 0) newRect.x -= rect.width;

			newRect.y = rect.y + _y;
			newRect.width = rect.width;
			newRect.height = rect.height;
			return newRect;
		}

		private function findHitArea():void{
			if(!_hitAreaCache) return;

			//判断是否已定义过
			if(_hitAreaCache.areaFrameDefined(_mainMc.currentFrame)) return;

			//取帧缓存
			var area:Object = _hitAreaCache.getAreaByFrame(_mainMc.currentFrame);
			if(area != null) return; //已有，跳出

			var hitModel:FighterHitModel = _ctrler.hitModel;

			var areaRects:Array = [];

			for(var i:int ; i < _mainMc.numChildren ; i++){
				var d:DisplayObject = _mainMc.getChildAt(i);
				var hitvo:HitVO = hitModel.getHitVO(d.name);

				if(d == null || hitvo == null) continue;

				//取缓存
				var areaCached:Object = _hitAreaCache.getAreaByDisplay(d);
				if(areaCached == null){
					//无缓存，创建并写入缓存
					var areaRect:Rectangle = d.getBounds(_mainMc);
					var areaCacheObj:Object = _hitAreaCache.cacheAreaByDisplay(d , areaRect , {hitVO:hitvo});
					areaRects.push(areaCacheObj);
				}else{
					areaRects.push(areaCached);
				}
			}

			if(areaRects.length < 1) areaRects = null;

			//写入帧缓存
			_hitAreaCache.cacheAreaByFrame(_mainMc.currentFrame , areaRects);
		}

		public override function hit(hitvo:HitVO, target:IGameSprite):void{
			if(target && _owner && _owner is FighterMain){
				(_owner as FighterMain).addQi(hitvo.power * GameConfig.QI_ADD_HIT_ASSISTER_RATE);
				GameLogic.hitTarget(hitvo,_owner , target);
			}
		}

		/**
		 * 当前攻击的攻击数据 return [FighterHitVO];
		 */
		public override function getCurrentHits():Array{
			if(!_hitAreaCache) return null;

			var areas:Array = _hitAreaCache.getAreaByFrame(_mainMc.currentFrame) as Array;

			//			trace('get cache' , _mainMc.currentFrame , areas);

			if(!areas || areas.length < 1) return null;

			var hits:Array = [];

			var i:int;
			var dobj:Object;
			var hitvo:HitVO;
			var area:Rectangle , area2:Rectangle;

			for(i ; i < areas.length ; i++){
				dobj = areas[i];
				var dname:String = dobj.name;
				hitvo = dobj.hitVO;

				if(!hitvo) continue;

				area = dobj.area;
				//缓存取出后，需要对重新计算位置
				hitvo.currentArea = getCurrentRect(area , 'hit'+i);
				hits.push(hitvo);
			}

			return hits;
		}

		public function getCurrentTarget():IGameSprite{
			if(_owner is FighterMain) return (_owner as FighterMain).getCurrentTarget();
			return null;
		}

	}
}
