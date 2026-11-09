/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.ide.component.effect {
import net.play5d.game.bvn.data.fighter.FighterHitFloorType;
import net.play5d.game.bvn.ide.component.BaseEffect;

/**
 * 击落地特效 IDE 组件。
 *
 * <p>FighterMain 时间轴组件：调用 <code>$effect_ctrler.hitFloor</code>。</p>
 * <p>检查器「落地类型」为中文枚举，运行时映射为 <code>FighterHitFloorType</code>。</p>
 *
 * @see net.play5d.game.bvn.data.fighter.FighterHitFloorType
 * @see net.play5d.game.bvn.ide.component.BaseEffect
 */
public class HitFloorEffect extends BaseEffect {

    /** @private 检查器枚举文案（与 TYPES 下标对齐） */
    private static const LABELS:Array = ['弹起', '正常', '重击'];

    /** @private 落地类型常量（与 LABELS 下标对齐） */
    private static const TYPES:Array = [
        FighterHitFloorType.TAN,
        FighterHitFloorType.NORMAL,
        FighterHitFloorType.HEAVY
    ];

    /** @private 落地类型（FighterHitFloorType） */
    private var _type:int = FighterHitFloorType.NORMAL;

    /** @private 落地类型检查器文案 */
    private var _typeLabel:String = '正常';

    /** @private 震动幅度 */
    private var _shakePow:Number = 0;

    /**
     * 设置击落地标题，并按当前落地类型刷新调用预览。
     *
     * @example
     * <listing version="3.0">
     * var effect:HitFloorEffect = new HitFloorEffect();
     * effect.type = '重击';
     * effect.shakePow = 6;
     * </listing>
     */
    public function HitFloorEffect() {
        super.title = '效果_击落地';
        refreshPreview();
    }

    /**
     * 落地类型（检查器文案）。
     *
     * <p>可选：弹起 / 正常 / 重击，对应 <code>FighterHitFloorType</code> 的 0 / 1 / 2。</p>
     *
     * @return 当前文案。
     * @default 正常
     */
    public function get type():String {
        return _typeLabel;
    }

    /** @private */
    [Inspectable(name='落地类型', type='String', enumeration='弹起,正常,重击', defaultValue='正常')]
    public function set type(v:String):void {
        var label:String = v ? v : '';
        var idx:int      = LABELS.indexOf(label);

        _typeLabel = label;
        if (idx >= 0) {
            _type = TYPES[idx];
        }

        refreshPreview();
    }

    /**
     * 震动幅度。
     *
     * @return 震动大小。
     * @default 0
     */
    public function get shakePow():Number {
        return _shakePow;
    }

    /** @private */
    [Inspectable(name='震动幅度', type='Number', defaultValue=0)]
    public function set shakePow(v:Number):void {
        _shakePow = v;
        refreshPreview();
    }

    /**
     * @inheritDoc
     */
    override public function doAction():void {
        if (!validateParam('落地类型', _typeLabel, LABELS)) {
            return;
        }

        invokeEffect('hitFloor', [_type, _shakePow]);
    }

    /** @private */
    private function refreshPreview():void {
        if (!validateParam('落地类型', _typeLabel, LABELS)) {
            return;
        }

        updateCallPreview('hitFloor', [_type, _shakePow]);
    }
}
}
