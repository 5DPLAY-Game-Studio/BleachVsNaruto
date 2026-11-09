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

/**
 * 角色或援助的展示数据和背景音乐。
 *
     * <p>初始化会把好友、敌人列表清成空数组，不读配置里的对应字段。
     * 没有 <code>start_frame</code> 时开场帧留着 0。有开场帧却没有背景音乐时打一条日志。
     * 没有胜利台词时，随机台词返回 <code>null</code>。</p>
 *
 * @see FighterModel
 */
public class FighterVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 角色 id。
     *
     * @default null
     */
    public var id:String;
    /**
     * 名字。
     *
     * @default null
     */
    public var name:String;
    /**
     * 漫画类型。0 为死神，1 为火影。
     *
     * @default 0
     */
    public var comicType:int;
    /**
     * 角色 SWF 地址。
     *
     * @default null
     */
    public var fileUrl:String;
    /**
     * 开场帧。配置没写时保持 0。
     *
     * @default 0
     */
    public var startFrame:int;
    /**
     * 小头像地址。
     *
     * @default null
     */
    public var faceUrl:String;
    /**
     * 大头像地址。
     *
     * @default null
     */
    public var faceBigUrl:String;
    /**
     * 血条头像地址。
     *
     * @default null
     */
    public var faceBarUrl:String;
    /**
     * 胜利图地址。
     *
     * @default null
     */
    public var faceWinUrl:String;
    /**
     * 好友 id。初始化后是空数组。
     *
     * @default null
     */
    public var contactFriends:Array;
    /**
     * 敌人 id。初始化后是空数组。
     *
     * @default null
     */
    public var contactEnemies:Array;
    /**
     * 胜利台词。
     *
     * @default null
     */
    public var says:Array;
    /**
     * 背景音乐地址。
     *
     * @default null
     */
    public var bgm:String;
    /**
     * 背景音乐权重。配置写了 <code>bgm</code> 却没有 <code>rate</code> 时会变成 <code>NaN</code>。
     *
     * @default 1
     */
    public var bgmRate:Number     = 1;
    /**
     * 是否需要提示。
     *
     * @default false
     */
    public var hasWarning:Boolean = false;

    /**
     * 是否存活。包数据里通常不用。
     *
     * @default false
     */
    public var isAlive:Boolean;

    /**
     * 用角色包里的一条记录填写字段。
     *
     * <p>没有 <code>path</code> 或 <code>data</code> 时抛错。</p>
     *
     * @param obj 含 <code>path</code> 和 <code>data</code> 的对象。
     * @example
     * <listing version="3.0">
     * vo.initByObject(obj);
     * </listing>
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

        if (dataObj['urls']) {
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
        }

        contactFriends = [];
        contactEnemies = [];

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
            TraceLang('fighter_vo.undefined_bgm', {fighterId: id});
        }
    }

    /**
     * 从胜利台词里随机一句。
     *
     * <p>没有台词或空数组时返回 <code>null</code>。</p>
     *
     * @return 一句台词。
     * @example
     * <listing version="3.0">
     * var line:String = vo.getRandSay();
     * </listing>
     */
    public function getRandSay():String {
        return KyoRandom.getRandomInArray(says);
    }

}
}
