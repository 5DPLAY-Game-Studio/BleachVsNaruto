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

package net.play5d.game.bvn.stage {
import flash.display.DisplayObject;

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.debug.Debugger;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.utils.GameLogger;
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.stage.IStage;

/**
 * 启动时的资源加载。
 *
 * <p>需要预加载时先走预加载，否则直接读配置，再加载基础资源。进度超过 1 时改成 1。步骤小于 1 时改成 1，大于总步数时改成总步数。
 * 失败时调用失败回调并不再继续。成功回调只调用一次，随后两个回调都清掉。界面还没构建时写进度会抛错。销毁和稍后构建是空的。</p>
 *
 * @see net.play5d.kyo.stage.IStage
 */
public class GameLoadingStage implements IStage {

    private var _ui:$loading$MC_loadingCover;
    private var _initBack:Function;
    private var _initFail:Function;

    /**
     * 显示对象
     */
    public function get display():DisplayObject {
        return _ui;
    }

    /**
     * 构建
     */
    public function build():void {
        _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.loading, '$loading$MC_loadingCover');
    }

    /**
     * 开始预加载或直接读配置。
     *
     * @param succ 资源都好了之后调用。没有下一次。
     * @param fail 预加载或配置失败时调用，参数是错误文字。
     * @throws TypeError 界面还没构建时。
     * @example
     * <listing version="3.0">
     * stage.loadGame(onOk, onFail);
     * </listing>
     */
    public function loadGame(succ:Function, fail:Function):void {
        _initBack = succ;
        _initFail = fail;

        if (AssetManager.I.needPreLoad()) {
            AssetManager.I.loadPreLoad(loadPreloadBack, loadPreloadFail, loadPreloadProgress);
            msg(GetLang('loading.prepare'));
        }
        else {
            loadPreloadBack();
        }
    }

    /**
     * 稍后构建
     */
    public function afterBuild():void {
    }

    /**
     * 销毁
     * @param back 回调函数
     */
    public function destroy(back:Function = null):void {

    }

    private function loadPreloadBack():void {
        GameData.I.loadConfig(loadConfigBack, loadConfigFail);
        msg(GetLang('loading.config'));
    }

    private function loadPreloadFail(errorStr:String = null):void {
        LogLang(GameLogger.DEBUG, 'load', 'game_loading_stage.preload_fail', {error: errorStr || ''});
        msg(GetLang('loading.prepare_fail'));
        if (_initFail != null) {
            _initFail(errorStr);
        }
    }

    private function loadPreloadProgress(p:Number):void {
        if (p > 1) {
            p = 1;
        }
        _ui.bar.bar.scaleX = p;
    }

    private function loadConfigFail(errorStr:String):void {
        LogLang(GameLogger.DEBUG, 'load', 'game_loading_stage.config_fail', {error: errorStr || ''});
        msg(GetLang('loading.config_fail'));
        if (_initFail != null) {
            _initFail(errorStr);
        }
    }

    private function loadConfigBack():void {
        AssetManager.I.loadBasic(loadAssetBack, loadAssetProgress);
        msg(GetLang('loading.assets'));
    }

    private function loadAssetProgress(p:Number, message:String, step:int, totalStep:int):void {
        if (p > 1) {
            TraceLang('game_loading_stage.progress_over_100', {where: message});
            p = 1;
        }
        if (step > totalStep) {
            step = totalStep;
        }
        if (step < 1) {
            step = 1;
        }
        _ui.bar.bar.scaleX = p;

        var txt:String = GetLang('loading.step', {
            itemName : message,
            step     : step,
            totalStep: totalStep
        });
        msg(txt);
        GameEvent.dispatchEvent(GameEvent.LOADING_GAME, {msg: txt, progress: p, step: step, totalStep: totalStep});
    }

    private function loadAssetBack():void {
        if (_initBack != null) {
            _initBack();
            _initBack = null;
        }
        _initFail = null;
    }

    private function msg(v:String):void {
        _ui.bar.txt.text = v;
    }

}
}
