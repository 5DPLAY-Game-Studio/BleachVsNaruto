/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

package net.play5d.game.bvn.ide.component {
import flash.text.TextField;

import net.play5d.game.bvn.ide.data.GameSpriteType;
import net.play5d.game.bvn.ide.interfaces.BaseComponent;

/**
 * 组件 基本效果
 */
public class BaseEffect extends BaseComponent {

    /////////////// 静态方法 ///////////////

    ///////////////////////////////////////


    /////////////// 构造方法 ///////////////

    /**
     * 构造方法
     */
    public function BaseEffect() {
        super();
    }

    ///////////////////////////////////////


    /////////////// 实现接口 ///////////////

    /**
     * 销毁自身
     */
    override public function destroy():void {
        titleTxt = null;
        textTxt  = null;

        _effectCtrler = null;

        super.destroy();
    }

    ///////////////////////////////////////


    /////////////// 公有属性 ///////////////

    /* 标题文本 */
    public var titleTxt:TextField = getChildByName('titleTxt') as TextField;
    /* 文字文本 */
    public var textTxt:TextField  = getChildByName('textTxt') as TextField;

    ///////////////////////////////////////


    /////////////// 私有属性 ///////////////

    /* 特效控制器 */
    protected var _effectCtrler:* = null;

    ///////////////////////////////////////


    /////////// Getter & Setter ///////////

    /* 标题文本 */
    public function get title():String {
        return titleTxt.text;
    }
    public function set title(v:String):void {
        titleTxt.text = v;
    }

    /* 文字文本 */
    public function get text():String {
        return textTxt.text;
    }
    public function set text(v:String):void {
        textTxt.text = v;
    }

    ///////////////////////////////////////


    /////////////// 公有方法 ///////////////

    /**
     * 第一帧要执行的代码
     */
    override public function init():void {
        // 初始化特效控制器
        initEffectCtrler();

        hidden();
        doAction();
        destroy();
    }

    /**
     * 要详细执行的动作
     */
    override public function doAction():void {
        super.doAction();
    }

    ///////////////////////////////////////


    /////////////// 私有方法 ///////////////

    /**
     * 初始化特效控制器
     */
    private function initEffectCtrler():void {
//        switch (_gameSpriteEntity.getSelfType()) {
//        case GameSpriteType.FIGHTER_MAIN:
//            _effectCtrler = $self.getCtrler().getEffectCtrl();
//            break;
//        }

        _effectCtrler = $owner.getCtrler().getEffectCtrl();
    }

    ///////////////////////////////////////
}
}
