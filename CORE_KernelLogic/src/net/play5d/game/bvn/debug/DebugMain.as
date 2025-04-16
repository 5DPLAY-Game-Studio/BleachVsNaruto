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

package net.play5d.game.bvn.debug {
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Rectangle;

import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.Bullet;
import net.play5d.game.bvn.fighter.FighterAttacker;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.ctrler.FighterCtrler;
import net.play5d.game.bvn.fighter.models.HitVO;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.utils.MCUtils;
import net.play5d.pcl.utils.ColorUtils;

/**
 * 调试面
 */
public class DebugMain {
    include '../../../../../../include/_INCLUDE_.as';

    // 实例
    private static var _instance:DebugMain;

    /**
     * 获取实例
     */
    public static function get I():DebugMain {
        _instance ||= new DebugMain();

        return _instance;
    }
    // 是否渲染面
    public var isRender:Boolean        = false;
    // 是否已初始化过
    private var _isInitialized:Boolean = false;
    // 游戏图层
    private var _gameLayer:Sprite;

    // 所有面元件
    private var _allMainSp:Sprite;

    /**
     * 初始化
     */
    public function initialize():void {
        if (_isInitialized) {
            return;
        }

        _isInitialized = true;
        GameRender.addAfter(render);
    }

    /**
     * 渲染面
     * @param display
     * @param rect
     */
    public function renderMain(display:DisplayObject, rect:Rectangle):void {
        if (!display || !rect) {
            return;
        }

        display.x      = rect.x;
        display.y      = rect.y;
        display.width  = rect.width;
        display.height = rect.height;

        _allMainSp.addChild(display);
    }

    /**
     * 渲染
     */
    private function render():void {
        // 停止渲染面，则清除目前所有的已渲染面
        if (!isRender) {
            cleanAllMain();
            return;
        }

        // 游戏场景不存在，返回
        if (!GameCtrl.I.gameState) {
            return;
        }

        _gameLayer = GameCtrl.I.gameState.gameLayer;

        // 角色数据不存在，停止并清除所有的已渲染面
        if (!P1 || !P2) {
            cleanAllMain();
            return;
        }

        const ALL_MAIN_SP_NAME:String = 'allMainSp';
        // 如果游戏图层不存在 所有面 元件，则生成一个
        if (!_gameLayer.getChildByName(ALL_MAIN_SP_NAME)) {
            _allMainSp      = new Sprite();
            _allMainSp.name = ALL_MAIN_SP_NAME;
            _gameLayer.addChild(_allMainSp);
        }

        // 将 所有面 元件置于游戏图层最顶层
        _gameLayer.setChildIndex(_gameLayer.getChildByName(ALL_MAIN_SP_NAME), _gameLayer.numChildren - 1);
        // 清空 所有面 元件里的所有面图形元件
        _allMainSp.removeChildren();

        // 开始渲染绘制新帧的 所有面
        renderAllMain();
    }

    /**
     * 渲染所有面
     */
    private function renderAllMain():void {
        // 渲染角色的面
        renderFighterMain(P1);
        renderFighterMain(P2);

        // 渲染部分精灵面
        MCUtils.renderGameSpritesCB(callBack);

        /**
         * 回调
         * @param sp 当前游戏精灵
         */
        function callBack(sp:IGameSprite):void {
            if (!sp) {
                return;
            }

            // 渲染辅助、飞行道具、独立道具的攻击面
            if (sp is Assister || sp is Bullet || sp is FighterAttacker) {
                [ArrayElementType('net.play5d.game.bvn.fighter.models.HitVO')]
                var hitVOs:Array = sp.getCurrentHits();
                renderHitMain(hitVOs);
            }

            // 渲染辅助、独立道具的判定面
            if (sp is Assister || sp is FighterAttacker) {
                var checker:String;
                var checkerArea:Rectangle;

                if (sp is Assister) {
                    checker = (sp as Assister).getCtrler().hitTargetChecker;
                    if (checker) {
                        checkerArea = (sp as Assister).getHitCheckRect(checker);
                    }
                }
                if (sp is FighterAttacker) {
                    checker = (sp as FighterAttacker).getCtrler().hitTargetChecker;
                    if (checker) {
                        checkerArea = (sp as FighterAttacker).getHitCheckRect(checker);
                    }
                }

                if (checkerArea && !checkerArea.isEmpty()) {
                    var checkerShape:Shape = MainUtils.getNewShape(ColorUtils.YELLOW);
                    renderMain(checkerShape, checkerArea);
                }
            }


        }

    }

    /**
     * 渲染攻击面
     * @param hitVOs 攻击值对象数组
     */
    private function renderHitMain(hitVOs:Array):void {
        if (!hitVOs || hitVOs.length == 0) {
            return;
        }

        for each (var hitVO:HitVO in hitVOs) {
            var hitArea:Rectangle = hitVO.currentArea;
            if (hitArea && !hitArea.isEmpty()) {
                var hitShape:Shape = MainUtils.getNewShape(ColorUtils.RED);
                renderMain(hitShape, hitArea);
            }
        }
    }

    /**
     * 渲染角色所有面
     *
     * @param fighter 目标角色
     */
    private function renderFighterMain(fighter:FighterMain):void {
        if (!fighter) {
            return;
        }

        // 渲染角色本体被打面
        var bodyArea:Rectangle = fighter.getBodyArea();
        if (bodyArea && !bodyArea.isEmpty()) {
            var bodyShape:Shape = MainUtils.getNewShape(ColorUtils.GREEN);
            renderMain(bodyShape, bodyArea);
        }

        // 渲染角色本体攻击面 + 灵压爆发攻击面
        [ArrayElementType('net.play5d.game.bvn.fighter.models.HitVO')]
        var hitVOs:Array = fighter.getCurrentHits();
        renderHitMain(hitVOs);

        // 渲染角色本体判定面
        var ctrler:FighterCtrler = fighter.getCtrler();
        var checker:String     = ctrler.getMcCtrl().getAction().hitTargetChecker;
        if (checker) {
            var checkerArea:Rectangle = ctrler.getHitCheckRect(checker);
            if (checkerArea && !checkerArea.isEmpty()) {
                var checkerShape:Shape = MainUtils.getNewShape(ColorUtils.YELLOW);
                renderMain(checkerShape, checkerArea);
            }
        }
    }


    /**
     * 清理已绘制的所有面
     */
    private function cleanAllMain():void {
        if (!_allMainSp) {
            return;
        }

        _allMainSp.removeChildren();
        _gameLayer.removeChild(_allMainSp);
        _allMainSp = null;
    }
}
}

import flash.display.Shape;
import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;
import flash.text.TextFormat;

/**
 * 面相关实用工具
 */
class MainUtils {

    // 默认样式
    public static const DEFAULT_FORMAT:TextFormat = (function ():TextFormat {
        var format:TextFormat = new TextFormat();
        format.font           = '微软雅黑';
        format.color          = 0x000000;
        format.size           = 6;

        return format;
    })();

    // 发光滤镜
    public static const GLOW_FILTER:GlowFilter = (function ():GlowFilter {
        var filter:GlowFilter = new GlowFilter();

        filter.color   = 0xFFFFFF;
        filter.alpha   = 1;
        filter.blurX   = 25;
        filter.blurY   = 25;
        filter.quality = BitmapFilterQuality.LOW;

        return filter;
    })();

    /**
     * 得到一个新 Shape 图形
     *
     * @param color 颜色
     * @param alpha 透明度
     *
     * @return 新 Shape 图形
     */
    public static function getNewShape(color:uint, alpha:Number = 0.33):Shape {
        var shape:Shape = new Shape();

        shape.graphics.beginFill(color, alpha);
        shape.graphics.drawRect(0, 0, 10, 10);
        shape.graphics.endFill();

        return shape;
    }

}
