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

package net.play5d.game.bvn.ui {
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.utils.setTimeout;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.events.SetBtnEvent;
import net.play5d.game.bvn.ui.settings.SetBtnGroup;
import net.play5d.game.bvn.utils.UiBitmap;

/**
 * 招式表。图片是异步加载的，销毁之后仍可能加进来。显示 100 毫秒后才打开按键。隐藏会立刻关掉按键。销毁后再隐藏会抛错。
 */
public class MoveListSp extends Sprite {

    /**
     * 开始加载招式图，并放上返回按钮。
     */
    public function MoveListSp() {
        super();

        UiBitmap.load('movelist.jpg', function (bmp:Bitmap):void {
            _pic        = bmp;
            _pic.width  = GameConfig.GAME_SIZE.x;
            _pic.height = GameConfig.GAME_SIZE.y;
            addChildAt(_pic, 0);
        });

        _btns = new SetBtnGroup();
        _btns.setBtnData([{label: 'BACK', cn: GetLang('common.back')}]);
        _btns.addEventListener(SetBtnEvent.SELECT, onSelect);
        _btns.x = 250;
        _btns.y = GameConfig.GAME_SIZE.y - 130;
        addChild(_btns);
    }
    /**
     * 按下返回时调用。null 时按下什么都不做。
     *
     * @default null
     */
    public var onBackSelect:Function;
    /** @private */
    private var _pic:Bitmap;
    private var _btns:SetBtnGroup;

    /**
     * 释放按钮。图片加载回调仍可能把图加进来。
     *
     * @example
     * <listing version="3.0">
     * list.destroy();
     * </listing>
     */
    public function destroy():void {
        if (_btns) {
            _btns.removeEventListener(SetBtnEvent.SELECT, onSelect);
            _btns.destroy();
            _btns = null;
        }
    }

    /**
     * 是否可见。刚创建时为 true。
     *
     * @return 可见时为 true。
     * @example
     * <listing version="3.0">
     * var on:Boolean = list.isShowing();
     * </listing>
     */
    public function isShowing():Boolean {
        return this.visible;
    }

    /**
     * 显示，并在 100 毫秒后打开按键。销毁后到时会抛错。
     *
     * @throws TypeError 按钮已经释放，且延时到点时。
     * @example
     * <listing version="3.0">
     * list.show();
     * </listing>
     */
    public function show():void {

        this.visible = true;
        setTimeout(function ():void {
            _btns.keyEnable = true;
        }, 100);
    }

    /**
     * 关掉按键并隐藏。销毁后抛错。
     *
     * @throws TypeError 按钮已释放时。
     * @example
     * <listing version="3.0">
     * list.hide();
     * </listing>
     */
    public function hide():void {
        _btns.keyEnable = false;
        this.visible    = false;
    }

    private function onSelect(e:Event):void {
        if (onBackSelect != null) {
            onBackSelect();
        }
    }
}
}
