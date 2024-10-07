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

package net.play5d.game.bvn.ui.dialog
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.geom.Point;
	import flash.text.TextFormatAlign;

	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.mosou_ctrls.MosouLogic;
	import net.play5d.game.bvn.data.FighterModel;
	import net.play5d.game.bvn.data.FighterVO;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.mosou.MosouFighterSellVO;
	import net.play5d.game.bvn.ui.Text;
	import net.play5d.game.bvn.ui.dialog.select.DotsGroupUI;
	import net.play5d.game.bvn.ui.dialog.select.SelectFighterList;
	import net.play5d.game.bvn.ui.dialog.select.SelectFighterUI;
	import net.play5d.game.bvn.ui.mosou.CoinUI;
	import net.play5d.game.bvn.utils.BtnUtils;
	import net.play5d.game.bvn.utils.ResUtils;

	public class MosouSelectDialog extends BaseDialog
	{
		private var _ui:dialog_select_fighter;
		private var _chooseBtn:SimpleButton;
		private var _buyBtn:SimpleButton;
		private var _selectFighterList:SelectFighterList;

		private var _fighterIndex:int;

		private var _nameText:Text;
		private var _infoText:Text;

		private var _curFighterUI:SelectFighterUI;

		private var _coinUI:CoinUI;

		private var _selectFace:DisplayObject;

		private var _dotGroup:DotsGroupUI;

		private var _coinico:Sprite;

		public function MosouSelectDialog(fighterIndex:int)
		{
			super();

			width = 741;
			height = 478;

			offsetY = 20;

			_fighterIndex = fighterIndex;

			_ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog, 'dialog_select_fighter');
			_dialogUI = _ui;

			_coinUI = new CoinUI(_ui.getChildByName("coinmc") as MovieClip);

			_chooseBtn = _ui.getChildByName("change") as SimpleButton;
			_buyBtn = _ui.getChildByName("buy") as SimpleButton;

			_coinico = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog, 'coin_icon_mc');

			BtnUtils.initBtn(_chooseBtn, btnHandler);
			BtnUtils.initBtn(_buyBtn, btnHandler);

			_nameText = new Text(0xFFFFFF);
			_nameText.width = 299;
			_nameText.align = TextFormatAlign.CENTER;
			_ui.ct_name.addChild(_nameText);

			_infoText = new Text();
			_ui.ct_money.addChild(_infoText);

			_selectFighterList = new SelectFighterList();
			_selectFighterList.x = -5;
			_selectFighterList.y = -10;
			_selectFighterList.onSelectFighter = onSelectFighter;
			_selectFighterList.onChangePage = onListPageChange;
			_ui.ct_list.addChild(_selectFighterList);

			_dotGroup = new DotsGroupUI();
			_dotGroup.x = 10;
			_dotGroup.y = 10;
			_dotGroup.onDotClick = onDotClick;
			_ui.ct_dots.addChild(_dotGroup);

			_dotGroup.update(_selectFighterList.getTotalPage());
		}

		private function onDotClick(page:int):void{
			_selectFighterList.setPage(page);
		}

		private function onListPageChange():void{
			_dotGroup.updateByPage(_selectFighterList.getPage());
		}

		private function updateSelectFace(data:MosouFighterSellVO):void{
			if(_selectFace){
				try{
					_ui.ct_face.removeChild(_selectFace);
				}catch(e:Error){}
				_selectFace = null;
			}

			var fv:FighterVO = FighterModel.I.getFighter(data.id);

			_selectFace = AssetManager.I.getFighterFaceWin(fv);
			if(_selectFace){
//				_selectFace.x = 498;
//				_selectFace.y = 3;
				_ui.ct_face.addChildAt(_selectFace, 0);
			}
		}

		private function onSelectFighter(ui:SelectFighterUI):void{
			_curFighterUI = ui;
			_nameText.text = FighterModel.I.getFighterName(ui.sellData.id);

			updateSelectFace(ui.sellData);

			if(ui.isBought()){
				_chooseBtn.visible = true;
				_buyBtn.visible = false;
				_infoText.text = "Lv." + ui.getLevel();

				if(_coinico){
					try{
						_ui.ct_money.removeChild(_coinico);
					}catch(e:Error){}

				}

				_infoText.x = 0;

			}else{
				_chooseBtn.visible = false;
				_buyBtn.visible = true;

				_infoText.text = ui.sellData.getPrice().toString();

				if(_coinico){
					_ui.ct_money.addChild(_coinico);
					_infoText.x = _coinico.width;
				}
			}
		}

		private function btnHandler(b:SimpleButton):void{
			if(!_curFighterUI) return;

			if(b == _chooseBtn){
				if(!_curFighterUI) return;
				GameData.I.mosouData.setFighterTeam(_fighterIndex, _curFighterUI.sellData.id);
				GameData.I.saveData();
				closeSelf();
			}
			if(b == _buyBtn){
				MosouLogic.I.buyFighter(_curFighterUI.sellData, function():void{
					_selectFighterList.update();
					onSelectFighter(_curFighterUI);
				});
			}
		}

		protected override function onDestory():void{
			super.onDestory();

			if(_coinUI){
				_coinUI.destory();
				_coinUI = null;
			}

			if(_dotGroup){
				_dotGroup.destory();
				_dotGroup = null;
			}

			if(_selectFighterList){
				_selectFighterList.destory();
				_selectFighterList = null;
			}
		}

	}
}
