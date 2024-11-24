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

package net.play5d.game.bvn.ui.dialog.mosou_state
{
	import com.greensock.TweenLite;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormatAlign;

	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.data.FighterModel;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
	import net.play5d.game.bvn.debug.DebugUtil;
	import net.play5d.game.bvn.ui.Text;

	public class BigFaceUI
	{
		include '../../../../../../../../include/_INCLUDE_.as';

		private var _ui:Sprite;
		private var _data:MosouFighterVO;

		private var _nametxt:Text;
		private var _leveltxt:Text;

		public function getUI():Sprite{
			return _ui;
		}

		public function BigFaceUI(ui:Sprite)
		{
			_ui = ui;
		}

		public function getFighter():MosouFighterVO{
			return _data;
		}

		public function setFighter(data:MosouFighterVO):void{
			_data = data;
			updateTexts();
			updateFace();
		}

		private function updateTexts():void{
			if(_nametxt == null){
				_nametxt = new Text(0xffff00, 24);
				_nametxt.width = 270;
				_nametxt.height = 60;
				_nametxt.align = TextFormatAlign.CENTER;
				_nametxt.y = 197;
				_ui.addChild(_nametxt);
			}

			if(_leveltxt == null){
				_leveltxt = new Text(0xffffff);
				_leveltxt.width = 270;
				_leveltxt.height = 30;
				_leveltxt.align = TextFormatAlign.CENTER;
				_leveltxt.y = 230;
				_ui.addChild(_leveltxt);
			}


			_nametxt.text = FighterModel.I.getFighterName(_data.id);
			_leveltxt.text = "Lv." + _data.getLevel();
		}

		private function updateFace():void{
			var ct:Sprite = _ui.getChildByName("ct") as Sprite;
			if(!ct) return;

			ct.removeChildren();

			var faceImg:DisplayObject = AssetManager.I.getFighterFaceWin(FighterModel.I.getFighter(_data.id));
			if(faceImg) ct.addChild(faceImg);
		}

		public function updatePos(pos:int ,tween:Boolean = true):void{
			var obj:Object = {};
			switch(pos){
				case 0:
					obj.x = 230;
					obj.y = 33;
					obj.scaleX = obj.scaleY = 1;
					if(_ui.parent) _ui.parent.addChild(_ui);
					break;
				case 1:
					obj.x = 70;
					obj.y = -24;
					obj.scaleX = obj.scaleY = 0.74;
					break;
				case 2:
					obj.x = 458;
					obj.y = -4;
					obj.scaleX = obj.scaleY = 0.74;
					break;
			}
			if(tween){
				TweenLite.to(_ui,0.2,obj);
			}else{
				_ui.x = obj.x;
				_ui.y = obj.y;
				_ui.scaleX = obj.scaleX;
				_ui.scaleY = obj.scaleY;
			}
		}

		public function updateLeader():void{
			var isLeaderMc:Sprite = _ui.getChildByName('isLeaderMc') as Sprite;
			if(isLeaderMc) isLeaderMc.visible = _data == GameData.I.mosouData.getLeader();
		}

	}
}
