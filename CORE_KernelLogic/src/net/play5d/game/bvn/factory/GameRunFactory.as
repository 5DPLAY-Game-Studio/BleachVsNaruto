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

package net.play5d.game.bvn.factory {
import flash.display.MovieClip;
import flash.utils.Dictionary;

import net.play5d.game.bvn.ctrler.game_stage_loader.GameStageLoadCtrl;
import net.play5d.game.bvn.data.FighterModel;
import net.play5d.game.bvn.data.FighterVO;
import net.play5d.game.bvn.data.MapVO;
import net.play5d.game.bvn.data.mosou.MosouEnemyVO;
import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
import net.play5d.game.bvn.fighter.Assister;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.map.MapMain;

public class GameRunFactory {
    include '../../../../../../include/_INCLUDE_.as';

    private static var _fighterCache:Dictionary = new Dictionary();

    public static function createEnemyByData(data:MosouEnemyVO):FighterMain {
        var fv:FighterVO = FighterModel.I.getFighter(data.fighterID, true);
        if (!fv) {
            return null;
        }

        var fighter:FighterMain = createFighterByData(fv, '2');
        if (!fighter) {
            return null;
        }

        fighter.mosouEnemyData = data;
        fighter.hp             = fighter.hpMax = data.maxHp;
        return fighter;
    }

    public static function createFighterByData(data:FighterVO, playerId:String):FighterMain {
        var mc:MovieClip        = GameStageLoadCtrl.I.getFighterMc(data.fileUrl, playerId);
        var fighter:FighterMain = new FighterMain(mc);
        fighter.data            = data;
        return fighter;
    }

    public static function createFighterByMosouData(
            data:FighterVO, mosouData:MosouFighterVO, playerId:String):FighterMain {
        var fighter:FighterMain = createFighterByData(data, playerId);
        if (!fighter) {
            return null;
        }

        fighter.initMosouFighter(mosouData);
        return fighter;
    }

    public static function createMapByData(data:MapVO):MapMain {
        var mc:MovieClip = GameStageLoadCtrl.I.getMapMc(data.fileUrl);
        var map:MapMain  = new MapMain(mc);
        map.data         = data;
        return map;
    }

//		public static function getCacheFighter(data:FighterVO):FighterMain{
//			if(_fighterCache[data]) return _fighterCache[data];
//
//			var fm:FighterMain = createFighterByData(data);
//			_fighterCache[data] = fm;
//
//			return fm;
//		}

    public static function createAssisterByData(data:FighterVO, playerId:String):Assister {
        var mc:MovieClip      = GameStageLoadCtrl.I.getAssisterMc(data.fileUrl, playerId);
        var assister:Assister = new Assister(mc);
        assister.data         = data;
        return assister;
    }

    public function GameRunFactory() {
    }

}
}
