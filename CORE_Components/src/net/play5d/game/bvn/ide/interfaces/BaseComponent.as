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

package net.play5d.game.bvn.ide.interfaces {
import flash.display.MovieClip;

import net.play5d.game.bvn.ide.entity.GameSpriteEntity;
import net.play5d.game.bvn.interfaces.IComponents;

/**
 * 基本组件
 */
public class BaseComponent extends MovieClip implements IComponents {

    /////////////// 静态方法 ///////////////

    ///////////////////////////////////////


    /////////////// 构造方法 ///////////////

    public function BaseComponent() {
        if (!root) {
            return;
        }

        // 初始化
        _gameSpriteEntity = new GameSpriteEntity(this);

        $self   = _gameSpriteEntity.self;
        $target = _gameSpriteEntity.target;
        $owner  = _gameSpriteEntity.owner;

        addFrameScript(0, init);
    }

    ///////////////////////////////////////


    /////////////// 实现接口 ///////////////

    /**
     * 销毁自身
     */
    public function destroy():void {
        try {
            parent.removeChild(this);
        }
        catch (e:Error) {
        }

        $self   = null;
        $target = null;
        $owner  = null;

        if (_gameSpriteEntity) {
            _gameSpriteEntity.destroy();
            _gameSpriteEntity = null;
        }
    }

    ///////////////////////////////////////


    /////////////// 公有属性 ///////////////

    ///////////////////////////////////////


    /////////////// 私有属性 ///////////////

    /* 游戏元件实体 */
    protected var _gameSpriteEntity:GameSpriteEntity;

    /* 自身类引用 */
    protected var $self:*   = null;
    /* 对手主人类引用，类型 FighterMain */
    protected var $target:* = null;
    /* 最顶主人类引用，类型 FighterMain */
    protected var $owner:*  = null;

    ///////////////////////////////////////


    /////////// Getter & Setter ///////////

    ///////////////////////////////////////

    /////////////// 公有方法 ///////////////

    /**
     * 初始化
     * 第一帧要执行的代码
     */
    public function init():void {
        hidden();
        doAction();
        destroy();
    }

    /**
     * 要详细执行的动作
     */
    public function doAction():void {
    }

    ///////////////////////////////////////


    /////////////// 私有方法 ///////////////

    /**
     * 隐藏自身
     */
    protected function hidden():void {
        visible = false;
    }

    ///////////////////////////////////////
}
}
