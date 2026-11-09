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

package net.play5d.game.bvn.events {
import flash.events.Event;

/**
 * 设置按钮发出的选择、选项和确认事件。
 *
 * <p>没有覆写 <code>clone</code>。显示列表按父类重派时，下面三个字段会丢掉。
 * 按钮组向上转发时用的是 <code>newEvent</code>，这三个字段会复制过去。
 * 选择事件只写 <code>selectedLabel</code>。选项变化只在当前选项存在时发出，并写 <code>optionKey</code> 和 <code>optionValue</code>。
 * 应用和取消构造时不写这三个字段。</p>
 *
 * @see flash.events.Event
 * @see #newEvent()
 */
public class SetBtnEvent extends Event {

    /**
     * 选中按钮。监听方读 <code>selectedLabel</code>。
     *
     * @eventType SELECT
     */
    public static const SELECT:String        = 'SELECT';
    /**
     * 选项改变。监听方读 <code>optionKey</code> 和 <code>optionValue</code>。
     *
     * @eventType OPTION_CHANGE
     */
    public static const OPTION_CHANGE:String = 'OPTION_CHANGE';
    /**
     * 应用设置。不带额外字段。
     *
     * @eventType APPLY_SET
     */
    public static const APPLY_SET:String     = 'APPLY_SET';
    /**
     * 取消设置。不带额外字段。
     *
     * @eventType CANCEL_SET
     */
    public static const CANCEL_SET:String    = 'CANCEL_SET';

    /**
     * 用事件名构造。三个附加字段保持 <code>null</code>，由发出方再赋值。
     *
     * @param type 事件名。为空时父类构造抛错。
     * @param bubbles 是否冒泡。默认 <code>false</code>。按钮发出时用的就是默认值。
     * @param cancelable 是否可取消。默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * var e:SetBtnEvent = new SetBtnEvent(SetBtnEvent.SELECT);
     * </listing>
     */
    public function SetBtnEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }
    /**
     * 选中按钮的标签。选择事件才会写它。
     *
     * @default null
     */
    public var selectedLabel:String;
    /**
     * 选项键。选项变化事件才会写它。
     *
     * @default null
     */
    public var optionKey:String;
    /**
     * 选项值。选项变化事件才会写它。
     *
     * @default null
     */
    public var optionValue:*;

    /**
     * 复制一份，连同三个附加字段。
     *
     * @return 新的设置按钮事件。
     * @example
     * <listing version="3.0">
     * var copy:SetBtnEvent = e.newEvent();
     * </listing>
     */
    public function newEvent():SetBtnEvent {
        var event:SetBtnEvent = new SetBtnEvent(type, bubbles, cancelable);
        event.selectedLabel   = selectedLabel;
        event.optionKey       = optionKey;
        event.optionValue     = optionValue;
        return event;
    }

}
}
