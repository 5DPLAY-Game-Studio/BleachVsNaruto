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

package net.play5d.game.bvn.ui.dialog.select
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;

	import net.play5d.game.bvn.cntlr.AssetManager;
	import net.play5d.game.bvn.data.FighterModel;
	import net.play5d.game.bvn.data.FighterVO;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.mosou.MosouFighterSellVO;
	import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
	import net.play5d.game.bvn.ui.Text;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.utils.KyoUtils;

	public class SelectFighterUI
	{
		include '../../../../../../../../include/_INCLUDE_.as';

		public var sellData:MosouFighterSellVO;
		private var _playerData:MosouFighterVO;
		private var _lvTxt:Text;
		private var _selectUI:MovieClip;
		private var _selected:Boolean;
		private var _faceImg:DisplayObject;
		public var ui:Sprite;


		public function SelectFighterUI(sellData:MosouFighterSellVO)
		{
			ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog, 'face_ui_mc');
			this.sellData = sellData;

			_selectUI = ui.getChildByName('seltmc') as MovieClip;

			_lvTxt = new Text(0xffffff,14);
			_lvTxt.visible = false;
			ui.addChild(_lvTxt);

			initFace();
			updateUI();
		}

		private function initFace():void{
			var fv:FighterVO = FighterModel.I.getFighter(sellData.id);
			var faceImg:DisplayObject = AssetManager.I.getFighterFace(fv);
			if(faceImg){
				faceImg.x = 1;
				ui.addChildAt(faceImg, 0);
			}
			_faceImg = faceImg;
		}

		public function select(v:Boolean):void{
			if(_selected == v) return;

			_selected = v;
			if(_selectUI){
				_selectUI.gotoAndPlay(v ? 'in' : 'out');
			}
		}

		public function isBought():Boolean{
			return _playerData != null;
		}

		public function getLevel():int{
			if(!_playerData) return 0;
			return _playerData.getLevel();
		}

		public function updateUI():void{
			_playerData = GameData.I.mosouData.getFighterDataById(sellData.id);

			if(_playerData){
				_lvTxt.visible = true;
				_lvTxt.text = "Lv." + _playerData.getLevel();
//				KyoUtils.grayMC(_faceImg, true);
				ui.alpha = 1;
			}else{
				_lvTxt.visible = false;
//				KyoUtils.grayMC(_faceImg);
				ui.alpha = .5;
			}
		}

	}
}
