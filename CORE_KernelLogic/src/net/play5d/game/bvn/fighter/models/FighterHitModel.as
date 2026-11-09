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

package net.play5d.game.bvn.fighter.models {
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 一个角色身上的攻击定义表。
 *
 * <p>按 id 取不到时返回 <code>undefined</code>。销毁后再查会抛错。
 * 元件名里没有 <code>atm</code>、又对不上 id 时返回 <code>null</code>。有 <code>atm</code> 时会先把这段字去掉再查。</p>
 *
 * @see HitVO
 */
public class FighterHitModel {

    /**
     * 记下所属角色。
     *
     * @param fighter 这些攻击的拥有者。
     * @example
     * <listing version="3.0">
     * var hits:FighterHitModel = new FighterHitModel(fighter);
     * </listing>
     */
    public function FighterHitModel(fighter:IGameSprite) {
        _fighter = fighter;
    }
    /** @private */
    private var _hitObj:Object = {};
    /** @private */
    private var _fighter:IGameSprite;

    /**
     * 丢掉攻击表和角色引用。
     *
     * @example
     * <listing version="3.0">
     * hits.destroy();
     * </listing>
     */
    public function destroy():void {
        _hitObj  = null;
        _fighter = null;
    }

    /**
     * 换成空表。
     *
     * @example
     * <listing version="3.0">
     * hits.clear();
     * </listing>
     */
    public function clear():void {
        _hitObj = {};
    }

    /**
     * 按 id 取攻击。没有时为 <code>undefined</code>。
     *
     * @param id 攻击 id。
     * @return 攻击数据。
     * @example
     * <listing version="3.0">
     * var hit:HitVO = hits.getHitVO(id);
     * </listing>
     */
    public function getHitVO(id:String):HitVO {
        return _hitObj[id];
    }

    /**
     * 攻击表本身。
     *
     * @return 内部表。
     * @example
     * <listing version="3.0">
     * var all:Object = hits.getAll();
     * </listing>
     */
    public function getAll():Object {
        return _hitObj;
    }

    /**
     * 取出 id 里包含这段文字的攻击。空字符串会命中全部。
     *
     * @param likeId 要包含的文字。为空时抛错。
     * @return 新的数组，可以是空的。
     * @example
     * <listing version="3.0">
     * var list:Vector.&lt;HitVO&gt; = hits.getHitVOLike('atk');
     * </listing>
     */
    public function getHitVOLike(likeId:String):Vector.<HitVO> {
        var hv:Vector.<HitVO> = new Vector.<HitVO>();
        for (var i:String in _hitObj) {
            if (i.indexOf(likeId) != -1) {
                hv.push(_hitObj[i]);
            }
        }
        return hv;
    }

    /**
     * 按元件名取攻击。先按全名查，查不到且名字里有 <code>atm</code> 时去掉这段再查。
     *
     * @param name 元件名。
     * @return 攻击数据。对不上且没有 <code>atm</code> 时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var hit:HitVO = hits.getHitVOByDisplayName(name);
     * </listing>
     */
    public function getHitVOByDisplayName(name:String):HitVO {
        var hv:HitVO = getHitVO(name);
        if (hv) {
            return hv;
        }

        if (name.indexOf('atm') == -1) {
            return null;
        }
        var id:String = name.replace('atm', '');
        return getHitVO(id);
    }

    /**
     * 放进一条攻击。同一 id 后来的覆盖先前的。
     *
     * <p><code>obj</code> 为空时，新的 <code>HitVO</code> 只留默认值。</p>
     *
     * @param id 攻击 id。
     * @param obj 写到攻击上的字段。
     * @example
     * <listing version="3.0">
     * hits.addHitVO(id, obj);
     * </listing>
     */
    public function addHitVO(id:String, obj:Object):void {
        var hv:HitVO = new HitVO(obj);
        hv.owner     = _fighter;
        hv.id        = id;
        _hitObj[id]  = hv;
    }

    /**
     * 给表里每条攻击写上威力倍率。
     *
     * @param v 倍率。
     * @example
     * <listing version="3.0">
     * hits.setPowerRate(1.5);
     * </listing>
     */
    public function setPowerRate(v:Number):void {
        for each(var i:HitVO in _hitObj) {
            i.powerRate = v;
        }
    }

}
}
