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
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.utils.ByteArray;

import net.play5d.game.bvn.data.vos.ConfigVO;
import net.play5d.game.bvn.input.IGameInput;

public interface IGameInterface {
    function initTitleUI(ui:DisplayObject):void;

    /**
     * 更多游戏
     */
    function moreGames():void;

    /**
     * 打开排行榜
     */
    function showRank():void;

    /**
     * 上传分数
     * @param score
     */
    function submitScore(score:int):void;

    /**
     * 保存
     * @param data
     */
    function saveGame(data:Object):void;

    /**
     * 读取
     * @return
     */
    function loadGame():Object;

    /**
     * 游戏输入接口
     * @param type 输入类型，对应类：net.play5d.game.bvn.input.GameInputType
     * @return
     */
    function getGameInput(type:String):Vector.<IGameInput>;

//		/**
//		 * 操作接口
//		 * @param player
//		 * @return
//		 */
//		function getFighterCtrl(player:int):IFighterActionCtrl;

    /**
     * 游戏菜单
     * @return [{txt:英文名,cn:中文名称,(func:回调函数),children:[{txt:英文名,cn:中文名称,func:回调函数}]}] , 返回NULL时使用默认菜单
     */
    function getGameMenu():Array;

    /**
     * 设置菜单
     * @return [{txt:"英文名",cn:"中文名",options:[{label:'英文选项名',cn:'中文选项名',value:值}],optoinKey:'对应configVO的属性名（可自定义，但不能和之前定义的属性名称重复！）'}]
     */
    function getSettingMenu():Array;


    /**
     * 更新输入设置 ，如果使用默认，返回FALSE
     */
    function updateInputConfig():Boolean;

    /**
     * 扩展设置项
     * @return {key: value}
     */
    function getConfigExtend():IExtendConfig;

    function afterBuildGame():void;

    function applyConfig(config:ConfigVO):void;

    /**
     * 制作群界面
     */
    function getCreadits(creditsInfo:String):Sprite;

    /**
     * 校验文件
     */
    function checkFile(url:String, file:ByteArray):Boolean;

    /**
     * 增加无双金币
     *
     * @param back 回调函数
     */
    function addMusouMoney(back:Function):void;

}
}
