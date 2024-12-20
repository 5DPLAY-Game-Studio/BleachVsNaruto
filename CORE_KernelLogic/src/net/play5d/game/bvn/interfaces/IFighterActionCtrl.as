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

package net.play5d.game.bvn.interfaces {
public interface IFighterActionCtrl {
    function initlize():void;

    function render():void;

    function renderAnimate():void;

    function destory():void;

    function enabled():Boolean;

//		function setEnabled(v:Boolean):void;

    function moveLEFT():Boolean;

    function moveRIGHT():Boolean;

    function defense():Boolean;

    function attack():Boolean;

    function jump():Boolean;

    function jumpQuick():Boolean;

    function jumpDown():Boolean; //从空中的板下来
    function dash():Boolean;

    function dashJump():Boolean; //倒地起身

    function skill1():Boolean;

    function skill2():Boolean;

    function zhao1():Boolean;

    function zhao2():Boolean;

    function zhao3():Boolean;

    function catch1():Boolean;

    function catch2():Boolean;

    function bisha():Boolean;

    function bishaUP():Boolean;

    function bishaSUPER():Boolean;

    function assist():Boolean;

    function specailSkill():Boolean;

    function attackAIR():Boolean;

    function skillAIR():Boolean;

    function bishaAIR():Boolean;

    function waiKai():Boolean;

    function waiKaiW():Boolean;

    function waiKaiS():Boolean;

    function ghostStep():Boolean;

    function ghostJump():Boolean;

    function ghostJumpDown():Boolean;
}
}
