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

public class MapVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    public var id:String;
    public var name:String;
    public var fileUrl:String;
    public var picUrl:String;
    public var bgm:String;

    /**
     * 通过对象进行初始化。
     *
     * @param obj 含 <code>path</code> 与地图字段的对象。
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
