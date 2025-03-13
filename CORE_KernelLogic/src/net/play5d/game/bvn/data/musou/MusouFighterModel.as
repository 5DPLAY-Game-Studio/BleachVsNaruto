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
public class MusouFighterModel {
    include '../../../../../../../include/_INCLUDE_.as';

    private static var _i:MusouFighterModel;

    public static function get I():MusouFighterModel {
        _i ||= new MusouFighterModel();
        return _i;
    }

    public function MusouFighterModel() {
    }

    public var fighters:Vector.<MusouFighterSellVO>;
    private var _inited:Boolean = false;

    public function init():void {
        if (!_inited) {
            initFighters();
            _inited = true;
        }
    }

    public function allCustom():void {
        fighters = new Vector.<MusouFighterSellVO>();
        _inited  = true;
    }

    public function addFighter(id:String, price:int):void {
        if (containsFighter(id)) {
            TraceLang('debug.trace.data.musou_fighter_model.repeat_add', id);
            return;
        }
        fighters.push(new MusouFighterSellVO(id, price));
    }

    private function initFighters():void {
        fighters = new Vector.<MusouFighterSellVO>();
        fighters.push(new MusouFighterSellVO('ichigo', 5000));
        fighters.push(new MusouFighterSellVO('ichigo_zero', 5000));

        fighters.push(new MusouFighterSellVO('rukia', 5000));
        fighters.push(new MusouFighterSellVO('renji', 5000));
        fighters.push(new MusouFighterSellVO('naruto', 5000));
        fighters.push(new MusouFighterSellVO('sakura', 5000));
        fighters.push(new MusouFighterSellVO('uryuu', 5000));
        fighters.push(new MusouFighterSellVO('lee', 5000));
        fighters.push(new MusouFighterSellVO('neji', 5000));
        fighters.push(new MusouFighterSellVO('temari', 5000));

        fighters.push(new MusouFighterSellVO('chad', 7000));
        fighters.push(new MusouFighterSellVO('karin', 7000));
        fighters.push(new MusouFighterSellVO('gaara', 7000));
        fighters.push(new MusouFighterSellVO('sasuke', 8000));
        fighters.push(new MusouFighterSellVO('orihime', 8000));
        fighters.push(new MusouFighterSellVO('ikkaku', 8000));
        fighters.push(new MusouFighterSellVO('gin', 8000));
        fighters.push(new MusouFighterSellVO('juggo', 8000));
        fighters.push(new MusouFighterSellVO('suigetsu', 8000));
        fighters.push(new MusouFighterSellVO('kakashi', 8000));
        fighters.push(new MusouFighterSellVO('sakura_sr', 8000));

        fighters.push(new MusouFighterSellVO('hinata', 8000));

        fighters.push(new MusouFighterSellVO('kimimaro', 9000));
        fighters.push(new MusouFighterSellVO('killerbee', 9000));

        fighters.push(new MusouFighterSellVO('toushirou', 10000));
        fighters.push(new MusouFighterSellVO('byakuya', 10000));
        fighters.push(new MusouFighterSellVO('jiraiya', 10000));
        fighters.push(new MusouFighterSellVO('orochimaru', 10000));
        fighters.push(new MusouFighterSellVO('deidara', 10000));

        fighters.push(new MusouFighterSellVO('soifon', 10000));
        fighters.push(new MusouFighterSellVO('konan', 10000));
        fighters.push(new MusouFighterSellVO('grimmjow', 10000));
        fighters.push(new MusouFighterSellVO('mayuri', 12000));

        fighters.push(new MusouFighterSellVO('yoruichi', 15000));
        fighters.push(new MusouFighterSellVO('kenpachi', 15000));
        fighters.push(new MusouFighterSellVO('itachi', 15000));
        fighters.push(new MusouFighterSellVO('pain', 15000));
        fighters.push(new MusouFighterSellVO('ichigo_bankai', 15000));
        fighters.push(new MusouFighterSellVO('naruto_oneTail', 15000));
        fighters.push(new MusouFighterSellVO('sasuke_susanoo', 15000));

        fighters.push(new MusouFighterSellVO('ichigo_vizored_half', 18000));
        fighters.push(new MusouFighterSellVO('naruto_hermit', 18000));

        fighters.push(new MusouFighterSellVO('starrk', 20000));
        fighters.push(new MusouFighterSellVO('ulquiorra', 23000));

        fighters.push(new MusouFighterSellVO('obito', 25000));

        fighters.push(new MusouFighterSellVO('aizen', 40000));
        fighters.push(new MusouFighterSellVO('madara', 42000));

        fighters.push(new MusouFighterSellVO('kenshin', 45000));

//			var userFighters:Vector.<MosouFighterVO> = GameData.I.mosouData.getFighterData();

//			for each(var i:MosouFighterVO in userFighters){
//				for each(var j:MusouFighterSellVO in fighters){
//					if(j.id == i.id) j.sold = true;
//				}
//			}

    }

    private function containsFighter(id:String):Boolean {
        for each(var f:MusouFighterSellVO in fighters) {
            if (f.id == id) {
                return true;
            }
        }
        return false;
    }


}
}
