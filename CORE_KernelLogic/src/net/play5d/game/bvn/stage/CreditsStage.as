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

package net.play5d.game.bvn.stage
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.events.SetBtnEvent;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.bvn.ui.SetBtnGroup;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.stage.IStage;

	public class CreditsStage implements IStage
	{

		private var _ui:Sprite;

		private var _btngroup:SetBtnGroup;

		private var _createsSp:DisplayObject;

		public function CreditsStage()
		{
		}

		/**
		 * 显示对象
		 */
		public function get display():DisplayObject
		{
			return _ui;
		}

		/**
		 * 构建
		 */
		public function build():void
		{

			SoundCtrl.I.BGM(AssetManager.I.getSound('back'));

			_ui = new Sprite();

			var bgbd:BitmapData = ResUtils.I.createBitmapData(ResUtils.swfLib.common_ui,'cover_bgimg',GameConfig.GAME_SIZE.x , GameConfig.GAME_SIZE.y);
			var bg:Bitmap = new Bitmap(bgbd);
			_ui.addChild(bg);

			var msg:String = getCreditsText();

			_createsSp = GameInterface.instance.getCreadits(msg);
			_createsSp ||= getDefaultCredits(msg);

			_ui.addChild(_createsSp);

			_btngroup = new SetBtnGroup();
//			_btngroup.x = 20;
			_btngroup.y = GameConfig.GAME_SIZE.y - 150;
			_btngroup.setBtnData([{label:"BACK",cn:"返回"}]);
			_btngroup.addEventListener(SetBtnEvent.SELECT,selectBtnHandler);
			_ui.addChild(_btngroup);

		}

		/**
		 * 稍后构建
		 */
		public function afterBuild():void
		{
		}

		/**
		 * 销毁
		 * @param back 回调函数
		 */
		public function destroy(back:Function =null):void
		{
			if(_btngroup){
				_btngroup.destory();
				_btngroup.removeEventListener(SetBtnEvent.SELECT,selectBtnHandler);
				_btngroup = null;
			}
		}

		private function selectBtnHandler(e:SetBtnEvent):void{
			MainGame.I.goMenu();
		}


		private function getCreditsText():String{

			var msg:String = "设计、美术、程序：剑jian" + "<br/>" +
				"人物制作：剑jian、数字化流天、L、V.临界幻想、Azrael，影、赤炎、水、 " + "<br/>" +
				"         洗橙子、酸菜鱼、星空、卡布托、司徒、小海、主流" + "<br/>" +
				"策划测试：剑jian、数字化流天、社长、渺渺" + "<br/>" +
				"卓越贡献：社长、渺渺" + "<br/>";
			return msg;
		}

		private function getDefaultCredits(msg:String):Sprite{
			var sp:Sprite = new Sprite();

			var txt:TextField = new TextField();

			var tf:TextFormat = new TextFormat();
			tf.font = "黑体";
			tf.size = 20;
			tf.color = 0xffff00;
			tf.leading = 15;

			txt.defaultTextFormat = tf;

			txt.multiline = true;
			txt.htmlText = msg;
			txt.autoSize = TextFieldAutoSize.LEFT;

			txt.x = 50;
			txt.y = 30;

//			txt.mouseEnabled = false;

			sp.addChild(txt);

			return sp;
		}

	}
}
