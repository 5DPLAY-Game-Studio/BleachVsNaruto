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

package net.play5d.game.bvn.ctrl
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.data.EffectModel;
	import net.play5d.game.bvn.data.EffectVO;
	import net.play5d.game.bvn.data.HitType;
	import net.play5d.game.bvn.debug.Debugger;
	import net.play5d.game.bvn.fighter.Assister;
	import net.play5d.game.bvn.fighter.FighterDefenseType;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.fighter.models.HitVO;
	import net.play5d.game.bvn.fighter.vos.FighterBuffVO;
	import net.play5d.game.bvn.interfaces.BaseGameSprite;
	import net.play5d.game.bvn.interfaces.IGameSprite;
	import net.play5d.game.bvn.stage.GameStage;
	import net.play5d.game.bvn.utils.EffectManager;
	import net.play5d.game.bvn.views.effects.BitmapFilterView;
	import net.play5d.game.bvn.views.effects.BlackBackView;
	import net.play5d.game.bvn.views.effects.BuffEffectView;
	import net.play5d.game.bvn.views.effects.EffectView;
	import net.play5d.game.bvn.views.effects.ShadowEffectView;
	import net.play5d.game.bvn.views.effects.ShineEffectView;
	import net.play5d.game.bvn.views.effects.SpecialEffectView;
	import net.play5d.kyo.utils.UUID;

	public class EffectCtrl
	{
		include "_INCLUDE_.as";

		public static var EFFECT_SMOOTHING:Boolean = true; //特效抗锯齿
		public static var SHADOW_ENABLED:Boolean = true; //残影开关
		public static var SHAKE_ENABLED:Boolean = true; //震动开关
		public static var BG_BULR_ENABLED:Boolean = true; //背景模糊开关

		public function EffectCtrl()
		{
		}

		private static var _i:EffectCtrl;
		public static function get I():EffectCtrl{
			_i ||= new EffectCtrl();
			return _i;
		}

		public var shineMaxCount:int = 3;

		private var _gameStage:GameStage;
		private var _effectLayer:Sprite;
		private var _manager:EffectManager;

		public var freezeEnabled:Boolean = true;
		public var bgBlurEnabled:Boolean = true;

		private const SHAKE_POW_MAX:int = 10;

		private var _freezeFrame:int = 0;
		private var _effects:Vector.<EffectView>;
		private var _justRenderAnimateTargets:Vector.<BaseGameSprite>;
		private var _justRenderTargets:Vector.<BaseGameSprite>;
		private var _shineEffects:Vector.<ShineEffectView>;
		private var _shadowEffects:Dictionary;
		private var _filterEffects:Vector.<BitmapFilterView> = new Vector.<BitmapFilterView>();
		private var _blackBack:BlackBackView;

		private var _shakeHoldX:int = 0;
		private var _shakeHoldY:int = 0;
		private var _shakePowX:int = 0;
		private var _shakePowY:int = 0;
		private var _shakeXDirect:int = 1;
		private var _shakeYDirect:int = 1;
		private var _shakeFrameX:int = 0;
		private var _shakeFrameY:int = 0;
		private var _shakeLoseX:int = 0;
		private var _shakeLoseY:int = 0;


		private var _renderAnimateGap:int = 0; //刷新动画间隔
		private var _renderAnimateFrame:int = 0;
		private var _renderAnimate:Boolean = true;

		private var _slowDownFrame:int;
		private var _blurFrame:int;
//		private var _blurHalfFrame:int;

		private var _replaceSkillFrame:int;
		private var _replaceSkillFrameHold:int;
		private var _replaceSkillPos:Point;
		private var _explodeSkillFrame:int;
		private var _explodeEffectPos:Point;

		private var _onFreezeOver:Vector.<Function> = null;

		private var _hitFocusTarget:IGameSprite;

		private var _frameEffectCount:Dictionary = new Dictionary();

		public function destory():void{
			if(_manager){
				_manager.destory();
				_manager = null;
			}

			if(_blackBack){
				_blackBack.destory();
				_blackBack = null;
			}

			_effects = null;
			_justRenderAnimateTargets = null;
			_justRenderTargets = null;
			_shineEffects = null;
			_shadowEffects = null;
			_gameStage = null;
			_effectLayer = null;

		}

		public function initlize(gameStage:GameStage , effectLayer:Sprite):void{
			_manager = new EffectManager();

			_gameStage = gameStage;
			_effectLayer = effectLayer;

			_effects = new Vector.<EffectView>();
			_justRenderAnimateTargets = new Vector.<BaseGameSprite>();
			_justRenderTargets = new Vector.<BaseGameSprite>();
			_shineEffects = new Vector.<ShineEffectView>();
			_shadowEffects = new Dictionary();

			_blackBack = new BlackBackView();
//			_backRootLayer.addChild(_blackBack);

			_renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / GameConfig.FPS_ANIMATE) - 1;

		}

		public function render():void{
			if(freezeEnabled) renderFreeze();

			//			if(_shineEffect) _shineEffect.render();

			renderSlowDown();
			renderShine();

			_frameEffectCount = new Dictionary();

			for(var i:int = 0 ; i < _effects.length ; i++){
				_effects[i].render();
			}

			if(isRenderAnimate()) renderAnimate();

			if(_replaceSkillFrameHold > 0) renderReplaceSkill();
			if(_explodeSkillFrame > 0) renderEnergyExplode();

			if(_justRenderTargets.length > 0){
				for each(var g:BaseGameSprite in _justRenderTargets){
					g.render();
					GameLogic.fixGameSpritePosition(g);
				}
			}

		}

		private function renderShine():void{
			var i:int,sv:ShineEffectView;
			for(i = 0 ; i < _shineEffects.length ; i++){
				sv = _shineEffects[i];
				sv.render();
			}
		}

		private function renderAnimate():void{
			var sv:ShineEffectView;
			var ev:EffectView;
			var s:ShadowEffectView;
			var f:BitmapFilterView;
			var i:int = 0;

			for(i = 0 ; i < _effects.length ; i++){
				ev = _effects[i];
				ev.renderAnimate();
			}

			for each(s in _shadowEffects){
				s.render();
			}

			if(_justRenderAnimateTargets.length > 0){
				var g:BaseGameSprite;
				for each(g in _justRenderAnimateTargets){
					g.renderAnimate();
				}
			}

			if(_blackBack) _blackBack.renderAnimate();

			renderShakeX();
			renderShakeY();

			renderRemoveEnemy();

			renderBgBlur();
		}

		private function isRenderAnimate():Boolean{
			if(_renderAnimateGap > 0){
				if(_renderAnimateFrame++ >= _renderAnimateGap){
					_renderAnimateFrame = 0;
					return true;
				}else{
					return false;
				}
			}
			return true;
		}

		private function renderFreeze():void{
			if(_freezeFrame > 0){
				_freezeFrame--;
				if(_freezeFrame <= 0){
					if(_onFreezeOver){
						for(var i:int ; i < _onFreezeOver.length ; i++){
							_onFreezeOver[i]();
						}
						_onFreezeOver = null;
					}

					if(_hitFocusTarget){
						_hitFocusTarget = null;
						GameCtrl.I.gameState.cameraResume();
					}

					GameCtrl.I.resume();
				}
			}
		}
		private function renderShakeX():void{
			var shakeX:Number = _shakeHoldX + _shakePowX;
			if(shakeX > 0){
				_gameStage.x = shakeX * _shakeXDirect;
				if(_shakePowX > 0 && _shakeFrameX % 2 == 0){
					_shakePowX -= _shakeLoseX;
					if(_shakePowX < _shakeLoseX){
						_shakePowX = 0;
						_gameStage.x = 0;
						_shakeFrameX = 0;
						_shakeLoseX = 0;
						return;
					}
				}
				_shakeFrameX++;
				_shakeXDirect *= -1;
			}
		}

		private function renderShakeY():void{
			var shakeY:Number = _shakeHoldY + _shakePowY;
			if(shakeY > 0){
				_gameStage.y = shakeY * _shakeYDirect;
				if(_shakePowY > 0 && _shakeFrameY % 2 == 0){
					_shakePowY -= _shakeLoseY;

					if(_shakePowY < _shakeLoseY){
						_shakePowY = 0;
						_gameStage.y = 0;
						_shakeFrameY = 0;
						_shakeLoseY = 0;
						return;
					}
				}

				_shakeYDirect *= -1;
				_shakeFrameY++;

			}
		}



		public function doHitEffect(hitvo:HitVO , hitRect:Rectangle , target:IGameSprite = null):void{

			if(Debugger.HIDE_HITEFFECT) return;

			var effect:EffectVO = _manager.getHitEffectVOByHitVO(hitvo, target);
			if(!effect) return;

			var ex:Number = hitRect.x + hitRect.width/2;
			var ey:Number = hitRect.y + hitRect.height/2;

			var direct:int = 1;
			if(effect.followDirect && hitvo.owner && hitvo.owner is IGameSprite){
				direct = (hitvo.owner as IGameSprite).direct;
			}

			if(hitvo.slowDown > 0){
				slowDown(1.5, hitvo.slowDown * 1000);
			}

			if(hitvo.focusTarget){
				_hitFocusTarget = target;
				GameCtrl.I.gameState.cameraFocusOne(target.getDisplay());
			}else{
				if(_hitFocusTarget && _hitFocusTarget == target) _hitFocusTarget = null;
			}

			doEffectVO(effect , ex ,ey , direct , target);
		}

		public function doDefenseEffect(hitvo:HitVO , hitRect:Rectangle , defenseType:int , target:IGameSprite = null):void{

//			var hitType:int = hitvo.hitType;
//
//			switch(defenseType){
//				case FighterDefenseType.SWOARD:
//					break;
//				case FighterDefenseType.HAND:
//					if(hitType == HitType.KAN) hitType = HitType.DA;
//					if(hitType == HitType.KAN_HEAVY) hitType = HitType.DA_HEAVY;
//					break;
//			}

			var effect:EffectVO = _manager.getDefenseEffectVOByHitVO(hitvo, defenseType, target);

			if(!effect) return;

			var ex:Number = hitRect.x + hitRect.width/2;
			var ey:Number = hitRect.y + hitRect.height/2;

			if(effect.shake){
				if(effect.shake.pow != undefined && effect.shake.pow != 0){
					//					var pow:Number = effect.shake.pow;
					//					var hitXY:Number = Math.abs(hitvo.hitx) + Math.abs(hitvo.hity);
					//					effect.shake.x = pow * (hitvo.hitx / hitXY);
					//					effect.shake.y = pow * (hitvo.hity / hitXY);
					effect.shake.x = 0;
					effect.shake.y = effect.shake.pow;
				}
			}

			var direct:int = 1;
			if(effect.followDirect && hitvo.owner && hitvo.owner is IGameSprite){
				direct = (hitvo.owner as IGameSprite).direct;
			}

			doEffectVO(effect , ex ,ey , direct , target);
		}

		public function doSteelHitEffect(hitvo:HitVO , hitRect:Rectangle , target:IGameSprite):void{

			if(Debugger.HIDE_HITEFFECT) return;

			var effect:EffectVO;

			switch(hitvo.hitType){
				case 0:
					return;
				case 1:
				case 6:
					effect = EffectModel.I.getEffect("steel_hit_kan");
					break;
				case 2:
				case 3:
					effect = EffectModel.I.getEffect("steel_hit_qdj");
					break;
				default:
					effect = EffectModel.I.getEffect("steel_hit_mfdj");
			}

			if(!effect) return;

			var ex:Number = hitRect.x + hitRect.width/2;
			var ey:Number = hitRect.y + hitRect.height/2;

			var direct:int = 1;
			if(effect.followDirect && hitvo.owner && hitvo.owner is IGameSprite){
				direct = (hitvo.owner as IGameSprite).direct;
			}

			doEffectVO(effect , ex ,ey , direct , target);
		}

		public function doEffectById(id:String , x:Number , y:Number , direct:int = 1  , target:IGameSprite = null, playSnd:Boolean = true):void{
			var effect:EffectVO = EffectModel.I.getEffect(id);
			if(effect) doEffectVO(effect , x , y , direct , target, playSnd);
		}

		public function assisterEffect(fz:Assister):void{
			var isNaruto:Boolean = fz.data.comicType == 1;
			if(isNaruto){
				doEffectById('fz_naruto',fz.x,fz.y);
			}else{
				doEffectById('fz_bleach',fz.x,fz.y);
			}
		}

		public function doEffectVO(effect:EffectVO , ex:Number , ey:Number , direct:int = 1 , target:IGameSprite = null, playSnd:Boolean = true):void{

			// 性能优化，每一帧只能同时存在N个同样的特效
			if(!_frameEffectCount[effect]) _frameEffectCount[effect] = 0;
			var v:int = _frameEffectCount[effect];
			if((_frameEffectCount[effect] = (++ v)) > 3) return;

			var effectView:EffectView = addEffect(effect , ex ,ey , direct, playSnd);

			if(effectView){
				_effectLayer.addChild(effectView.display);
			}

			if(effect.freeze > 0){
				freeze(effect.freeze);
			}

			if(effect.shake){
				var time:Number = effect.shake.time != undefined ? effect.shake.time : 0;
				var shakex:Number = effect.shake.x != undefined ? effect.shake.x : 0;
				var shakey:Number = effect.shake.y != undefined ? effect.shake.y : 0;

				shake(shakex , shakey , time);
			}

			if(effect.shine){
				var color:uint = effect.shine.color != undefined ? effect.shine.color : 0xffffff;
				var alpha:Number = effect.shine.alpha != undefined ? effect.shine.alpha : 0.2;
				shine(color , alpha);
			}

			if(effect.slowDown){
				var rate:Number = effect.slowDown.rate != undefined ? effect.slowDown.rate : 1.5;
				var slowDownTime:int = effect.slowDown.time != undefined ? effect.slowDown.time : 1000;
				slowDown(rate , slowDownTime);
			}

			if(target){
				effectView.setTarget(target);
			}

			if(effect.specialEffectId && target && target is FighterMain){
				doSpecialEffect(effect.specialEffectId , target as FighterMain);
			}
		}

		public function doSpecialEffect(id:String , target:FighterMain):void{
			var data:EffectVO = EffectModel.I.getEffect(id);
			var effect:SpecialEffectView = addEffect(data,target.x,target.y,target.direct) as SpecialEffectView;
			if(effect){
				effect.setTarget(target);
				_effectLayer.addChild(effect.display);
			}
		}

		public function doBuffEffect(id:String , target:FighterMain, buff:FighterBuffVO):void{
			var data:EffectVO = EffectModel.I.getEffect(id);
			var effect:BuffEffectView = addEffect(data,target.x,target.y,target.direct) as BuffEffectView;
			if(effect){
				effect.setTarget(target);
				effect.setBuff(buff);
				_effectLayer.addChild(effect.display);
			}
		}

		private function addEffect(data:EffectVO , x:Number , y:Number , direct:int = 1, playSound:Boolean = true):EffectView{
			var effectView:EffectView = _manager.getEffectView(data);
			if(!effectView) return null;
			effectView.start(x , y , direct, playSound);
			effectView.addRemoveBack(removeEffect);
			_effects.push(effectView);
			return effectView;
		}

		private function removeEffect(effect:EffectView):void{
			var id:int = _effects.indexOf(effect);
			if(id != -1) _effects.splice(id,1);
		}

		//		public function isFreezing():Boolean{
		//			return _freezeFrame > 0;
		//		}

		public function freeze(time:int):void{
			if(!freezeEnabled) return;
			if(time < 1) return;
			var frame:int = (time / 1000) * GameConfig.FPS_GAME;
			if(frame < 1) return;
			if(_freezeFrame > frame) return;
			_freezeFrame = frame;

			if(time > 300){
				if(GameCtrl.I.slowRate > 0){
					bgBlur(GameCtrl.I.slowRate * 4, 0, 500);
				}
			}

			GameCtrl.I.pause();
		}

		/**
		 * 只RENDER指定元素
		 * @param targets BaseGameSprite | Vector.<BaseGameSprite>
		 */
		private function justRender(target:BaseGameSprite):void{
			if(_justRenderTargets.indexOf(target) == -1){
				_justRenderTargets.push(target);
			}
		}

		/**
		 * 只RENDER指定元素 (动画帧率)
		 * @param animateTargets BaseGameSprite | Vector.<BaseGameSprite>
		 */
		private function justRenderAnimate(animateTarget:BaseGameSprite):void{
			if(_justRenderAnimateTargets.indexOf(animateTarget) == -1){
				_justRenderAnimateTargets.push(animateTarget);
			}
		}

		/**
		 * 取消RENDER指定元素
		 * @param targets
		 * @return 是否已全部取消
		 */
		private function cancelJustRender(target:BaseGameSprite):Boolean{
			var index:int = _justRenderTargets.indexOf(target);
			if(index != -1){
				_justRenderTargets.splice(index, 1);
			}
			return _justRenderTargets.length < 1;
		}

		/**
		 * 取消RENDER指定元素 (动画帧率)
		 * @param animateTargets
		 * @return 是否已全部取消
		 */
		private function cancelJustRenderAnimate(target:BaseGameSprite):Boolean{
			var index:int = _justRenderAnimateTargets.indexOf(target);
			if(index != -1){
				_justRenderAnimateTargets.splice(index, 1);
			}
			return _justRenderAnimateTargets.length < 1;
		}

		public function shine(color:uint = 0xffffff , alpha:Number = 0.2):void{

			if(GameConfig.FPS_SHINE_EFFECT == 0) return;

			if(_shineEffects.length > shineMaxCount){
				_shineEffects[0].removeSelf();
			}
			var sv:ShineEffectView = _manager.getShine();
			sv.init(color,alpha);
			sv.onRemove = removeShine;
			_shineEffects.push(sv);
			_gameStage.addChild(sv);
		}
		private function removeShine(s:ShineEffectView):void{
			var id:int = _shineEffects.indexOf(s);
			if(id != -1) _shineEffects.splice(id,1);
		}

		public function startShake(sx:Number , sy:Number):void{
			_shakeHoldX = sx;
			_shakeHoldY = sy;
		}

		public function endShake():void{
			_shakeHoldX = 0;
			_shakeHoldY = 0;
			_gameStage.x = 0;
			_gameStage.y = 0;
		}

		public function shake(powX:Number = 0 , powY:Number = 3 , time:int = 500):void{

			if(!SHAKE_ENABLED) return;

			if(isNaN(powX) || isNaN(powY)){
				return;
			}

			if(Math.abs(_shakePowX) > Math.abs(powX) || Math.abs(_shakePowY) > Math.abs(powY)) return;

			//			trace('shake' , powX , powY , time);

			if(powX != 0){
				if(_shakePowX == 0){
					_shakeXDirect = powX > 0 ? 1 : -1;
					_shakePowX = Math.abs(powX);
				}else{
					_shakePowX += Math.abs(powX) / 2;
				}

				if(_shakePowX > SHAKE_POW_MAX) _shakePowX = SHAKE_POW_MAX;
			}

			if(powY != 0){
				if(_shakePowY == 0){
					_shakeYDirect = powY > 0 ? 1 : -1;
					_shakePowY = Math.abs(powY);
				}else{
					_shakePowY += Math.abs(powY) / 2;
				}
				if(_shakePowY > SHAKE_POW_MAX) _shakePowY = SHAKE_POW_MAX;
			}

			if(time <= 0) time = 500;

			_shakeLoseX = Math.ceil(_shakePowX / (time / 1000 * GameConfig.FPS_ANIMATE));
			_shakeLoseY = Math.ceil(_shakePowY / (time / 1000 * GameConfig.FPS_ANIMATE));

			//			trace('shake2' , _shakePowX , _shakePowY , _shakeLoseX , _shakeLoseY , time);

			if(_shakeLoseX < 1) _shakeLoseX = 1;
			if(_shakeLoseY < 1) _shakeLoseY = 1;
		}

		public function startShadow(target:DisplayObject , r:int = 0 , g:int = 0 , b:int = 0):void{

			if(!SHADOW_ENABLED) return;

			var sv:ShadowEffectView = _shadowEffects[target];

			if(sv){
				sv.r = r;
				sv.g = g;
				sv.b = b;
				sv.stopShadow = false;
				return;
			}

			sv = new ShadowEffectView(target,r,g,b);
			sv.onRemove = removeShadow;
			sv.container = _effectLayer;

			_shadowEffects[target] = sv;
		}

		public function endShadow(target:DisplayObject):void{

			if(!SHADOW_ENABLED) return;

			if(!_shadowEffects) return;
			var sv:ShadowEffectView = _shadowEffects[target];
			if(sv) sv.stopShadow = true;
		}

		private function removeShadow(s:ShadowEffectView):void{
			if(!_shadowEffects) return;
			delete _shadowEffects[s.target];
		}

		//		public function dash(target:FighterMain):void{
		//			doEffectById('dash',target.x,target.y);
		//		}

		public function bisha(target:BaseGameSprite , isSuper:Boolean = false , face:DisplayObject = null):void{
			justRenderAnimate(target);
			GameCtrl.I.pause();
			GameCtrl.I.setRenderHit(false);
			_gameStage.addChildAt(_blackBack , 0);
			_blackBack.fadIn();
			if(face && target is FighterMain) showFace((target as FighterMain) , face);

			if(isSuper){
				GameCtrl.I.gameState.cameraFocusOne(target.getDisplay());
				doEffectById("bisha_super",target.x , target.y - 50);
			}else{
				doEffectById("bisha",target.x , target.y - 50);
			}

			_gameStage.getMap().setVisible(false);
			_gameStage.setVisibleByClass(BitmapFilterView, false);

		}
		public function endBisha(target:BaseGameSprite):void{
			if(cancelJustRenderAnimate(target)){
				GameCtrl.I.resume();
				GameCtrl.I.gameState.cameraResume();
				GameCtrl.I.setRenderHit(true);
				_blackBack.fadOut();

				_gameStage.getMap().setVisible(true);
				_gameStage.setVisibleByClass(BitmapFilterView, true);
			}
		}

		private function showFace(target:FighterMain , face:DisplayObject):void{
			var faceId:int = 1;
			var curTarget:IGameSprite = target.getCurrentTarget();
			if(curTarget){
				var display:DisplayObject = curTarget.getDisplay();
				if(display){
					faceId = target.getDisplay().x > display.x ? 2 : 1;
				}
			}
			//			if(target.team){
			//				if(target.team.id == 2) faceId = 2;
			//			}
			_blackBack.showBishaFace(faceId,face);
		}


		public function wanKai(target:FighterMain , face:DisplayObject = null):void{
			justRenderAnimate(target);
			GameCtrl.I.pause();
			GameCtrl.I.setRenderHit(false);
			_gameStage.addChildAt(_blackBack , 0);
			_blackBack.fadIn();
			if(face) showFace(target,face);

			GameCtrl.I.gameState.cameraFocusOne(target.getDisplay());
			doEffectById("bisha_super",target.x , target.y - 50);

			_gameStage.getMap().setVisible(false);
			_gameStage.setVisibleByClass(BitmapFilterView, false);

		}

		public function endWanKai(target:FighterMain):void{
			if(cancelJustRenderAnimate(target)){
				GameCtrl.I.resume();
				GameCtrl.I.gameState.cameraResume();
				_blackBack.fadOut();
				GameCtrl.I.setRenderHit(true);
				_gameStage.getMap().setVisible(true);
			}
		}

		public function jumpEffect(x:Number,y:Number):void{
			doEffectById('jump', x , y);
		}

		public function jumpAirEffect(x:Number,y:Number):void{
			doEffectById('jump_air', x , y);
		}

		public function touchFloorEffect(x:Number,y:Number):void{
			doEffectById('touch_floor', x , y);
		}

		/**
		 * 击落地效果
		 * @param type 0=弹，1=正常落地，2=重落地
		 */
		public function hitFloorEffect(type:int , x:Number,y:Number):void{
			switch(type){
				case 0:
					doEffectById('hit_floor', x , y);
					break;
				case 1:
					doEffectById('hit_floor_low', x , y);
					break;
				case 2:
					doEffectById('hit_floor_heavy', x , y);
					doEffectById('hit_floor_yan', x , y);
					break;
			}

		}

		/**
		 * 慢放效果
		 */
		public function slowDown(rate:Number , time:int = 1000):void{
			//			var fps:Number = GameConfig.FPS_GAME / rate;
			//			MainGame.I.setFPS(fps);

			if(GameCtrl.I.slowRate > rate) return;

			GameCtrl.I.slow(rate);
			bgBlur(rate * 2, 0, 250);
			_renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / (GameConfig.FPS_ANIMATE / rate)) - 1;
			if(time == 0){
				_slowDownFrame = 0;
			}else{
				//				_slowDownFrame = time / fps;
				_slowDownFrame = time / 1000 * GameConfig.FPS_GAME;
			}
		}

		public function bgBlur(blurX:Number, blurY:Number, time:int = 1000):void{
			if(!BG_BULR_ENABLED) return;
			if(!bgBlurEnabled) return;
			if(_gameStage.getMap().getSmoothing().x > blurX || _gameStage.getMap().getSmoothing().y > 0){
				return;
			}
			_gameStage.getMap().setSmoothing(blurX, blurY);
			_blurFrame = time / 1000 * GameConfig.FPS_ANIMATE;
//			if(time > 1000) _blurHalfFrame = _blurFrame / 2;
		}

		public function cancelBgBlur():void{
			_blurFrame = 0;
			_gameStage.getMap().setSmoothing(0, 0);
		}

		private function renderBgBlur():void{
			if(_blurFrame > 0){
//				if(_blurFrame < _blurHalfFrame){
//					var smoothing:Point = _gameStage.getMap().getSmoothing();
//					_gameStage.getMap().setSmoothing(smoothing.x / 2, smoothing.y / 2);
//				}
				if(--_blurFrame <= 0) cancelBgBlur();
			}
		}

		private function renderSlowDown():void{
			if(_slowDownFrame > 0){
				_slowDownFrame--;
				if(_slowDownFrame <= 0) slowDownResume();
			}
		}

		public function slowDownResume():void{
			//			MainGame.I.setFPS(GameConfig.FPS_GAME);
			GameCtrl.I.slowResume();
			_renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / GameConfig.FPS_ANIMATE) - 1;
			_slowDownFrame = 0;
		}

		public function BGEffect(id:String , hold:Number = -1):void{
			var data:EffectVO = EffectModel.I.getEffect(id);
			if(!data) return;

			var effect:EffectView = addEffect(data,0,0,1);
			if(hold != -1) effect.holdFrame = hold * GameConfig.FPS_ANIMATE;
			if(effect){
				effect.addRemoveBack(function():void{
					_gameStage.getMap().setVisible(true);
				});
				_gameStage.getMap().setVisible(false);
				_gameStage.addChildAt(effect.display , 0);
			}
		}

		public function setOnFreezeOver(v:Function):void{
			if(!_onFreezeOver){
				_onFreezeOver = new Vector.<Function>();
			}
			_onFreezeOver.push(v);
		}

		/**
		 * 替身术
		 * @param target
		 */
		public function replaceSkill(target:BaseGameSprite):void{
			//			_pauseRenderTarget = target;
			GameCtrl.I.pause();
			_gameStage.addChildAt(_blackBack,0);
			_gameStage.getMap().setVisible(false);

			doEffectById("replaceSp",target.x , target.y);
			_replaceSkillPos = new Point(target.x,target.y);

			_replaceSkillFrame = 0;
			_replaceSkillFrameHold = GameConfig.FPS_GAME;
		}
		private function endReplaceSkill():void{
			GameCtrl.I.resume();
			//			_pauseRenderTarget = null;
			_blackBack.fadOut();
			_gameStage.getMap().setVisible(true);
			_replaceSkillFrameHold = 0;
		}

		private function renderReplaceSkill():void{
			_replaceSkillFrame ++;
			if(_replaceSkillFrame == 1){
				doEffectById('replaceSp2' , _replaceSkillPos.x , _replaceSkillPos.y);
			}

			if(_replaceSkillFrame > _replaceSkillFrameHold){
				endReplaceSkill();
			}
		}

		/**
		 * 灵压爆发
		 */
		public function energyExplode(target:BaseGameSprite):void{
			//			_pauseRenderTarget = target;
			GameCtrl.I.pause();
			_gameStage.addChildAt(_blackBack,0);
			_gameStage.getMap().setVisible(false);

			doEffectById("explodeSp",target.x , target.y);
			_explodeEffectPos = new Point(target.x , target.y);

			_explodeSkillFrame = 0.7 * GameConfig.FPS_GAME;
		}
		private function endEnergyExplode():void{
			doEffectById("explodeSp2",_explodeEffectPos.x , _explodeEffectPos.y);

			GameCtrl.I.resume();
			//			_pauseRenderTarget = null;
			_blackBack.fadOut();
			_gameStage.getMap().setVisible(true);
			_explodeSkillFrame = 0;
		}
		private function renderEnergyExplode():void{
			_explodeSkillFrame--;
			if(_explodeSkillFrame <= 0){
				endEnergyExplode();
			}
		}

		public function ghostStep(target:BaseGameSprite):void{
			justRender(target);
			justRenderAnimate(target);
			GameCtrl.I.pause();
			_gameStage.addChildAt(_blackBack,0);
			_blackBack.fadIn();
			_gameStage.getMap().setVisible(false);
			SoundCtrl.I.playSwcSound(snd_ghost_jump);
			//			slowDown(1.1,0);
		}
		public function endGhostStep(target:BaseGameSprite):void{
			var cancel1:Boolean = cancelJustRender(target);
			var cancel2:Boolean = cancelJustRenderAnimate(target);
			if(cancel1 && cancel2){
				GameCtrl.I.resume();
				_blackBack.fadOut();
				_gameStage.getMap().setVisible(true);
			}

			//			slowDown(1.1,200);
		}

		/**
		 * 持续滤镜效果
		 */
		public function startFilter(target:BaseGameSprite, filter:BitmapFilter, filterOffset:Point = null):void{
			var bv:BitmapFilterView;
			for each(var i:BitmapFilterView in _filterEffects){
				if(i.target == target){
					bv = i;
					break;
				}
			}

			if(!bv){
				bv = new BitmapFilterView(target, filter, filterOffset);
				GameCtrl.I.addGameSprite(0, bv, 0);
				_filterEffects.push(bv);
			}else{
				bv.update(filter, filterOffset);
			}

		}

		public function endFilter(target:BaseGameSprite):void{
			for(var i:int = 0 ; i < _filterEffects.length ; i++){
				var bv:BitmapFilterView = _filterEffects[i];
				if(bv.target == target){
					GameCtrl.I.removeGameSprite(bv, true);
					_filterEffects.splice(i, 1);
					break;
				}
			}
		}

		private var _removeEnemieMap:Object = {};

		private function renderRemoveEnemy():void{
			var removes:Array = [];

			for(var i:String in _removeEnemieMap){
				var o:Object = _removeEnemieMap[i];
				var f:FighterMain = o.fighter;
				var callback:Function = o.callback;

				if(!f){
					delete _removeEnemieMap[i];
					continue;
				}

				if(f.getDisplay().alpha > 0){
					f.getDisplay().alpha -= 0.05;
				}else{
					if(callback != null) callback();
					o.fighter = null;
					o.callback = null;
					delete _removeEnemieMap[i];
				}
			}

		}

		/**
		 * 敌人出生效果
		 */
		public function enemyBirthEffect(f:FighterMain):void{
			f.getDisplay().alpha = 1;
			if(f.data.comicType == 0){
				EffectCtrl.I.doEffectById('fz_bleach',f.x , f.y , f.direct, null, false);
			}else{
				EffectCtrl.I.doEffectById('fz_naruto',f.x , f.y , f.direct, null, false);
			}
		}

		/**
		 * 移除敌人效果
		 */
		public function removeEnemyEffect(f:FighterMain, callback:Function = null):void{
			_removeEnemieMap[UUID.create()] = { fighter:f, callback: callback };
		}




		//P 当前，N前提条件
		private var wayPoints:Array = [

			{P: "p1", N: null},

			{P: "p2", N: "p1"},
			{P: "p2_1", N: "p2"},
			{P: "p2_2", N: "p2"},


			{P: "p3", N: ["p2_1", "p2_2"]},
			{P: "p3_1", N: "p3"},
			{P: "p3_1_1", N: "p3_1"},
			{P: "p3_1_2", N: "p3_1_1"},

			{P: "p3_2", N: "p3"},
			{P: "p3_2_4", N: "p3_2"}, {P: "p3_2_3", N: "p3_2_4"},
			{P: "p3_2_1", N: "p3_2"}, {P: "p3_2_2", N: "p3_2_1"},
			{P: "p3_2_5", N: "p3_2_4"},
			{P: "p3_2_6", N: ["p3_2_5", "p3_2_4"]},

			{P: "p4", N: ["p3_1_2", "p3_2_5"]},

			{P: "p5", N: "p3_2_6"},
		];



	}
}
