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

package net.play5d.game.bvn.ui.select
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.MapModel;
	import net.play5d.game.bvn.data.MapVO;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.ui.UIUtils;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.BitmapText;
	import net.play5d.kyo.utils.KyoRandom;

	public class MapSelectUI extends Sprite
	{
		include '../../../../../../../include/_INCLUDE_.as';

		public var enabled:Boolean = false;
		public var inputType:String;

		private var _mapmc:select_map_mc;
		private var _txtmc:select_map_txt_mc;
		private var _txt:BitmapText;
		private var _maps:Array;

		private var _curId:int;
		private var _picCache:Object = {};

		private var _prevListener:Function;
		private var _nextListener:Function;
		private var _confrimListener:Function;

		public function MapSelectUI()
		{
			super();
			build();
		}

		public function addMouseEvents(prev:Function, next:Function, confrim:Function):void{
			_mapmc.left_arrow.buttonMode = true;
			_mapmc.right_arrow.buttonMode = true;
			_mapmc.kuang.buttonMode = true;

			_prevListener = prev;
			_nextListener = next;
			_confrimListener = confrim;

			if(GameConfig.TOUCH_MODE){
				_mapmc.left_arrow.addEventListener(TouchEvent.TOUCH_TAP, touchHandler);
				_mapmc.right_arrow.addEventListener(TouchEvent.TOUCH_TAP, touchHandler);
				_mapmc.kuang.addEventListener(TouchEvent.TOUCH_TAP, touchHandler);
			}else{
				_mapmc.left_arrow.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
				_mapmc.right_arrow.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
				_mapmc.kuang.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);

				_mapmc.left_arrow.addEventListener(MouseEvent.CLICK, mouseHandler);
				_mapmc.right_arrow.addEventListener(MouseEvent.CLICK, mouseHandler);
				_mapmc.kuang.addEventListener(MouseEvent.CLICK, mouseHandler);
			}

		}

		private function touchHandler(e:TouchEvent):void{
			switch(e.currentTarget){
				case _mapmc.left_arrow:
					if(_prevListener != null) _prevListener();
					break;
				case _mapmc.right_arrow:
					if(_nextListener != null) _nextListener();
					break;
				case _mapmc.kuang:
					if(_confrimListener != null) _confrimListener();
					break;
			}
			SoundCtrl.I.sndConfrim();
		}

		private function mouseHandler(e:MouseEvent):void{

			if(e.type == MouseEvent.MOUSE_OVER){
				SoundCtrl.I.sndSelect();
				return;
			}

			switch(e.currentTarget){
				case _mapmc.left_arrow:
					if(_prevListener != null) _prevListener();
					break;
				case _mapmc.right_arrow:
					if(_nextListener != null) _nextListener();
					break;
				case _mapmc.kuang:
					if(_confrimListener != null) _confrimListener();
					break;
			}
			SoundCtrl.I.sndConfrim();
		}

		private function build():void{

			_mapmc = ResUtils.I.createDisplayObject(ResUtils.swfLib.select , 'select_map_mc');
			_maps = MapModel.I.getAllMaps();

			_mapmc.x = (GameConfig.GAME_SIZE.x - _mapmc.bg.width) / 2;
			_mapmc.y = GameConfig.GAME_SIZE.y * 0.25;
			_mapmc.ct.x -= 2;
			addChild(_mapmc);

			if(GameUI.SHOW_CN_TEXT){
				_txtmc = ResUtils.I.createDisplayObject(ResUtils.swfLib.select , 'select_map_txt_mc');
				_txtmc.x = (GameConfig.GAME_SIZE.x - _txtmc.width) / 2;
				_txtmc.y = GameConfig.GAME_SIZE.y - _txtmc.height - 35;
				addChild(_txtmc);

				_txt = new BitmapText(true,0xffffff,[new GlowFilter(0,1,3,3,3)]);
				UIUtils.formatText(_txt.textfield , {color:0xffffff , size:14 , align:TextFormatAlign.CENTER});
				_txt.width = _txtmc.width;
				_txtmc.addChild(_txt);
			}


			showMap(0);
		}

		public function destory():void{

			_prevListener = null;
			_nextListener = null;
			_confrimListener = null;

			if(_mapmc){

				_mapmc.left_arrow.removeEventListener(TouchEvent.TOUCH_TAP, touchHandler);
				_mapmc.right_arrow.removeEventListener(TouchEvent.TOUCH_TAP, touchHandler);
				_mapmc.kuang.removeEventListener(TouchEvent.TOUCH_TAP, touchHandler);

				_mapmc.left_arrow.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
				_mapmc.right_arrow.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
				_mapmc.kuang.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);

				_mapmc.left_arrow.removeEventListener(MouseEvent.CLICK, mouseHandler);
				_mapmc.right_arrow.removeEventListener(MouseEvent.CLICK, mouseHandler);
				_mapmc.kuang.removeEventListener(MouseEvent.CLICK, mouseHandler);
			}

			if(this.parent){
				try{
					this.parent.removeChild(this);
				}catch(e:Error){}
			}
			if(_txt){
				_txt.destory();
				_txt = null;
			}
		}

		public function select(back:Function):void{
			var mv:MapVO = _maps[_curId];
			if(mv){
				while(mv.id == 'random'){
					mv = KyoRandom.getRandomInArray(_maps);
				}
				GameData.I.selectMap = mv.id;
				enabled = false;
				if(back != null) back();
			}
		}

		public function prev():void{
			var id:int = _curId-1;
			if(id < 0) id = _maps.length - 1;
			showMap(id);
		}

		public function next():void{
			var id:int = _curId+1;
			if(id > _maps.length - 1) id = 0;
			showMap(id);
		}

		private function showMap(id:int):void{
			_curId = id;
			var mv:MapVO = _maps[id];
			var pic:DisplayObject = getPic(mv);

			_mapmc.ct.removeChildren();
			if(pic) _mapmc.ct.addChild(pic);

			if(_txt) _txt.text = mv.name;
		}

		private function getPic(mv:MapVO):DisplayObject{
			var d:DisplayObject = _picCache[mv.id];
			if(d) return d;

			d = AssetManager.I.getMapPic(mv);
			_picCache[mv.id] = d;

			return d;
		}



	}
}
