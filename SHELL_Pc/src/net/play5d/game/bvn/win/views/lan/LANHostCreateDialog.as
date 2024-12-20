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
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.win.ctrls.LANGameCtrl;
import net.play5d.game.bvn.win.ctrls.LANServerCtrl;
import net.play5d.game.bvn.win.data.HostVO;
import net.play5d.game.bvn.win.data.LanGameModel;
import net.play5d.game.bvn.win.utils.UIAssetUtil;
import net.play5d.kyo.stage.IStage;
import net.play5d.kyo.utils.KyoBtnUtils;

//import net.play5d.game.bvn.win.ctrls.UDPHostCtrl;
public class LANHostCreateDialog implements IStage {
    public function LANHostCreateDialog() {
    }
    public var onCreate:Function;
    public var onClose:Function;
    private var _ui:MovieClip;

    /**
     * 显示对象
     */
    public function get display():DisplayObject {
        return _ui;
    }

    public function close():void {
        if (onClose != null) {
            onClose();
        }
        MainGame.stageCtrl.removeLayer(this);
    }

    /**
     * 构建
     */
    public function build():void {
        _ui = UIAssetUtil.I.createDisplayObject('build_win_mc');
        _ui.check_pass.addEventListener(Event.CHANGE, checkHandler);

        KyoBtnUtils.initBtn(_ui.btn_ok, btnHandler);
        KyoBtnUtils.initBtn(_ui.btn_close, close);

        _ui.txt_pass.visible = false;

        _ui.comb_mode.addItem({label: 'TEAM VS - 小队模式', data: 1});
//			_ui.comb_mode.addItem( { label: "SINGLE VS - 单人模式", data:2 } );
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
        _ui.btn_ok.removeEventListener(MouseEvent.CLICK, btnHandler);
        _ui.check_pass.removeEventListener(Event.CHANGE, checkHandler);

        KyoBtnUtils.disposeBtn(_ui.btn_ok);
        KyoBtnUtils.disposeBtn(_ui.btn_close);

    }

    private function btnHandler():void {

        SoundCtrl.I.sndConfrim();

        var name:String = _ui.txt_hostname.text;
        var pass:String = '';
        var mode:int    = _ui.comb_mode.selectedItem.data;

        if (name == '') {
            GameUI.alert('ERROR', '请输入主机名称');
            return;
        }

        if (_ui.check_pass.selected) {
            pass = _ui.txt_pass.text;
        }

        var hv:HostVO = new HostVO();
        hv.name       = name;
        hv.gameMode   = mode;
        hv.password   = pass;
        hv.ownerName  = LanGameModel.I.playerName;
        hv.tcpPort    = LANGameCtrl.PORT_TCP;
        hv.udpPort    = LANGameCtrl.PORT_UDP_SERVER;

        LANServerCtrl.I.startServer(hv);

        if (onCreate != null) {
            onCreate();
        }

        close();
    }

    private function checkHandler(e:Event):void {
        _ui.txt_pass.visible = _ui.check_pass.selected;
    }
}
}
