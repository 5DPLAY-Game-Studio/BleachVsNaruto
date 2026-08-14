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
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.events.GameEvent;

/**
 * 无双暂停对话框。
 *
 * @see BasePauseDialog
 */
public class MusouPauseDialog extends BasePauseDialog {

    /**
     * 构造无双暂停菜单。
     */
    public function MusouPauseDialog() {
        super([
                  {label: 'BACK MAP', cn: GetLang('txt.musou_pause_dialog.back_map')},
                  {label: 'MOVE LIST', cn: GetLang('txt.common.move_list')},
                  {label: 'CONTINUE', cn: GetLang('txt.common.continue')}
              ], true);
    }

    /** @inheritDoc */
    override protected function handleExtraSelect(label:String):Boolean {
        if (label != 'BACK MAP') {
            return false;
        }

        _btnGroup.keyEnable = false;
        GameUI.confrim(
                GetLang('confirm.musou_pause_dialog.back_map_title'),
                GetLang('confirm.musou_pause_dialog.back_map'),
                function ():void {
                    MainGame.I.goWorldMap();
                    GameEvent.dispatchEvent(GameEvent.MUSOU_BACK_MAP);
                },
                function ():void {
                    _btnGroup.keyEnable = true;
                },
                true
        );

        return true;
    }
}
}
