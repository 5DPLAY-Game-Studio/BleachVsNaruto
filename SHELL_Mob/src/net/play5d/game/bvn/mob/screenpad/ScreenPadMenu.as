package net.play5d.game.bvn.mob.screenpad {
import flash.display.Stage;
import flash.events.TouchEvent;

import net.play5d.game.bvn.mob.input.ScreenPadInput;

public class ScreenPadMenu {

    public function ScreenPadMenu(stage:Stage) {
        super();
        _stage = stage;
        build();
    }
    public var inputers:Vector.<ScreenPadInput>;
//		private var _ok:ScreenPadBtn;
    private var _arrow:ScreenPadArrow;
//		private var _cancel:ScreenPadBtn;
    private var _stage:Stage;
    private var _listened:Boolean;
    private var _downCache:Object = {};
    private var _btns:Vector.<ScreenPadBtnBase>;
    private var W:Number;
    private var H:Number;

    public function reBuild():void {
        try {
            for (var i:int; i < _btns.length; i++) {
                _stage.removeChild(_btns[i].display);
                _btns[i].onRemove();
            }
        }
        catch (e:Error) {
        }
        build();
    }

    public function show():void {
        for (var i:int; i < _btns.length; i++) {
            _stage.addChild(_btns[i].display);
            _btns[i].onAdd();
        }
    }

    public function hide():void {
        try {
            for (var i:int; i < _btns.length; i++) {
                _stage.removeChild(_btns[i].display);
                _btns[i].onRemove();
            }
        }
        catch (e:Error) {
        }

        for each(var p:ScreenPadInput in inputers) {
            p.clear();
        }

    }

    private function build():void {
        W     = launch.FULL_SCREEN_SIZE.x;
        H     = launch.FULL_SCREEN_SIZE.y;
        _btns = new Vector.<ScreenPadBtnBase>();

        _arrow = addArrow(['up', 'down', 'left', 'right'], ScreenPadAsset.arrow, 0.2, 0, 0, 0.2, 0.5);
        addBtn('select', ScreenPadAsset.ok, 0, 0, 1, 0.3);
        addBtn('back', ScreenPadAsset.cancel, 0, 0, 0.3, 1.7);

        initBtns();
    }

    private function addArrow(keyIds:Array, asset:Class, left:Number = 0, top:Number = 0, right:Number = 0,
                              bottom:Number                                                            = 0, areaAdd:Number                                        = 0
    ):ScreenPadArrow {
        var arrow:ScreenPadArrow = ScreenPadUtils.getArrow(asset);
        arrow.moveAble           = false;
        arrow.setKeyIds(keyIds[0], keyIds[1], keyIds[2], keyIds[3]);
        arrow.areaAdd = ScreenPadUtils.cm2pixel(areaAdd);

        if (left != 0) {
            arrow.display.x = ScreenPadUtils.cm2pixel(left);
        }
        if (top != 0) {
            arrow.display.y = ScreenPadUtils.cm2pixel(top);
        }
        if (right != 0) {
            arrow.display.x = W - arrow.display.width - ScreenPadUtils.cm2pixel(right);
        }
        if (bottom != 0) {
            arrow.display.y = H - arrow.display.height - ScreenPadUtils.cm2pixel(bottom);
        }

        _btns.push(arrow);

        return arrow;
    }

    private function addBtn(keyId:String, asset:Class, left:Number = 0, top:Number = 0, right:Number = 0,
                            bottom:Number                                                            = 0, areaAdd:Number = 0
    ):ScreenPadBtn {
        var btn:ScreenPadBtn = ScreenPadUtils.getButton(asset);
        btn.moveAble         = false;
        btn.keyId            = keyId;
        btn.areaAdd          = ScreenPadUtils.cm2pixel(areaAdd);

        if (left != 0) {
            btn.display.x = ScreenPadUtils.cm2pixel(left);
        }
        if (top != 0) {
            btn.display.y = ScreenPadUtils.cm2pixel(top);
        }
        if (right != 0) {
            btn.display.x = W - btn.display.width - ScreenPadUtils.cm2pixel(right);
        }
        if (bottom != 0) {
            btn.display.y = H - btn.display.height - ScreenPadUtils.cm2pixel(bottom);
        }

        _btns.push(btn);

        return btn;
    }

    private function initBtns():void {
        for each(var i:ScreenPadBtnBase in _btns) {
            i.initArea();
        }
    }

    private function setInputerDown(key:Object, down:Boolean):void {

        if (key == null) {
            return;
        }

//			trace('setInputerDown' , key , down);

        var t:ScreenPadInput;
        var i:int, j:int;
        var ks:Array;
        var k:String;
        var il:int, kl:int;

        il = inputers.length;

        for (i = 0; i < il; i++) {
            t = inputers[i];

            if (key is String) {
                t.setDown(key as String, down);
            }

            if (key is Array) {
                ks = key as Array;
                kl = ks.length;
                for (j = 0; j < kl; j++) {
                    k = ks[j];
                    t.setDown(k, down);
                }
            }

        }
    }

    public function touchHandler(e:TouchEvent):void {
        var touchId:int   = e.touchPointID;
        var touchX:Number = e.stageX;
        var touchY:Number = e.stageY;

        var b:ScreenPadBtnBase;

        if (e.type == TouchEvent.TOUCH_END) {
            if (_downCache[touchId]) {
                b = _downCache[touchId].btn;
                b.touchUP();
                setInputerDown(_downCache[touchId].key, false);
                delete _downCache[touchId];
            }
            return;
        }

        for (var i:int; i < _btns.length; i++) {
            b = _btns[i];
            switch (e.type) {
            case TouchEvent.TOUCH_BEGIN:
                if (b.checkArea(touchX, touchY)) {
                    b.touchDown(touchX, touchY);
                    _downCache[touchId] = {btn: b, key: b.keyId};
                    setInputerDown(b.keyId, true);
                }
                break;
            case TouchEvent.TOUCH_MOVE:
                b.touchMove(touchX, touchY);
                if (b == _arrow && b.isDown() && _downCache[touchId].key != b.keyId) {
                    setInputerDown(_downCache[touchId].key, false);
                    _downCache[touchId].key = b.keyId;
                    setInputerDown(b.keyId, true);
                }
                break;
            }
        }

    }


}
}
