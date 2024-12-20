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

package net.play5d.game.bvn.ui
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrler.GameRender;
	import net.play5d.game.bvn.data.GameMode;
	import net.play5d.game.bvn.data.MessionModel;
	//import net.play5d.game.bvn.data.mosou.MosouMissionModel;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.input.GameInputType;
	import net.play5d.game.bvn.input.GameInputer;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.bvn.utils.TouchMoveEvent;
	import net.play5d.game.bvn.utils.TouchUtils;

	public class MenuBtnGroup extends Sprite
	{
		include '../../../../../../include/_INCLUDE_.as';

		public var enabled:Boolean = true;
		protected var _btnConfig:Array;
		protected var _xadd:Number = -40;
		protected var _yadd:Number = 5;
		private var _btnIndex:int;
		private var _startPoint:Point;
		private var _btnHeight:Number = 0;

		public function MenuBtnGroup()
		{
			super();

			if(GameConfig.TOUCH_MODE){
				this.scaleX = this.scaleY = 1.3;
				TouchUtils.I.listenOneFinger(MainGame.I.stage, touchMoveHandler, false, true);
			}
		}

		public function setGap(x:Number, y:Number):void{
			_xadd = x;
			_yadd = y;
		}

		// 手指滑动
		private function touchMoveHandler(event:TouchMoveEvent):void{
			if(event.type == TouchMoveEvent.TOUCH_MOVE){
				this.y += event.deltaY;
//				this.mouseChildren = false;
			}

			if(event.type == TouchMoveEvent.TOUCH_END){
				var toY:Number = -1;

				if(event.endY > event.startY){
					if(this.y > _startPoint.y) toY = _startPoint.y;
				}

				if(event.endY < event.startY){
					var bottom:Number = GameConfig.GAME_SIZE.y - this.height - 10; //最底端
					if(this.y < bottom) toY = bottom;
				}

				if(toY != -1){
					TweenLite.to(this,0.2,{y:toY});
				}

			}
		}

		public function destory():void{

			GameRender.remove(render);

			TouchUtils.I.unlistenOneFinger(MainGame.I.stage);

			for each(var b:MenuBtn in _btns){
				b.removeEventListener(TouchEvent.TOUCH_TAP, touchHandler);
				b.removeEventListener(MouseEvent.CLICK,mouseHandler);
				b.removeEventListener(MouseEvent.MOUSE_OVER,mouseHandler);
				b.dispose();
			}
			_btns = null;
		}

		public function fadIn(duration:Number = 0.5 , itemDelay:Number = 0.05):void{
			for(var i:int ; i < _btns.length ; i++){
				var b:MenuBtn = _btns[i];
				b.ui.scaleX = 0.01;
				TweenLite.to(b.ui,duration,{scaleX:1,delay:i*itemDelay,ease:Back.easeOut});
			}
		}

		 public function build():void{

			 _startPoint = new Point(x,y);

			_btnConfig = GameInterface.instance.getGameMenu();
			_btnConfig ||= GameInterface.getDefaultMenu();

			for(var i:int ; i < _btnConfig.length ; i++){
				var o:Object = _btnConfig[i];
				addMenuBtn(o);
			}
			setBtns(true,false);
			if(!GameConfig.TOUCH_MODE){
				hoverBtn(_btns[0]);
			}

			if(GameConfig.TOUCH_MODE){
				this.y += 50;
			}

			GameRender.add(render);

		}

		private var _btns:Array = [];
		private function addMenuBtn(o:Object , isChild:Boolean = false):MenuBtn{
			var b:MenuBtn = new MenuBtn(o.txt , o.cn , o.func);
			if(GameConfig.TOUCH_MODE){
				b.addEventListener(TouchEvent.TOUCH_TAP, touchHandler);
			}else{
				b.addEventListener(MouseEvent.CLICK,mouseHandler);
				b.addEventListener(MouseEvent.MOUSE_OVER,mouseHandler);
			}

			if(!isChild){
				b.index = _btns.length;
				_btns.push(b);
				if(_btnHeight == 0) _btnHeight = b.height;
			}

			var children:Array = o.children;
			if(children){
				b.children = [];
				for(var j:int = 0 ; j < children.length ; j++){
					var o2:Object = children[j];
					var cb:MenuBtn = addMenuBtn(o2,true);
					b.children.push(cb);
					cb.childMode();
					cb.index = j;
				}
			}

			return b;

		}

		private function touchEndHandler():void{
			if(!_startPoint || _btns.length < 7) return;

			var H:Number = GameConfig.GAME_SIZE.y - 10; //最底端
			var H2:Number = _startPoint.y + this.height; //组件的底端

			if(H2 < H) return;

			var H3:Number = H - _startPoint.y; //相对高度
			var step:Number = H3 / _btns.length; //高度与按钮数据的比例
			var itemHeight:Number = _btnHeight + _yadd; //每个按钮的高度+GAP
			var offsetY:Number = _btnIndex * (step - itemHeight) + _startPoint.y;

			TweenLite.to(this,0.2,{y:offsetY});

		}

		protected function mouseHandler(type:String , target:MenuBtn):void{
			if(!enabled) return;
			switch(type){
				case MouseEvent.MOUSE_OVER:
					hoverBtn(target);
					break;
				case MouseEvent.CLICK:
					selectBtn(target);
					break;
			}
		}

		protected function touchHandler(type:String, target:MenuBtn):void{
			if(TouchUtils.I.isDraging()) return;

			if(target.children && target.children.length > 0){
				hoverBtn(target);
				selectBtn(target);
				return;
			}


			if(!target.isHover()){
				hoverBtn(target, false);
			}else{
				selectBtn(target);
			}

		}

		private function moveScroll():void{
			if(!_startPoint || _btns.length < 7) return;

			var H:Number = GameConfig.GAME_SIZE.y - 10; //最底端
			var H2:Number = _startPoint.y + this.height; //组件的底端

			if(H2 < H) return;

			var W:Number = GameConfig.GAME_SIZE.x - 20;//最左端
			var W2:Number	= _startPoint.x + this.width;//组件的左端

			if(W2 < W) return;

			var H3:Number = H - _startPoint.y; //相对高度
			var W3:Number = W - _startPoint.x; //相对宽度

			var stepX:Number = W3 / _btns.length; //宽度与按钮数据的比例
			var stepY:Number = H3 / _btns.length; //高度与按钮数据的比例

			var itemWidth:Number = _xadd; //每个按钮的宽度
			var itemHeight:Number = _btnHeight + _yadd; //每个按钮的高度+GAP

			var offsetX:Number = _btnIndex * (stepX - itemWidth) * 0.1 + _startPoint.x;
			var offsetY:Number = _btnIndex * (stepY - itemHeight) + _startPoint.y;

			TweenLite.to(this,0.2,{x:offsetX,y:offsetY});

		}

		private function hoverBtn(btn:MenuBtn, isMoveScroll:Boolean = true):void{
//			trace('hoverBtn',btn.index);
			var b:MenuBtn;
			for(var i:int ; i< _btns.length ; i++){
				b = _btns[i];
				if(b == btn){
					b.hover();
					_btnIndex = i;
					if(isMoveScroll) moveScroll();
				}else{
					b.normal();
				}
			}

			if(_showIngChildrenBtn){
				var children:Array = _showIngChildrenBtn.children;
				for(var j:int ; j < children.length ; j++){
					b = children[j];
					if(b == btn){
						b.hover();
						_btnIndex = j;
					}else{
						b.normal();
					}
				}
			}

		}

		protected function selectBtn(target:MenuBtn):void{
			if(target.children){
				toogleChildren(target);
				return;
			}

			var func:Function;

			if(target.func != null){
				func = target.func as Function;
			}else{
				func = getFucByLabel(target.label);
			}

			var callFunc:Function = function():void{
				if(func != null) func();
				this.mouseEnabled = this.mouseChildren = true;
				enabled = true;
			}
//			this.mouseEnabled = this.mouseChildren = false;
			enabled = false;
			target.select(callFunc);
		}

		private function getFucByLabel(label:String):Function{
			var func:Function;
			switch(label){
				case 'TEAM ACRADE':
					func = function():void{
						GameMode.currentMode = GameMode.TEAM_ACRADE;
						MessionModel.I.reset();
						if(GameConfig.SHOW_HOW_TO_PLAY){
							MainGame.I.goHowToPlay();
						}else{
							MainGame.I.goSelect();
						}

						GameEvent.dispatchEvent(GameEvent.ENTER_TEAM_STAGE);
					}
					break;
				case 'TEAM VS PEOPLE':
					func = function():void{
						GameMode.currentMode = GameMode.TEAM_VS_PEOPLE;
						MainGame.I.goSelect();

						GameEvent.dispatchEvent(GameEvent.ENTER_TEAM_STAGE);
					}
					break;
				case 'TEAM VS CPU':
					func = function():void{
						GameMode.currentMode = GameMode.TEAM_VS_CPU;
						MainGame.I.goSelect();

						GameEvent.dispatchEvent(GameEvent.ENTER_TEAM_STAGE);
					}
					break;
				case 'TEAM WATCH':
					func = function():void {
						GameMode.currentMode = GameMode.TEAM_WATCH;
						MainGame.I.goSelect();

						GameEvent.dispatchEvent(GameEvent.ENTER_TEAM_STAGE);
					};
					break;
				case 'SINGLE ACRADE':
					func = function():void{
						GameMode.currentMode = GameMode.SINGLE_ACRADE;
						MessionModel.I.reset();
						if(GameConfig.SHOW_HOW_TO_PLAY){
							MainGame.I.goHowToPlay();
						}else{
							MainGame.I.goSelect();
						}

						GameEvent.dispatchEvent(GameEvent.ENTER_SINGLE_STAGE);
					}
					break;
				case 'SINGLE VS PEOPLE':
					func = function():void{
						GameMode.currentMode = GameMode.SINGLE_VS_PEOPLE;
						MainGame.I.goSelect();

						GameEvent.dispatchEvent(GameEvent.ENTER_SINGLE_STAGE);
					}
					break;
				case 'SINGLE VS CPU':
					func = function():void{
						GameMode.currentMode = GameMode.SINGLE_VS_CPU;
						MainGame.I.goSelect();

						GameEvent.dispatchEvent(GameEvent.ENTER_SINGLE_STAGE);
					}
					break;
				case 'SINGLE WATCH':
					func = function():void {
						GameMode.currentMode = GameMode.SINGLE_WATCH;
						MainGame.I.goSelect();

						GameEvent.dispatchEvent(GameEvent.ENTER_SINGLE_STAGE);
					};
					break;
				case 'SURVIVOR':
					func = function():void{
						GameMode.currentMode = GameMode.SURVIVOR;
						MessionModel.I.reset();
						MainGame.I.goSelect();
					}
					break;
				case 'MUSOU ACRADE':
					func = function():void{
						GameMode.currentMode = GameMode.MOSOU_ACRADE;
						MainGame.I.goWorldMap();

						GameEvent.dispatchEvent(GameEvent.ENTER_MOSOU_STAGE);
					}
					break;
				case 'OPTION':
					func = function():void{
						MainGame.I.goOption();
					}
					break;
				case 'TRAINING':
					func = function():void{
						GameMode.currentMode = GameMode.TRAINING;
						MainGame.I.goSelect();

						GameEvent.dispatchEvent(GameEvent.ENTER_TRAIN_STAGE);
					}
					break;
				case 'CREDITS':
					func = function():void{
						MainGame.I.goCredits();
					}
					break;
				case 'MORE GAMES':
					func = function():void{
						MainGame.I.moreGames();
					}
					break;
			}

			return func;

		}



		private var _showIngChildrenBtn:MenuBtn;
		private function toogleChildren(btn:MenuBtn):void{
			if(_showIngChildrenBtn){
				var isSame:Boolean = btn == _showIngChildrenBtn;
				if(!isSame) _showIngChildrenBtn.normal();
				closeChildren(isSame,isSame);
				if(isSame) return;
			}
			_showIngChildrenBtn = btn;
			setBtns(true,true);
			btn.openChild();
			hoverBtn(btn.children[0]);
		}

		private function closeChildren(isSetBtns:Boolean , tween:Boolean):void{
			var children:Array = _showIngChildrenBtn.children;
			for(var i:int=0 ; i < children.length ; i++){
				var b:MenuBtn = children[i];
				try{
					removeChild(b.ui);
				}catch(e:Error){}
			}
			_showIngChildrenBtn.closeChild();
			_showIngChildrenBtn = null;
			if(isSetBtns) setBtns(false,tween);
		}

		private function setBtns(_addChild:Boolean , _tween:Boolean = false):void{
			var lx:Number = 0;
			var ly:Number = 0;
			for(var i:int ; i < _btns.length ; i++){
				var b:MenuBtn = _btns[i];
				if(_tween){
					TweenLite.to(b.ui,0.2,{x:lx,y:ly});
				}else{
					b.ui.x = lx;
					b.ui.y = ly;
				}

				lx += _xadd;
				ly += b.height + _yadd;
				if(_addChild) addChild(b.ui);

				if(_showIngChildrenBtn == b){
					for(var j:int ; j < b.children.length ; j++){
						var cb:MenuBtn = b.children[j];
						cb.ui.x = lx;
						cb.ui.y = ly;
						if(_tween){
							cb.ui.scaleX = 0.01;
							TweenLite.to(cb.ui,0.2,{scaleX:1,delay:j*0.04,ease:Back.easeOut});
						}
						if(_addChild) addChild(cb.ui);

						lx += _xadd;
						ly += cb.height + _yadd;
					}
				}
			}
		}

		private function render():void{
			if(!enabled) return;

			if(GameUI.showingDialog()) return;

			var btns:Array = _showIngChildrenBtn ? _showIngChildrenBtn.children : _btns;

			if(GameInputer.up(GameInputType.MENU,1)){
				_btnIndex--;
				if(_btnIndex < 0) _btnIndex = btns.length-1;
				hoverBtn(btns[_btnIndex]);
			}

			if(GameInputer.down(GameInputType.MENU,1)){
				_btnIndex++;
				if(_btnIndex > btns.length-1) _btnIndex = 0;
				hoverBtn(btns[_btnIndex]);
			}

			if(GameInputer.select(GameInputType.MENU,1)){
				selectBtn(btns[_btnIndex]);
			}

			if(GameInputer.back(1)){
				if(_showIngChildrenBtn){
					_btnIndex = _showIngChildrenBtn.index;
					closeChildren(true,true);
				}
			}

		}

	}
}
