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

/**
 * 已注册的角色。
 *
 * <p>没初始化时，遍历和按 id 取值会抛错。<code>getFighter</code> 在表已经建好但没有这个 id 时返回 <code>null</code>。
 * 背景音乐在地址为空或权重不大于 0 时返回 <code>null</code>。头目曲只认 <code>boss_naruto</code> 和 <code>boss_bleach</code>。</p>
 *
 * @see FighterVO
 */
public class FighterModel {

    /** @private */
    private static var _i:FighterModel;

    /**
     * 唯一实例。第一次读取时创建。
     *
     * @return 角色表。
     * @example
     * <listing version="3.0">
     * var vo:FighterVO = FighterModel.I.getFighter(id);
     * </listing>
     */
    public static function get I():FighterModel {
        _i ||= new FighterModel();
        return _i;
    }

    /** @private */
    private var _fighterObj:Object;

    /**
     * 取全部角色表。返回的是内部那一份。
     *
     * <p>还没初始化时为 <code>null</code>。</p>
     *
     * @return id 到角色数据的对象。
     * @example
     * <listing version="3.0">
     * var all:Object = FighterModel.I.getAllFighters();
     * </listing>
     */
    public function getAllFighters():Object {
        return _fighterObj;
    }

    /**
     * 按漫画类型和条件筛选角色。
     *
     * <p>条件先判断，不过就跳过。表还没建时抛错。</p>
     *
     * @param comicType 漫画类型。默认 -1，表示不限。
     * @param condition 过滤函数，参数是角色数据，返回 <code>false</code> 时跳过。可省略。
     * @return 新的数组。
     * @example
     * <listing version="3.0">
     * var list:Vector.&lt;FighterVO&gt; = FighterModel.I.getFighters(1);
     * </listing>
     */
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

    /**
     * 按 id 取角色。
     *
     * @param id 角色 id。
     * @param clone 是否返回克隆。默认 <code>false</code>，返回表里的那一份。
     * @return 角色数据。没有时为 <code>null</code>。表还没建时抛错。
     * @example
     * <listing version="3.0">
     * var vo:FighterVO = FighterModel.I.getFighter(id, true);
     * </listing>
     */
    public function getFighter(id:String, clone:Boolean = false):FighterVO {
        var fv:FighterVO = _fighterObj[id];
        if (!fv) {
            return null;
        }
        return clone ? fv.clone() as FighterVO : fv;
    }

    /**
     * 按 id 取角色名。
     *
     * @param id 角色 id。
     * @return 名字。没有这个角色时为 <code>N/A</code>。表还没建时抛错。
     * @example
     * <listing version="3.0">
     * var name:String = FighterModel.I.getFighterName(id);
     * </listing>
     */
    public function getFighterName(id:String):String {
        var fv:FighterVO = _fighterObj[id];
        if (!fv) {
            return 'N/A';
        }
        return fv.name;
    }

    /**
     * 按角色 id 做一份战斗背景音乐。
     *
     * <p>没有角色、没有地址，或权重不大于 0 时返回 <code>null</code>。</p>
     *
     * @param id 角色 id。
     * @return 曲目。id 用角色 id。
     * @example
     * <listing version="3.0">
     * var bgm:BgmVO = FighterModel.I.getFighterBGM(id);
     * </listing>
     */
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

    /**
     * 按固定 id 做头目曲。
     *
     * <p>只认 <code>boss_naruto</code> 和 <code>boss_bleach</code>。权重固定为 1。</p>
     *
     * @param id 曲目 id。
     * @return 曲目。其它 id 为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var bgm:BgmVO = FighterModel.I.getBossBGM('boss_naruto');
     * </listing>
     */
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

    /**
     * 用角色包对象重建整张表。
     *
     * <p>缺少 <code>fighter</code>、<code>path</code> 或 <code>data</code> 时抛错。同 id 后者覆盖。</p>
     *
     * @param obj 含 <code>fighter.path</code> 和 <code>fighter.data</code> 的对象。
     * @example
     * <listing version="3.0">
     * FighterModel.I.initByObject(obj);
     * </listing>
     */
    public function initByObject(obj:Object):void {
        _fighterObj = {};

        var pathObj:Object = obj['fighter']['path'];
        var dataArr:Array  = obj['fighter']['data'];
        for each (var data:Object in dataArr) {
            var newData:Object = {
                path: pathObj,
                data: data
            };

            var fv:FighterVO = new FighterVO();
            fv.initByObject(newData);

            _fighterObj[fv.id] = fv;
        }
    }

    /**
     * 清空已注册角色。
     */
    public function clear():void {
        _fighterObj = {};
    }

    /**
     * 注册单个角色（同 id 覆盖）。
     *
     * @param fv 角色 VO。
     */
    public function register(fv:FighterVO):void {
        if (!fv || !fv.id) {
            return;
        }
        _fighterObj ||= {};
        _fighterObj[fv.id] = fv;
    }

}
}
