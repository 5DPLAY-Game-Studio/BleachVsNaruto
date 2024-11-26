package net.play5d.game.bvn.mob.views {
import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.utils.Dictionary;

import net.play5d.game.bvn.ctrl.SoundCtrl;
import net.play5d.game.bvn.mob.GameInterfaceManager;
import net.play5d.game.bvn.mob.RootSprite;
import net.play5d.game.bvn.mob.events.ScreenPadEvent;
import net.play5d.game.bvn.mob.screenpad.ScreenPadBtnBase;
import net.play5d.game.bvn.mob.screenpad.ScreenPadGame;
import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
import net.play5d.game.bvn.mob.screenpad.ScreenPadUtils;
import net.play5d.game.bvn.mob.utils.UIAssetUtil;

public class CustomScreenBtnView {
    public function CustomScreenBtnView() {
        _ui = UIAssetUtil.I.createDisplayObject('screen_pad_set_ui_mc');

        _ui.graphics.beginFill(0, 0.8);
        _ui.graphics.drawRect(0, 0, RootSprite.FULL_SCREEN_SIZE.x, RootSprite.FULL_SCREEN_SIZE.y);
        _ui.graphics.endFill();

        _width  = RootSprite.FULL_SCREEN_SIZE.x;
        _height = ScreenPadUtils.cm2pixel(0.8);
        _scale  = _height / 55;

        _btnItemSetUI = new CustomSetBtnItemUI(_scale);
        _ui.addChild(_btnItemSetUI.getUI());

        initBtns('close', 'up', 'down', 'left', 'right',
                 'center', 'side', 'zoomin', 'zoomout', 'ok'
        );

        initView();

        initPad();
    }
    private var _ui:Sprite;
    private var _width:int;
    private var _height:int;
    private var _scale:Number      = 1;
    private var _btns:Array;
    private var _btnPos:Dictionary = new Dictionary();
    private var _btnItemSetUI:CustomSetBtnItemUI;
    private var _screenPad:ScreenPadGame;
    private var _screenBtns:Vector.<ScreenPadBtnBase>;
    private var _moveStep:Point;

    public function getDisplay():Sprite {
        return _ui;
    }

    private function initView():void {
        var btnbg:DisplayObject = _ui.getChildByName('btnbg');
        if (btnbg) {
            btnbg.width  = _width;
            btnbg.height = _height;
        }

        var btn:DisplayObject = _ui.getChildByName('up');

        var btnGap:int = btn.width * 0.15;

        var xx:Number = 0;
        var b:DisplayObject;
        var i:int;

        for (i = 0; i < _btns.length; i++) {
            b   = _btns[i];
            b.x = xx;
            xx += btnGap + b.width;
            if (i == 0 || i == _btns.length - 2) {
                xx += btnGap;
            }
        }

        var centerBtnWidth:Number     = xx;
        var centerBtnLen:int          = _btns.length - 2;
        var centerBtnFullWidth:Number = RootSprite.FULL_SCREEN_SIZE.x;
        var btnStartX:Number          = (
                                                centerBtnFullWidth - centerBtnWidth
                                        ) / 2;

        for (i = 0; i < _btns.length; i++) {
            b = _btns[i];
            b.x += btnStartX;
        }
    }

    private function initBtns(...params):void {
        _btns = [];
        for each(var i:String in params) {
            var b:DisplayObject = _ui.getChildByName(i);
            if (b) {
                _btnPos[b] = new Point(b.x, b.y);
                _btns.push(b);
                b.scaleX = b.scaleY = _scale;
                b.addEventListener(TouchEvent.TOUCH_TAP, btnTouchHandler);
            }
        }
    }

    private function removeSelf():void {
        if (_screenPad) {
            _screenPad.destory();
            _screenPad = null;
        }

        if (_btns) {
            for each(var i:DisplayObject in _btns) {
                i.removeEventListener(TouchEvent.TOUCH_TAP, btnTouchHandler);
            }
            _btns = null;
        }

        if (_ui) {
            try {
                _ui.parent.removeChild(_ui);
            }
            catch (e:Error) {
                trace(e);
            }
            _ui = null;
        }
    }

    private function doOK():void {
        GameInterfaceManager.config.screenPadConfig.joySet = _screenPad.getBtnPosData();
        ScreenPadManager.reBuild();
        removeSelf();
    }

    private function initPad():void {
        _screenPad = new ScreenPadGame(RootSprite.STAGE);
        _screenPad.showEditMode();
        _screenPad.addEventListener(ScreenPadEvent.CUSTOM_MOVING, screenPadCustomHandler);
        _screenPad.addEventListener(ScreenPadEvent.CUSTOM_SELECT, screenPadCustomHandler);
        _screenBtns = _screenPad.getBtns();

        _moveStep   = new Point();
        _moveStep.x = RootSprite.FULL_SCREEN_SIZE.x * 0.01;
        _moveStep.y = RootSprite.FULL_SCREEN_SIZE.y * 0.01;
    }

    private function moveAllBtns(X:Number = 0, Y:Number = 0):void {
        for each(var i:ScreenPadBtnBase in _screenBtns) {
            i.display.x += X;
            i.display.y += Y;
        }
    }

    private function moveLRBtns(X:Number = 0):void {
        var centerX:Number = RootSprite.FULL_SCREEN_SIZE.x / 2;
        for each(var i:ScreenPadBtnBase in _screenBtns) {
            if (i.display.x < centerX) {
                i.display.x += X;
            }
            else {
                i.display.x -= X;
            }

        }
    }

    private function zoomBtns(z:Number):void {
        for each(var i:ScreenPadBtnBase in _screenBtns) {
            zoomBtn(i, z);
        }
    }

    private function zoomBtn(b:ScreenPadBtnBase, z:Number):void {
        if (!b) {
            return;
        }
        var v:Number     = b.display.scaleX;
        v += z;
        b.display.scaleX = b.display.scaleY = v;
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
            target.y += 5 * _scale;
            target.alpha  = 0.5;
            TweenLite.to(target, 0.2, {alpha: 1, y: oy});
        }

        switch (target.name) {
        case 'close':
            removeSelf();
            break;
        case 'up':
            moveAllBtns(0, -_moveStep.x);
            break;
        case 'down':
            moveAllBtns(0, _moveStep.x);
            break;
        case 'left':
            moveAllBtns(-_moveStep.x, 0);
            break;
        case 'right':
            moveAllBtns(_moveStep.x, 0);
            break;
        case 'center':
            moveLRBtns(_moveStep.x);
            break;
        case 'side':
            moveLRBtns(-_moveStep.x);
            break;
        case 'zoomin':
            zoomBtns(0.1);
            break;
        case 'zoomout':
            zoomBtns(-0.1);
            break;
        case 'ok':
            doOK();
            break;
        }

        if (target.name == 'ok') {
            SoundCtrl.I.sndConfrim();
        }
        else {
            SoundCtrl.I.sndSelect();
        }
    }

    private function screenPadCustomHandler(e:ScreenPadEvent):void {
        switch (e.type) {
        case ScreenPadEvent.CUSTOM_MOVING:
            _btnItemSetUI.show(e.screenPadBtn);
            break;
        case ScreenPadEvent.CUSTOM_SELECT:
            _btnItemSetUI.show(e.screenPadBtn);
            break;
        }
    }

}
}
