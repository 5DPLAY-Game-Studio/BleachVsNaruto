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

package net.play5d.game.bvn.map
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;

	import net.play5d.game.bvn.debug.Debugger;
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.data.MapVO;
	import net.play5d.game.bvn.interfaces.IGameSprite;
	import net.play5d.game.bvn.stage.GameStage;

	public class MapMain
	{
		include '../../../../../../include/_INCLUDE_.as';

		public var mapLayer:MapLayer;
		public var frontLayer:MapLayer;
		public var frontFixLayer:MapLayer;
		public var bgLayer:MapLayer;

		public var p1pos:Point;
		public var p2pos:Point;

		public var left:Number = 0;
		public var right:Number = 0;
		public var bottom:Number = 0;
		public var playerBottom:Number = 0;

		public var mapMc:Sprite;

		public var data:MapVO;

		public var gameState:GameStage;

		private var _defaultFrontPos:Point;

		private var _smoothing:Point = new Point();

		public function MapMain(mapmc:Sprite)
		{
			super();
			this.mapMc = mapmc;
		}

		public function destory():void{
			if(mapMc){
				try{
					//mapMc.stopAllMovieClips();
					mapMc.removeChildren();
				}catch(e:Error){
					trace(e);
				}
				mapMc = null;
			}
			if(mapLayer){
				mapLayer.destory();
				mapLayer = null;
			}
			if(frontLayer){
				frontLayer.destory();
				frontLayer = null;
			}
			if(frontFixLayer){
				frontFixLayer.destory();
				frontFixLayer = null;
			}
			if(bgLayer){
				bgLayer.destory();
				bgLayer = null;
			}
		}

		public function setVisible(v:Boolean):void{

			if(Debugger.HIDE_MAP && v) return;

			if(mapLayer && mapLayer.enabled) mapLayer.visible = v;
			if(frontLayer && frontLayer.enabled) frontLayer.visible = v;
			if(frontFixLayer && frontFixLayer.enabled) frontFixLayer.visible = v;
			if(bgLayer && bgLayer.enabled) bgLayer.visible = v;
		}

		public function getSmoothing():Point{
			return _smoothing;
		}

		public function setSmoothing(blurX:Number = 0, blurY:Number = 0):void{
			_smoothing.x = blurX;
			_smoothing.y = blurY;

			if(mapLayer && mapLayer.enabled) mapLayer.setSmoothing(blurX, blurY);
			if(bgLayer && bgLayer.enabled) bgLayer.setSmoothing(blurX * 3, blurY  * 3);
			if(frontLayer && frontLayer.enabled) frontLayer.setSmoothing(blurX * 2, blurY * 2);
			if(frontFixLayer && frontFixLayer.enabled) frontFixLayer.setSmoothing(blurX * 2, blurY * 2);
		}

		public function initlize():void{
			var leftLine:DisplayObject = mapMc.getChildByName('line_left');
			var rightLine:DisplayObject = mapMc.getChildByName('line_right');
			var bottomLine:DisplayObject = mapMc.getChildByName('line_bottom');
			var playerBottomLine:DisplayObject = mapMc.getChildByName('line_player_bottom');

			var gamesize:Point = GameConfig.GAME_SIZE;

			if(leftLine) left = leftLine.x;
			if(rightLine) right = rightLine.x;
			if(bottomLine) bottom = bottomLine.y;
			if(playerBottomLine) playerBottom = playerBottomLine.y;

			var p1mc:DisplayObject = mapMc.getChildByName("p1");
			var p2mc:DisplayObject = mapMc.getChildByName("p2");

			if(p1mc) p1pos = new Point(p1mc.x , p1mc.y);
			if(p2mc) p2pos = new Point(p2mc.x , p2mc.y);

			mapLayer = new MapLayer(mapMc.getChildByName("map"));
			frontLayer = new MapLayer(mapMc.getChildByName("front"));
			frontFixLayer = new MapLayer(mapMc.getChildByName("front_fix"));
			bgLayer = new MapLayer(mapMc.getChildByName("bg"));

			if(bgLayer.enabled){
//				bgLayer.drawBitmap(false, 0);
				bgLayer.normalize();
				mapMc.addChild(bgLayer);
			}

			var offsetY:Number = gamesize.y - bottom;

			if(mapLayer.enabled){
				mapLayer.normalize();
				mapLayer.y += offsetY;
				mapMc.addChild(mapLayer);
			}

			if(frontLayer.enabled){
				frontLayer.normalize();
				frontLayer.y += offsetY;
				_defaultFrontPos = new Point(frontLayer.x,frontLayer.y);
				mapMc.addChild(frontLayer);
			}

			if(frontFixLayer.enabled){
				frontFixLayer.normalize();
				frontFixLayer.y += offsetY;
				mapMc.addChild(frontFixLayer);
			}

			playerBottom += offsetY;
			bottom += offsetY;

			if(p1pos) p1pos.y += offsetY;
			if(p2pos) p2pos.y += offsetY;

			initFloor(offsetY);

			if(Debugger.HIDE_MAP) setVisible(false);

		}

		public function getStageSize():Point{
			return new Point(mapLayer.width , GameConfig.GAME_SIZE.y);
		}

		public function getMapBottomDistance():Number{
			return bottom - playerBottom;
		}

		private var _floors:Array;
		private function initFloor(offsetY:Number):void{
			_floors = [];
			var floormc:Sprite = mapMc.getChildByName("floor") as Sprite;
			if(!floormc) return;

			for(var i:int ; i < floormc.numChildren ; i++){
				var f:DisplayObject = floormc.getChildAt(i);
				if(f){
					var fv:FloorVO = new FloorVO();
					fv.xFrom = floormc.x + f.x;
					fv.xTo = floormc.x + f.x + f.width;
					fv.y = floormc.y + f.y + offsetY;
					_floors.push(fv);
				}
			}
		}

		public function getFloorHitTest(x:Number,y:Number,speed:Number):FloorVO{
			for(var i:int ; i < _floors.length ; i++){
				var fv:FloorVO = _floors[i];
				if(fv.hitTest(x,y,speed)) return fv;
			}
			return null;
		}

		public function render(gameX:Number , gameY:Number , zoom:Number):void{
			var gameSps:Vector.<IGameSprite> = gameState.getGameSprites();
			if(!gameSps || gameSps.length < 1) return;

			if(frontLayer && frontLayer.enabled){
				var gx:Number = gameX;
				var gy:Number = gameY+bottom;

				frontLayer.x = gx*0.1 + _defaultFrontPos.x;
				var yy:Number = gy*0.1 + _defaultFrontPos.y;
				(yy < _defaultFrontPos.y) && (yy = _defaultFrontPos.y);
				frontLayer.y = yy;

				frontLayer.renderOptical(gameSps);
			}

			if(frontFixLayer && frontFixLayer.enabled){
				frontFixLayer.renderOptical(gameSps);
			}

		}

	}
}
