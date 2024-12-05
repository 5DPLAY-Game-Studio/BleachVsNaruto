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

package net.play5d.game.bvn.win.views.lan {
import flash.display.DisplayObject;
import flash.display.Sprite;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.cntlr.AssetManager;
import net.play5d.game.bvn.cntlr.SoundCtrl;
import net.play5d.game.bvn.events.SetBtnEvent;
import net.play5d.game.bvn.ui.SetBtnGroup;
import net.play5d.game.bvn.win.utils.UIAssetUtil;
import net.play5d.kyo.stage.IStage;

public class LANGameState implements IStage {
    public function LANGameState() {
        super();
    }
    private var _ui:Sprite;
    private var _btnGroup:SetBtnGroup;
    private var _hostList:HostListDialog;

    /**
     * 显示对象
     */
    public function get display():DisplayObject {
        return _ui;
    }

    /**
     * 构建
     */
    public function build():void {
        _ui = UIAssetUtil.I.createDisplayObject('spr_lan');

        _btnGroup = new SetBtnGroup();
        _btnGroup.setBtnData([
                                 {label: 'JOIN GAME', cn: '加入游戏'},
                                 {label: 'BUILD GAME', cn: '创建游戏'},
                                 {label: 'PROFILE', cn: '个人信息'},
                                 {label: 'EXIT', cn: '退出'}
                             ]);

        _btnGroup.addEventListener(SetBtnEvent.SELECT, btnHandler);

        _ui.addChild(_btnGroup);

        SoundCtrl.I.BGM(AssetManager.I.getSound('continue'));
//
//			_hostList.ui.x = 20;
//			_hostList.ui.y = 50;
//
//			_ui.addChild(_hostList.ui);
    }

    public function showHostList():void {
        _btnGroup.keyEnable = false;
        _hostList           = new HostListDialog();
        _hostList.onClose   = onDialogClose;
        MainGame.stageCtrl.addLayer(_hostList, 10, 10);
    }

    /**
     * 稍后构建
     */
    public function afterBuild():void {

    }

    /**
     * 销毁
     * @param back 回调函数
     */
    public function destroy(back:Function = null):void {
        if (_btnGroup) {
            _btnGroup.destory();
            _btnGroup = null;
        }
    }

    private function onDialogClose():void {
        if (_btnGroup) {
            _btnGroup.keyEnable = true;
        }
    }

    private function onCreateHost():void {
        var room:LANRoomState = new LANRoomState();
        MainGame.stageCtrl.goStage(room);
        room.hostMode();
    }

    private function btnHandler(e:SetBtnEvent):void {
        switch (e.selectedLabel) {
        case 'JOIN GAME':
            showHostList();
            break;
        case 'BUILD GAME':
            _btnGroup.keyEnable            = false;
            var dialog:LANHostCreateDialog = new LANHostCreateDialog();
            dialog.onCreate                = onCreateHost;
            dialog.onClose                 = onDialogClose;
            MainGame.stageCtrl.addLayer(dialog, 0, 0);
            break;
        case 'PROFILE':
            _btnGroup.keyEnable       = false;
            var dialog2:ProfileDialog = new ProfileDialog();
            dialog2.onClose           = onDialogClose;
            MainGame.stageCtrl.addLayer(dialog2, 0, 0);
            break;
        case 'EXIT':
            MainGame.I.goMenu();
            break;
        }
    }


}
}
