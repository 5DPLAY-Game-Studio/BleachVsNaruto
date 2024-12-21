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
import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.GameRender;
import net.play5d.game.bvn.utils.ResUtils;

public class TransUI {
    include '../../../../../../include/_INCLUDE_.as';

    public function TransUI() {
        ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui, 'trans_mc');
    }
    public var ui:trans_mc;
    private var _renderAnimateGap:int   = 0; //刷新动画间隔
    private var _renderAnimateFrame:int = 0;
    private var _fadInBack:Function;

//		private var _justRender:Boolean;
    private var _fadOutBack:Function;
    private var _rendering:Boolean = true;

    public function destory():void {
        GameRender.remove(render);
    }

    public function fadIn(back:Function = null):void {
//			trace('fadIn');
        _fadOutBack = null;

        _fadInBack = back;
        ui.gotoAndStop('fadin');
        startRender();
    }

    public function fadOut(back:Function = null):void {
        _fadInBack = null;

//			trace('fadOut');
        _fadOutBack = back;
        ui.gotoAndStop('fadout');
        startRender();
    }

    private function startRender():void {
        _renderAnimateGap   = Math.ceil(MainGame.I.getFPS() / GameConfig.FPS_UI) - 1;
        _renderAnimateFrame = 0;

        _rendering = true;

        GameRender.add(render);

    }

    private function stopRender():void {
        _rendering = false;
        GameRender.remove(render);
    }

    private function render():void {

        if (!_rendering) {
            return;
        }

        if (_renderAnimateGap > 0) {
            if (_renderAnimateFrame++ >= _renderAnimateGap) {
                _renderAnimateFrame = 0;
                renderAnimate();
            }
        }
        else {
            renderAnimate();
        }
    }

    private function renderAnimate():void {

//			trace('TrainsUI.renderAnimate',ui.currentFrame,ui.currentFrameLabel);

        if (ui.currentFrameLabel == 'stop') {

            //这里要处理在fadinback中定义了fadoutback的情况，所以只能这样写

            if (_fadInBack != null) {
                _fadInBack();
                _fadInBack = null;
                return;
            }
            if (_fadOutBack != null) {
                _fadOutBack();
                _fadOutBack = null;
                return;
            }

            stopRender();

            return;
        }
        ui.nextFrame();
    }

}
}
