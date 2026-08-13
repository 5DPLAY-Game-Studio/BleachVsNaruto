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
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.utils.ByteArray;

import net.play5d.game.bvn.input.IGameInput;

/**
 * 壳层游戏能力注入契约。
 *
 * <p>由各入口实现并赋给 <code>GameInterface.instance</code>，内核通过该接口访问存档、
 * 输入、菜单、排行榜与平台扩展，而不依赖具体壳实现。</p>
 *
 * <p><code>applyConfig</code> 参数为 <code>Object</code>（运行时为配置 VO），以免 Shared
 * 反向依赖内核配置类型。</p>
 *
 * @see IExtendConfig
 * @see IGameInput
 * @example
 * <listing version="3.0">
 * // GameInterface.instance = new MyGameInterfaceManager();
 * var inputs:Vector.&lt;IGameInput&gt; = GameInterface.instance.getGameInput('P1');
 * </listing>
 */
public interface IGameInterface {
    /**
     * 初始化标题界面上的壳层附加 UI。
     * @param ui 标题界面显示对象。
     * @example
     * <listing version="3.0">
     * instance.initTitleUI(titleMc);
     * </listing>
     */
    function initTitleUI(ui:DisplayObject):void;

    /**
     * 打开更多游戏。
     * @example
     * <listing version="3.0">
     * instance.moreGames();
     * </listing>
     */
    function moreGames():void;

    /**
     * 打开排行榜。
     * @example
     * <listing version="3.0">
     * instance.showRank();
     * </listing>
     */
    function showRank():void;

    /**
     * 上传分数。
     * @param score 分数。
     * @example
     * <listing version="3.0">
     * instance.submitScore(12000);
     * </listing>
     */
    function submitScore(score:int):void;

    /**
     * 保存游戏数据。
     * @param data 存档对象。
     * @example
     * <listing version="3.0">
     * instance.saveGame(saveObj);
     * </listing>
     */
    function saveGame(data:Object):void;

    /**
     * 读取游戏数据。
     * @return 存档对象；无存档时可为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var data:Object = instance.loadGame();
     * </listing>
     */
    function loadGame():Object;

    /**
     * 按类型取得输入设备列表。
     * @param type 输入类型（如菜单 / P1 / P2）。
     * @return 输入实现向量。
     * @example
     * <listing version="3.0">
     * var list:Vector.&lt;IGameInput&gt; = instance.getGameInput('MENU');
     * </listing>
     */
    function getGameInput(type:String):Vector.<IGameInput>;

    /**
     * 游戏主菜单配置。
     * @return 菜单项数组；返回 <code>null</code> 时使用默认菜单。
     * @example
     * <listing version="3.0">
     * var menu:Array = instance.getGameMenu();
     * </listing>
     */
    function getGameMenu():Array;

    /**
     * 设置菜单配置。
     * @return 设置项数组。
     * @example
     * <listing version="3.0">
     * var menu:Array = instance.getSettingMenu();
     * </listing>
     */
    function getSettingMenu():Array;

    /**
     * 按壳逻辑刷新输入配置。
     * @return 已由壳处理时为 <code>true</code>；需内核默认处理时为 <code>false</code>。
     * @example
     * <listing version="3.0">
     * if (!instance.updateInputConfig()) {
     *     // 使用默认键位绑定
     * }
     * </listing>
     */
    function updateInputConfig():Boolean;

    /**
     * 扩展设置。
     * @return 扩展配置实现。
     * @example
     * <listing version="3.0">
     * var ext:IExtendConfig = instance.getConfigExtend();
     * </listing>
     */
    function getConfigExtend():IExtendConfig;

    /**
     * 对局场景构建完成后的壳层回调。
     * @example
     * <listing version="3.0">
     * instance.afterBuildGame();
     * </listing>
     */
    function afterBuildGame():void;

    /**
     * 应用运行配置（画质、音量等）。
     * @param config 配置对象（通常为内核配置 VO）。
     * @example
     * <listing version="3.0">
     * instance.applyConfig(configVo);
     * </listing>
     */
    function applyConfig(config:Object):void;

    /**
     * 制作人员界面。
     * @param creditsInfo 基础致谢 HTML/文本。
     * @return 展示用精灵。
     * @example
     * <listing version="3.0">
     * var sp:Sprite = instance.getCreadits(info);
     * </listing>
     */
    function getCreadits(creditsInfo:String):Sprite;

    /**
     * 校验资源文件。
     * @param url 资源路径。
     * @param file 文件字节。
     * @return 通过为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (!instance.checkFile(url, bytes)) {
     *     // 拒绝加载
     * }
     * </listing>
     */
    function checkFile(url:String, file:ByteArray):Boolean;

    /**
     * 增加无双金币。
     * @param back 回调，签名为 <code>function(money:*):void</code>。
     * @example
     * <listing version="3.0">
     * instance.addMusouMoney(function (money:*):void {
     *     // ...
     * });
     * </listing>
     */
    function addMusouMoney(back:Function):void;
}
}
