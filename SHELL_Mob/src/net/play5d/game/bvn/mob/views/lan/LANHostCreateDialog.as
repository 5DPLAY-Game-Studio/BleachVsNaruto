package net.play5d.game.bvn.mob.views.lan {
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;

import net.play5d.game.bvn.MainGame;
import net.play5d.game.bvn.ctrler.SoundCtrl;
import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
import net.play5d.game.bvn.mob.utils.UIAssetUtil;
import net.play5d.kyo.stage.effect.ZoomEffect;

public class LANHostCreateDialog implements Istage {
    public function LANHostCreateDialog() {
    }
    public var onClose:Function;
    public var onOK:Function;
    public var setting:Object = {};
    private var _ui:MovieClip;
    private var _settingData:Array = [
        {
            'title': '游戏模式', 'en': 'Game Mode', 'key': 'game_mode',
            options: [{'name': '小队', 'en': 'Team vs', 'value': 1}, {'name': '单人', 'en': 'Single vs', 'value': 2}]
        },
        {
            'title': '回合时间', 'en': 'Game Time', 'key': 'game_time',
            options: [{'name': '60', 'en': '60', 'value': 60}, {'name': '90', 'en': '90', 'value': 90}]
        },
        {
            'title': '人物血量', 'en': 'HP', 'key': 'hp',
            options: [{'name': '100%', 'en': '100%', 'value': 1}, {'name': '200%', 'en': '200%', 'value': 2}]
        }
    ];
    private var _setItems:Array;
    private var _isOK:Boolean;

    public function get display():DisplayObject {
        return _ui;
    }

    public function close():void {
        MainGame.stageCtrl.removeLayer(this, new ZoomEffect(0.2), function ():void {
            if (_isOK) {
                if (onOK != null) {
                    onOK();
                }
            }
            if (onClose != null) {
                onClose();
            }
        });
    }

    public function build():void {
        _ui = UIAssetUtil.I.createDisplayObject('dialog_host');
        buildItems();
        ScreenPadManager.addTouchListener(_ui.btn_ok, okHandler);
        ScreenPadManager.addTouchListener(_ui.btn_back, backHandler);
    }

    public function afterBuild():void {
    }

    public function destory(back:Function = null):void {
        ScreenPadManager.removeTouchListener(_ui.btn_ok);
        ScreenPadManager.removeTouchListener(_ui.btn_back);
    }

    private function buildItems():void {
        _setItems = [];
        for (var i:int; i < _settingData.length; i++) {
            var data:Object         = _settingData[i];
            var item:HostDialogItem = new HostDialogItem(data);
            item.ui.x               = 100;
            item.ui.y               = 50 + i * 100;
            _ui.addChild(item.ui);
            _setItems.push(item);
        }
    }

    private function okHandler(btn:DisplayObject):void {
        for each(var i:HostDialogItem in _setItems) {
            var o:Object   = i.getSelectData();
            setting[o.key] = o.value;
        }

        _isOK = true;

        SoundCtrl.I.sndConfrim();

        close();
    }

    private function backHandler(b:DisplayObject):void {
        SoundCtrl.I.sndSelect();
        close();
    }

    private function checkHandler(e:Event):void {
        _ui.txt_pass.visible = _ui.check_pass.selected;
    }
}
}
