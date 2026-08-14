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
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.lan.SelectFighterDataType;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.stage.LoadingStage;
import net.play5d.game.bvn.stage.SelectFighterStage;

/**
 * 局域网选人服务端逻辑（汇总双方选择并推进步骤）。
 *
 * @see SelectFighterClientLogic
 */
public class SelectFighterServerLogic {
    /**
     * 构造选人服务端逻辑。
     */
    public function SelectFighterServerLogic() {
    }

    /** @private */
    private var _timeout:int;
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
        GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_FINISH, onSelectFinish);
        GameEvent.addEventListener(GameEvent.SELECT_FIGHTER_INDEX, onSelectFighterIndex);
    }

    /**
     * 移除事件监听。
     */
    public function dispose():void {
        GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_STEP, onSelectStep);
        GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_FINISH, onSelectFinish);
        GameEvent.removeEventListener(GameEvent.SELECT_FIGHTER_INDEX, onSelectFighterIndex);
        _sendTCP = null;
    }

    /**
     * 处理客户端选人包。
     * @param data 载荷。
     * @return 已识别为选人协议时为 <code>true</code>。
     */
    public function receiveSelect(data:Object):Boolean {
        var arr:Array = data as Array;
        if (!arr || arr[0] != SelectFighterDataType.KEY) {
            return false;
        }

        var type:int = data[1];

        switch (type) {
        case SelectFighterDataType.SELECT:
            try {
                var stg:SelectFighterStage = MainGame.stageCtrl.currentStage as SelectFighterStage;
                stg.setSelect(2, arr[2]);
                checkSelectFinish();
            }
            catch (e:Error) {
            }
            break;
        case SelectFighterDataType.INDEX:
            try {
                var stg2:LoadingStage = MainGame.stageCtrl.currentStage as LoadingStage;
                stg2.setOrder(2, data[2]);
                checkSelectIndexFinish();
            }
            catch (e:Error) {
            }
            break;
        }

        return true;
    }

    /** @private */
    private function checkSelectFinish():void {
        var stg:SelectFighterStage = MainGame.stageCtrl.currentStage as SelectFighterStage;
        if (stg.p1SelectFinish && stg.p2SelectFinish) {
            clearTimeout(_timeout);
            _timeout = setTimeout(function ():void {
                _sendTCP([SelectFighterDataType.KEY, SelectFighterDataType.NEXT_STEP]);
                stg.nextStep();
            }, 1000);
        }
    }

    /** @private */
    private function checkSelectIndexFinish():void {
        try {
            var stg:LoadingStage = MainGame.stageCtrl.currentStage as LoadingStage;
            if (stg.selectFinish()) {
                setTimeout(function ():void {
                    var orders:Array = stg.getSort();

                    _sendTCP([SelectFighterDataType.KEY, SelectFighterDataType.INDEX_FINISH, orders[0], orders[1]]);
                    stg.gotoGame(orders[0], orders[1]);
                }, 1000);
            }
        }
        catch (e:Error) {
        }
    }

    /** @private */
    private function onSelectStep(e:GameEvent):void {
        _sendTCP([SelectFighterDataType.KEY, SelectFighterDataType.SELECT, e.param]);
        checkSelectFinish();
    }

    /** @private */
    private function onSelectFinish(e:GameEvent):void {
        _sendTCP(SelectFighterSyncPayload.packFighterFinish(
                GameData.I.p1Select, GameData.I.p2Select, GameData.I.selectMap
        ));

        var stg:SelectFighterStage = MainGame.stageCtrl.currentStage as SelectFighterStage;
        stg.goLoadGame();
    }

    /** @private */
    private function onSelectFighterIndex(e:GameEvent):void {
        _sendTCP([SelectFighterDataType.KEY, SelectFighterDataType.INDEX, e.param]);
        checkSelectIndexFinish();
    }
}
}
