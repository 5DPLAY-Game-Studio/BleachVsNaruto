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

public class MosouWaveVO implements IInstanceVO {
    include '../../../../../../../include/_INCLUDE_.as';
    include '../../../../../../../include/Clone.as';

//		public static function createByXML(xml:XML):MosouWaveVO{
//			var wave:MosouWaveVO = new MosouWaveVO();
//			wave.hold = int(xml.@hold);
//			for each(var j:XML in xml.enemy){
//				wave.addEnemy(MusouEnemyVO.createByXML(j));
//			}
//
//			if(xml.repeat.length() > 0){
//				for each(var r:XML in xml.repeat){
//					if(r.enemy.length() > 0){
//						var waveRepeat:MusouWaveRepeatVO = new MusouWaveRepeatVO();
//						wave.addRepeat(waveRepeat);
//
//						waveRepeat.type = int(r.@type);
//						waveRepeat.hold = int(r.@hold);
//
//						for each(var e:XML in r.enemy){
//							waveRepeat.addEnemy(MusouEnemyVO.createByXML(e));
//						}
//
//					}
//				}
//			}
//			return wave;
//		}

    public static function createByJSON(json:Object):MosouWaveVO {
        var wave:MosouWaveVO = new MosouWaveVO();
        wave.hold            = int(json.hold);

        var enemies:Array = json.enemies;
        for (var j:int = 0; j < enemies.length; j++) {
            wave.addEnemy(MusouEnemyVO.createByJSON(enemies[j]));
        }

        if (json.repeat) {
            wave.repeats = new Vector.<MusouWaveRepeatVO>();

            var waveRepeat:MusouWaveRepeatVO = new MusouWaveRepeatVO();
            waveRepeat.type                  = json.repeat.type;
            waveRepeat.hold                  = json.repeat.hold;

            var repeatEnemies:Array = json.repeat.enemies;
            for (var k:int = 0; k < repeatEnemies.length; k++) {
                waveRepeat.addEnemy(MusouEnemyVO.createByJSON(repeatEnemies[k]));
            }

            wave.repeats.push(waveRepeat);
        }

        return wave;
    }

    public function MosouWaveVO() {
    }
    public var id:int;
    /**
     * 敌人数组 （{id: fighterID, amount: 数量, hp: 血量}）
     */
    public var enemies:Vector.<MusouEnemyVO>;
    /**
     * 重复定义
     */
    public var repeats:Vector.<MusouWaveRepeatVO>;
    /**
     * 持续时间（秒）
     */
    public var hold:int;

    public function getAllEnemies():Vector.<MusouEnemyVO> {
        if (!repeats) {
            return enemies;
        }

        var result:Vector.<MusouEnemyVO> = enemies.concat();
        for each(var i:MusouWaveRepeatVO in repeats) {
            if (i.enemies) {
                result = result.concat(i.enemies);
            }
        }

        return result;
    }

    public function getAllEnemieIds():Array {
        var result:Array                     = [];
        var allEnemies:Vector.<MusouEnemyVO> = getAllEnemies();

        for each(var e:MusouEnemyVO in allEnemies) {
            if (result.indexOf(e.fighterID) == -1) {
                result.push(e.fighterID);
            }
        }

        return result;
    }

    public function getBosses():Vector.<MusouEnemyVO> {
        var result:Vector.<MusouEnemyVO>     = new Vector.<MusouEnemyVO>();
        var allEnemies:Vector.<MusouEnemyVO> = getAllEnemies();

        for each(var e:MusouEnemyVO in allEnemies) {
            if (!e.isBoss) {
                continue;
            }

            if (result.indexOf(e) == -1) {
                result.push(e);
            }
        }

        return result;
    }

    public function addEnemy(enemyAdd:Vector.<MusouEnemyVO>):void {
        enemies ||= new Vector.<MusouEnemyVO>();

        for each(var e:MusouEnemyVO in enemyAdd) {
            e.wave = this;
            enemies.push(e);
        }
    }

    public function addRepeat(repeat:MusouWaveRepeatVO):void {
        repeats ||= new Vector.<MusouWaveRepeatVO>();

        repeat.wave = this;
        repeats.push(repeat);
    }

    public function bossCount():int {
        var count:int;
        for each(var i:MusouEnemyVO in enemies) {
            if (i.isBoss) {
                count++;
            }
        }
        return count;
    }

}
}
