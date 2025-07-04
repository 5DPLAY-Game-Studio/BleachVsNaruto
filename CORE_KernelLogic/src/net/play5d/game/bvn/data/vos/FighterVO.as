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
import net.play5d.kyo.utils.KyoRandom;

public class FighterVO implements IInstanceVO {
    include '../../../../../../../include/_INCLUDE_.as';
    include '../../../../../../../include/Clone.as';

    public var id:String;
    public var name:String;
    public var comicType:int; //0=死神,1=火影
    public var fileUrl:String;
    public var startFrame:int;
    public var faceUrl:String;
    public var faceBigUrl:String;
    public var faceBarUrl:String;
    public var faceWinUrl:String;
    public var contactFriends:Array;
    public var contactEnemys:Array;
    public var says:Array;
    public var bgm:String;
    public var bgmRate:Number = 1;
    // 是否值得注意
    public var hasWarning:Boolean = false;

    public var isAlive:Boolean;

    /**
     * 通过对象进行初始化
     *
     * @param obj 对象
     */
    public function initByObject(obj:Object):void {
        var pathObj:Object = obj['path'];
        var dataObj:Object = obj['data'];

        var fighterPath:String = pathObj['fighter'];
        var facePath:String    = pathObj['face'];
        var bgmPath:String     = pathObj['bgm'];

        id         = dataObj['id'];
        name       = dataObj['name'];
        comicType  = dataObj['comic_type'];
        if (dataObj['start_frame'] != null){
            startFrame = dataObj['start_frame'];
        }

        if (dataObj['urls']['file']) {
            fileUrl    = fighterPath + dataObj['urls']['file'];
        }
        if (dataObj['urls']['face']) {
            faceUrl    = facePath + dataObj['urls']['face'];
        }
        if (dataObj['urls']['face_big']) {
            faceBigUrl = facePath + dataObj['urls']['face_big'];
        }
        if (dataObj['urls']['face_bar']) {
            faceBarUrl = facePath + dataObj['urls']['face_bar'];
        }
        if (dataObj['urls']['face_win']) {
            faceWinUrl = facePath + dataObj['urls']['face_win'];
        }

        contactFriends = [];
        contactEnemys  = [];

        if (dataObj['says']) {
            says = dataObj['says'];
        }

        if (dataObj['bgm']) {
            bgm     = bgmPath + dataObj['bgm']['url'];
            bgmRate = dataObj['bgm']['rate'];
        }

        if (dataObj['hasWarning']) {
            hasWarning = dataObj['hasWarning'];
        }

        if (startFrame != 0 && !bgm) {
            TraceLang('debug.trace.data.fighter_vo.undefined_bgm', id);
        }
    }

    /**
     * 获得随机胜利语言
     *
     * @return 随机胜利语言
     */
    public function getRandSay():String {
        return KyoRandom.getRandomInArray(says);
    }

}
}
