package net.play5d.game.bvn.mob.views {
import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.utils.Dictionary;

import net.play5d.game.bvn.mob.screenpad.ScreenPadBtnBase;
import net.play5d.game.bvn.mob.utils.UIAssetUtil;

public class CustomSetBtnItemUI {
    public function CustomSetBtnItemUI(scale:Number) {
        _ui         = UIAssetUtil.I.createDisplayObject('item_set_btns_mc');
        _ui.scaleX  = _ui.scaleY = scale;
        _ui.visible = false;
        initBtns('zoomin2', 'zoomout2');
    }
    private var _ui:Sprite;
    private var _target:ScreenPadBtnBase;
    private var _btns:Array;
    private var _btnPos:Dictionary = new Dictionary();
    private var _scale:Number      = 1;

    public function getUI():Sprite {
        return _ui;
    }

    public function show(target:ScreenPadBtnBase):void {
        _target     = target;
        _ui.visible = true;
        _ui.x       = _target.display.x + _target.display.width - _ui.width;
        _ui.y       = _target.display.y;
    }

    public function hide():void {
        _target     = null;
        _ui.visible = false;
    }

    private function initBtns(...params):void {
        _btns = [];
        for each(var i:String in params) {
            var b:DisplayObject = _ui.getChildByName(i);
            if (b) {
                _btnPos[b] = new Point(b.x, b.y);
                _btns.push(b);
                b.addEventListener(TouchEvent.TOUCH_TAP, btnTouchHandler);
            }
        }
    }

    private function zoomBtn(z:Number):void {
        if (!_target) {
            return;
        }
        var v:Number           = _target.display.scaleX;
        v += z;
        _target.display.scaleX = _target.display.scaleY = v;
    }

    private function btnTouchHandler(e:TouchEvent):void {
        var target:DisplayObject = e.currentTarget as DisplayObject;
        if (!target) {
            return;
        }

        var bp:Point = _btnPos[target];
        if (!bp) {
            target.alpha = 0.5;
            TweenLite.to(target, 0.2, {alpha: 1});
        }
        else {
            var oy:Number = bp.y;
            target.y += 5;
            target.alpha  = 0.5;
            TweenLite.to(target, 0.2, {alpha: 1, y: oy});
        }

        switch (target.name) {
        case 'zoomin2':
            zoomBtn(0.1);
            break;
        case 'zoomout2':
            zoomBtn(-0.1);
            break;
        }
    }
}
}
