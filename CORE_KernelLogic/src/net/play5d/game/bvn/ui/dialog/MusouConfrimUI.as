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

import flash.display.SimpleButton;
import flash.text.TextFormatAlign;

import net.play5d.game.bvn.ui.Text;
import net.play5d.game.bvn.utils.BtnUtils;
import net.play5d.game.bvn.utils.ResUtils;

public class MusouConfrimUI extends BaseDialog {
    include '../../../../../../../include/_INCLUDE_OVERRIDE_.as';

//		private var _cnTxt:Text;

//		public var yesBack:Function;
//		public var noBack:Function;

    public function MusouConfrimUI() {
        super();

        width  = 495;
        height = 240;

        _ui       = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog, 'dialog_confrim');
        _dialogUI = _ui;

        build();
    }

//		protected var _noBtn:SimpleButton;
//		protected var _yesBtn:SimpleButton;
    private var _ui:dialog_confrim;

    protected override function onDestory():void {
        super.onDestory();
        if (_cnTxt) {
            _cnTxt.destory();
            _cnTxt = null;
        }
        BtnUtils.destoryBtn(_noBtn);
        BtnUtils.destoryBtn(_yesBtn);
    }

    override public function setMsg(en:String = null, cn:String = null):void {
        setTitle(en);

        if (!cn) {
            return;
        }

        _cnTxt.text    = cn;
        _cnTxt.visible = true;
    }

    protected function build():void {
        _cnTxt         = new Text();
        _cnTxt.leading = 12;
        _cnTxt.x       = 15;
        _cnTxt.y       = 35;
        _cnTxt.width   = 460;
        _cnTxt.height  = 140;
        _cnTxt.multiLine(true);
        _cnTxt.align = TextFormatAlign.CENTER;
        _ui.addChild(_cnTxt);

        _noBtn  = _ui.getChildByName('no') as SimpleButton;
        _yesBtn = _ui.getChildByName('yes') as SimpleButton;

        BtnUtils.initBtn(_noBtn, okHandler);
        BtnUtils.initBtn(_yesBtn, okHandler);
    }

    private function okHandler(e:SimpleButton):void {
        switch (e) {
        case _yesBtn:
            if (yesBack != null) {
                yesBack();
            }
            break;
        case _noBtn:
            if (noBack != null) {
                noBack();
            }
            break;
        }
    }

}
}
