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
import net.play5d.game.bvn.data.vos.FighterVO;

/**
 * 已注册的援助。
 *
 * <p><code>getAssister</code> 的 <code>clone</code> 参数不会使用，返回的一直是表里那一份。
 * 没有这个 id 时为 <code>undefined</code>。表还没建时抛错。</p>
 *
 * @see FighterVO
 */
public class AssisterModel {

    /** @private */
    private static var _i:AssisterModel;

    /**
     * 唯一实例。第一次读取时创建。
     *
     * @return 援助表。
     * @example
     * <listing version="3.0">
     * var vo:FighterVO = AssisterModel.I.getAssister(id);
     * </listing>
     */
    public static function get I():AssisterModel {
        _i ||= new AssisterModel();
        return _i;
    }

    /** @private */
    private var _assisterObj:Object;

    /**
     * 取全部援助表。返回的是内部那一份。
     *
     * @return id 到援助数据的对象。还没初始化时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var all:Object = AssisterModel.I.getAllAssisters();
     * </listing>
     */
    public function getAllAssisters():Object {
        return _assisterObj;
    }

    /**
     * 按漫画类型和条件筛选援助。
     *
     * <p>条件先判断。表还没建时抛错。</p>
     *
     * @param comicType 漫画类型。默认 -1，表示不限。
     * @param condition 过滤函数。可省略。
     * @return 新的数组。
     * @example
     * <listing version="3.0">
     * var list:Vector.&lt;FighterVO&gt; = AssisterModel.I.getAssisters();
     * </listing>
     */
    public function getAssisters(comicType:int = -1, condition:Function = null):Vector.<FighterVO> {
        var vec:Vector.<FighterVO> = new Vector.<FighterVO>();
        for each(var i:FighterVO in _assisterObj) {
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
     * 按 id 取援助。
     *
     * <p><code>clone</code> 不会使用。</p>
     *
     * @param id 援助 id。
     * @param clone 未使用。默认 <code>false</code>。
     * @return 表里的那一份。没有时为 <code>undefined</code>。
     * @example
     * <listing version="3.0">
     * var vo:FighterVO = AssisterModel.I.getAssister(id);
     * </listing>
     */
    public function getAssister(id:String, clone:Boolean = false):FighterVO {
        return _assisterObj[id];
    }

    /**
     * 用援助包对象重建整张表。
     *
     * <p>结构和角色包相同。缺少 <code>fighter</code> 时抛错。</p>
     *
     * @param obj 含 <code>fighter.path</code> 和 <code>fighter.data</code> 的对象。
     * @example
     * <listing version="3.0">
     * AssisterModel.I.initByObject(obj);
     * </listing>
     */
    public function initByObject(obj:Object):void {
        _assisterObj = {};

        var pathObj:Object = obj['fighter']['path'];
        var dataArr:Array  = obj['fighter']['data'];
        for each (var data:Object in dataArr) {
            var newData:Object = {
                path: pathObj,
                data: data
            };

            var fv:FighterVO = new FighterVO();
            fv.initByObject(newData);

            _assisterObj[fv.id] = fv;
        }
    }

    /**
     * 清空已注册援助。
     */
    public function clear():void {
        _assisterObj = {};
    }

    /**
     * 注册单个援助（同 id 覆盖）。
     *
     * @param fv 援助 VO。
     */
    public function register(fv:FighterVO):void {
        if (!fv || !fv.id) {
            return;
        }
        _assisterObj ||= {};
        _assisterObj[fv.id] = fv;
    }
}
}
