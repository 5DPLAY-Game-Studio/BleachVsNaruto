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

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.GameQuality;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.GameRender;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.data.ConfigVO;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.events.SetBtnEvent;
	import net.play5d.game.bvn.input.GameInputType;
	import net.play5d.game.bvn.input.GameInputer;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.game.bvn.utils.TouchMoveEvent;
	import net.play5d.game.bvn.utils.TouchUtils;

	public class SetBtnGroup extends Sprite
	{
		include "_INCLUDE_.as";

		public var keyEnable:Boolean = true;

		public var startX:Number = 100;
		public var startY:Number = 50;
		public var endY:Number = 0; //scroll时使用
		public var gap:Number = 75;

		/**
		 * 排列方向： 0=横向，1=纵向
		 */
		public var direct:int = 1;
		public var gameInputType:String = GameInputType.MENU;

		private var _btns:Vector.<SetBtn>;
		private var _arrow:select_arrow_mc;
		private var _arrowIndex:int = -1;

		private var _scrollRect:Rectangle;

//		public static var TOUCH_ENABLED:Boolean = true;


		public function SetBtnGroup()
		{
			super();
			if(GameConfig.TOUCH_MODE){
				this.scaleX = this.scaleY = 1.1;
				TouchUtils.I.listenOneFinger(this, touchMoveHandler, false, true);
			}
		}

		// 手指滑动
		private function touchMoveHandler(event:TouchMoveEvent):void{
//			trace('touchMoveHandler', TOUCH_ENABLED);

			if(!_scrollRect) return;
//			if(!TOUCH_ENABLED) return;

			if(event.type == TouchMoveEvent.TOUCH_MOVE){
				_scrollRect.y -= event.deltaY;
				updateScroll();
			}

			if(event.type == TouchMoveEvent.TOUCH_END){
				var toY:Number = -1;

				if(event.endY > event.startY){
					if(_scrollRect.y < 0) toY = 0;
				}

				if(event.endY < event.startY){
					var bh:Number = endY != 0 ? endY : _scrollRect.height; //最底端
					var bottom:Number = GameConfig.GAME_SIZE.y - bh + 100; //最底端
					if(_scrollRect.y > bottom) toY = bottom;
				}

				if(toY != -1){
					TweenLite.to(_scrollRect,0.2,{y:toY,onUpdate:updateScroll});
				}

			}
		}

		public function initScroll(W:Number , H:Number):void{
			_scrollRect = new Rectangle(0,0,W,H);
			this.scrollRect = _scrollRect;
		}

		public function initMainSet():void{
			initMainBtns();
			initArrow();

			GameRender.add(render , this);
			GameInputer.focus();
			GameInputer.enabled = true;

		}

		public function initKeySet():void{
			setBtnData([
				{label:"SET ALL",cn:"设置全部"},
				{label:"SET DEFAULT",cn:"还原默认按键"},
				{label:"APPLY",cn:"应用"},
				{label:"CANCEL",cn:"取消"}
			]);
		}

		/**
		 * 设置按钮数据
		 * @param v [{label:String,cn:String}]
		 */
		public function setBtnData(v:Array , defaultSelect:int = 0):void{
			_btns = new Vector.<SetBtn>();

			var btn:SetBtn;

			for(var i:int ; i < v.length ; i++){
				var o:Object = v[i];
				btn = addBtn(o.label,o.cn,o.options);
				if(o.optoinKey != undefined) btn.optionKey = o.optoinKey;
				if(o.optionValue != undefined) btn.setOptionByValue(o.optionValue);
			}

			initArrow(defaultSelect);

			GameRender.add(render , this);

			GameInputer.focus();
			GameInputer.enabled = true;
		}

		public function destory():void{
			if(_btns){
				for each(var b:SetBtn in _btns){
					b.destory();
					b.removeEventListener(TouchEvent.TOUCH_TAP, touchHandler);
					b.removeEventListener(MouseEvent.MOUSE_OVER,mouseHandler);
					b.removeEventListener(MouseEvent.CLICK,mouseHandler);
					b.removeEventListener(SetBtnEvent.OPTION_CHANGE,onChangeOption);
					b.removeEventListener(SetBtnEvent.SELECT,onSelect);
				}
				_btns = null;
			}

			GameRender.remove(render , this);
			TouchUtils.I.unlistenOneFinger(this);
			// 用stage有点问题
		}

		private function initMainBtns():void{

			_btns = new Vector.<SetBtn>();

			var settingMenu:Array = GameInterface.instance.getSettingMenu();
			settingMenu ||= [
				{txt:"P1 KEY SET",cn:"玩家1 按键设置"},
				{txt:"P2 KEY SET",cn:"玩家2 按键设置"},
				{txt:"COM LEVEL",cn:"电脑等级",
					options:[
						{label:'VERY EASY',cn:'非常简单',value:1},
						{label:'EASY',cn:'简单',value:2},
						{label:'NORMAL',cn:'正常',value:3},
						{label:'HARD',cn:'困难',value:4},
						{label:'VERY HARD',cn:'非常困难',value:5},
						{label:'HELL',cn:'地狱',value:6}
					],
					optoinKey:'AI_level'
				},
				{txt:"OPERATE MODE",cn:"按键操作模式",
					options:[
						{label:'NORMAL',cn:'正常模式',value:0},
						{label:'CLASSIC',cn:'经典模式',value:1}
					],
					optoinKey:'keyInputMode'
				},
				{txt:"LIFE",cn:"生命值",
					options:[
						{label:'50%',cn:'50%',value:0.5},
						{label:'100%',cn:'100%',value:1},
						{label:'200%',cn:'200%',value:2},
						{label:'300%',cn:'300%',value:3},
						{label:'500%',cn:'500%',value:5}
					],
					optoinKey:'fighterHP'
				},
				{txt:"TIME",cn:"对战时间",
					options:[
						{label:'30s',cn:'30秒',value:30},
						{label:'60s',cn:'60秒',value:60},
						{label:'90s',cn:'90秒',value:90},
						{label:'∞',cn:'无限制',value:-1}
					],
					optoinKey:'fightTime'
				},
				{txt:"SOUND",cn:"游戏音效",
					options:[
						{label:'0%',cn:'0%',value:0},
						{label:'10%',cn:'10%',value:0.1},
						{label:'30%',cn:'30%',value:0.3},
						{label:'50%',cn:'50%',value:0.5},
						{label:'70%',cn:'70%',value:0.7},
						{label:'100%',cn:'100%',value:1}
					],
					optoinKey:'soundVolume'
				},
				{txt:"BGM",cn:"背景音乐",
					options:[
						{label:'0%',cn:'0%',value:0},
						{label:'10%',cn:'10%',value:0.1},
						{label:'30%',cn:'30%',value:0.3},
						{label:'50%',cn:'50%',value:0.5},
						{label:'70%',cn:'70%',value:0.7},
						{label:'100%',cn:'100%',value:1}
					],
					optoinKey:'bgmVolume'
				},
				{txt:"QUALITY",cn:"画质等级",
					options:[
						{label:'LOW',cn:'低',value:GameQuality.LOW},
						{label:'MEDIUM',cn:'中',value:GameQuality.MEDIUM},
						{label:'HIGH',cn:'高',value:GameQuality.HIGH},
						{label:'BEST',cn:'最高',value:GameQuality.BEST}
					],
					optoinKey:'quality'
				},
			];

			var btn:SetBtn;
			var config:ConfigVO = GameData.I.config;

			for(var i:int ; i < settingMenu.length ; i++){
				var o:Object = settingMenu[i];
				btn = addBtn(o.txt,o.cn,o.options);
				if(o.select) btn.onSelect = o.select;
				btn.optionKey = o.optoinKey;
				if(btn.optionKey) btn.setOptionByValue(config.getValueByKey(btn.optionKey));
			}

			addBtn("CANCEL","取消");
			addBtn("APPLY","应用");

			this.graphics.beginFill(0,0);
			this.graphics.drawRect(0, 0, GameConfig.GAME_SIZE.x , _btns[_btns.length - 1].y + 300);
			this.graphics.endFill();
		}

		private function addBtn(label:String , cn:String , options:Array = null):SetBtn{
			var btn:SetBtn = new SetBtn(label,cn);

			if(GameConfig.TOUCH_MODE){
				btn.addEventListener(TouchEvent.TOUCH_TAP, touchHandler);
			}else{
				btn.addEventListener(MouseEvent.MOUSE_OVER,mouseHandler);
				btn.addEventListener(MouseEvent.CLICK,mouseHandler);
			}


			switch(direct){
				case 0:
					btn.x = startX + gap * _btns.length;
					btn.y = startY;
					break;
				case 1:
					btn.x = startX;
					btn.y = startY + gap * _btns.length;
					break;
			}

			addChild(btn);

			if(options){
				btn.setOption(options);
				btn.addEventListener(SetBtnEvent.OPTION_CHANGE,onChangeOption);
			}else{
				btn.addEventListener(SetBtnEvent.SELECT,onSelect);
			}

			_btns.push(btn);

			return btn;
		}

		private function touchHandler(e:TouchEvent):void{
			if(!keyEnable) return;

			var btn:SetBtn = e.currentTarget as SetBtn;
			var index:int = _btns.indexOf(btn);

			if(index == -1) return;

			var option:Object = btn.getOption();

			if(index == _arrowIndex){
				if(option != null){
					btn.nextOption();
				}else{
					btn.select();
				}

				return;
			}

			setArrowIndex(index, true, false);
		}

		private function mouseHandler(e:MouseEvent):void{
			if(!keyEnable) return;
			var btn:SetBtn = e.currentTarget as SetBtn;
			switch(e.type){
				case MouseEvent.MOUSE_OVER:
					var index:int = _btns.indexOf(btn);
					if(index != -1) setArrowIndex(index);
					break;
				case MouseEvent.CLICK:
					if(btn.getOption() == null){
						btn.select();
					}else{
						if(e.target){
							switch(e.target.name){
								case 'prevArrow':
									btn.prevOption();
									break;
								case 'nextArrow':
									btn.nextOption();
									break;
							}
						}
					}
					break;
			}


		}

		private function initArrow(index:int = 0):void{
			_arrow = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui,'select_arrow_mc');
			addChild(_arrow);
			setArrowIndex(index);
		}

		public function setArrowIndex(id:int, sound:Boolean = true, isScroll:Boolean = true):void{
			if(_arrowIndex == id) return;

			if(id < 0) id = _btns.length-1;
			if(id > _btns.length-1) id = 0;

			var btn:SetBtn = _btns[id];

			_arrowIndex = id;
			_arrow.x = btn.x - 10;
			_arrow.y = btn.y + 15;

			_btns.every(function(item:SetBtn , i:int , v:Vector.<SetBtn>):Boolean{
				if(btn == item){
					item.hover();
				}else{
					item.hoverOut();
				}
				return true;
			});

			if(sound) SoundCtrl.I.sndSelect();


			if(isScroll) moveScroll();
//			btn.hover();

		}

		private function moveScroll():void{
			if(!_scrollRect) return;

			if(direct == 1){

				if(_btns.length < 8) return;

				var H:Number = endY != 0 ? endY : _scrollRect.height;
				var H2:Number = this.height;

				if(H2 < H) return;

				var H3:Number = H - startY;
//				var curY:Number = _arrow.y;

				var step:Number = H3 / _btns.length;
				var offsetY:Number = -_arrowIndex * (step - gap);

				TweenLite.to(_scrollRect,0.2,{y:offsetY,onUpdate:updateScroll});

			}

		}

		private function updateScroll():void{
			this.scrollRect = _scrollRect;
		}

		private function render():void{
			if(!keyEnable) return;
			if(!_btns || _btns.length < 1) return;
			var btn:SetBtn = _btns[_arrowIndex];

			if(GameInputer.up(gameInputType,1)){
				if(direct == 1) setArrowIndex(_arrowIndex-1);
			}

			if(GameInputer.down(gameInputType,1)){
				if(direct == 1) setArrowIndex(_arrowIndex+1);
			}

			if(GameInputer.left(gameInputType,1)){
				if(direct == 0) setArrowIndex(_arrowIndex-1);
				if(direct == 1) btn.prevOption();
			}

			if(GameInputer.right(gameInputType,1)){
				if(direct == 0) setArrowIndex(_arrowIndex+1);
				if(direct == 1) btn.nextOption();
			}

			if(GameInputer.select(gameInputType,1)){
				btn.select();
			}

		}

		private function onChangeOption(e:SetBtnEvent):void{
			dispatchEvent(e.newEvent());
		}

		private function onSelect(e:SetBtnEvent):void{
			var btn:SetBtn = e.currentTarget as SetBtn;
			if(btn.onSelect != null) btn.onSelect();
			dispatchEvent(e.newEvent());
		}

	}
}
