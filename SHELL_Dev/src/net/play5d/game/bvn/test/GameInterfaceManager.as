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

package net.play5d.game.bvn.test {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.utils.ByteArray;

import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.input.GameKeyInput;
import net.play5d.game.bvn.interfaces.IGameInput;
import net.play5d.game.bvn.interfaces.IExtendConfig;
import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
import net.play5d.game.bvn.interfaces.IGameInterface;
import net.play5d.game.bvn.map.MapLayerCacheUtil;
import net.play5d.game.bvn.utils.CreditsSpriteUtil;
import net.play5d.kyo.utils.WebUtils;

public class GameInterfaceManager implements IGameInterface {

    public function initTitleUI(ui:DisplayObject):void {
    }

    public function moreGames():void {
        WebUtils.getURL('http://www.1212321.com');
    }

    public function submitScore(score:int):void {
    }

    public function showRank():void {
    }

    public function saveGame(data:Object):void {
    }

    public function loadGame():Object {
        return null;
    }

    public function getFighterCtrl(player:int):IFighterActionCtrl {
        return null;
    }

    public function getGameMenu():Array {
        return null;
    }

    public function getSettingMenu():Array {
        return null;
    }

    public function getGameInput(type:String):Vector.<IGameInput> {
        var vec:Vector.<IGameInput> = new Vector.<IGameInput>();
        vec.push(new GameKeyInput());

        return vec;
    }

    public function getConfigExtend():IExtendConfig {
        return null;
    }

    public function afterBuildGame():void {
        MapLayerCacheUtil.enableBitmapCache(GameCtrl.I.gameState.getMap());
    }

    /**
     * 更新输入设置
     */
    public function updateInputConfig():Boolean {
        return false;
    }

    public function applyConfig(config:Object):void {
    }

    public function getCredits(creditsInfo:String):Sprite {
        return CreditsSpriteUtil.build(creditsInfo, 'dev.txt.game_interface_manager.commit');
    }

    public function checkFile(url:String, file:ByteArray):Boolean {
        return true;
    }

    public function addMusouMoney(back:Function):void {
        back(100 + Math.random() * 200);
    }
}
}
