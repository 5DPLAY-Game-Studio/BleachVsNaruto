/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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

package net.play5d.game.bvn.data.vos {
import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 一张地图的 id、影片、预览图和背景音乐。
 *
 * <p>初始化时，对象里没有 <code>file</code> 或 <code>img</code> 键就用 id 拼默认文件名。键在但值为空时，对应地址写成 <code>null</code>。
 * 背景音乐没有或为空时写成 <code>null</code>。</p>
 *
 * @see MapModel
 */
public class MapVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 地图 id。
     *
     * @default null
     */
    public var id:String;
    /**
     * 地图名字。
     *
     * @default null
     */
    public var name:String;
    /**
     * 地图 SWF 地址。
     *
     * @default null
     */
    public var fileUrl:String;
    /**
     * 预览图地址。
     *
     * @default null
     */
    public var picUrl:String;
    /**
     * 背景音乐地址。
     *
     * @default null
     */
    public var bgm:String;

    /**
     * 用地图包里的一条记录填写字段。
     *
     * <p>没有 <code>path</code> 时抛错。</p>
     *
     * @param obj 含 <code>path</code> 与地图字段的对象。
     * @example
     * <listing version="3.0">
     * vo.initByObject(obj);
     * </listing>
     */
    public function initByObject(obj:Object):void {
        var pathObj:Object = obj['path'];

        id   = obj['id'];
        name = obj['name'];

        if (obj['file']) {
            fileUrl = pathObj['map'] + obj['file'];
        }
        else if (!('file' in obj)) {
            fileUrl = pathObj['map'] + obj['id'] + '.swf';
        }
        else {
            fileUrl = null;
        }

        if (obj['img']) {
            picUrl = pathObj['map'] + obj['img'];
        }
        else if (!('img' in obj)) {
            picUrl = pathObj['map'] + obj['id'] + '.png';
        }
        else {
            picUrl = null;
        }

        if (obj['bgm']) {
            bgm = pathObj['bgm'] + obj['bgm'];
        }
        else {
            bgm = null;
        }
    }

}
}
