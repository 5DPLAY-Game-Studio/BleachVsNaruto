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

package net.play5d.game.bvn.ctrler.lan {
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.lan.SelectFighterDataType;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.stage.LoadingStage;
import net.play5d.game.bvn.stage.SelectFighterStage;

/**
 * 局域网选人客户端逻辑（TCP 选人 / 出战顺序同步）。
 *
 * @see SelectFighterServerLogic
 */
public class SelectFighterClientLogic {
    /**
     * 构造选人客户端逻辑。
     */

    /** @private 发送 TCP 回调，签名 <code>function(data:Object):void</code> */
    private var _sendTCP:Function;

    /**
     * 注册事件并禁用自动收尾。
     * @param sendTCP TCP 发送函数。
     */
    public function init(sendTCP:Function):void {
        _sendTCP = sendTCP;

        SelectFighterSyncPayload.disableAutoFinish();
        GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_STEP, onSelectStep);
        GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_INDEX, onSelectIndex);
    }

    /**
     * 移除事件监听。
     */
    public function dispose():void {
        GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_STEP, onSelectStep);
        GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_INDEX, onSelectIndex);
        _sendTCP = null;
    }

    /**
     * 处理服务端选人包。
     * @param data 载荷。
     * @return 已识别为选人协议时为 <code>true</code>。
     */
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

    /** @private */
    private function onSelectFighter(arr:Array):void {
        if (MainGame.stageCtrl.currentStage is SelectFighterStage) {
            GameData.I.selectMap = SelectFighterSyncPayload.unpackFighterFinish(
                    arr, GameData.I.p1Select, GameData.I.p2Select
            );
            (MainGame.stageCtrl.currentStage as SelectFighterStage).goLoadGame();
        }
    }

    /** @private */
    private function receiveSelectIndex(arr:Array):void {
        var stg:LoadingStage = MainGame.stageCtrl.currentStage as LoadingStage;
        if (stg) {
            stg.setOrder(1, arr[2]);
        }
    }

    /** @private */
    private function onSelectFighterIndexFinish(arr:Array):void {
        if (MainGame.stageCtrl.currentStage is LoadingStage) {
            (MainGame.stageCtrl.currentStage as LoadingStage).gotoGame(arr[2], arr[3]);
        }
    }

    /** @private */
    private function onSelectStep(e:GameEvent):void {
        _sendTCP([SelectFighterDataType.KEY, SelectFighterDataType.SELECT, e.param]);
    }

    /** @private */
    private function onSelectIndex(e:GameEvent):void {
        _sendTCP([SelectFighterDataType.KEY, SelectFighterDataType.INDEX, e.param]);
    }
}
}
