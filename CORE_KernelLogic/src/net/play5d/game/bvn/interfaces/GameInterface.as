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
     * 当前壳实现。未注入时是 null，<code>checkFile</code> 和 <code>addMoney</code> 走默认逻辑。
     *
     * @default null
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
                txt: 'TEAM PLAY', cn: GetLang('menu.team_play'), children: [
                    {txt: 'TEAM ARCADE', cn: GetLang('menu.team_arcade')},
                    {txt: 'TEAM VS PEOPLE', cn: GetLang('menu.team_vs_people')},
                    {txt: 'TEAM VS CPU', cn: GetLang('menu.team_vs_cpu')},
                    {txt: 'TEAM WATCH', cn: GetLang('menu.team_watch')}
                ]
            },

            {
                txt: 'SINGLE PLAY', cn: GetLang('menu.single_play'), children: [
                    {txt: 'SINGLE ARCADE', cn: GetLang('menu.single_arcade')},
                    {txt: 'SINGLE VS PEOPLE', cn: GetLang('menu.single_vs_people')},
                    {txt: 'SINGLE VS CPU', cn: GetLang('menu.single_vs_cpu')},
                    {txt: 'SINGLE WATCH', cn: GetLang('menu.single_watch')}
                ]
            },

            {
                txt: 'MUSOU PLAY', cn: GetLang('menu.musou_play'), children: [
                    {txt: 'MUSOU ARCADE', cn: GetLang('menu.musou_arcade')}
                ]
            },

            {txt: 'OPTION', cn: GetLang('menu.option')},
            {txt: 'TRAINING', cn: GetLang('menu.training')},
            {txt: 'CREDITS', cn: GetLang('menu.credits')},
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
     * 增加无双金币。金额先转成 int，小于 1 或大于 5000 时不调用原来的回调。
     *
     * <p>没有壳实例时，用 100 以上、不足 600 的随机数再走同一套限制。</p>
     *
     * @param back 成功回调，签名为 <code>function(money:int):void</code>。金额被丢掉时不会调用。null 且金额通过时会抛错。
     * @throws TypeError 金额通过但 <code>back</code> 为 null 时。
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
