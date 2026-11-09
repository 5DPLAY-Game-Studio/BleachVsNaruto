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

package net.play5d.game.bvn.ctrler.game_ctrls {
import flash.display.MovieClip;
import net.play5d.game.bvn.ctrler.game_stage_loader.GameStageLoadCtrl;
import net.play5d.game.bvn.data.FighterModel;
import net.play5d.game.bvn.data.vos.FighterVO;
import net.play5d.game.bvn.data.vos.MapVO;
import net.play5d.game.bvn.data.musou.MusouEnemyVO;
import net.play5d.game.bvn.data.musou.player.MusouFighterVO;
import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.map.MapMain;

/**
 * 用已加载的影片剪辑组装对局里的角色、地图和援助。
 *
 * <p>角色 id 在 <code>FighterModel</code> 里没有时，建敌人返回 <code>null</code>。
 * 影片路径不在加载缓存里时，取影片会抛错。影片取到 <code>null</code> 时仍会 <code>new</code>，由角色构造记错误，本类不返回 <code>null</code>。</p>
 *
 * @see GameStageLoadCtrl
 */
public class GameRunFactory {

    /**
     * 按无双敌人数据建场上角色，玩家 id 固定为 <code>2</code>。
     *
     * <p>体力上限和当前体力都写成 <code>data.maxHp</code>。找不到角色数据时返回 <code>null</code>。</p>
     *
     * @param data 敌人数据。
     * @return 场上角色；没有对应角色数据时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var enemy:FighterMain = GameRunFactory.createEnemyByData(vo);
     * </listing>
     */
    public static function createEnemyByData(data:MusouEnemyVO):FighterMain {
        var fv:FighterVO = FighterModel.I.getFighter(data.fighterID, true);
        if (!fv) {
            return null;
        }

        var fighter:FighterMain = createFighterByData(fv, '2');
        if (!fighter) {
            return null;
        }

        fighter.musouEnemyData = data;
        fighter.hp             = fighter.hpMax = data.maxHp;
        return fighter;
    }

    /**
     * 按角色数据和玩家 id 建场上角色。
     *
     * @param data 角色数据。
     * @param playerId 玩家 id，传给取影片。
     * @return 场上角色。
     * @example
     * <listing version="3.0">
     * var f:FighterMain = GameRunFactory.createFighterByData(vo, '1');
     * </listing>
     */
    public static function createFighterByData(data:FighterVO, playerId:String):FighterMain {
        var mc:MovieClip        = GameStageLoadCtrl.I.getFighterMc(data.fileUrl, playerId);
        var fighter:FighterMain = new FighterMain(mc);
        fighter.data            = data;
        return fighter;
    }

    /**
     * 建角色并写入无双养成数据。
     *
     * @param data 角色数据。
     * @param musouData 无双养成数据。
     * @param playerId 玩家 id。
     * @return 场上角色。
     * @example
     * <listing version="3.0">
     * var f:FighterMain = GameRunFactory.createFighterByMusouData(vo, musou, '1');
     * </listing>
     */
    public static function createFighterByMusouData(
            data:FighterVO, musouData:MusouFighterVO, playerId:String):FighterMain {
        var fighter:FighterMain = createFighterByData(data, playerId);
        if (!fighter) {
            return null;
        }

        fighter.initMusouFighter(musouData);
        return fighter;
    }

    /**
     * 按地图数据建地图。
     *
     * @param data 地图数据。
     * @return 地图。
     * @example
     * <listing version="3.0">
     * var map:MapMain = GameRunFactory.createMapByData(vo);
     * </listing>
     */
    public static function createMapByData(data:MapVO):MapMain {
        var mc:MovieClip = GameStageLoadCtrl.I.getMapMc(data.fileUrl);
        var map:MapMain  = new MapMain(mc);
        map.data         = data;
        return map;
    }

    /**
     * 按角色数据和玩家 id 建援助。
     *
     * @param data 角色数据。
     * @param playerId 玩家 id。
     * @return 援助。
     * @example
     * <listing version="3.0">
     * var a:Assister = GameRunFactory.createAssisterByData(vo, '1');
     * </listing>
     */
    public static function createAssisterByData(data:FighterVO, playerId:String):Assister {
        var mc:MovieClip      = GameStageLoadCtrl.I.getAssisterMc(data.fileUrl, playerId);
        var assister:Assister = new Assister(mc);
        assister.data         = data;
        return assister;
    }

}
}
