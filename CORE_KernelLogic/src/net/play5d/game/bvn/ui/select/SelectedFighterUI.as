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

package net.play5d.game.bvn.ui.select {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.filters.GlowFilter;
import flash.text.TextFormatAlign;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.ui.UIUtils;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.display.BitmapText;

/**
 * 大头像
 * @author weijian
 */
public class SelectedFighterUI extends EventDispatcher {
    include '../../../../../../../include/_INCLUDE_.as';

    public function SelectedFighterUI(ui:Sprite) {
        this.ui = ui;

        ui.mouseChildren = false;

        if (GameUI.SHOW_CN_TEXT) {
            _text = new BitmapText(true, 0xffffff, [new GlowFilter(0, 1, 3, 3, 3)]);

            if (ui is selected_item_p1_mc) {
                UIUtils.formatText(_text.textfield, {color: 0xffffff, size: 14, align: TextFormatAlign.RIGHT});
                _text.width = ui.width - 10;
            }
            else {
                UIUtils.formatText(_text.textfield, {color: 0xffffff, size: 14, align: TextFormatAlign.LEFT});
                _text.x     = 10;
                _text.width = ui.width - 10;
            }

            _text.y = ui.height - 30;
            ui.addChild(_text);
        }
    }
    public var ui:Sprite;
    public var trueY:Number = 0;
    private var _fighterIndex:int = -1;
    private var _face:DisplayObject;
    private var _fighter:FighterVO;
    private var _text:BitmapText;
    private var _uiWidth:Number;

    public function mouseEnabled(v:Boolean):void {
        if (v) {
            if (GameConfig.TOUCH_MODE) {
                ui.addEventListener(TouchEvent.TOUCH_TAP, mouseHandler);
            }
            else {
                ui.buttonMode = true;
                ui.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
                ui.addEventListener(MouseEvent.CLICK, mouseHandler);
            }
        }
        else {
            ui.buttonMode = false;
            ui.removeEventListener(TouchEvent.TOUCH_TAP, mouseHandler);
            ui.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
            ui.removeEventListener(MouseEvent.CLICK, mouseHandler);
        }

    }

    public function destory():void {
        if (ui) {
            ui.removeEventListener(TouchEvent.TOUCH_TAP, mouseHandler);
            ui.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
            ui.removeEventListener(MouseEvent.CLICK, mouseHandler);
        }
        if (_text) {
            _text.destory();
            _text = null;
        }
    }

    public function setFighter(vo:FighterVO):void {

        if (!vo) {
            return;
        }

        _fighter = vo;

        if (_text) {
            _text.text = vo.name;
        }

        var ctm:$select$SP_ct  = ui.getChildByName('ct') as $select$SP_ct;
        var ct:Sprite = ctm ? ctm.getChildByName('ct') as Sprite : null;
        if (ct) {

            if (_face) {
                try {
                    ct.removeChild(_face);
                }
                catch (e:Error) {
                }
            }

            var face:DisplayObject = AssetManager.I.getFighterFaceBig(vo);
            if (face) {
                _face = face;
                ct.addChild(face);
            }
        }
    }

    public function getFighter():FighterVO {
        return _fighter;
    }

    public function getFighterIndex():int {
        return _fighterIndex;
    }

    public function setFighterIndex(index:int):void {
        _fighterIndex = index;

        var au:$loading$MC_selectText = ResUtils.I.createDisplayObject(
                ResUtils.swfLib.select,
                '$loading$MC_selectText'
        );
        au.gotoAndStop(index);
        ui.addChild(au);
        if (ui is selected_item_p1_mc) {
            au.x = -8;
        }
        else {
            au.x = 252 - au.width;
        }
        au.y = -5;

        mouseEnabled(false);
    }

    public function setAssister():void {
        var au:$loading$MC_selectText = ResUtils.I.createDisplayObject(
                ResUtils.swfLib.select,
                'seltwzmc'
        );
        au.gotoAndStop(4);
        ui.addChild(au);
        if (ui is selected_item_p1_mc) {
            au.x = -8;
        }
        else {
            au.x = 176;
        }
        au.y = -5;
    }

    private function mouseHandler(e:Event):void {
        dispatchEvent(e);
    }

}
}
