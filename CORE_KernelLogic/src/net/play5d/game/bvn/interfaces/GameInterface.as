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

package net.play5d.game.bvn.interfaces {
import flash.utils.ByteArray;

/**
 * 壳层 <code>IGameInterface</code> 的静态入口与默认菜单。
 *
 * <p>入口启动时设置 <code>instance</code>；未注入时部分方法提供安全默认行为。</p>
 *
 * @see IGameInterface
 * @example
 * <listing version="3.0">
 * GameInterface.instance = new MyGameInterfaceManager();
 * var menu:Array = GameInterface.getDefaultMenu();
 * </listing>
 */
public class GameInterface {
    /**
     * 当前壳实现；未注入时部分静态方法走默认逻辑。
     */
    public static var instance:IGameInterface;

    /**
     * 默认主菜单结构（多语言文案）。
     * @return 菜单项数组。
     * @example
     * <listing version="3.0">
     * var a:Array = GameInterface.getDefaultMenu();
     * </listing>
     */
    public static function getDefaultMenu():Array {
        var a:Array = [

            {
                txt: 'TEAM PLAY', cn: GetLang('txt.game_interface.team_play'), children: [
                    {txt: 'TEAM ACRADE', cn: GetLang('txt.game_interface.team_play_acrade')},
                    {txt: 'TEAM VS PEOPLE', cn: GetLang('txt.game_interface.team_play_vs_people')},
                    {txt: 'TEAM VS CPU', cn: GetLang('txt.game_interface.team_play_vs_CPU')},
                    {txt: 'TEAM WATCH', cn: GetLang('txt.game_interface.team_play_watch')}
                ]
            },

            {
                txt: 'SINGLE PLAY', cn: GetLang('txt.game_interface.single_play'), children: [
                    {txt: 'SINGLE ACRADE', cn: GetLang('txt.game_interface.single_play_acrade')},
                    {txt: 'SINGLE VS PEOPLE', cn: GetLang('txt.game_interface.single_play_vs_people')},
                    {txt: 'SINGLE VS CPU', cn: GetLang('txt.game_interface.single_play_vs_CPU')},
                    {txt: 'SINGLE WATCH', cn: GetLang('txt.game_interface.single_play_watch')}
                ]
            },

            {
                txt: 'MUSOU PLAY', cn: GetLang('txt.game_interface.musou_play'), children: [
                    {txt: 'MUSOU ACRADE', cn: GetLang('txt.game_interface.musou_acrade')}
                ]
            },

            {txt: 'OPTION', cn: GetLang('txt.game_interface.option')},
            {txt: 'TRAINING', cn: GetLang('txt.game_interface.training')},
            {txt: 'CREDITS', cn: GetLang('txt.game_interface.credits')},
//            {txt: 'MORE GAMES', cn: GetLang('txt.game_interface.more_games')}
        ];
        return a;
    }

    /**
     * 校验资源文件；无实例时默认通过。
     * @param url 资源路径。
     * @param file 文件字节。
     * @return 通过为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (!GameInterface.checkFile(url, bytes)) {
     *     return;
     * }
     * </listing>
     */
    public static function checkFile(url:String, file:ByteArray):Boolean {
        if (instance) {
            return instance.checkFile(url, file);
        }
        return true;
    }

    /**
     * 增加无双金币；无实例时回退随机小数额。
     * @param back 成功回调，签名为 <code>function(money:int):void</code>。
     * @example
     * <listing version="3.0">
     * GameInterface.addMoney(function (mm:int):void {
     *     // ...
     * });
     * </listing>
     */
    public static function addMoney(back:Function):void {
        function addMoneyBack(money:*):void {
            var mm:int = int(money);
            if (mm < 1) {
                return;
            }
            if (mm > 5000) {
                return;
            }
            back(mm);
        }

        if (instance) {
            instance.addMusouMoney(addMoneyBack);
            return;
        }
        addMoneyBack(100 + Math.random() * 500);
    }
}
}
