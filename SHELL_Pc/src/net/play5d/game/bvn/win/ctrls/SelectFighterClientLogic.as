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

package net.play5d.game.bvn.win.ctrls {
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.stage.LoadingStage;
import net.play5d.game.bvn.stage.SelectFighterStage;
import net.play5d.game.bvn.win.utils.SelectFighterDataType;

public class SelectFighterClientLogic {
    public function SelectFighterClientLogic() {
    }

    public function init():void {
        SelectFighterStage.AUTO_FINISH = false;
        LoadingStage.AUTO_START_GAME   = false;
        GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_STEP, onSelectStep);
        GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_INDEX, onSelectIndex);
    }

    public function dispose():void {
        GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_STEP, onSelectStep);
        GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_INDEX, onSelectIndex);
    }

    public function receiveSelect(data:Object):Boolean {
        var arr:Array = data as Array;
        if (!arr || arr[0] != SelectFighterDataType.KEY) {
            return false;
        }

        var type:int = arr[1];
        var stg:SelectFighterStage;

        switch (type) {
        case SelectFighterDataType.SELECT:
            try {
                stg = MainGame.stageCtrl.currentStage as SelectFighterStage;
                stg.setSelect(1, arr[2]);
            }
            catch (e:Error) {
            }
            break;
        case SelectFighterDataType.NEXT_STEP:
            try {
                stg = MainGame.stageCtrl.currentStage as SelectFighterStage;
                stg.nextStep();
            }
            catch (e:Error) {
            }
            break;
        case SelectFighterDataType.FIGHTER_FINISH:
            onSelectFighter(arr);
            break;
        case SelectFighterDataType.INDEX:
            receiveSelectIndex(arr);
            break;
        case SelectFighterDataType.INDEX_FINISH:
            onSelectFighterIndexFinish(arr);
            break;
        }

        return true;
    }


    private function onSelectFighter(arr:Array):void {
        if (MainGame.stageCtrl.currentStage is SelectFighterStage) {
            GameData.I.p1Select.fighter1 = arr[2];
            GameData.I.p1Select.fighter2 = arr[3];
            GameData.I.p1Select.fighter3 = arr[4];
            GameData.I.p1Select.fuzhu    = arr[5];

            GameData.I.p2Select.fighter1 = arr[6];
            GameData.I.p2Select.fighter2 = arr[7];
            GameData.I.p2Select.fighter3 = arr[8];
            GameData.I.p2Select.fuzhu    = arr[9];

            GameData.I.selectMap = arr[10];

            (
                    MainGame.stageCtrl.currentStage as SelectFighterStage
            ).goLoadGame();
        }
    }

    private function receiveSelectIndex(arr:Array):void {
        var stg:LoadingStage = MainGame.stageCtrl.currentStage as LoadingStage;
        if (stg) {
            stg.setOrder(1, arr[2]);
        }
    }

    private function onSelectFighterIndexFinish(arr:Array):void {
        if (MainGame.stageCtrl.currentStage is LoadingStage) {
            (
                    MainGame.stageCtrl.currentStage as LoadingStage
            ).gotoGame(arr[2], arr[3]);
        }
    }

    private function onSelectStep(e:GameEvent):void {
        var data:Array = [SelectFighterDataType.KEY, SelectFighterDataType.SELECT, e.param];
        LANClientCtrl.I.sendTCP(data);
    }

    private function onSelectIndex(e:GameEvent):void {
        var data:Array = [SelectFighterDataType.KEY, SelectFighterDataType.INDEX, e.param];
        LANClientCtrl.I.sendTCP(data);
    }

}
}
