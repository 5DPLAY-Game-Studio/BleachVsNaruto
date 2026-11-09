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
/**
 * 无双商店角色和价格。
 *
 * <p>第一次 <code>init</code> 才填内置列表。之后再调不会重填。<code>allCustom</code> 会把列表换成空的，并挡住后面的 <code>init</code>。
 * 还没初始化就 <code>addFighter</code> 会抛错。重复 id 只打日志，不覆盖价格。</p>
 *
 * @see MusouFighterSellVO
 */
public class MusouFighterModel {

    /** @private */
    private static var _i:MusouFighterModel;

    /**
     * 单例。第一次访问时创建。
     *
     * @return 商店数据。
     * @example
     * <listing version="3.0">
     * var model:MusouFighterModel = MusouFighterModel.I;
     * </listing>
     */
    public static function get I():MusouFighterModel {
        _i ||= new MusouFighterModel();
        return _i;
    }


    /**
     * 在售角色。初始化前为 <code>null</code>。
     *
     * @default null
     */
    public var fighters:Vector.<MusouFighterSellVO>;
    /** @private */
    private var _inited:Boolean = false;

    /**
     * 填内置商店。已经填过，或调用过 <code>allCustom</code> 时直接返回。
     *
     * @example
     * <listing version="3.0">
     * MusouFighterModel.I.init();
     * </listing>
     */
    public function init():void {
        if (!_inited) {
            initFighters();
            _inited = true;
        }
    }

    /**
     * 换成空列表，并让之后的 <code>init</code> 不再填内置角色。
     *
     * @example
     * <listing version="3.0">
     * MusouFighterModel.I.allCustom();
     * </listing>
     */
    public function allCustom():void {
        fighters = new Vector.<MusouFighterSellVO>();
        _inited  = true;
    }

    /**
     * 追加一个在售角色。
     *
     * <p>已经有这个 id 时打日志并返回。列表还是 <code>null</code> 时抛错。</p>
     *
     * @param id 角色 id。
     * @param price 价格。
     * @example
     * <listing version="3.0">
     * MusouFighterModel.I.addFighter(id, 5000);
     * </listing>
     */
    public function addFighter(id:String, price:int):void {
        if (containsFighter(id)) {
            TraceLang('musou_fighter_model.repeat_add', {fighterId: id});
            return;
        }
        fighters.push(new MusouFighterSellVO(id, price));
    }

    /** @private */
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

    }

    /** @private */
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
