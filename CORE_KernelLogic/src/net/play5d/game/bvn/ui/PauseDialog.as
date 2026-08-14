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

/**
 * 对战暂停对话框。
 *
 * @see BasePauseDialog
 */
public class PauseDialog extends BasePauseDialog {

    /**
     * 构造对战暂停菜单。
     */
    public function PauseDialog() {
        super([
                  {label: 'GAME TITLE', cn: GetLang('txt.pause_dialog.game_title')},
                  {label: 'MOVE LIST', cn: GetLang('txt.common.move_list')},
                  {label: 'CONTINUE', cn: GetLang('txt.common.continue')}
              ]);
    }

    /** @inheritDoc */
    override protected function handleExtraSelect(label:String):Boolean {
        if (label != 'GAME TITLE') {
            return false;
        }

        _btnGroup.keyEnable = false;
        GameUI.confrim(
                GetLang('confirm.common.back_menu_title'),
                GetLang('confirm.common.back_menu'),
                function ():void {
                    MainGame.I.goMenu();
                },
                function ():void {
                    _btnGroup.keyEnable = true;
                },
                IsMobile()
        );

        return true;
    }
}
}
