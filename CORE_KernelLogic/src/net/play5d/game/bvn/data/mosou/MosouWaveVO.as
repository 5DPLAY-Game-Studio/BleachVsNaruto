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

package net.play5d.game.bvn.data.mosou {
public class MosouWaveVO {
    include '../../../../../../../include/_INCLUDE_.as';

//		public static function createByXML(xml:XML):MosouWaveVO{
//			var wave:MosouWaveVO = new MosouWaveVO();
//			wave.hold = int(xml.@hold);
//			for each(var j:XML in xml.enemy){
//				wave.addEnemy(MosouEnemyVO.createByXML(j));
//			}
//
//			if(xml.repeat.length() > 0){
//				for each(var r:XML in xml.repeat){
//					if(r.enemy.length() > 0){
//						var waveRepeat:MosouWaveRepeatVO = new MosouWaveRepeatVO();
//						wave.addRepeat(waveRepeat);
//
//						waveRepeat.type = int(r.@type);
//						waveRepeat.hold = int(r.@hold);
//
//						for each(var e:XML in r.enemy){
//							waveRepeat.addEnemy(MosouEnemyVO.createByXML(e));
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
            wave.addEnemy(MosouEnemyVO.createByJSON(enemies[j]));
        }

        if (json.repeat) {
            wave.repeats = new Vector.<MosouWaveRepeatVO>();

            var waveRepeat:MosouWaveRepeatVO = new MosouWaveRepeatVO();
            waveRepeat.type                  = json.repeat.type;
            waveRepeat.hold                  = json.repeat.hold;

            var repeatEnemies:Array = json.repeat.enemies;
            for (var k:int = 0; k < repeatEnemies.length; k++) {
                waveRepeat.addEnemy(MosouEnemyVO.createByJSON(repeatEnemies[k]));
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
    public var enemies:Vector.<MosouEnemyVO>;
    /**
     * 重复定义
     */
    public var repeats:Vector.<MosouWaveRepeatVO>;
    /**
     * 持续时间（秒）
     */
    public var hold:int;

    public function getAllEnemies():Vector.<MosouEnemyVO> {
        if (!repeats) {
            return enemies;
        }

        var result:Vector.<MosouEnemyVO> = enemies.concat();
        for each(var i:MosouWaveRepeatVO in repeats) {
            if (i.enemies) {
                result = result.concat(i.enemies);
            }
        }

        return result;
    }

    public function getAllEnemieIds():Array {
        var result:Array                     = [];
        var allEnemies:Vector.<MosouEnemyVO> = getAllEnemies();

        for each(var e:MosouEnemyVO in allEnemies) {
            if (result.indexOf(e.fighterID) == -1) {
                result.push(e.fighterID);
            }
        }

        return result;
    }

    public function getBosses():Vector.<MosouEnemyVO> {
        var result:Vector.<MosouEnemyVO>     = new Vector.<MosouEnemyVO>();
        var allEnemies:Vector.<MosouEnemyVO> = getAllEnemies();

        for each(var e:MosouEnemyVO in allEnemies) {
            if (!e.isBoss) {
                continue;
            }

            if (result.indexOf(e) == -1) {
                result.push(e);
            }
        }

        return result;
    }

    public function addEnemy(enemyAdd:Vector.<MosouEnemyVO>):void {
        enemies ||= new Vector.<MosouEnemyVO>();

        for each(var e:MosouEnemyVO in enemyAdd) {
            e.wave = this;
            enemies.push(e);
        }
    }

    public function addRepeat(repeat:MosouWaveRepeatVO):void {
        repeats ||= new Vector.<MosouWaveRepeatVO>();

        repeat.wave = this;
        repeats.push(repeat);
    }

    public function bossCount():int {
        var count:int;
        for each(var i:MosouEnemyVO in enemies) {
            if (i.isBoss) {
                count++;
            }
        }
        return count;
    }

}
}
