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

package net.play5d.game.bvn.ide.entity {
import flash.display.DisplayObject;
import flash.display.MovieClip;

import net.play5d.game.bvn.ide.data.GamePKGName;
import net.play5d.game.bvn.ide.data.GameSpriteType;
import net.play5d.game.bvn.ide.interfaces.BaseComponent;
import net.play5d.game.bvn.ide.utils.GameSpriteUtils;

/**
 * 游戏元件实体。
 *
 * <p>将 IDE 组件所在显示树解析为运行时 <code>self</code> / <code>target</code> / <code>owner</code>。</p>
 * <p>反射类静态缓存一次；owner 通过递归上溯到 FighterMain。</p>
 *
 * @see net.play5d.game.bvn.ide.data.GameSpriteType
 * @see net.play5d.game.bvn.ide.utils.GameSpriteUtils
 */
public class GameSpriteEntity {

    /** @private 是否已加载反射类 */
    private static var _classesReady:Boolean = false;

    /** @private */
    private static var FighterMain:Class;

    /** @private */
    private static var Assister:Class;

    /** @private */
    private static var Bullet:Class;

    /** @private */
    private static var FighterAttacker:Class;

    /** @private */
    private static var GameCtrl:Class;

    /** @private 组件所在父级 MC */
    private var _thisMc:MovieClip;

    /** @private 自身类引用 */
    private var _self:* = null;

    /** @private 对手主人类引用 */
    private var _target:* = null;

    /** @private 最顶主人类引用 */
    private var _owner:* = null;

    /** @private 自身类型 */
    private var _selfType:String = null;

    /**
     * 构造方法。
     *
     * @param component 组件。
     */
    public function GameSpriteEntity(component:BaseComponent) {
        ensureClasses();
        _thisMc = component.parent ? component.parent as MovieClip : null;
    }

    /**
     * 销毁自身。
     */
    public function destroy():void {
        _thisMc   = null;
        _self     = null;
        _target   = null;
        _owner    = null;
        _selfType = null;
    }

    /**
     * 自身游戏精灵引用。
     *
     * @return 自身游戏精灵；未找到时返回 <code>null</code>。
     */
    public function get self():* {
        if (_self) {
            return _self;
        }

        if (!GameCtrl || !_thisMc) {
            return null;
        }

        try {
            var gameStage:*   = GameCtrl.I.gameState;
            var gameSprites:* = gameStage.getGameSprites();

            for each (var sp:* in gameSprites) {
                var d:DisplayObject = sp.getDisplay();
                if (d == _thisMc || (_thisMc.parent && d == _thisMc.parent)) {
                    _self = sp;
                    return _self;
                }
            }
        }
        catch (e:Error) {
        }

        return null;
    }

    /**
     * 对手主人类引用（始终为 FighterMain）。
     *
     * @return 对手 FighterMain；未找到时返回 <code>null</code>。
     */
    public function get target():* {
        if (_target) {
            return _target;
        }

        try {
            var o:* = owner;
            if (o) {
                _target = o.getCurrentTarget();
            }
        }
        catch (e:Error) {
            return null;
        }

        return FighterMain ? _target as FighterMain : _target;
    }

    /**
     * 最顶主人类引用（始终为 FighterMain）。
     *
     * @return 玩家 FighterMain；未找到时返回 <code>null</code>。
     */
    public function get owner():* {
        if (_owner) {
            return _owner;
        }

        _owner = resolveFighterOwner(self);
        return _owner;
    }

    /**
     * 获取自身类型。
     *
     * @return 自身类型字符串（见 <code>GameSpriteType</code>）。
     *
     * @see net.play5d.game.bvn.ide.data.GameSpriteType
     */
    public function getSelfType():String {
        if (_selfType) {
            return _selfType;
        }

        _selfType = getType(self);
        return _selfType;
    }

    /** @private */
    private static function ensureClasses():void {
        if (_classesReady) {
            return;
        }
        _classesReady = true;

        FighterMain     = GameSpriteUtils.getGameSpriteClass(GameSpriteType.FIGHTER_MAIN);
        Assister        = GameSpriteUtils.getGameSpriteClass(GameSpriteType.ASSISTER);
        Bullet          = GameSpriteUtils.getGameSpriteClass(GameSpriteType.BULLET);
        FighterAttacker = GameSpriteUtils.getGameSpriteClass(GameSpriteType.FIGHTER_ATTACKER);
        GameCtrl        = GameSpriteUtils.getGameClass(GamePKGName.CTRLER_GAMECTRLS + 'GameCtrl');
    }

    /** @private */
    private function resolveFighterOwner(sp:*):* {
        if (!sp) {
            return null;
        }

        var type:String = getType(sp);
        if (type == GameSpriteType.FIGHTER_MAIN) {
            return sp;
        }

        var next:* = null;
        try {
            switch (type) {
            case GameSpriteType.ASSISTER:
            case GameSpriteType.FIGHTER_ATTACKER:
                next = sp.getOwner();
                break;
            case GameSpriteType.BULLET:
                next = sp.owner;
                break;
            }
        }
        catch (e:Error) {
            return null;
        }

        if (!next || next == sp) {
            return null;
        }

        return resolveFighterOwner(next);
    }

    /** @private */
    private static function getType(sp:*):String {
        if (!sp) {
            return GameSpriteType.UNKNOWN;
        }

        if (FighterMain && sp is FighterMain) {
            return GameSpriteType.FIGHTER_MAIN;
        }
        if (Assister && sp is Assister) {
            return GameSpriteType.ASSISTER;
        }
        if (Bullet && sp is Bullet) {
            return GameSpriteType.BULLET;
        }
        if (FighterAttacker && sp is FighterAttacker) {
            return GameSpriteType.FIGHTER_ATTACKER;
        }

        return GameSpriteType.UNKNOWN;
    }
}
}
