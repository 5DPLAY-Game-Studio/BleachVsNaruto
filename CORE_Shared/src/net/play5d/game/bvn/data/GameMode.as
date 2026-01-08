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

package net.play5d.game.bvn.data {
/**
 * 游戏模式
 */
public class GameMode {
    include '../../../../../../include/ImportVersion.as';

    public static const TEAM_ACRADE:int    = 10;
    public static const TEAM_VS_PEOPLE:int = 11;
    public static const TEAM_VS_CPU:int    = 12;
    public static const TEAM_WATCH:int     = 13;

    public static const SINGLE_ACRADE:int    = 20;
    public static const SINGLE_VS_PEOPLE:int = 21;
    public static const SINGLE_VS_CPU:int    = 22;
    public static const SINGLE_WATCH:int     = 23;

    public static const SURVIVOR:int = 30;

    public static const TRAINING:int = 40;

    public static const MOSOU_ACRADE:int = 100;

    public static var currentMode:int;

    public static function getTeams():Array {
        return [
            {id: TeamID.TEAM_1, name: 'P1'},
            {id: TeamID.TEAM_2, name: 'P2'}
        ];
    }

    /**
     * 组队模式
     */
    public static function isTeamMode():Boolean {
        return currentMode == TEAM_ACRADE ||
               currentMode == TEAM_VS_CPU ||
               currentMode == TEAM_VS_PEOPLE ||
               currentMode == MOSOU_ACRADE ||
               currentMode == TEAM_WATCH;
    }

    /**
     * 一人模式（经典）
     */
    public static function isSingleMode():Boolean {
        return currentMode == SINGLE_ACRADE ||
               currentMode == SINGLE_VS_CPU ||
               currentMode == SINGLE_VS_PEOPLE ||
               currentMode == SINGLE_WATCH;
    }

    public static function isVsPeople():Boolean {
        return currentMode == TEAM_VS_PEOPLE || currentMode == SINGLE_VS_PEOPLE;
    }

    public static function isVsCPU(includeTraining:Boolean = true):Boolean {
        return currentMode == TEAM_VS_CPU ||
               currentMode == SINGLE_VS_CPU ||
               (includeTraining && currentMode == TRAINING) ||
               currentMode == TEAM_WATCH ||
               currentMode == SINGLE_WATCH;
    }

    public static function isWatch():Boolean {
        return currentMode == TEAM_WATCH || currentMode == SINGLE_WATCH;
    }

    /**
     * 过关模式（包括SURVIVOR）
     */
    public static function isAcrade():Boolean {
        return currentMode == SINGLE_ACRADE || currentMode == TEAM_ACRADE || currentMode == SURVIVOR;
    }

}
}
