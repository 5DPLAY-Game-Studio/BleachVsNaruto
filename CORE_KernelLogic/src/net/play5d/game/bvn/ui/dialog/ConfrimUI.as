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

package net.play5d.game.bvn.ui.dialog {
import com.greensock.TweenLite;

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormatAlign;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.events.SetBtnEvent;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.SetBtnGroup;
import net.play5d.game.bvn.ui.UIUtils;
import net.play5d.game.bvn.utils.BtnUtils;
import net.play5d.kyo.display.bitmap.BitmapFontText;
import net.play5d.kyo.display.shapes.Box;

public class ConfrimUI extends BaseDialog {
    include '../../../../../../../include/_INCLUDE_OVERRIDE_.as';

    public function ConfrimUI() {
        super();
//			_ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog, 'dialog_confrim');
//			_dialogUI= _ui;

        build();
    }
    private var _enTxt:BitmapFontText;
    private var _old_cnTxt:TextField;
    private var _btnGroup:SetBtnGroup;

//		public var yesBack:Function;
//		public var noBack:Function;
    private var _ui:Sprite;

    override protected function onDestory():void {
        super.onDestory();

        if (_old_cnTxt) {
            _old_cnTxt = null;
        }
        if (_cnTxt) {
            _cnTxt.destory();
            _cnTxt = null;
        }
        if (_enTxt) {
            _enTxt.dispose();
            _enTxt = null;
        }
        if (_btnGroup) {
            _btnGroup.removeEventListener(SetBtnEvent.SELECT, selectHandler);
            _btnGroup.destory();
            _btnGroup = null;
        }

        BtnUtils.destoryBtn(_noBtn);
        BtnUtils.destoryBtn(_yesBtn);
    }

    override public function setMsg(en:String = null, cn:String = null):void {
        _enTxt.text = en ? en : '';
        _enTxt.x    = (
                              GameConfig.GAME_SIZE.x - _enTxt.width
                      ) / 2;

//			if(!cn) return;

        if (_old_cnTxt) {
            _old_cnTxt.text = cn ? cn : "";
        }
        if (_cnTxt) {
            _cnTxt.text = cn ? cn : "";
        }
    }

    private function build():void {
        _ui       = new Sprite();
        _dialogUI = _ui;

//			var bg:Sprite = new Sprite();
//			bg.graphics.beginFill(0x000000,0.3);
//			bg.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);
//			bg.graphics.endFill();
//			addChild(bg);

        var box:Box = new Box(GameConfig.GAME_SIZE.x, 300, 0, 0.8);
        box.y       = (
                              GameConfig.GAME_SIZE.y - box.height
                      ) / 2;
        _ui.addChild(box);

        _enTxt   = new BitmapFontText(AssetManager.I.getFont('font1'));
        _enTxt.y = 18;
        box.addChild(_enTxt);

        if (GameUI.SHOW_CN_TEXT) {
            _old_cnTxt = new TextField();
            UIUtils.formatText(_old_cnTxt, {color: 0xffffff, size: 20, align: TextFormatAlign.CENTER});
            _old_cnTxt.y            = _enTxt.y + _enTxt.height + 80;
            _old_cnTxt.width        = GameConfig.GAME_SIZE.x;
            _old_cnTxt.height       = 100;
            _old_cnTxt.mouseEnabled = false;
            box.addChild(_old_cnTxt);
        }


        _btnGroup        = new SetBtnGroup();
        _btnGroup.startX = _btnGroup.startY = 0;
        _btnGroup.direct = 0;
        _btnGroup.gap    = 200;
        _btnGroup.setBtnData([{label: 'YES', cn: '是'}, {label: 'NO', cn: '否'}], 1);
        _btnGroup.addEventListener(SetBtnEvent.SELECT, selectHandler);
        _btnGroup.x = (
                              GameConfig.GAME_SIZE.x - _btnGroup.width
                      ) / 2 + 30;
        _btnGroup.y = box.height - 80;
        box.addChild(_btnGroup);

        var boxy:Number = box.y;
        box.y           = GameConfig.GAME_SIZE.y;
        TweenLite.to(box, 0.2, {y: boxy});
    }

    private function selectHandler(e:SetBtnEvent):void {
        switch (e.selectedLabel) {
        case 'YES':
            if (yesBack != null) {
                yesBack();
            }
            break;
        case 'NO':
            if (noBack != null) {
                noBack();
            }
            break;
        }
    }

}
}
