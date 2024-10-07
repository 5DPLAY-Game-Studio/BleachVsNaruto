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

package net.play5d.game.bvn.ui.mosou
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.ctrl.mosou_ctrls.MosouCtrl;
	import net.play5d.kyo.utils.KyoDrawUtils;

	public class MosouWaveUI
	{
		private var _ui:Sprite;
		private var _txtCur:TextField;
		private var _txtMax:TextField;
		private var _circleMc:Sprite;
		private var _circleBp:Bitmap;
		public function MosouWaveUI(ui:Sprite)
		{
			_ui = ui;

			_txtCur = ui.getChildByName('txt') as TextField;
			_txtMax = ui.getChildByName('txt_max') as TextField;

			_circleBp = new Bitmap();

			var ct:Sprite = ui.getChildByName('ct_circle') as Sprite;
			ct.addChild(_circleBp);

//			test();
		}

		public function renderAnimate():void{
			var mosouCtrl:MosouCtrl = GameCtrl.I.getMosouCtrl();
			_txtCur.text = mosouCtrl.currentWave.toString();
			_txtMax.text = mosouCtrl.waveCount.toString();
			renderCircle();
		}

		private function renderCircle():void{
			var mosouCtrl:MosouCtrl = GameCtrl.I.getMosouCtrl();
			var angle:int = (mosouCtrl.getWavePercent() * 360) << 0;
			_circleBp.bitmapData = KyoDrawUtils.drawRing(10, 29, angle, [0xffff00, 0xff0000],1);
//			_circleBp.bitmapData = KyoDrawUtils.drawRing(10, _radius, angle, [0xffff00, 0xff0000],1);
		}

//		private var _radius:Number = 20;
//		private function test():void{
//			MainGame.I.stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
//		}
//		private function wheelHandler(e:MouseEvent):void{
//			if(e.delta > 0) _radius += 0.5;
//			if(e.delta < 0) _radius -= 0.5;
//			trace(_radius);
//		}

	}
}
