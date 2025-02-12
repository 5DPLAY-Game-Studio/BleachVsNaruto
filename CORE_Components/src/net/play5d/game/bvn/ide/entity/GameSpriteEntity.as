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

package net.play5d.game.bvn.ide.entity {
import flash.display.DisplayObject;
import flash.display.MovieClip;

import net.play5d.game.bvn.ide.data.GamePKGName;
import net.play5d.game.bvn.ide.data.GameSpriteType;
import net.play5d.game.bvn.ide.interfaces.BaseComponent;
import net.play5d.game.bvn.ide.utils.GameSpriteUtils;

/**
 * 游戏元件实体
 */
public class GameSpriteEntity {

    /////////////// 静态方法 ///////////////

    ///////////////////////////////////////


    /////////////// 构造方法 ///////////////

    /**
     * 构造函数
     * @param component 组件
     */
    public function GameSpriteEntity(component:BaseComponent) {
        _this      = component.parent ? component.parent as MovieClip : null;
        _component = component;

        FighterMain     = GameSpriteUtils.getGameSpriteClass(GameSpriteType.FIGHTER_MAIN);
        Assister        = GameSpriteUtils.getGameSpriteClass(GameSpriteType.ASSISTER);
        Bullet          = GameSpriteUtils.getGameSpriteClass(GameSpriteType.BULLET);
        FighterAttacker = GameSpriteUtils.getGameSpriteClass(GameSpriteType.FIGHTER_ATTACKER);

        GameCtrl = GameSpriteUtils.getGameClass(GamePKGName.CTRLER_GAMECTRLS + 'GameCtrl');
    }

    ///////////////////////////////////////


    /////////////// 实现接口 ///////////////

    /**
     * 销毁自身
     */
    public function destroy():void {
        _this      = null;
        _component = null;

        FighterMain     = null;
        Assister        = null;
        Bullet          = null;
        FighterAttacker = null;

        GameCtrl = null;

        _self   = null;
        _target = null;
        _owner  = null;

        _selfType = null;
    }


    ///////////////////////////////////////


    /////////////// 公有属性 ///////////////

    ///////////////////////////////////////


    /////////////// 私有属性 ///////////////

    /* 指向放置的组件 this */
    private var _this:MovieClip;
    /* 组件 */
    private var _component:BaseComponent;

    /* FighterMain  */
    private var FighterMain:Class;
    /* Assister */
    private var Assister:Class;
    /* Bullet */
    private var Bullet:Class;
    /* FighterAttacker */
    private var FighterAttacker:Class;

    /* GameCtrl */
    private var GameCtrl:Class;

    ///////////////////////////////////////


    /////////// Getter & Setter ///////////

    /* 自身类引用 */
    private var _self:* = null;
    /**
     * 获得自身类引用
     *
     * @return 返回自身 Class
     */
    public function get self():* {
        if (_self) {
            return _self;
        }

        try {
            // 游戏场景
            var gameStage:*   = GameCtrl.I.gameState;
            // 游戏元件
            var gameSprites:* = gameStage.getGameSprites();

            for each (var sp:* in gameSprites) {
                var d:DisplayObject = sp.getDisplay();

                // 等于 this 可获取 FighterAttacker Bullet Assister
                // 等于 this.parent 可获取 FighterMain
                if ((_this        && d == _this) ||
                    (_this.parent && d == _this.parent)
                ) {
                    _self = sp;

                    return _self;
                }
            }
        }
        catch (e:Error) {
        }

        return null;
    }

    /* 对手主人类引用，类型 FighterMain */
    private var _target:* = null;
    /**
     * 获得对手主人类引用，始终返回 FighterMain
     *
     * @return 返回对手 FighterMain
     */
    public function get target():* {
        if (_target) {
            return _target;
        }

        try {
            _target = owner.getCurrentTarget();
        }
        catch (e:Error) {
            return null;
        }

        return _target as FighterMain;
    }

    /* 最顶主人类引用，类型 FighterMain */
    private var _owner:* = null;
    /**
     * 获得最顶主人类引用，始终返回 FighterMain
     *
     * @return 返回玩家 FighterMain
     */
    public function get owner():* {
        if (_owner) {
            return _owner;
        }

        // 临时 owner
        var tOwner:* = null;

        /**
         * FighterMain 直接返回
         * Assister        的 owner 可能是 FighterMain
         * Bullet          的 owner 可能是 FighterMain Assister FighterAttacker
         * FighterAttacker 的 owner 可能是 FighterMain Assister
         */

        try {
            switch (getSelfType()) {
            case GameSpriteType.FIGHTER_MAIN:
                _owner = self;

                break;
            case GameSpriteType.ASSISTER:
                _owner = self.getOwner();

                break;
            case GameSpriteType.BULLET:
                tOwner = self.owner;

                switch (_getType(tOwner)) {
                case GameSpriteType.FIGHTER_MAIN:
                    _owner = tOwner;

                    break;
                case GameSpriteType.ASSISTER:
                    _owner = tOwner.getOwner();

                    break;
                case GameSpriteType.FIGHTER_ATTACKER:
                    tOwner = tOwner.getOwner();

                    switch (_getType(tOwner)) {
                    case GameSpriteType.FIGHTER_MAIN:
                        _owner = tOwner;

                        break;
                    case GameSpriteType.ASSISTER:
                        _owner = tOwner.getOwner();

                        break;
                    }

                    break;
                }

                break;
            case GameSpriteType.FIGHTER_ATTACKER:
                tOwner = self.getOwner();

                switch (_getType(tOwner)) {
                case GameSpriteType.FIGHTER_MAIN:
                    _owner = tOwner;

                    break;
                case GameSpriteType.ASSISTER:
                    _owner = tOwner.getOwner();

                    break;
                }

                break;
            }
        }
        catch (e:Error) {
            return null;
        }

        return _owner;
    }

    /* 自身类型 */
    private var _selfType:String = null;
    /**
     * 获取自身类型
     *
     * @return 返回自身类型
     */
    public function getSelfType():String {
        if (_selfType) {
            return _selfType;
        }

        _selfType = _getType(self);

        return _selfType;
    }

    ///////////////////////////////////////


    /////////////// 公有方法 ///////////////

    ///////////////////////////////////////


    /////////////// 私有方法 ///////////////

    /**
     * 获取类型
     *
     * @param sp 指定sp
     * @return 返回类型
     */
    private function _getType(sp:*):String {
        const TYPE_ARRAY:Array = [
            {
                cls : FighterMain,
                type: GameSpriteType.FIGHTER_MAIN
            }, {
                cls : Assister,
                type: GameSpriteType.ASSISTER
            }, {
                cls : Bullet,
                type: GameSpriteType.BULLET
            }, {
                cls : FighterAttacker,
                type: GameSpriteType.FIGHTER_ATTACKER
            }
        ];

        var type:String = GameSpriteType.UNKNOWN;

        // 遍历是否存在当前的类型
        for each (var o:Object in TYPE_ARRAY) {
            var cls:Class = o.cls as Class;

            if (sp is cls) {
                type = o.type as String;

                break;
            }
        }

        return type;
    }

    ///////////////////////////////////////
}
}
