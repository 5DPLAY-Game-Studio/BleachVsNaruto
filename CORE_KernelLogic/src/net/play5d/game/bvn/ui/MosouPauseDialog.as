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

package net.play5d.game.bvn.ui {
import flash.display.Sprite;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;
import net.play5d.game.bvn.events.GameEvent;
import net.play5d.game.bvn.events.SetBtnEvent;

public class MosouPauseDialog extends Sprite {
    include '../../../../../../include/_INCLUDE_.as';

    public function MosouPauseDialog() {
        _bg = new Sprite();
        _bg.graphics.beginFill(0, 0.5);
        _bg.graphics.drawRect(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);
        _bg.graphics.endFill();

        addChild(_bg);

        _btnGroup = new SetBtnGroup();
        _btnGroup.setBtnData([
                                 {label: 'BACK MAP', cn: '回大地图'},
                                 {label: 'MOVE LIST', cn: '出招表'},
                                 {label: 'CONTINUE', cn: '继续游戏'}
                             ], 2);
        _btnGroup.addEventListener(SetBtnEvent.SELECT, btnGroupSelectHandler);

        addChild(_btnGroup);
    }
    private var _bg:Sprite;
    private var _btnGroup:SetBtnGroup;
    private var _moveList:MoveListSp;

    public function destory():void {
        if (_btnGroup) {
            _btnGroup.removeEventListener(SetBtnEvent.SELECT, btnGroupSelectHandler);
            _btnGroup.destory();
            _btnGroup = null;
        }
        if (_moveList) {
            _moveList.destory();
            _moveList = null;
        }
    }

    public function isShowing():Boolean {
        return visible;
    }

    public function show():void {
        this.visible        = true;
        _btnGroup.keyEnable = true;
        _btnGroup.setArrowIndex(2);
    }

    public function hide():Boolean {
        if (_moveList && _moveList.isShowing()) {
            hideMoveList();
            return false;
        }

        this.visible        = false;
        _btnGroup.keyEnable = false;
        GameUI.closeConfrim();

        return true;
    }

    private function showMoveList():void {
        if (!_moveList) {
            _moveList              = new MoveListSp();
            _moveList.onBackSelect = hideMoveList;
            addChild(_moveList);
        }

        _btnGroup.keyEnable = false;
        _moveList.show();
    }

    private function hideMoveList():void {
        _moveList.hide();
        _btnGroup.keyEnable = true;

        GameEvent.dispatchEvent(GameEvent.PAUSE_GAME_MENU, "movelist-back");
    }

    private function btnGroupSelectHandler(e:SetBtnEvent):void {
        if (GameUI.showingDialog()) {
            return;
        }
        switch (e.selectedLabel) {
        case 'BACK MAP':
            _btnGroup.keyEnable = false;
            GameUI.confrim('BACK MAP?', '返回到大地图？', function ():void {
                MainGame.I.goWorldMap();
                GameEvent.dispatchEvent(GameEvent.MOSOU_BACK_MAP);
            }, function ():void {
                _btnGroup.keyEnable = true;
            }, true);
            break;
        case 'MOVE LIST':
            showMoveList();
            GameEvent.dispatchEvent(GameEvent.PAUSE_GAME_MENU, 'movelist');
            break;
        case 'CONTINUE':
            GameCtrl.I.resume(true);
            break;
        }
    }

}
}
