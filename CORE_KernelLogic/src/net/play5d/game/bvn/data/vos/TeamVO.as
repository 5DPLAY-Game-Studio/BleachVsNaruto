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
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.interfaces.IInstanceVO;

/**
 * 一支队伍和它的精灵。
 *
 * <p><code>getAliveChildren</code> 每次返回同一条缓冲。下一次调用会改掉上一次的内容。
 * 不是 <code>BaseGameSprite</code> 的精灵一律算存活。</p>
 *
 * @see TeamMap
 */
public class TeamVO implements IInstanceVO {

    include '../../../../../../../include/Clone.as';

    /**
     * 按 id 建队伍。
     *
     * @param id 队伍 id。
     * @param name 名字。默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var team:TeamVO = new TeamVO(1, 'P1');
     * </listing>
     */
    public function TeamVO(id:int, name:String = null) {
        this.id   = id;
        this.name = name;
    }

    /**
     * 队伍 id。
     *
     * @default 0
     */
    public var id:int;
    /**
     * 队伍名字。
     *
     * @default null
     */
    public var name:String;
    /**
     * 队伍里的精灵。重复加入会被忽略。
     */
    public var children:Vector.<IGameSprite>   = new Vector.<IGameSprite>();
    /** @private getAliveChildren 复用缓冲 */
    private var _aliveBuf:Vector.<IGameSprite> = new Vector.<IGameSprite>();

    /**
     * 取还活着的精灵。
     *
     * <p>返回内部缓冲，下次调用会清空再填。</p>
     *
     * @return 存活精灵。
     * @example
     * <listing version="3.0">
     * var alive:Vector.&lt;IGameSprite&gt; = team.getAliveChildren();
     * </listing>
     */
    public function getAliveChildren():Vector.<IGameSprite> {
        var result:Vector.<IGameSprite> = _aliveBuf;
        result.length                   = 0;
        for (var i:int; i < children.length; i++) {
            var c:IGameSprite = children[i];
            if (c is BaseGameSprite) {
                if ((
                        c as BaseGameSprite
                ).isAlive) {
                    result.push(c);
                }
            }
            else {
                result.push(c);
            }
        }
        return result;
    }

    /**
     * 加入精灵。已经在队伍里时忽略。
     *
     * @param v 精灵。
     * @example
     * <listing version="3.0">
     * team.addChild(sprite);
     * </listing>
     */
    public function addChild(v:IGameSprite):void {
        var index:int = children.indexOf(v);
        if (index == -1) {
            children.push(v);
        }
    }

    /**
     * 从队伍拿掉精灵。不在队伍里时什么都不做。
     *
     * @param v 精灵。
     * @example
     * <listing version="3.0">
     * team.removeChild(sprite);
     * </listing>
     */
    public function removeChild(v:IGameSprite):void {
        var index:int = children.indexOf(v);
        if (index != -1) {
            children.splice(index, 1);
        }
    }

}
}
