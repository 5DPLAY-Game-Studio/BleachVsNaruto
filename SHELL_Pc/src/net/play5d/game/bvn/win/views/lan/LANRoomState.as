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
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.utils.Timer;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.AssetManager;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.data.GameMode;
import net.play5d.game.bvn.ui.GameUI;
import net.play5d.game.bvn.win.ctrls.LANClientCtrl;
import net.play5d.game.bvn.win.ctrls.LANServerCtrl;
import net.play5d.game.bvn.win.data.HostVO;
import net.play5d.game.bvn.win.data.LanGameModel;
import net.play5d.game.bvn.win.utils.UIAssetUtil;
import net.play5d.kyo.stage.IStage;
import net.play5d.kyo.utils.KyoBtnUtils;
import net.play5d.kyo.utils.KyoDisplayUtils;

public class LANRoomState implements IStage {
    private var _ui:MovieClip;
    private var _txtChat:*;
    private var _host:HostVO;
    private var _isOwner:Boolean;
    private var _playerMap:Object = {};
    private var _startTimer:Timer;

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
        _ui = UIAssetUtil.I.createDisplayObject('room_mc');
        _ui.input_chart.addEventListener('enter', submitChat);

        KyoBtnUtils.initBtn(_ui.btn_chart, submitChat);
        KyoBtnUtils.initBtn(_ui.btn_start, startGame);
        KyoBtnUtils.initBtn(_ui.btn_exit, exit);

        SoundCtrl.I.BGM(AssetManager.I.getSound('continue'));
    }

    public function setStartAble(v:Boolean):void {
        if (_ui.btn_start && _ui.btn_start.visible) {
            (
                    _ui.btn_start as SimpleButton
            ).mouseEnabled = v;
            KyoDisplayUtils.grayMC(_ui.btn_start, v);
        }
    }

    public function hostMode():void {
        _isOwner = true;
        _host    = LANServerCtrl.I.host;
        LANServerCtrl.I.setRoom(this);
        initUI();
    }

    public function clientMode(host:HostVO):void {
        LANClientCtrl.I.setRoom(this);
        addPlayer('self', LanGameModel.I.playerName);
        _isOwner = false;
        _host    = host;
        initUI();
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

        if (_startTimer) {
            _startTimer.removeEventListener(TimerEvent.TIMER, startTimerHandler);
            _startTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, startTimerHandler);
            _startTimer.stop();
            _startTimer = null;
        }

        if (_isOwner) {
            if (!LANServerCtrl.I.active) {
                LANServerCtrl.I.stopServer();
            }
        }
        else {
            if (!LANClientCtrl.I.active) {
                LANClientCtrl.I.dispose();
            }

        }

        try {
            _ui.input_chart.removeEventListener('enter', submitChat);
            KyoBtnUtils.disposeBtn(_ui.btn_chart);
            KyoBtnUtils.disposeBtn(_ui.btn_start);
            KyoBtnUtils.disposeBtn(_ui.btn_exit);
        }
        catch (e:Error) {
        }
    }

    public function startGameTimer():void {
        if (_startTimer) {
            return;
        }
        _startTimer = new Timer(1000, 5);
        _startTimer.addEventListener(TimerEvent.TIMER, startTimerHandler);
        _startTimer.addEventListener(TimerEvent.TIMER_COMPLETE, startTimerHandler);

        _startTimer.start();
    }

    public function addPlayer(id:String, name:String):void {

        if (_playerMap[id]) {
            TraceLang('debug.trace.data.lan_room_state.player_exists', {id: id});
            return;
        }

        var item:LANRoomPlayerItem = new LANRoomPlayerItem(id, name);
        item.enableOut();

        _playerMap[id] = item;

        var ct_player:Sprite = _ui.ct_player;
        item.ui.y            = 60;
        ct_player.addChild(item.ui);
    }

    public function removePlayer(id:String):void {
        var item:LANRoomPlayerItem = _playerMap[id];
        if (item) {
            try {
                _ui.ct_player.removeChild(item.ui);
            }
            catch (e:Error) {
            }
            item.destroy();
        }

        delete _playerMap[id];
    }

    public function pushChat(str:String, name:String = null):void {
        var chatStr:String = name ? name + ' : ' + str : str;
        _txtChat.appendText(chatStr + '\n');
    }

    public function exitRoom(msg:String = null):void {
        exit();
        if (msg) {
            GameUI.alert(GetLang('alert.exit_title'), msg);
        }
    }

    /**
     * 开始前的操作锁定
     */
    public function lockStart():void {
        if (_ui.btn_start && _ui.btn_start.visible) {
            (
                    _ui.btn_start as SimpleButton
            ).mouseEnabled = false;
            KyoDisplayUtils.grayMC(_ui.btn_start);
        }
        if (_ui.btn_exit && _ui.btn_exit.visible) {
            (
                    _ui.btn_exit as SimpleButton
            ).mouseEnabled = false;
            KyoDisplayUtils.grayMC(_ui.btn_exit);
        }
    }

    private function initUI():void {
        _ui.txt_name.text     = _host.name;
        _ui.txt_mode.text     = _host.getGameModeStr();
        _ui.txt_pass.text     = _host.password
                ? GetLang('txt.lan_room_state.password', {password: _host.password})
                : '';
        _ui.btn_start.visible = _isOwner;
        _ui.txt_start.visible = _isOwner;
        _txtChat              = _ui.txt_chart;
        addOwner();
    }

    private function submitChat(...params):void {
        var content:String = _ui.input_chart.text;
        if (content == '') {
            return;
        }

        _ui.input_chart.text = '';

        if (_isOwner) {
            LANServerCtrl.I.sendChat(content, LanGameModel.I.playerName);
        }
        else {
            LANClientCtrl.I.sendChat(content);
        }

    }

    private function startGame():void {
        if (_isOwner) {
            SoundCtrl.I.sndConfrim();
            LANServerCtrl.I.sendStart();
        }
    }

    private function exit():void {
        var ls:LANGameState = new LANGameState();
        MainGame.stageCtrl.goStage(ls);

        if (!_isOwner) {
            ls.showHostList();
        }

    }

    private function addOwner():void {
        var item:MovieClip = UIAssetUtil.I.createDisplayObject('player_item_mc');
        item.txt.text      = _host.ownerName;
        item.type.gotoAndStop(1);
        item.btn_out.visible = false;

        var ct_player:Sprite = _ui.ct_player;
        ct_player.addChild(item);
    }

    private function startTimerHandler(e:TimerEvent):void {
        if (e.type == TimerEvent.TIMER) {
            pushChat(GetLang('txt.lan_room_state.start_countdown', {
                sec: _startTimer.repeatCount - _startTimer.currentCount + 1
            }), null);
        }

        if (e.type == TimerEvent.TIMER_COMPLETE) {
            if (_isOwner) {
                LANServerCtrl.I.gameStart();
            }
            else {
                LANClientCtrl.I.gameStart();
            }

            switch (_host.gameMode) {
            case 1:
                GameMode.currentMode = GameMode.TEAM_VS_PEOPLE;
                break;
            case 2:
                GameMode.currentMode = GameMode.SINGLE_VS_PEOPLE;
                break;
            }
            MainGame.I.goSelect();
        }
    }

}
}
