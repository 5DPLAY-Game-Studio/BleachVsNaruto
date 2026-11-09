/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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
 * Animate IDE 组件基类（类，非 interface）。
 *
 * <p>生命周期：构造挂接第 0 帧，再执行 <code>init</code>（隐藏 → <code>doAction</code> → <code>destroy</code>）。</p>
 * <p><code>$self</code> / <code>$target</code> / <code>$owner</code> 在 <code>bindContext</code> 时惰性解析。</p>
 *
 * @see net.play5d.game.bvn.interfaces.IComponents
 * @see net.play5d.game.bvn.ide.entity.GameSpriteEntity
 */
public class BaseComponent extends MovieClip implements IComponents {

    /** @private 游戏元件实体（惰性创建） */
    protected var _gameSpriteEntity:GameSpriteEntity;

    /**
     * 自身游戏精灵。
     *
     * <p><code>bindContext</code> 时写入；销毁后为 <code>null</code>。</p>
     *
     * @default null
     * @see #bindContext()
     */
    protected var $self:* = null;

    /**
     * 对手主人类引用，解析后为 FighterMain。
     *
     * @default null
     * @see #bindContext()
     */
    protected var $target:* = null;

    /**
     * 最顶主人类引用，解析后为 FighterMain。
     *
     * @default null
     * @see #bindContext()
     */
    protected var $owner:* = null;

    /**
     * 挂到舞台后，把 <code>init</code> 登记到第 0 帧。
     *
     * <p>没有 <code>root</code> 时不登记，供检查器预览实例使用。</p>
     *
     * @example
     * <listing version="3.0">
     * var component:BaseComponent = new BaseComponent();
     * </listing>
     */
    public function BaseComponent() {
        if (!root) {
            return;
        }

        addFrameScript(0, init);
    }

    /**
     * @inheritDoc
     */
    public function destroy():void {
        try {
            if (parent) {
                parent.removeChild(this);
            }
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

    /**
     * 初始化。
     *
     * <p>第一帧执行：绑定上下文 → 隐藏 → 动作 → 销毁。</p>
     *
     * @example
     * <listing version="3.0">
     * component.init();
     * </listing>
     * @see #doAction()
     * @see #destroy()
     */
    public function init():void {
        bindContext();
        hidden();
        doAction();
        destroy();
    }

    /**
     * 执行组件动作。
     *
     * <p>基类为空实现，子类覆盖后调用对应控制器。</p>
     *
     * @example
     * <listing version="3.0">
     * doAction();
     * </listing>
     */
    public function doAction():void {
    }

    /**
     * 绑定游戏上下文引用。
     *
     * <p>仅在需要 <code>$self</code> / <code>$target</code> / <code>$owner</code> 时创建实体。</p>
     *
     * @example
     * <listing version="3.0">
     * bindContext();
     * </listing>
     * @see #$self
     * @see #$target
     * @see #$owner
     * @see net.play5d.game.bvn.ide.entity.GameSpriteEntity
     */
    protected function bindContext():void {
        if (!_gameSpriteEntity) {
            _gameSpriteEntity = new GameSpriteEntity(this);
        }

        $self   = _gameSpriteEntity.self;
        $target = _gameSpriteEntity.target;
        $owner  = _gameSpriteEntity.owner;
    }

    /**
     * 隐藏自身，避免模板出现在画面上。
     *
     * @example
     * <listing version="3.0">
     * hidden();
     * </listing>
     */
    protected function hidden():void {
        visible = false;
    }
}
}
