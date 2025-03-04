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

package net.play5d.game.bvn.data {
import net.play5d.game.bvn.data.vos.BgmVO;
import net.play5d.game.bvn.data.vos.FighterVO;

public class FighterModel {
    include '../../../../../../include/_INCLUDE_.as';

    private static var _i:FighterModel;

    public static function get I():FighterModel {
        _i ||= new FighterModel();
        return _i;
    }

    public function FighterModel() {
    }
    private var _fighterObj:Object;

    public function getAllFighters():Object {
        return _fighterObj;
    }

    public function getFighters(comicType:int = -1, condition:Function = null):Vector.<FighterVO> {
        var vec:Vector.<FighterVO> = new Vector.<FighterVO>();
        for each(var i:FighterVO in _fighterObj) {
            if (condition != null && !condition(i)) {
                continue;
            }
            if (comicType == -1 || i.comicType == comicType) {
                vec.push(i);
            }
        }
        return vec;
    }

    public function getFighter(id:String, clone:Boolean = false):FighterVO {
//			return _fighterObj[id];
        var fv:FighterVO = _fighterObj[id];
        if (!fv) {
            return null;
        }
        return clone ? fv.clone() as FighterVO : fv;
    }

    public function getFighterName(id:String):String {
        var fv:FighterVO = _fighterObj[id];
        if (!fv) {
            return 'N/A';
        }
        return fv.name;
    }

    public function getFighterBGM(id:String):BgmVO {
        var fv:FighterVO = getFighter(id);
        if (!fv || !fv.bgm || fv.bgmRate <= 0) {
            return null;
        }

        var bv:BgmVO = new BgmVO();
        bv.id        = fv.id;
        bv.url       = fv.bgm;
        bv.rate      = fv.bgmRate;
        return bv;
    }

    public function getBossBGM(id:String):BgmVO {
        var bv:BgmVO = new BgmVO();
        bv.id        = id;
        bv.rate      = 1;

        switch (id) {
        case 'boss_naruto':
            bv.url = 'bgm/narutoboss.mp3';
            break;
        case 'boss_bleach':
            bv.url = 'bgm/bleachboss.mp3';
            break;
        default:
            return null;
        }

        return bv;
    }

    public function initByXML(xml:XML):void {
        _fighterObj = {};

        for each(var i:XML in xml.fighter) {
            var fv:FighterVO = new FighterVO();
            fv.initByXML(i);
            _fighterObj[fv.id] = fv;
        }

    }


}
}
