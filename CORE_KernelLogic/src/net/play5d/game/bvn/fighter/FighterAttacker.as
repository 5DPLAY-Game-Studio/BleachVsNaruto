package net.play5d.game.bvn.fighter
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.ctrl.GameLogic;
	import net.play5d.game.bvn.fighter.ctrler.FighterAttackerCtrler;
	import net.play5d.game.bvn.fighter.models.FighterHitModel;
	import net.play5d.game.bvn.fighter.models.HitVO;
	import net.play5d.game.bvn.fighter.utils.McAreaCacher;
	import net.play5d.game.bvn.interfaces.BaseGameSprite;
	import net.play5d.game.bvn.interfaces.IGameSprite;
	
	public class FighterAttacker extends BaseGameSprite
	{
		public var onRemove:Function;
		public var isAttacking:Boolean;
		
		private var _ctrler:FighterAttackerCtrler;
		private var _owner:IGameSprite;
		
		public var moveToTargetX:Boolean;
		public var moveToTargetY:Boolean;
		
		public var followTargetX:Boolean;
		public var followTargetY:Boolean;
		
		public var rangeX:Point;
		public var rangeY:Point;
		
		private var _startX:Number = 0;
		private var _startY:Number = 0;
		
//		public var x:Number = 0;
//		public var y:Number = 0;
		
		private var _hitAreaCache:McAreaCacher = new McAreaCacher("hit");
		private var _hitCheckAreaCache:McAreaCacher = new McAreaCacher("hit_check");
		private var _rectCache:Object = {};
		private var _mcOrgPoint:Point;
		
//		private var _offset:Point = new Point();
		
		private var _isRenderMainAnimate:Boolean = true;
		
		public function getOwner():IGameSprite{
			return _owner;
		}
		
		public function get name():String{
			return _mainMc.name;
		}
		
		public function getCtrler():FighterAttackerCtrler{
			return _ctrler;
		}
		
		public function FighterAttacker(mainmc:MovieClip , params:Object = null)
		{
			super(mainmc);
			
			_mcOrgPoint = new Point(mainmc.x , mainmc.y);
			
			_startX = _mcOrgPoint.x;
			_startY = _mcOrgPoint.y;
			
			_x = _startX;
			_y = _startY;
			
			_ctrler = new FighterAttackerCtrler(this);
			
			if(mainmc.setAttackerCtrler){
				mainmc.setAttackerCtrler(_ctrler);
			}
			
			if(params){
				
				if(params.x != undefined){
					if(params.x is Number){
						_startX = params.x + _mcOrgPoint.x;
					}else{
						moveToTargetX = params.x.moveToTarget == true;
						followTargetX = params.x.followTarget == true;
						if(params.x.offset != undefined) _startX = params.x.offset;
						if(params.x.range != undefined && params.x.range is Array){
							rangeX = new Point(params.x.range[0] , params.x.range[1]);
						}
					}
				}
				
				if(params.y != undefined){
					if(params.y is Number){
						_startY = params.y + _mcOrgPoint.y;
					}else{
						moveToTargetY = params.y.moveToTarget == true;
						followTargetY = params.y.followTarget == true;
						if(params.y.offset != undefined) _startY = params.y.offset;
						if(params.y.range != undefined && params.y.range is Array){
							rangeY = new Point(params.y.range[0] , params.y.range[1]);
						}
					}
				}
				
				if(params.applyG != undefined) isApplyG = params.applyG == true;
				
			}
			
		}
		
		public override function destory(dispose:Boolean = true):void{
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
			_rectCache = null;
			_owner = null;
			_mcOrgPoint = null;
			
			super.destory(true);
		}
		
		public function setOwner(v:IGameSprite):void{
			_owner = v;
			
			direct = v.direct;
			
			if(_owner is FighterMain) _ctrler.effect = (_owner as FighterMain).getCtrler().getEffectCtrl();
			if(_owner is Assister) _ctrler.effect = (_owner as Assister).getCtrler().effect;
		}
		
		public function init():void{
			
			if(!_owner) return;
			
//			var ownerDisplay:DisplayObject = _owner.getDisplay();
			
//			if(direct > 0) _x += ownerDisplay.x;
//			if(direct < 0) _x -= ownerDisplay.x;
			
			if(direct > 0){
				_x = _owner.x + _startX;
			}else{
				_x = _owner.x - _startX;
			}
//			_x += ownerDisplay.x;
			_y += _owner.y;
			
			if(_owner is FighterMain){
				var fmc:FighterMC = (_owner as FighterMain).getMC();
				_x += fmc.x;
				_y += fmc.y;
			}
			
//			_x *= direct;
			
			if(!moveToTargetX && !moveToTargetY) return;
			
			var target:IGameSprite = getTarget();
			if(target){
				if(moveToTargetX){
					var tx:Number = target.x + (_startX * direct);
					if(rangeX){
						var xDis:Number;
						if(direct > 0){
							xDis = tx - _owner.x;
							if(xDis < rangeX.x) tx = _owner.x + rangeX.x;
							if(xDis > rangeX.y) tx = _owner.x + rangeX.y;
						}else{
							xDis = _owner.x - tx;
							if(xDis < rangeX.x) tx = _owner.x - rangeX.x;
							if(xDis > rangeX.y) tx = _owner.x - rangeX.y;
						}
					}
					_x = tx;
				}
				if(moveToTargetY){
					var ty:Number = target.y + _startY;
					if(rangeY){
						var yDis:Number = ty - _owner.y;
						if(yDis < rangeY.x) ty = target.y + rangeY.x;
						if(yDis > rangeY.y) ty = target.y + rangeY.y;
					}
					_y = ty;
				}
			}
			
			isAttacking = true;
			
		}
		
		public override function renderAnimate():void{
			if(!_isRenderMainAnimate) return;
			super.renderAnimate();
			mc.nextFrame();
			findHitArea();
			if(mc.currentFrame == mc.totalFrames-1) removeSelf();
		}
		
		public override function render():void
		{
			super.render();
			_ctrler.render();
			renderFollowTarget();
		}
		
		public function stopFollowTarget():void{
			followTargetX = false;
			followTargetY = false;
		}
		
		private function renderFollowTarget():void{
			if(!followTargetX && !followTargetY) return;
			var target:IGameSprite = getTarget();
			if(!target) return;
			
//			var targetDisplay:DisplayObject = target.getDisplay();
//			if(!targetDisplay) return;
			
			if(followTargetX) _x = target.x + (_startX * direct);
			if(followTargetY) _y = target.y + _startY;
		}
		
		public function moveToTarget(offsetX:Number = NaN , offsetY:Number = NaN):void{
			var target:IGameSprite = getTarget();
			if(!target) return;
			
//			var targetDisplay:DisplayObject = target.getDisplay();
//			if(!targetDisplay) return;
			
			if(!isNaN(offsetX)) _x = target.x + (offsetX * direct);
			if(!isNaN(offsetY)) _y = target.y + offsetY;
		}
		
		public function stop():void{
			_isRenderMainAnimate = false;
		}
		
		public function gotoAndPlay(frame:String):void{
			_mainMc.gotoAndStop(frame);
			_isRenderMainAnimate = true;
		}
		
		public function gotoAndStop(frame:String):void{
			_mainMc.gotoAndStop(frame);
			_isRenderMainAnimate = false;
		}
		
		public function getTargets():Vector.<IGameSprite>{
			if(_owner is FighterMain) return (_owner as FighterMain).getTargets();
			if(_owner is Assister) return (_owner as Assister).getTargets();
			return null;
		}
		
		private function getTarget():IGameSprite{
			if(_owner is FighterMain) return (_owner as FighterMain).getCurrentTarget();
			if(_owner is Assister) return (_owner as Assister).getCurrentTarget();
			return null;
		}
		
		public function removeSelf():void{
			if(onRemove != null) onRemove(this);
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
		
		
		private function getHitModel():FighterHitModel{
			if(_owner is FighterMain){
				return (_owner as FighterMain).getCtrler().hitModel;
			}
			if(_owner is Assister){
				return (_owner as Assister).getCtrler().hitModel;
			}
			throw new Error("不支持的owner类型!");
			return null;
		}
		
		
		private function findHitArea():void{
			if(!_hitAreaCache) return;
			var hitModel:FighterHitModel = getHitModel();
			if(!hitModel) return;
			
			//判断是否已定义过
			if(_hitAreaCache.areaFrameDefined(_mainMc.currentFrame)) return;
			
			//取帧缓存
			var area:Object = _hitAreaCache.getAreaByFrame(_mainMc.currentFrame);
			if(area != null) return; //已有，跳出
			
			var areaRects:Array = [];
			
			for(var i:int ; i < _mainMc.numChildren ; i++){
				var d:DisplayObject = _mainMc.getChildAt(i);
				var hitvo:HitVO = hitModel.getHitVOByDisplayName(d.name);
				
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
//			trace('cache' , _mainMc.currentFrame);
		}
		
		private function getOwnerFighter():FighterMain{
			if(_owner is FighterMain) return _owner as FighterMain;
			if(_owner is Assister) return (_owner as Assister).getOwner() as FighterMain;
			return null;
		}
		
		public override function hit(hitvo:HitVO, target:IGameSprite):void{
			var owner:FighterMain = getOwnerFighter();
			if(target && owner){
				var rate:Number = _owner is Assister ? GameConfig.QI_ADD_HIT_ASSISTER_RATE : GameConfig.QI_ADD_HIT_ATTACKER_RATE;
				owner.addQi(hitvo.power * rate);
				GameLogic.hitTarget(hitvo , owner , target);
			}
		}
		
	}
}