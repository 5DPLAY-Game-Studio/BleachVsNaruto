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
import flash.display.DisplayObject;
import flash.display.Sprite;

import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.fighter.FighterMain;

public class MusouFightBarUI {
    include '../../../../../../../include/_INCLUDE_.as';

    public function MusouFightBarUI(ui:$musou$MC_hpBarGroup) {
        _ui = ui;

        _hpbar = new MusouHpBar(ui.hpbar, ui.hpbar2);
        _qibar = new MusouQiBar(ui.qibar);

        _energybar = new MusouEnergyBar(ui.energybar);

        _littleHpBar1 = new MusouMiniHpBar(ui.little_hp_1);
        _littleHpBar2 = new MusouMiniHpBar(ui.little_hp_2);

        _face = ui.facemc;
    }
    private var _ui:$musou$MC_hpBarGroup;
    private var _face:mosou_hpbar_facemc;
    private var _hpbar:MusouHpBar;
    private var _qibar:MusouQiBar;
    private var _energybar:MusouEnergyBar;
    private var _littleHpBar1:MusouMiniHpBar;
    private var _littleHpBar2:MusouMiniHpBar;
    private var _group:GameRunFighterGroup;

    public function setFighter(group:GameRunFighterGroup):void {
        _group = group;
        updateFighters();
    }

    public function updateFighters():void {
        _hpbar.setFighter(_group.currentFighter);
        _qibar.setFighter(_group.currentFighter);
        _energybar.setFighter(_group.currentFighter);
        updateFace();

        var fighters:Vector.<FighterVO> = _group.getFighters(true);

        var fighter1:FighterMain = _group.getFighter(fighters[0]);
        var fighter2:FighterMain = _group.getFighter(fighters[1]);

        _littleHpBar1.setFighter(fighter1);
        _littleHpBar2.setFighter(fighter2);
    }

    public function render():void {
        _hpbar.render();
        _qibar.render();
        _energybar.render();
    }

    public function renderAnimate():void {
        _littleHpBar1.renderAnimate();
        _littleHpBar2.renderAnimate();
    }

    private function updateFace():void {
        var ct:Sprite = _face.getChildByName('ct') as Sprite;
        if (ct) {
            var faceImg:DisplayObject = AssetManager.I.getFighterFaceBar(_group.currentFighter.data);
            if (faceImg) {
                ct.removeChildren();
                ct.addChild(faceImg);
            }
        }

    }


}
}
