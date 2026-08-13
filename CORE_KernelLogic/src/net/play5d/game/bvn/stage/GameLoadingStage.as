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
import net.play5d.game.bvn.utils.ResUtils;
import net.play5d.kyo.stage.IStage;

public class GameLoadingStage implements IStage {

    public function GameLoadingStage() {
    }
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

    public function loadGame(succ:Function, fail:Function):void {
        _initBack = succ;
        _initFail = fail;

        if (AssetManager.I.needPreLoad()) {
            AssetManager.I.loadPreLoad(loadPreloadBack, loadPreloadFail, loadPreloadProgress);
            msg(GetLang('txt.game_loading_stage.prepare'));
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
        msg(GetLang('txt.game_loading_stage.loading_config'));
    }

    private function loadPreloadFail(errorStr:String = null):void {
        Debugger.log(GetLang('debug.log.data.game_loading_stage.preload_fail', {error: errorStr || ''}));
        msg(GetLang('txt.game_loading_stage.prepare_fail'));
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
        Debugger.log(GetLang('debug.log.data.game_loading_stage.config_fail', {error: errorStr || ''}));
        msg(GetLang('txt.game_loading_stage.config_fail'));
        if (_initFail != null) {
            _initFail(errorStr);
        }
    }

    private function loadConfigBack():void {
        AssetManager.I.loadBasic(loadAssetBack, loadAssetProgress);
        msg(GetLang('txt.game_loading_stage.loading_assets'));
    }

    private function loadAssetProgress(p:Number, message:String, step:int, totalStep:int):void {
        if (p > 1) {
            TraceLang('debug.trace.data.game_loading_stage.progress_over_100', {where: message});
            p = 1;
        }
        if (step > totalStep) {
            step = totalStep;
        }
        if (step < 1) {
            step = 1;
        }
        _ui.bar.bar.scaleX = p;

        var txt:String = GetLang('txt.game_loading_stage.loading_step', {
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
