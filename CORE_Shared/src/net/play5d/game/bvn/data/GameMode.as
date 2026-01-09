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

    /*----------------------------- 静态公有属性 -----------------------------*/

    // 小队闯关模式
    public static const TEAM_ARCADE:int    = 10;
    // 小队双人对战
    public static const TEAM_VS_PEOPLE:int = 11;
    // 小队对战电脑
    public static const TEAM_VS_CPU:int    = 12;
    // 小队观战模式
    public static const TEAM_WATCH:int     = 13;

    // 单人闯关模式
    public static const SINGLE_ARCADE:int    = 20;
    // 单人双人对战
    public static const SINGLE_VS_PEOPLE:int = 21;
    // 单人对战电脑
    public static const SINGLE_VS_CPU:int    = 22;
    // 单人观战模式
    public static const SINGLE_WATCH:int     = 23;

    // 挑战模式（未启用）
    public static const SURVIVOR:int = 30;

    // 练习模式
    public static const TRAINING:int = 40;

    // 无双冒险
    public static const MUSOU_ARCADE:int = 100;

    /*----------------------------- 动态公有属性 -----------------------------*/

    // 当前模式
    public static var currentMode:int;

    /*----------------------------- 静态私有属性 -----------------------------*/

    // 所有小队模式（小队闯关模式，小队对战电脑，小队双人对战，小队观战模式，无双冒险）
    private static const _isTeamModes:Vector.<int> = (function ():Vector.<int> {
        var modes:Vector.<int> = new Vector.<int>();
        modes.push(
                TEAM_ARCADE,
                TEAM_VS_CPU,
                TEAM_VS_PEOPLE,
                TEAM_WATCH,
                MUSOU_ARCADE
        );

        return modes;
    })();

    // 所有单人模式（单人闯关模式，单人对战电脑，单人双人对战，单人观战模式）
    private static const _isSingleModes:Vector.<int> = (function ():Vector.<int> {
        var modes:Vector.<int> = new Vector.<int>();
        modes.push(
                SINGLE_ARCADE,
                SINGLE_VS_CPU,
                SINGLE_VS_PEOPLE,
                SINGLE_WATCH
        );

        return modes;
    })();

    // 所有双人对战（小队双人对战，单人双人对战）
    private static const _isVsPeopleModes:Vector.<int> = (function ():Vector.<int> {
        var modes:Vector.<int> = new Vector.<int>();
        modes.push(
                TEAM_VS_PEOPLE,
                SINGLE_VS_PEOPLE
        );

        return modes;
    })();

    // 所有对战电脑（小队对战电脑，小队观战模式，单人对战电脑，单人观战模式）
    private static const _isVsCPUModes:Vector.<int> = (function ():Vector.<int> {
        var modes:Vector.<int> = new Vector.<int>();
        modes.push(
                TEAM_VS_CPU,
                TEAM_WATCH,
                SINGLE_VS_CPU,
                SINGLE_WATCH
        );

        return modes;
    })();

    // 所有观战模式（小队观战模式，单人观战模式）
    private static const _isWatchModes:Vector.<int> = (function ():Vector.<int> {
        var modes:Vector.<int> = new Vector.<int>();
        modes.push(
                TEAM_WATCH,
                SINGLE_WATCH
        );

        return modes;
    })();

    // 所有闯关模式（小队闯关模式，单人闯关模式，挑战模式）
    private static const _isArcadeModes:Vector.<int> = (function ():Vector.<int> {
        var modes:Vector.<int> = new Vector.<int>();
        modes.push(
                TEAM_ARCADE,
                SINGLE_ARCADE,
                SURVIVOR
        );

        return modes;
    })();


    /*----------------------------- 静态公有方法 -----------------------------*/

    /**
     * 获得全部队伍信息
     * @return 全部队伍信息
     */
    public static function getAllTeams():Array {
        return [
            {
                id  : TeamID.TEAM_1,
                name: 'P1'
            }, {
                id  : TeamID.TEAM_2,
                name: 'P2'
            }
        ];
    }

    /*----------------------------- -----------------------------*/

    /**
     * 判断当前模式是否为小队模式（小队闯关模式，小队对战电脑，小队双人对战，小队观战模式，无双冒险）
     * @return 当前模式是否为小队模式
     */
    public static function isTeamMode():Boolean {
        return _isTeamModes.indexOf(currentMode) != -1;
    }

    /**
     * 判断当前模式是否为单人模式（单人闯关模式，单人对战电脑，单人双人对战，单人观战模式）
     * @return 当前模式是否为单人模式
     */
    public static function isSingleMode():Boolean {
        return _isSingleModes.indexOf(currentMode) != -1;
    }

    /**
     * 判断当前模式是否为双人对战（小队双人对战，单人双人对战）
     * @return 当前模式是否为双人对战
     */
    public static function isVsPeople():Boolean {
        return _isVsPeopleModes.indexOf(currentMode) != -1;
    }

    /**
     * 判断当前模式是否为对战电脑（小队对战电脑，小队观战模式，单人对战电脑，单人观战模式[，练习模式]）
     * @param hasTraining 是否包含【练习模式】？
     * @return 当前模式是否为双人对战
     */
    public static function isVsCPU(hasTraining:Boolean = true):Boolean {
        return (currentMode == TRAINING && hasTraining) ||
               _isVsCPUModes.indexOf(currentMode) != -1;
    }

    /**
     * 判断当前模式是否为观战模式（小队观战模式，单人观战模式）
     * @return 当前模式是否为观战模式
     */
    public static function isWatch():Boolean {
        return _isWatchModes.indexOf(currentMode) != -1;
    }

    /**
     * 判断当前模式是否为闯关模式（小队观战模式，单人观战模式，挑战模式）
     * @return 当前模式是否为闯关模式
     */
    public static function isArcade():Boolean {
        return _isArcadeModes.indexOf(currentMode) != -1;
    }

    /*----------------------------- 静态私有方法 -----------------------------*/

}
}
