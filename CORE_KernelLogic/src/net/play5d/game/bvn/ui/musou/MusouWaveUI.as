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

package net.play5d.game.bvn.ui.musou {
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;

import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.ctrler.musou_ctrls.MusouCtrl;
import net.play5d.kyo.utils.KyoColor;
import net.play5d.kyo.utils.KyoDrawUtils;

/**
 * 无双波次。没有 <code>ct_circle</code> 时构造抛错。文本缺失时刷新抛错。圆环角度是进度乘 360 后的整数。
 */
public class MusouWaveUI {

    /**
     * 记下波次文本，并在圆环容器里放一张位图。
     *
     * @param ui 波次界面。null 或没有圆环容器时抛错。
     * @throws TypeError 界面或圆环容器缺失时。
     */
    public function MusouWaveUI(ui:Sprite) {
        _ui = ui;

        _txtCur = ui.getChildByName('txt') as TextField;
        _txtMax = ui.getChildByName('txt_max') as TextField;

        _circleBp = new Bitmap();

        var ct:Sprite = ui.getChildByName('ct_circle') as Sprite;
        ct.addChild(_circleBp);

    }
    private var _ui:Sprite;
    private var _txtCur:TextField;
    private var _txtMax:TextField;
    private var _circleMc:Sprite;
    private var _circleBp:Bitmap;

    /**
     * 刷新当前波、总波和圆环。
     *
     * @throws TypeError 文本或无双对局缺失时。
     * @example
     * <listing version="3.0">
     * wave.renderAnimate();
     * </listing>
     */
    public function renderAnimate():void {
        var musouCtrl:MusouCtrl = GameCtrl.I.getMusouCtrl();
        _txtCur.text            = musouCtrl.currentWave.toString();
        _txtMax.text            = musouCtrl.waveCount.toString();
        renderCircle();
    }

    private function renderCircle():void {
        var musouCtrl:MusouCtrl = GameCtrl.I.getMusouCtrl();
        var angle:int           = (
                                          musouCtrl.getWavePercent() * 360
                                  ) << 0;
        _circleBp.bitmapData    = KyoDrawUtils.drawRing(10, 29, angle, [KyoColor.YELLOW, KyoColor.RED], 1);
    }

}
}
