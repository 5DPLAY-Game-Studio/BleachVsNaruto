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

package net.play5d.kyo.stage {
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.utils.getQualifiedClassName;
import flash.utils.setTimeout;

import net.play5d.kyo.stage.effect.IStageFadEffect;
import net.play5d.kyo.stage.events.KyoStageEvent;

public class KyoStageCtrl extends EventDispatcher {
    public function KyoStageCtrl(mainStage:Sprite) {
        _mainStage = mainStage;
    }

    /**
     * 切换场景时，暂时停止场景的点击事件
     */
    public var changeStateMouseGap:int = 0;
    private var _mainStage:Sprite;
    private var _curStage:IStage;
    private var _layers:Array          = [];

    public function get currentStage():IStage {
        return _curStage;
    }

    public function get noneLayer():Boolean {
        return _layers.length == 0;
    }

    private function set stageMouseChildren(v:Boolean):void {
        if (_mainStage.stage) {
            _mainStage.stage.mouseChildren = v;
        }
    }

    /**
     * 切换换场景
     * @param stg 场景对象，继续接口：Istage
     * @param sameChange 在切换到的场景与当前场景相同时，是否也要切换
     * @param buildAfterDestory 在当前场景卸载后加载新场景
     */
    public function goStage(stg:IStage, sameChange:Boolean = false, buildAfterDestory:Boolean = false):Boolean {
        function detoryComplete():void {
            try {
                _mainStage.removeChild(_curStage.display);
            }
            catch (e:Error) {
                trace('KyoStageCtrl: goStage:', e);
            }

            _curStage = null;
            newStage();
        }

        function newStage():void {
            if (changeStateMouseGap > 0) {
                stageMouseChildren = false;
                setTimeout(function ():void {
                    stageMouseChildren = true;
                }, changeStateMouseGap);
            }

            _curStage = stg;
            _curStage.build();
            _mainStage.addChild(_curStage.display);
            _curStage.afterBuild();
        }

        if (!sameChange) {
            var classname:String = getQualifiedClassName(stg);
            var classname2:String = getQualifiedClassName(_curStage);
            if (classname == classname2) {
                return false;
            }
        }
        if (_curStage) {
            if (buildAfterDestory) {
                _curStage.destroy(detoryComplete);
            }
            else {
                _curStage.destroy();
                detoryComplete();
            }
        }
        else {
            newStage();
        }

        dispatchEvent(new KyoStageEvent(KyoStageEvent.CHANGE_STATE, stg));

        return true;
    }

    /**
     * 显示弹出层
     * @param layer 弹出层
     * @param x NaN 时 = 水平居中
     * @param y NaN 时 = 垂直居中
     * @param removeElse (独占)为true时，关闭其他已经弹出的层
     * @param effect 弹出时效果
     */
    public function addLayer(
            layer:IStage, x:Number = 0, y:Number = 0, removeElse:Boolean = false, effect:IStageFadEffect = null,
            addBack:Function                                                                             = null
    ):void {
        if (removeElse) {
            removeAllLayer();
        }
        layer.build();

        var sw:Number = _mainStage.stage.stageWidth;
        var sh:Number = _mainStage.stage.stageHeight;

        var dw:Number = layer.display.width * _mainStage.scaleX;
        var dh:Number = layer.display.height * _mainStage.scaleY;

        if (isNaN(x)) {
            layer.display.x = (
                                      sw - dw
                              ) / 2;
        }
        else {
            layer.display.x = x;
        }
        if (isNaN(y)) {
            layer.display.y = (
                                      sh - dh
                              ) / 2;
        }
        else {
            layer.display.y = y;
        }
        _mainStage.addChild(layer.display);
        if (effect) {
            effect.fadIn(layer, effectBack);
        }
        else {
            effectBack();
        }

        function effectBack():void {
            layer.afterBuild();
            if (addBack != null) {
                addBack();
            }
        }

        _layers.push(layer);
    }

    public function hasLayer(layer:Object):Boolean {
        for each(var i:IStage in _layers) {
            if (layer is IStage) {
                if (i == layer) {
                    return true;
                }
            }
            if (layer is Class) {
                var c:Class = layer as Class;
                if (i is c) {
                    return true;
                }
            }
        }
        return false;
    }

    public function removeLayer(layer:IStage, effect:IStageFadEffect = null, removeBack:Function = null):void {

        if (effect) {
            effect.fadOut(layer, effectFin);
        }
        else {
            effectFin();
        }

        function effectFin():void {
            try {
                _mainStage.removeChild(layer.display);
                layer.destroy();
            }
            catch (e:Error) {
                trace('KyoStageCtrl: removeLayer:', e);
            }
            var ix:int = _layers.indexOf(layer);
            if (ix != -1) {
                _layers.splice(ix, 1);
            }

            if (removeBack != null) {
                removeBack();
            }
        }

    }

    public function removeAllLayer():void {
        for each(var i:IStage in _layers) {
            removeLayer(i);
        }
        _layers = [];
    }

    public function clean(_removeAllLayer:Boolean = true):void {
        if (_removeAllLayer) {
            removeAllLayer();
        }
        if (_curStage) {
            _curStage.destroy();
            _mainStage.removeChild(_curStage.display);
            _curStage = null;
        }
    }

}
}
