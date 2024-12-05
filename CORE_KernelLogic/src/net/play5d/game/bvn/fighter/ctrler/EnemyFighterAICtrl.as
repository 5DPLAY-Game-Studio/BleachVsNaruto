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

package net.play5d.game.bvn.fighter.ctrler {

import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.cntlr.game_ctrls.GameCtrl;
import net.play5d.game.bvn.fighter.data.FighterActionState;
import net.play5d.game.bvn.fighter.data.FighterHitRange;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 小兵AI逻辑
 */
public class EnemyFighterAICtrl implements IFighterActionCtrl {
    include '../../../../../../../include/_INCLUDE_.as';

    public function EnemyFighterAICtrl() {
    }
    public var fighter:FighterMain;
//		private var _targetFighter:FighterMain;
    private var _target:IGameSprite;
    private var _followFrame:int   = 0;
    private var _following:Boolean = false;
    private var _followDis:int     = 0;
    private var _moveLeft:Boolean  = false;
    private var _moveRight:Boolean = false;
    private var _jump:Boolean      = false;
    private var _jumpDown:Boolean  = false;
    private var _attackFrame:int = 0;
    private var _attack:Boolean = false;
    private var _zhao:Boolean;

    public function initlize():void {
    }

    public function destory():void {
        fighter = null;
        _target = null;
    }

    public function enabled():Boolean {
        return GameCtrl.I.actionEnable;
    }

    public function render():void {

    }

    public function renderAnimate():void {
        if (!fighter) {
            return;
        }

        _target = fighter.getCurrentTarget();

        if (!_target) {
            _following = false;
            _attack    = false;
            _zhao      = false;
            return;
        }

        renderFollow();
        renderMove();
        renderAttack();
    }

    public function moveLEFT():Boolean {
        return _moveLeft;
    }

    public function moveRIGHT():Boolean {
        return _moveRight;
    }

    public function defense():Boolean {
        return false;
    }

    public function attack():Boolean {
        return _attack && targetInRange(FighterHitRange.ATTACK);
    }

    public function jump():Boolean {
        return _jump;
    }

    public function jumpQuick():Boolean {
        return false;
    }

    public function jumpDown():Boolean {
        return _jumpDown;
    }

    public function dash():Boolean {
        return false;
    }

    public function dashJump():Boolean {
        return false;
    }

    public function skill1():Boolean {
        return _zhao && targetInRange(FighterHitRange.SKILL1);
    }

    public function skill2():Boolean {
        return _zhao && targetInRange(FighterHitRange.SKILL2);
    }

    public function zhao1():Boolean {
        return _zhao && targetInRange(FighterHitRange.ZHAO1);
    }

    public function zhao2():Boolean {
        return _zhao && targetInRange(FighterHitRange.ZHAO2);
    }

    public function zhao3():Boolean {
        return _zhao && targetInRange(FighterHitRange.ZHAO3);
    }

    public function catch1():Boolean {
        return false;
    }

    public function catch2():Boolean {
        return false;
    }

    public function bisha():Boolean {
        return false;
    }

    public function bishaUP():Boolean {
        return false;
    }

    public function bishaSUPER():Boolean {
        return false;
    }

    public function assist():Boolean {
        return false;
    }

    public function specailSkill():Boolean {
        return false;
    }

    public function attackAIR():Boolean {
        return _attack && targetInRange(FighterHitRange.JUMP_ATTACK);
    }

    public function skillAIR():Boolean {
        return _zhao && targetInRange(FighterHitRange.JUMP_SKILL);
    }

    public function bishaAIR():Boolean {
        return false;
    }

    public function waiKai():Boolean {
        return false;
    }

    public function waiKaiW():Boolean {
        return false;
    }

    public function waiKaiS():Boolean {
        return false;
    }

    public function ghostStep():Boolean {
        return false;
    }

    public function ghostJump():Boolean {
        return false;
    }

    public function ghostJumpDown():Boolean {
        return false;
    }

    /**
     * 跟随
     */
    private function renderFollow():void {
        if (_followFrame-- > 0) {
            return;
        }

        _followFrame = GameConfig.FPS_ANIMATE * 2;

        _following = Math.random() < 0.5;

        if (_following) {
            _followDis = Math.random() > 0.6 ? (
                    10 + Math.random() * 20
            ) : (
                                 50 + Math.random() * 100
                         );
        }
    }

    private function renderMove():void {
        if (!_following) {
            return;
        }

        var aimX:Number = fighter.x > _target.x ? _target.x + _followDis : _target.x - _followDis;

        _moveLeft = _moveRight = false;

        if (fighter.x < aimX - 20) {
            _moveRight = true;
        }
        if (fighter.x > aimX + 20) {
            _moveLeft = true;
        }

        if (Math.abs(fighter.y - _target.y) < 30) {
            _jump     = false;
            _jumpDown = false;
        }
        else {
            _jump     = fighter.y > _target.y;
            _jumpDown = fighter.y < _target.y;
        }

        if (!_moveLeft && !_moveRight && !_jump && !_jumpDown) {
            _following = false;
        }

    }

    private function renderAttack():void {
        if (FighterActionState.isAttacking(fighter.actionState)) {
            _attack = Math.random() < 0.05;
            _zhao   = false;
            return;
        }

        if (_attackFrame++ < GameConfig.FPS_ANIMATE * 3) {
            return;
        }
        _attackFrame = 0;

        _attack = Math.random() < 0.2;
        _zhao   = Math.random() < 0.1;
    }

    private function targetInRange(id:String):Boolean {
        var area:Rectangle = _target.getBodyArea();
        if (!area) {
            return false;
        }
        var hr:Rectangle = fighter.getHitRange(id);
        if (!hr) {
            return false;
        }
        return !area.intersection(hr).isEmpty();
    }
}
}
