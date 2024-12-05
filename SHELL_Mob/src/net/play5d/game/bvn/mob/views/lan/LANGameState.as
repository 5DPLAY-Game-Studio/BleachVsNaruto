package net.play5d.game.bvn.mob.views.lan {
import com.greensock.TweenLite;
import com.greensock.easing.Back;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.cntlr.AssetManager;
import net.play5d.game.bvn.cntlr.SoundCtrl;
import net.play5d.game.bvn.mob.ctrls.LANClientCtrl;
import net.play5d.game.bvn.mob.ctrls.LANServerCtrl;
import net.play5d.game.bvn.mob.data.HostVO;
import net.play5d.game.bvn.mob.events.LanEvent;
import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
import net.play5d.game.bvn.mob.utils.UIAssetUtil;
import net.play5d.kyo.stage.effect.ZoomEffect;

public class LANGameState implements Istage {
    public function LANGameState() {
        super();
    }
    private var _ui:MovieClip;

    public function get display():DisplayObject {
        return _ui;
    }

    public function build():void {
        _ui = UIAssetUtil.I.createDisplayObject('spr_lan');
        SoundCtrl.I.BGM(AssetManager.I.getSound('continue'));
        mainMenu();
    }

    public function afterBuild():void {

    }

    public function destory(back:Function = null):void {
        ScreenPadManager.clearTouchListener();
    }

    private function mainMenu():void {
        _ui.gotoAndPlay(1);
        _ui.addEventListener(Event.COMPLETE, initMainMenu);

        function initMainMenu(e:Event):void {
            _ui.removeEventListener(Event.COMPLETE, initMainMenu);

            ScreenPadManager.addTouchListener(_ui.btn1, mainBtnHandler);
            ScreenPadManager.addTouchListener(_ui.btn2, mainBtnHandler);
            ScreenPadManager.addTouchListener(_ui.btn_back, mainBtnHandler);

        }
    }

    private function btnTouchEffect(d:DisplayObject, back:Function = null, sound:Boolean = true):void {
        if (!d.visible) {
            return;
        }
        if (sound) {
            SoundCtrl.I.sndSelect();
        }
        var scalex:Number = d.scaleX;
        var scaley:Number = d.scaleY;
        var dalpha:Number = d.alpha;
        d.scaleX          = scalex * 0.8;
        d.scaleY          = scaley * 0.8;
        d.alpha           = dalpha * 0.8;
        TweenLite.to(d, .3, {scaleX: scalex, scaleY: scaley, alpha: dalpha, ease: Back.easeOut, onComplete: back});
    }

    private function mainBtnHandler(target:DisplayObject):void {
        btnTouchEffect(target, effectBack);

        function effectBack():void {
            switch (target) {
            case _ui.btn1:
                showHostDialog();
                break;
            case _ui.btn2:
                runClient();
                break;
            case _ui.btn_back:
                MainGame.I.goMenu();
                break;
            }
        }

    }

    private function showHostDialog():void {
        var dialog:LANHostCreateDialog = new LANHostCreateDialog();
        dialog.onOK                    = onDialogOK;
        dialog.onClose                 = onDialogClose;
        MainGame.stageCtrl.addLayer(dialog, 30, 100, false, new ZoomEffect());

        try {
            _ui.btn1.visible     = false;
            _ui.btn2.visible     = false;
            _ui.btn_back.visible = false;

            _ui.label_host.visible   = false;
            _ui.label_client.visible = false;
            _ui.label_back.visible   = false;

        }
        catch (e:Error) {
            trace(e);
        }

        function onDialogClose():void {
            dialog = null;
            try {
                _ui.btn1.visible     = true;
                _ui.btn2.visible     = true;
                _ui.btn_back.visible = true;

                _ui.label_host.visible   = true;
                _ui.label_client.visible = true;
                _ui.label_back.visible   = true;

            }
            catch (e:Error) {
                trace(e);
            }
        }

        function onDialogOK():void {
            runHost(dialog.setting);
        }
    }

    private function runHost(setting:Object):void {

        _ui.addEventListener(Event.COMPLETE, hostCom1);
        _ui.gotoAndPlay('conn_host');

        function hostCom1(e:Event):void {
            _ui.removeEventListener(Event.COMPLETE, hostCom1);

            ScreenPadManager.addTouchListener(_ui.btn_back, backHandler);

            //setting
            trace(setting);

            var hv:HostVO = new HostVO();
            hv.gameMode   = setting.game_mode;
            hv.gameTime   = setting.game_time;
            hv.hp         = setting.hp;

            LANServerCtrl.I.startServer(hv);
            LANServerCtrl.I.addEventListener(LanEvent.CLIENT_JOIN_SUCCESS, hostConnect);
        }

        function hostConnect(e:LanEvent):void {
            _ui.addEventListener(Event.COMPLETE, hostCom2);
            _ui.gotoAndPlay('conn_host_ready');
        }

        function hostCom2(e:Event):void {
            _ui.removeEventListener(Event.COMPLETE, hostCom2);

            ScreenPadManager.addTouchListener(_ui.btn, startGameHost);
            ScreenPadManager.addTouchListener(_ui.btn_back, backHandler);
        }

    }

    private function runClient():void {
        _ui.addEventListener(Event.COMPLETE, clientCom1);
        _ui.gotoAndPlay('conn_client');

        function clientCom1(e:Event):void {
            _ui.removeEventListener(Event.COMPLETE, clientCom1);
            ScreenPadManager.addTouchListener(_ui.btn_back, backHandler);
            LANClientCtrl.I.initlize();
            LANClientCtrl.I.findHost(findHostHandler);
        }

        function findHostHandler(host:HostVO):void {
            LANClientCtrl.I.cancelFindHost();
            LANClientCtrl.I.join(host, joinHostBack);
        }

        function joinHostBack(succ:Boolean):void {
            if (succ) {
                clientConnect();
            }
            else {
                LANClientCtrl.I.findHost(findHostHandler);
            }
        }

        function clientConnect():void {
            _ui.addEventListener(Event.COMPLETE, clientCom2);
            _ui.gotoAndPlay('conn_client_ready');
        }

        function clientCom2(e:Event):void {
            _ui.removeEventListener(Event.COMPLETE, clientCom2);
            ScreenPadManager.addTouchListener(_ui.btn_back, backHandler);
        }

    }

    private function backHandler(target:DisplayObject):void {

        LANClientCtrl.I.dispose();
        LANServerCtrl.I.stopServer();

        ScreenPadManager.removeTouchListener(_ui.btn_back);
        btnTouchEffect(target, mainMenu);
    }

    private function startGameHost(t:DisplayObject):void {
        trace('startGameHost');
        btnTouchEffect(t, null, false);
        SoundCtrl.I.sndConfrim();

        LANServerCtrl.I.sendGameStart();
        LANServerCtrl.I.gameStart();
    }


}
}
