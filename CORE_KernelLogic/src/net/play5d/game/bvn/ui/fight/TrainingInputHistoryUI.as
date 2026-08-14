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

package net.play5d.game.bvn.ui.fight {
import com.greensock.TweenLite;

import flash.display.Sprite;
import flash.geom.ColorTransform;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.GameRunFighterGroup;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.data.fighter.FighterInputCmd;
import net.play5d.game.bvn.data.fighter.FighterSpecialFrame;
import net.play5d.game.bvn.fighter.FighterMC;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.fighter.events.FighterEvent;
import net.play5d.game.bvn.input.GameInputType;
import net.play5d.game.bvn.input.GameInputer;
import net.play5d.kyo.display.bitmap.BitmapFont;
import net.play5d.kyo.display.bitmap.BitmapFontText;

/**
 * 练习模式单侧技能输入历史。
 *
 * <p>移动 <code>A</code>/<code>D</code> 按键边沿显示，防御 <code>S</code> 在进入防御时显示；
 * 攻击/技能等按出招指令显示（与自定义帧标签无关，如 <code>砍技21</code> 仍记 <code>WJ</code>）；
 * 同一连段内技能用 <code>-</code> 衔接为一行（如 <code>J-J-WJ-WU-WI</code>），
 * <code>idle()</code> 调用后另起一行；灵压爆发/替身术的 <code>O</code> 与快速起身的 <code>L</code>
 * 使用菜单选中同款红色；历史分布在辅助头像到连击数字之间；
 * 回到站立待机并持续片刻后清空。</p>
 *
 * @see BitmapFontText
 * @see FighterEvent#DO_ACTION
 * @see FighterInputCmd
 * @see FighterSpecialFrame
 */
public class TrainingInputHistoryUI extends Sprite {

    /** @private 最新输入基准 Y（贴近辅助头像上方）。 */
    private static const BASE_Y:Number                       = 490;
    /**
     * @private 最旧项消失上限 Y（贴近连击数字 / hits）。
     * <p>继续上移会越过此线并淡出，不进入主头像区域。</p>
     */
    private static const TOP_Y:Number                        = 150;
    /** @private 行距 */
    private static const LINE_GAP:Number                     = 34;
    /** @private 相对高度可容纳层数再减 1 */
    private static const MAX_LAYERS_CUT:int                  = 1;
    /** @private 可见行数上限（由 BASE/TOP/行距预计算） */
    private static const MAX_ITEMS:int                       = int((BASE_Y - TOP_Y) / LINE_GAP) - MAX_LAYERS_CUT + 1;
    /** @private 位图字缩放 */
    private static const TEXT_SCALE:Number                   = 0.7;
    /** @private 上移动画时长（秒） */
    private static const MOVE_TIME:Number                    = 0.12;
    /** @private 淡出时长（秒） */
    private static const FADE_TIME:Number                    = 0.5;
    /** @private 站立待机后延迟清空（秒） */
    private static const IDLE_HOLD_SEC:Number                = 1;
    /** @private 连段衔接符 */
    private static const COMBO_SEP:String                    = '-';
    /** @private 普通攻击帧前缀（砍） */
    private static const ATTACK_CHAR:String                  = FighterSpecialFrame.ATTACK.charAt(0);
    /** @private 砍技前缀（砍技），用于排除普通连段误判 */
    private static const SKILL_PREFIX:String                 = FighterSpecialFrame.SKILL_1.substr(0, 2);
    /** @private 菜单选中同款红色 ColorTransform */
    private static const HIGHLIGHT_CT:ColorTransform         = new ColorTransform(1, 1, 1, 1, 50, -30, -30, 0);

    /**
     * @private 帧标签 → 输入串（键/值均来自 CORE_Shared）。
     * <p>普通连段 <code>砍1</code>/<code>砍2</code>… 由 <code>actionToText</code> 另行识别为 <code>J</code>。</p>
     */
    private static const ACTION_TEXT:Object = buildActionText();

    /** @private */
    private static function buildActionText():Object {
        var map:Object = {};
        map[FighterSpecialFrame.SKILL_1]     = FighterInputCmd.SKILL_1;
        map[FighterSpecialFrame.SKILL_2]     = FighterInputCmd.SKILL_2;
        map[FighterSpecialFrame.ZHAO_1]      = FighterInputCmd.ZHAO_1;
        map[FighterSpecialFrame.ZHAO_2]      = FighterInputCmd.ZHAO_2;
        map[FighterSpecialFrame.ZHAO_3]      = FighterInputCmd.ZHAO_3;
        map[FighterSpecialFrame.BISHA]       = FighterInputCmd.BISHA;
        map[FighterSpecialFrame.BISHA_UP]    = FighterInputCmd.BISHA_UP;
        map[FighterSpecialFrame.BISHA_SUPER] = FighterInputCmd.BISHA_SUPER;
        map[FighterSpecialFrame.BISHA_AIR]   = FighterInputCmd.BISHA_AIR;
        map[FighterSpecialFrame.ATTACK_AIR]  = FighterInputCmd.ATTACK_AIR;
        map[FighterSpecialFrame.SKILL_AIR]   = FighterInputCmd.SKILL_AIR;
        map[FighterSpecialFrame.SKILL_AIR_W] = FighterInputCmd.SKILL_AIR_W;
        map[FighterSpecialFrame.SKILL_AIR_S] = FighterInputCmd.SKILL_AIR_S;
        map[FighterSpecialFrame.DASH]        = FighterInputCmd.DASH;
        map[FighterSpecialFrame.JUMP]        = FighterInputCmd.JUMP;
        map[FighterSpecialFrame.JUMP_DOWN]   = FighterInputCmd.JUMP_DOWN;
        map[FighterSpecialFrame.BANKAI]      = FighterInputCmd.BANKAI;
        map[FighterSpecialFrame.BANKAI_W]    = FighterInputCmd.BANKAI_W;
        map[FighterSpecialFrame.BANKAI_S]    = FighterInputCmd.BANKAI_S;

        return map;
    }

    /**
     * @param inputType 输入类型（如 <code>GameInputType.P1</code> / <code>P2</code>）。
     * @param alignRight 是否右对齐（P2 侧）。
     * @example
     * <listing version="3.0">
     * var p1:TrainingInputHistoryUI = new TrainingInputHistoryUI(GameInputType.P1);
     * var p2:TrainingInputHistoryUI = new TrainingInputHistoryUI(GameInputType.P2, true);
     * </listing>
     */
    public function TrainingInputHistoryUI(inputType:String, alignRight:Boolean = false) {
        super();

        _inputType   = inputType;
        _alignRight  = alignRight;
        mouseEnabled = mouseChildren = false;

        _font            = AssetManager.I.getFont('font1');
        _items           = new Vector.<BitmapFontText>();
        _idleHoldFrames  = IDLE_HOLD_SEC * GameConfig.FPS_GAME;
        _idleHoldTimer   = 0;
        _prevLeft        = false;
        _prevRight       = false;
        _pushedThisFrame = false;
        _comboOpen       = false;
    }

    /** @private */
    private var _inputType:String;
    /** @private */
    private var _alignRight:Boolean;
    /** @private 复用位图字体，避免每次 push 查表 */
    private var _font:BitmapFont;
    /** @private 从旧到新 */
    private var _items:Vector.<BitmapFontText>;
    /** @private 上一帧左方向是否按下 */
    private var _prevLeft:Boolean;
    /** @private 上一帧右方向是否按下 */
    private var _prevRight:Boolean;
    /** @private 站立待机需持续的帧数 */
    private var _idleHoldFrames:int;
    /** @private 已持续站立待机的帧数 */
    private var _idleHoldTimer:int;
    /** @private 当前绑定的角色 */
    private var _boundFighter:FighterMain;
    /** @private 本帧是否已有新历史（含事件回调） */
    private var _pushedThisFrame:Boolean;
    /** @private 上一帧动作状态（用于防御边沿 / 回 NORMAL） */
    private var _prevActionState:int = -1;
    /** @private 当前技能连段行是否可继续用 - 衔接 */
    private var _comboOpen:Boolean;

    /**
     * 每帧采样移动/防御输入，并处理待机清空。
     *
     * @example
     * <listing version="3.0">
     * history.render();
     * </listing>
     */
    public function render():void {
        _pushedThisFrame = false;

        if (!GameCtrl.I || !GameCtrl.I.actionEnable) {
            syncPrevWithoutPush();
            unbindFighter();

            return;
        }

        bindFighter(getFighter());
        sampleMoveAndGuard();
        updateIdleClear();
    }

    /**
     * 释放全部字符、事件与缓动。
     *
     * @example
     * <listing version="3.0">
     * history.destroy();
     * </listing>
     */
    public function destroy():void {
        unbindFighter();

        var i:int;
        var txt:BitmapFontText;
        if (_items) {
            for (i = 0; i < _items.length; i++) {
                TweenLite.killTweensOf(_items[i]);
            }
            _items = null;
        }

        while (numChildren > 0) {
            txt = getChildAt(0) as BitmapFontText;
            removeChildAt(0);
            if (txt) {
                TweenLite.killTweensOf(txt);
                txt.dispose();
            }
        }

        _font = null;
    }

    /** @private 采样 A/D 边沿与防御进入，并更新动作状态边沿。 */
    private function sampleMoveAndGuard():void {
        var fighter:FighterMain = _boundFighter;
        var state:int           = fighter ? fighter.actionState : -1;

        // 技能等结束后回 NORMAL：清方向边沿，使技能中一直按住的 A/D 在落地后仍能记一次
        if (state == FighterActionState.NORMAL &&
            _prevActionState != FighterActionState.NORMAL &&
            _prevActionState != -1) {
            resetMoveEdges();
        }

        var leftDown:Boolean  = GameInputer.left(_inputType, 0);
        var rightDown:Boolean = GameInputer.right(_inputType, 0);
        var canMove:Boolean   = state == FighterActionState.NORMAL;

        if (canMove && leftDown && !_prevLeft) {
            pushText(FighterInputCmd.LEFT);
        }
        if (canMove && rightDown && !_prevRight) {
            pushText(FighterInputCmd.RIGHT);
        }

        _prevLeft  = leftDown;
        _prevRight = rightDown;

        if (state == FighterActionState.DEFENSE_ING &&
            _prevActionState != FighterActionState.DEFENSE_ING) {
            // 幽步（下+冲刺）或其连段间隙不单独记 S，避免 S SL S SL
            if (!GameInputer.dash(_inputType, 0) &&
                !(isLastText(FighterInputCmd.GHOST_DASH_S) && GameInputer.down(_inputType, 0))) {
                pushText(FighterInputCmd.DEFENSE);
            }
        }

        _prevActionState = state;
    }

    /** @private 回到站立待机且本帧无新输入时，持续片刻后再清空。 */
    private function updateIdleClear():void {
        if (!_pushedThisFrame && isFighterStandIdle()) {
            if (_idleHoldTimer < _idleHoldFrames) {
                _idleHoldTimer++;
            }
            if (_idleHoldTimer >= _idleHoldFrames) {
                clearAll();
                _idleHoldTimer = 0;
            }
        }
        else {
            _idleHoldTimer = 0;
        }
    }

    /** @private */
    private function bindFighter(fighter:FighterMain):void {
        if (_boundFighter == fighter) {
            return;
        }
        unbindFighter();
        _boundFighter = fighter;
        if (_boundFighter) {
            _boundFighter.addEventListener(FighterEvent.DO_ACTION, onDoAction);
            _boundFighter.addEventListener(FighterEvent.IDLE, onFighterIdle);
        }
    }

    /** @private */
    private function unbindFighter():void {
        if (!_boundFighter) {
            return;
        }
        _boundFighter.removeEventListener(FighterEvent.DO_ACTION, onDoAction);
        _boundFighter.removeEventListener(FighterEvent.IDLE, onFighterIdle);
        _boundFighter = null;
    }

    /** @private idle() 后打断技能连段衔接，并释放方向边沿。 */
    private function onFighterIdle(e:FighterEvent):void {
        _comboOpen = false;
        resetMoveEdges();
    }

    /** @private */
    private function onDoAction(e:FighterEvent):void {
        if (!GameCtrl.I || !GameCtrl.I.actionEnable) {
            return;
        }

        var params:Object     = e.params;
        var input:String      = params ? (params.input as String) : null;
        var action:String     = params ? (params.action as String) : null;
        var highlight:Boolean = params ? Boolean(params.highlight) : false;
        if (!action && _boundFighter && _boundFighter.getMC()) {
            action = _boundFighter.getMC().currentFrameName;
        }

        // 优先用出招时传入的指令串（与自定义帧标签无关）
        var text:String = input ? input : actionToText(action);
        if (text) {
            pushText(text, highlight);
        }
    }

    /** @private 暂停等不可操作时只同步边沿状态。 */
    private function syncPrevWithoutPush():void {
        _prevLeft  = GameInputer.left(_inputType, 0);
        _prevRight = GameInputer.right(_inputType, 0);

        var fighter:FighterMain = getFighter();
        _prevActionState = fighter ? fighter.actionState : -1;
    }

    /** @private 清 A/D 边沿，使下一帧仍按住的方向可记一次。 */
    private function resetMoveEdges():void {
        _prevLeft  = false;
        _prevRight = false;
    }

    /** @private 取当前侧出战角色。 */
    private function getFighter():FighterMain {
        if (!GameCtrl.I || !GameCtrl.I.gameRunData) {
            return null;
        }

        var group:GameRunFighterGroup = (_inputType == GameInputType.P2)
                ? GameCtrl.I.gameRunData.p2FighterGroup
                : GameCtrl.I.gameRunData.p1FighterGroup;

        return group ? group.currentFighter : null;
    }

    /**
     * @private 是否处于站立待机（NORMAL + 站立帧）。
     */
    private function isFighterStandIdle():Boolean {
        var fighter:FighterMain = _boundFighter;
        if (!fighter || fighter.actionState != FighterActionState.NORMAL) {
            return false;
        }

        var mc:FighterMC = fighter.getMC();

        return mc != null && mc.currentFrameName == FighterSpecialFrame.IDLE;
    }

    /**
     * @private 将动作帧标签转为输入串；非技能段返回 <code>null</code>。
     */
    private function actionToText(action:String):String {
        if (!action || action.length == 0) {
            return null;
        }
        // 摔技：按当前左右键显示 AJ/DJ 或 AU/DU
        if (action == FighterSpecialFrame.CATCH_1) {
            return getCatchSideLetter() + FighterInputCmd.ATTACK;
        }
        if (action == FighterSpecialFrame.CATCH_2) {
            return getCatchSideLetter() + FighterInputCmd.ZHAO_1;
        }

        var mapped:String = ACTION_TEXT[action] as String;
        if (mapped) {
            return mapped;
        }
        // 普通连段：砍1 / 砍2 / 砍3…（排除砍技）
        if (action.indexOf(ATTACK_CHAR) == 0 && action.indexOf(SKILL_PREFIX) != 0) {
            return FighterInputCmd.ATTACK;
        }

        return null;
    }

    /**
     * @private 摔技左右方向字母；优先当前按键（双边同时按偏右），否则用朝向。
     */
    private function getCatchSideLetter():String {
        if (GameInputer.right(_inputType, 0)) {
            return FighterInputCmd.RIGHT;
        }
        if (GameInputer.left(_inputType, 0)) {
            return FighterInputCmd.LEFT;
        }
        if (_boundFighter && _boundFighter.direct > 0) {
            return FighterInputCmd.RIGHT;
        }

        return FighterInputCmd.LEFT;
    }

    /** @private */
    private function pushText(text:String, highlight:Boolean = false):void {
        if (!text || !_items) {
            return;
        }

        // 幽步 SL 会先触发防御 S，去掉紧邻的多余 S
        if (text == FighterInputCmd.GHOST_DASH_S) {
            removeTrailingText(FighterInputCmd.DEFENSE);
        }

        var moveOrGuard:Boolean = isMoveOrGuardText(text);
        if (moveOrGuard || highlight) {
            _comboOpen = false;
        }
        else if (_comboOpen && tryAppendCombo(text)) {
            return;
        }

        while (_items.length >= MAX_ITEMS) {
            fadeOutOldest();
        }

        var txt:BitmapFontText = new BitmapFontText(_font);
        txt.text               = text;
        txt.scaleX = txt.scaleY = TEXT_SCALE;
        if (highlight) {
            txt.applyColorTransform(HIGHLIGHT_CT);
        }
        txt.x = _alignRight ? -txt.width : 0;
        txt.y = BASE_Y;
        addChild(txt);
        _items.push(txt);

        _idleHoldTimer   = 0;
        _pushedThisFrame = true;
        // 高亮特殊技不并入后续连段；移动/防御同样打断
        _comboOpen = !moveOrGuard && !highlight;

        layoutItems(true);
    }

    /**
     * @private 同一连段内接到末行（如 <code>J-J-WJ-WU-WI</code>）。
     * @return 已合并到末行时为 <code>true</code>。
     */
    private function tryAppendCombo(text:String):Boolean {
        if (!_items || _items.length == 0) {
            return false;
        }

        var last:BitmapFontText = _items[_items.length - 1];
        if (!last || isMoveOrGuardText(last.text)) {
            return false;
        }

        last.text              = last.text + COMBO_SEP + text;
        last.scaleX = last.scaleY = TEXT_SCALE;
        last.x                 = _alignRight ? -last.width : 0;
        _idleHoldTimer         = 0;
        _pushedThisFrame       = true;

        return true;
    }

    /** @private 是否为移动/防御单键（打断连段）。 */
    private function isMoveOrGuardText(s:String):Boolean {
        return s == FighterInputCmd.LEFT ||
               s == FighterInputCmd.RIGHT ||
               s == FighterInputCmd.DEFENSE;
    }

    /**
     * @private 若末条历史等于指定文本则立刻移除（用于合并 S+L → SL）。
     */
    private function removeTrailingText(match:String):void {
        if (!_items || _items.length == 0) {
            return;
        }

        var last:BitmapFontText = _items[_items.length - 1];
        if (!last || last.text != match) {
            return;
        }

        _items.pop();
        TweenLite.killTweensOf(last);
        disposeItem(last);
        layoutItems(false);
    }

    /** @private */
    private function isLastText(match:String):Boolean {
        if (!_items || _items.length == 0) {
            return false;
        }

        var last:BitmapFontText = _items[_items.length - 1];

        return last != null && last.text == match;
    }

    /** @private 角色站立待机时清空全部历史。 */
    private function clearAll():void {
        if (!_items || _items.length == 0) {
            return;
        }

        var fading:Vector.<BitmapFontText> = _items;
        _items     = new Vector.<BitmapFontText>();
        _comboOpen = false;

        var i:int;
        for (i = 0; i < fading.length; i++) {
            fadeOutItem(fading[i]);
        }
    }

    /** @private */
    private function fadeOutItem(txt:BitmapFontText):void {
        TweenLite.killTweensOf(txt);
        TweenLite.to(txt, FADE_TIME, {
            alpha     : 0,
            onComplete: function():void {
                disposeItem(txt);
            }
        });
    }

    /** @private */
    private function layoutItems(animate:Boolean):void {
        var n:int = _items.length;
        var i:int;
        var txt:BitmapFontText;
        var ty:Number;
        for (i = 0; i < n; i++) {
            txt = _items[i];
            ty  = BASE_Y - (n - 1 - i) * LINE_GAP;
            TweenLite.killTweensOf(txt);
            if (animate) {
                TweenLite.to(txt, MOVE_TIME, {y: ty});
            }
            else {
                txt.y = ty;
            }
        }
    }

    /** @private */
    private function fadeOutOldest():void {
        if (_items.length == 0) {
            return;
        }

        fadeOutItem(_items.shift());
    }

    /** @private */
    private function disposeItem(txt:BitmapFontText):void {
        if (!txt) {
            return;
        }
        TweenLite.killTweensOf(txt);
        if (txt.parent) {
            txt.parent.removeChild(txt);
        }
        txt.dispose();
    }

}
}
