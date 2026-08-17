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

package net.play5d.game.bvn.ctrler.effect {
import flash.display.DisplayObject;
import flash.geom.ColorTransform;
import flash.geom.Point;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.EffectCtrl;
import net.play5d.game.bvn.ctrler.GameLogic;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.data.TeamID;
import net.play5d.game.bvn.data.fighter.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.BaseGameSprite;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.map.MapMain;
import net.play5d.game.bvn.stage.GameStage;
import net.play5d.game.bvn.views.effects.BitmapFilterView;
import net.play5d.game.bvn.views.effects.BlackBackView;

/**
 * 必杀黑屏域：黑底、地图压暗、只渲染目标，及替身 / 灵压爆发演出。
 *
 * @see EffectCtrl
 */
public class EffectBlackBackHandler {

    /** @private 每帧向目标倍率逼近的步长 */
    private static const BLACK_BACK_RATE:Number = 0.025;
    /** @private 必杀中背景变暗目标倍率 */
    private static const BLACK_BACK_DARK:Number = 0.3;
    /** @private 正常亮度倍率 */
    private static const BLACK_BACK_NORMAL:Number = 1;

    /** @private */
    private var _ctrl:EffectCtrl;
    /** @private */
    private var _gameStage:GameStage;
    /** @private */
    private var _blackBack:BlackBackView;
    /** @private */
    private var _justRenderAnimateTargets:Vector.<BaseGameSprite>;
    /** @private */
    private var _justRenderTargets:Vector.<BaseGameSprite>;
    /** @private */
    private var _renderBlackBack:Boolean;
    /** @private */
    private var _blackBackMul:Number = 1;
    /** @private */
    private var _blackBackCt:ColorTransform;
    /** @private */
    private var _replaceSkillFrame:int;
    /** @private */
    private var _replaceSkillFrameHold:int;
    /** @private */
    private var _replaceSkillPos:Point;
    /** @private */
    private var _explodeSkillFrame:int;
    /** @private */
    private var _explodeEffectPos:Point;

    /**
     * 绑定门面与舞台，创建黑屏视图。
     *
     * @param ctrl <code>EffectCtrl</code> 门面。
     * @param gameStage 游戏主舞台。
     * @example
     * <listing version="3.0">
     * handler.initialize(EffectCtrl.I, stage);
     * </listing>
     */
    public function initialize(ctrl:EffectCtrl, gameStage:GameStage):void {
        _ctrl      = ctrl;
        _gameStage = gameStage;

        _justRenderAnimateTargets = new Vector.<BaseGameSprite>();
        _justRenderTargets        = new Vector.<BaseGameSprite>();
        _blackBack                = new BlackBackView();

        _renderBlackBack = false;
        _blackBackMul    = BLACK_BACK_NORMAL;
        _blackBackCt     = null;
        _replaceSkillFrame = _explodeSkillFrame = 0;
        _replaceSkillFrameHold = 0;
    }

    /**
     * 销毁黑屏视图并释放引用。
     *
     * @example
     * <listing version="3.0">
     * handler.destroy();
     * </listing>
     */
    public function destroy():void {
        _replaceSkillFrame = _explodeSkillFrame = 0;
        _replaceSkillFrameHold = 0;

        if (_blackBack) {
            _blackBack.destroy();
            _blackBack = null;
        }

        _renderBlackBack = false;
        _blackBackMul    = BLACK_BACK_NORMAL;
        _blackBackCt     = null;

        _justRenderAnimateTargets = null;
        _justRenderTargets        = null;
        _ctrl                     = null;
        _gameStage                = null;
    }

    /**
     * 开始渲染必杀时地图压暗。
     *
     * @example
     * <listing version="3.0">
     * handler.startRenderBlackBack();
     * </listing>
     */
    public function startRenderBlackBack():void {
        _renderBlackBack = true;
    }

    /**
     * 必杀演出。
     *
     * @param target 发动方。
     * @param isSuper 是否超必杀。
     * @param face 特写。
     * @example
     * <listing version="3.0">
     * handler.bisha(fighter, false, face);
     * </listing>
     */
    public function bisha(target:BaseGameSprite, isSuper:Boolean = false, face:DisplayObject = null):void {
        justRenderAnimate(target);
        GameCtrl.I.pause();
        GameCtrl.I.setRenderHit(false);
        _gameStage.addChildAt(_blackBack, 0);
        _blackBack.fadIn();
        if (face && target is FighterMain) {
            showFace(target as FighterMain, face);
        }

        if (isSuper) {
            GameCtrl.I.gameState.cameraFocusOne(target.getDisplay());
            _ctrl.doEffectById('bisha_super', target.x, target.y - 50);
        }
        else {
            _ctrl.doEffectById('bisha', target.x, target.y - 50);
        }

        _gameStage.getMap().setVisible(false);
        _gameStage.setVisibleByClass(BitmapFilterView, false);
    }

    /**
     * 结束必杀演出。
     *
     * @param target 发动方。
     * @example
     * <listing version="3.0">
     * handler.endBisha(fighter);
     * </listing>
     */
    public function endBisha(target:BaseGameSprite):void {
        if (cancelJustRenderAnimate(target)) {
            GameCtrl.I.resume();
            GameCtrl.I.gameState.cameraResume();
            GameCtrl.I.setRenderHit(true);
            _blackBack.fadOut();

            _gameStage.getMap().setVisible(true);
            _gameStage.setVisibleByClass(BitmapFilterView, true);
        }
    }

    /**
     * 卍解演出。
     *
     * @param target 发动方。
     * @param face 特写。
     * @example
     * <listing version="3.0">
     * handler.wanKai(fighter, face);
     * </listing>
     */
    public function wanKai(target:FighterMain, face:DisplayObject = null):void {
        justRenderAnimate(target);
        GameCtrl.I.pause();
        GameCtrl.I.setRenderHit(false);
        _gameStage.addChildAt(_blackBack, 0);
        _blackBack.fadIn();
        if (face) {
            showFace(target, face);
        }

        GameCtrl.I.gameState.cameraFocusOne(target.getDisplay());
        _ctrl.doEffectById('bisha_super', target.x, target.y - 50);

        _gameStage.getMap().setVisible(false);
        _gameStage.setVisibleByClass(BitmapFilterView, false);
    }

    /**
     * 结束卍解演出。
     *
     * @param target 发动方。
     * @example
     * <listing version="3.0">
     * handler.endWanKai(fighter);
     * </listing>
     */
    public function endWanKai(target:FighterMain):void {
        if (cancelJustRenderAnimate(target)) {
            GameCtrl.I.resume();
            GameCtrl.I.gameState.cameraResume();
            _blackBack.fadOut();
            GameCtrl.I.setRenderHit(true);
            _gameStage.getMap().setVisible(true);
        }
    }

    /**
     * 替身术演出。
     *
     * @param target 发动方。
     * @example
     * <listing version="3.0">
     * handler.replaceSkill(fighter);
     * </listing>
     */
    public function replaceSkill(target:BaseGameSprite):void {
        GameCtrl.I.pause();
        _gameStage.addChildAt(_blackBack, 0);
        _gameStage.getMap().setVisible(false);

        _ctrl.doEffectById('replaceSp', target.x, target.y);
        _replaceSkillPos = new Point(target.x, target.y);

        _replaceSkillFrame     = 0;
        _replaceSkillFrameHold = GameConfig.FPS_GAME;
    }

    /**
     * 灵压爆发演出。
     *
     * @param target 发动方。
     * @example
     * <listing version="3.0">
     * handler.energyExplode(fighter);
     * </listing>
     */
    public function energyExplode(target:BaseGameSprite):void {
        GameCtrl.I.pause();
        _gameStage.addChildAt(_blackBack, 0);
        _gameStage.getMap().setVisible(false);

        _ctrl.doEffectById('explodeSp', target.x, target.y);
        _explodeEffectPos = new Point(target.x, target.y);

        _explodeSkillFrame = 0.7 * GameConfig.FPS_GAME;
    }

    /**
     * 鬼步开始。
     *
     * @param target 发动方。
     * @example
     * <listing version="3.0">
     * handler.ghostStep(fighter);
     * </listing>
     */
    public function ghostStep(target:BaseGameSprite):void {
        justRender(target);
        justRenderAnimate(target);
        GameCtrl.I.pause();
        _gameStage.addChildAt(_blackBack, 0);
        _blackBack.fadIn();
        _gameStage.getMap().setVisible(false);
        SoundCtrl.I.playSwcSound(snd_ghost_jump);
    }

    /**
     * 鬼步结束。
     *
     * @param target 发动方。
     * @example
     * <listing version="3.0">
     * handler.endGhostStep(fighter);
     * </listing>
     */
    public function endGhostStep(target:BaseGameSprite):void {
        var cancel1:Boolean = cancelJustRender(target);
        var cancel2:Boolean = cancelJustRenderAnimate(target);
        if (cancel1 && cancel2) {
            GameCtrl.I.resume();
            _blackBack.fadOut();
            _gameStage.getMap().setVisible(true);
        }
    }

    /**
     * 逻辑帧：地图压暗、替身 / 灵压倒计时、只渲染目标。
     *
     * @example
     * <listing version="3.0">
     * handler.render();
     * </listing>
     */
    public function render():void {
        if (_renderBlackBack) {
            renderBlackBack();
        }

        if (_replaceSkillFrameHold > 0) {
            renderReplaceSkill();
        }
        if (_explodeSkillFrame > 0) {
            renderEnergyExplode();
        }

        if (_justRenderTargets && _justRenderTargets.length > 0) {
            for each(var g:BaseGameSprite in _justRenderTargets) {
                g.render();
                GameLogic.fixGameSpritePosition(g);
            }
        }
    }

    /**
     * 动画帧：黑屏视图与只渲染动画目标。
     *
     * @example
     * <listing version="3.0">
     * handler.renderAnimate();
     * </listing>
     */
    public function renderAnimate():void {
        if (_justRenderAnimateTargets && _justRenderAnimateTargets.length > 0) {
            for each(var g:BaseGameSprite in _justRenderAnimateTargets) {
                g.renderAnimate();
            }
        }

        if (_blackBack) {
            _blackBack.renderAnimate();
        }
    }

    /** @private */
    private function justRender(target:BaseGameSprite):void {
        if (_justRenderTargets.indexOf(target) == -1) {
            _justRenderTargets.push(target);
        }
    }

    /** @private */
    private function justRenderAnimate(animateTarget:BaseGameSprite):void {
        if (_justRenderAnimateTargets.indexOf(animateTarget) == -1) {
            _justRenderAnimateTargets.push(animateTarget);
        }
    }

    /** @private */
    private function cancelJustRender(target:BaseGameSprite):Boolean {
        var index:int = _justRenderTargets.indexOf(target);
        if (index != -1) {
            _justRenderTargets.splice(index, 1);
        }
        return _justRenderTargets.length < 1;
    }

    /** @private */
    private function cancelJustRenderAnimate(target:BaseGameSprite):Boolean {
        var index:int = _justRenderAnimateTargets.indexOf(target);
        if (index != -1) {
            _justRenderAnimateTargets.splice(index, 1);
        }
        return _justRenderAnimateTargets.length < 1;
    }

    /** @private */
    private function showFace(target:FighterMain, face:DisplayObject):void {
        var faceId:int            = TeamID.TEAM_1;
        var curTarget:IGameSprite = target.getCurrentTarget();
        if (curTarget) {
            var display:DisplayObject = curTarget.getDisplay();
            if (display) {
                faceId = target.getDisplay().x > display.x ?
                         TeamID.TEAM_2 :
                         TeamID.TEAM_1;
            }
        }

        _blackBack.showBishaFace(faceId, face);
    }

    /** @private */
    private function renderBlackBack():void {
        var mapLayer:MapMain = _gameStage.getMap();
        if (!mapLayer) {
            return;
        }

        var bishaIng:Boolean
                = (P1 && FighterActionState.isBishaIng(P1.actionState))
                || (P2 && FighterActionState.isBishaIng(P2.actionState));

        if (bishaIng) {
            if (_blackBackMul != BLACK_BACK_DARK) {
                applyBlackBackMul(mapLayer, BLACK_BACK_DARK);
            }

            return;
        }

        if (_blackBackMul + BLACK_BACK_RATE >= BLACK_BACK_NORMAL) {
            mapLayer.resetColorTransform();
            _renderBlackBack = false;
            _blackBackMul    = BLACK_BACK_NORMAL;

            return;
        }

        applyBlackBackMul(mapLayer, _blackBackMul + BLACK_BACK_RATE);
    }

    /** @private */
    private function applyBlackBackMul(mapLayer:MapMain, mul:Number):void {
        if (!_blackBackCt) {
            _blackBackCt = new ColorTransform();
        }

        _blackBackMul = mul;
        _blackBackCt.redMultiplier = _blackBackCt.greenMultiplier = _blackBackCt.blueMultiplier = mul;
        mapLayer.setColorTransform(_blackBackCt);
    }

    /** @private */
    private function endReplaceSkill():void {
        GameCtrl.I.resume();
        _blackBack.fadOut();
        _gameStage.getMap().setVisible(true);
        _replaceSkillFrameHold = 0;
    }

    /** @private */
    private function renderReplaceSkill():void {
        _replaceSkillFrame++;
        if (_replaceSkillFrame == 1) {
            _ctrl.doEffectById('replaceSp2', _replaceSkillPos.x, _replaceSkillPos.y);
        }

        if (_replaceSkillFrame > _replaceSkillFrameHold) {
            endReplaceSkill();
        }
    }

    /** @private */
    private function endEnergyExplode():void {
        _ctrl.doEffectById('explodeSp2', _explodeEffectPos.x, _explodeEffectPos.y);

        GameCtrl.I.resume();
        _blackBack.fadOut();
        _gameStage.getMap().setVisible(true);
        _explodeSkillFrame = 0;
    }

    /** @private */
    private function renderEnergyExplode():void {
        _explodeSkillFrame--;
        if (_explodeSkillFrame <= 0) {
            endEnergyExplode();
        }
    }
}
}
