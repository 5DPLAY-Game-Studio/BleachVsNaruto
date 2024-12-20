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

package net.play5d.game.bvn.ui.bigmap
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;

	import net.play5d.game.bvn.ctrler.AssetManager;
	import net.play5d.game.bvn.ctrler.mosou_ctrls.MosouLogic;
	import net.play5d.game.bvn.data.FighterModel;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.mosou.MosouWorldMapAreaVO;
	import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.ui.Text;
	import net.play5d.game.bvn.ui.dialog.DialogManager;
	import net.play5d.game.bvn.ui.dialog.MosouStateDialog;
	import net.play5d.game.bvn.utils.BtnUtils;


	public class WorldMapPointUI extends EventDispatcher
	{
		include '../../../../../../../include/_INCLUDE_.as';

		public static const EVENT_SELECT:String = "EVENT_SELECT";

		private var _pointMc:Sprite;
		private var _ppmc:MovieClip;
		private var _facemc:Sprite;
		private var _maskMc:MovieClip;
		public var data:MosouWorldMapAreaVO;
		private var _perTxt:Text;
		private var _lvTxt:Text;

		public function WorldMapPointUI(pointMc:Sprite, maskMc:MovieClip , data:MosouWorldMapAreaVO)
		{
			_pointMc = pointMc;
			_maskMc = maskMc;

			_ppmc = _pointMc.getChildByName("pmc") as MovieClip;
			_facemc = _pointMc.getChildByName("face") as Sprite;

			BtnUtils.btnMode(_ppmc);
			BtnUtils.btnMode(_facemc);

			this.data = data;

			update();
			initEvents();
		}

		public function getPosition():Point{
			return new Point(_pointMc.x, _pointMc.y);
		}

		public function destory():void{
			BtnUtils.destoryBtn(_ppmc);
			BtnUtils.destoryBtn(_facemc);
			if(_lvTxt){
				_lvTxt.destory();
				_lvTxt = null;
			}
		}


		public function update():void{
			var isOpen:Boolean = MosouLogic.I.checkAreaIsOpen(data.id);
			try{
				if(isOpen){
					_pointMc.visible = true;
					_maskMc.visible = true;

					updateCurrent();
					updatePercent();
					updateColor();


				}else{
					_pointMc.visible = false;
					_maskMc.visible = false;
				}
			}catch(e:Error){
				trace("WorldMapPointUI", e);
			}

		}

		private function initEvents():void{
			BtnUtils.initBtn(_ppmc, btnHandler);
			BtnUtils.initBtn(_facemc, btnHandler);
		}

		private function btnHandler(b:DisplayObject):void{
			if(b == _facemc){
				GameEvent.dispatchEvent(GameEvent.MOSOU_FIGHTER);
				DialogManager.showDialog(new MosouStateDialog());
				return;
			}
			if(b == _ppmc){
				this.dispatchEvent(new Event(EVENT_SELECT));
			}
		}

		private function updateCurrent():void{
			var isCurrent:Boolean = MosouLogic.I.checkCurrentArea(data.id);

			if(!isCurrent){
				if(_facemc && _facemc.visible){
					TweenLite.to(_facemc, 0.1, {scaleX: 0.1, scaleY: 0.1, onComplete: function():void{
						_facemc.visible = false;
					}});
				}
				if(_lvTxt) _lvTxt.visible = false;
//				if(_maskMc) _maskMc.gotoAndStop(1);
			}else{
//				if(_maskMc) _maskMc.gotoAndStop('current');
				updateFace();
			}

		}

		private function updateFace():void{
			if(!_facemc) return;

			_facemc.visible = true;

			var ct:Sprite = _facemc.getChildByName('ct') as Sprite;
			if(!ct) return;

			var leader:MosouFighterVO = GameData.I.mosouData.getLeader();
			if(!leader) return;

			var faceImg:DisplayObject = AssetManager.I.getFighterFace(FighterModel.I.getFighter(leader.id));
			if(faceImg){
				faceImg.x = 1;
				ct.removeChildren();
				ct.addChild(faceImg);
			}

			if(!_lvTxt){
				_lvTxt = new Text(0xffffff, 12);
				_lvTxt.align = TextFieldAutoSize.RIGHT;
				_lvTxt.x = -15;
				_lvTxt.y = -32;
				_facemc.addChild(_lvTxt);
			}

			_lvTxt.text = "Lv." + leader.getLevel();
			_lvTxt.visible = true;

			_facemc.scaleX = _facemc.scaleY = 0.01;
			TweenLite.to(_facemc, 0.1, { scaleX: 1, scaleY : 1, ease: Back.easeOut, delay: 0.1 });
		}

		private function updatePercent():void{
			if(!_perTxt){
				_perTxt = new Text();
				_perTxt.fontSize = 20;
				_perTxt.y = 35;
				_pointMc.addChild(_perTxt);
			}

			var per:Number = MosouLogic.I.getAreaPercent(data.id);

			_perTxt.text = int(per * 100) + "%";
			_perTxt.x = -_perTxt.getTextWidth() / 2 + 12;
		}

		private function updateColor():void{
			if(!_ppmc) return;

			if(data.building()){
				_ppmc.gotoAndStop(2);
				return;
			}

			var per:Number = MosouLogic.I.getAreaPercent(data.id);
			if(per < 0.6){
				_ppmc.gotoAndStop(3);
				return;
			}

			if(per < 1){
				_ppmc.gotoAndStop(4);
				return;
			}

			_ppmc.gotoAndStop(1);
		}


	}
}
