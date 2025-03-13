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

package net.play5d.game.bvn.data.musou {
import net.play5d.game.bvn.interfaces.IInstanceVO;

public class MusouEnemyVO implements IInstanceVO {
    include '../../../../../../../include/_INCLUDE_.as';
    include '../../../../../../../include/Clone.as';

    public static function create(
            fighterID:String, maxHp:int = 200, atk:int = 0, isBoss:Boolean = false, exp:int = 10,
            money:int                                                                       = 10
    ):MusouEnemyVO {
        var ev:MusouEnemyVO = new MusouEnemyVO();

        ev.fighterID = fighterID;
        ev.isBoss    = isBoss;

        if (maxHp > 0) {
            ev.maxHp = maxHp;
        }

        if (atk > 0) {
            ev.atk = atk;
        }

        if (exp > 0) {
            ev.exp = exp;
        }
        else {
            ev.exp = isBoss ? 100 : 10;
        }

        if (money > 0) {
            ev.money = money;
        }
        else {
            ev.money = isBoss ? 100 : 10;
        }

        return ev;
    }

    public static function createByJSON(json:Object):Vector.<MusouEnemyVO> {
        var id:String      = json.id;
        var hp:int         = json.hp;
        var atk:int        = json.atk;
        var amount:int     = json.amount;
        var isBoss:Boolean = json.isBoss;
        var exp:int        = json.exp;
        var money:int      = json.money;

        var result:Vector.<MusouEnemyVO> = new Vector.<MusouEnemyVO>();
        for (var i:int; i < amount; i++) {
            var mv:MusouEnemyVO = create(id, hp, atk, isBoss, exp, money);
            result.push(mv);
        }
        return result;
    }

    public function MusouEnemyVO() {
    }
    public var fighterID:String;
    public var maxHp:int = 0;
    public var atk:int   = 0;
    public var isBoss:Boolean;
    public var wave:MosouWaveVO;
    public var repeat:MusouWaveRepeatVO;
    public var level:int = 1;
    private var exp:int   = 10;
    private var money:int = 10;

//		public static function createByXML(xml:XML):Vector.<MusouEnemyVO>{
//			var id:String = xml.@id.toString();
//			var hp:int = xml.@hp;
//			var amount:int = xml.@amount;
//			var isBoss:Boolean = xml.@isBoss == "true";
//			var result:Vector.<MusouEnemyVO> = new Vector.<MusouEnemyVO>();
//			for(var i:int; i < amount; i++){
//				var mv:MusouEnemyVO = create(id, hp, isBoss);
//				result.push(mv);
//			}
//			return result;
//		}

    public function getExp():int {
        var levelAdd:int = isBoss ? (
                level * 10
        ) : (
                                   level * 2
                           );
        return exp + levelAdd;
    }

    public function getMoney():int {
        var levelAdd:int = isBoss ? (
                level * 5
        ) : (
                                   level * 1
                           );
        return money + levelAdd;
    }
}
}
