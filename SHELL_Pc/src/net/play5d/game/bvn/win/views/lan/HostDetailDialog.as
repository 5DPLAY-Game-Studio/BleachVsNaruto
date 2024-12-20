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
import net.play5d.game.bvn.win.ctrls.LANClientCtrl;
import net.play5d.game.bvn.win.data.HostVO;
import net.play5d.game.bvn.win.utils.LANUtils;
import net.play5d.game.bvn.win.utils.UIAssetUtil;
import net.play5d.kyo.stage.IStage;

public class HostDetailDialog implements IStage {
    public function HostDetailDialog() {
    }
    private var _ui:MovieClip;
    private var _data:HostVO;

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
        _ui = UIAssetUtil.I.createDisplayObject('detail_win_mc');
        _ui.btn_join.addEventListener(MouseEvent.CLICK, joinHandler);
        _ui.btn_close.addEventListener(MouseEvent.CLICK, close);
    }

    public function setData(data:HostVO):void {
        _data             = data;
        _ui.txt_name.text = data.name;
        _ui.txt_mode.text = '游戏模式：' + data.getGameModeStr();
        _ui.txt_time.text = '创建时间：' + LANUtils.getTimeStr(data.updateTime);

        if (data.password) {
            initPass();
        }
        else {
            _ui.pass.visible = false;
        }

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
        try {
            _ui.btn_join.removeEventListener(MouseEvent.CLICK, joinHandler);
            _ui.btn_close.removeEventListener(MouseEvent.CLICK, close);
        }
        catch (e:Error) {
        }
    }

    private function initPass():void {
        _ui.pass.visible         = true;
        _ui.pass.correct.visible = false;
        _ui.pass.txt.addEventListener(Event.CHANGE, passChangeHandler);
    }

    private function joinHostBack(succ:Boolean, msg:String):void {
        if (succ) {
            var room:LANRoomState = new LANRoomState();
            MainGame.stageCtrl.removeAllLayer();
            MainGame.stageCtrl.goStage(room);
            room.clientMode(_data);
        }
        else {
            if (msg) {
                GameUI.alert('FAILED', msg);
            }
        }
    }


    private function close(...params):void {
        MainGame.stageCtrl.removeLayer(this);
    }

    private function passChangeHandler(e:Event):void {
        if (_ui.pass.txt.text == _data.password) {
            _ui.pass.correct.visible = true;
        }
        else {
            _ui.pass.correct.visible = false;
        }
    }

    private function joinHandler(e:MouseEvent):void {

        SoundCtrl.I.sndConfrim();

        if (_data.password) {
            if (_ui.pass.txt.text != _data.password) {
                GameUI.alert('FAIL', '密码不正确');
                return;
            }
        }

        close();

        LANClientCtrl.I.join(_data, joinHostBack);
    }
}
}
