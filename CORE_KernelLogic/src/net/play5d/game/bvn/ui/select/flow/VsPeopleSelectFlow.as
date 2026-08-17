/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.ui.select.flow {

/**
 * 双人对战选人流程。
 *
 * @see ISelectModeFlow
 */
public class VsPeopleSelectFlow implements ISelectModeFlow {

    /**
     * @inheritDoc
     */
    public function createP2SelectVO():Boolean {
        return true;
    }

    /**
     * @inheritDoc
     */
    public function initBothSelecters():Boolean {
        return true;
    }

    /**
     * @inheritDoc
     */
    public function shouldWaitBothPlayers():Boolean {
        return true;
    }

    /**
     * @inheritDoc
     */
    public function resolveNextStep(curStep:int):SelectFlowAction {
        switch (curStep) {
        case 0:
            return new SelectFlowAction(SelectFlowAction.INIT_FIGHTER, 1);
        case 1:
            return new SelectFlowAction(SelectFlowAction.FADOUT_ASSIST, 3);
        case 3:
            return new SelectFlowAction(SelectFlowAction.FADOUT_MAP, 5);
        case 5:
            return new SelectFlowAction(SelectFlowAction.SELECT_FINISH, -1);
        }
        return new SelectFlowAction();
    }
}
}
