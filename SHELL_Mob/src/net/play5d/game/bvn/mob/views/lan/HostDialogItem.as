package net.play5d.game.bvn.mob.views.lan {
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;

import net.play5d.game.bvn.mob.utils.UIAssetUtil;

public class HostDialogItem {
    public function HostDialogItem(data:Object) {
        super();
        _data = data;
        ui    = UIAssetUtil.I.createDisplayObject('check_line_mc');

        _txt   = ui.getChildByName('txt') as TextField;
        _enTxt = ui.getChildByName('txt_en') as TextField;


        _txt.text    = data.title;
        _txt.width   = _txt.textWidth + 50;
        _enTxt.text  = data.en;
        _enTxt.width = _enTxt.textWidth + 50;

        buildCheckGroup();
        updateEnText();
    }
    public var ui:Sprite;
    private var _txt:TextField;
    private var _enTxt:TextField;
    private var _data:Object;
    private var _checkGroup:InsCheckGroup;

    public function getSelectData():Object {
        var o:Object = {
            key  : _data.key,
            value: _checkGroup.selectData.value
        };
        return o;
    }

    private function buildCheckGroup():void {
        var gp:InsCheckGroup = new InsCheckGroup(_data.key, _data.options);
        gp.x                 = _txt.width;
        gp.addEventListener(Event.CHANGE, groupChangeHandler);
        ui.addChild(gp);
        _checkGroup = gp;
    }

    private function updateEnText():void {
        _enTxt.text  = _data.en + ' : ' + _checkGroup.selectData.en;
        _enTxt.width = _enTxt.textWidth + 50;
    }

    private function groupChangeHandler(e:Event):void {
        updateEnText();
    }

}

}

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;

import net.play5d.game.bvn.cntlr.SoundCtrl;
import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
import net.play5d.game.bvn.mob.utils.UIAssetUtil;

internal class InsCheckGroup extends Sprite {
    public function InsCheckGroup(key:String, datas:Array):void {

        _checkMcs = [];

        this.mouseEnabled = this.mouseChildren = false;
        this.key          = key;

        for (var i:int; i < datas.length; i++) {
            var checkmc:InsCheckMc = new InsCheckMc(datas[i]);

            if (i == 0) {
                checkmc.selected(true);
                selectData = datas[i];
            }

            _checkMcs.push(checkmc);
            checkmc.ui.x = i * 130;
            addChild(checkmc.ui);
            ScreenPadManager.addTouchListener(checkmc.ui, touchHandler);
        }

    }
    public var key:String;
    public var selectData:Object;
    private var _checkMcs:Array;

    private function touchHandler(d:DisplayObject):void {
        var newSelectData:Object = null;

        SoundCtrl.I.sndSelect();

        for each(var i:InsCheckMc in _checkMcs) {
            if (i.ui == d) {
                newSelectData = i.data;
                i.selected(true);
            }
            else {
                i.selected(false);
            }
        }

        if (selectData != newSelectData) {
            selectData = newSelectData;
            dispatchEvent(new Event(Event.CHANGE));
        }


    }

}

internal class InsCheckMc {
    public function InsCheckMc(data:Object) {
        this.data         = data;
        ui                = UIAssetUtil.I.createDisplayObject('ckmc');
        ui.txtmc.txt.text = data.name;
    }
    public var ui:MovieClip;
    public var data:Object;

    public function selected(v:Boolean):void {
        ui.gotoAndStop(v ? 2 : 1);
    }

}
