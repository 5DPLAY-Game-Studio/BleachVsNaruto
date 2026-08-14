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
import net.play5d.game.bvn.data.lan.SelectFighterDataType;
import net.play5d.game.bvn.data.vos.SelectVO;
import net.play5d.game.bvn.stage.LoadingStage;
import net.play5d.game.bvn.stage.SelectFighterStage;

/**
 * 局域网选人 <code>FIGHTER_FINISH</code> 载荷与自动收尾开关。
 *
 * @see SelectFighterServerLogic
 * @see SelectFighterClientLogic
 */
public class SelectFighterSyncPayload {

    /**
     * 禁用选人/加载阶段自动收尾（联机由服务端推进）。
     *
     * @example
     * <listing version="3.0">
     * SelectFighterSyncPayload.disableAutoFinish();
     * </listing>
     */
    public static function disableAutoFinish():void {
        SelectFighterStage.AUTO_FINISH = false;
        LoadingStage.AUTO_START_GAME   = false;
    }

    /**
     * 打包选人完成载荷。
     *
     * @param p1Select P1 选择。
     * @param p2Select P2 选择。
     * @param selectMap 地图 id。
     * @return TCP 数组载荷。
     * @example
     * <listing version="3.0">
     * var data:Array = SelectFighterSyncPayload.packFighterFinish(p1, p2, mapId);
     * </listing>
     */
    public static function packFighterFinish(
            p1Select:SelectVO, p2Select:SelectVO, selectMap:String
    ):Array {
        return [
            SelectFighterDataType.KEY, SelectFighterDataType.FIGHTER_FINISH,
            p1Select.fighter1, p1Select.fighter2, p1Select.fighter3, p1Select.fuzhu,
            p2Select.fighter1, p2Select.fighter2, p2Select.fighter3, p2Select.fuzhu,
            selectMap
        ];
    }

    /**
     * 解包选人完成载荷到双方 <code>SelectVO</code>。
     *
     * @param arr 完整选人数组。
     * @param p1Select 写入目标 P1。
     * @param p2Select 写入目标 P2。
     * @return 地图 id（<code>arr[10]</code>）。
     * @example
     * <listing version="3.0">
     * var mapId:String = SelectFighterSyncPayload.unpackFighterFinish(arr, p1, p2);
     * </listing>
     */
    public static function unpackFighterFinish(
            arr:Array, p1Select:SelectVO, p2Select:SelectVO
    ):String {
        p1Select.fighter1 = arr[2];
        p1Select.fighter2 = arr[3];
        p1Select.fighter3 = arr[4];
        p1Select.fuzhu    = arr[5];

        p2Select.fighter1 = arr[6];
        p2Select.fighter2 = arr[7];
        p2Select.fighter3 = arr[8];
        p2Select.fuzhu    = arr[9];

        return arr[10];
    }
}
}
