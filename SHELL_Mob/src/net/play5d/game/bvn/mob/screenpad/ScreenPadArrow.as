package net.play5d.game.bvn.mob.screenpad {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Timer;

public class ScreenPadArrow extends ScreenPadBtnBase {

    public function ScreenPadArrow() {
    }
    private var _keyUP:String;
    private var _keyDOWN:String;
    private var _keyLEFT:String;
    private var _keyRIGHT:String;
    private var _downV:String;
    private var _downH:String;
    private var _lightH:Bitmap;
    private var _lightV:Bitmap;
    private var _center:Rectangle;
    private var _upBitmap:BitmapData;
    private var _startTouchPoint:Point;
    private var _touchMoving:Boolean;
    private var _resetPoint:Point;
    private var _resetTimer:Timer;

    public override function initArea():void {
        super.initArea();
        _center = new Rectangle(
                _orgBounds.x + _orgBounds.width * 0.3,
                _orgBounds.y + _orgBounds.height * 0.3,
                _orgBounds.x + _orgBounds.width * 0.7,
                _orgBounds.y + _orgBounds.height * 0.7
        );

        _resetPoint = new Point(_orgBounds.x, _orgBounds.y);

        _lightH = new ScreenPadAsset.light();
        _lightV = new ScreenPadAsset.light();

        _lightH.scaleX = _lightH.scaleY = _orgScale;
        _lightV.scaleX = _lightV.scaleY = _orgScale;

        _lightH.alpha = display.alpha;
        _lightV.alpha = display.alpha;

        _lightH.visible = false;
        _lightV.visible = false;

        if (moveAble) {
            _resetTimer = new Timer(1000, 1);
            _resetTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetTimeHandler);
        }
    }

    public override function updateBounds():void {
        super.updateBounds();
        _center.x      = _orgBounds.x + _orgBounds.width * 0.4;
        _center.y      = _orgBounds.y + _orgBounds.height * 0.3;
        _center.width  = _orgBounds.x + _orgBounds.width * 0.6;
        _center.height = _orgBounds.y + _orgBounds.height * 0.7;
    }

    public override function onAdd():void {
        super.onAdd();
        display.parent.addChild(_lightH);
        display.parent.addChild(_lightV);
    }

    public override function onRemove():void {
        super.onRemove();
        try {
            _lightH.parent.removeChild(_lightH);
            _lightV.parent.removeChild(_lightV);
        }
        catch (e:Error) {
        }

        if (_resetTimer) {
            _resetTimer.stop();
        }
    }

    protected override function onTouchDown(X:Number, Y:Number):void {
        if (Y < _center.y) {
            _downV = _keyUP;
        }
        if (Y > _center.height) {
            _downV = _keyDOWN;
        }
        if (X < _center.x) {
            _downH = _keyLEFT;
        }
        if (X > _center.width) {
            _downH = _keyRIGHT;
        }

        updateKeyId();
    }

    protected override function onTouchUp():void {
        super.touchUP();

        _downV = null;
        _downH = null;

        updateKeyId();
    }

    protected override function downState():void {
        if (_downH == _keyLEFT) {
            _lightH.visible = true;
            _lightH.x       = _orgBounds.x - _lightH.width / 2;
            _lightH.y       = _orgBounds.y - _lightH.height / 2 + _orgBounds.width / 2;
        }

        if (_downH == _keyRIGHT) {
            _lightH.visible = true;
            _lightH.x       = _orgBounds.x - _lightH.width / 2 + _orgBounds.width;
            _lightH.y       = _orgBounds.y - _lightH.height / 2 + _orgBounds.width / 2;
        }

        if (_downV == _keyUP) {
            _lightV.visible = true;
            _lightV.x       = _orgBounds.x - _lightV.width / 2 + _orgBounds.width / 2;
            _lightV.y       = _orgBounds.y - _lightV.height / 2;
        }

        if (_downV == _keyDOWN) {
            _lightV.visible = true;
            _lightV.x       = _orgBounds.x - _lightV.width / 2 + _orgBounds.width / 2;
            _lightV.y       = _orgBounds.y - _lightV.height / 2 + _orgBounds.height;
        }

        if (_resetTimer) {
            _resetTimer.stop();
        }
    }

    protected override function onTouchMove(X:Number, Y:Number):void {

        if (!_isDown) {
            return;
        }

        _downV = null;
        _downH = null;

        if (Y < _center.y) {
            _downV = _keyUP;
        }
        if (Y > _center.height) {
            _downV = _keyDOWN;
        }
        if (X < _center.x) {
            _downH = _keyLEFT;
        }
        if (X > _center.width) {
            _downH = _keyRIGHT;
        }
        updateKeyId();

        if (moveAble) {
            updateMovePosition(X, Y);
        }
    }

    protected override function moveState():void {
        if (!_isDown) {
            return;
        }
        _lightH.visible = false;
        _lightV.visible = false;
        downState();
    }

    protected override function upState():void {
        super.upState();
        _lightH.visible = false;
        _lightV.visible = false;

        _startTouchPoint = null;
        _touchMoving     = false;

        if (_resetTimer) {
            _resetTimer.reset();
            _resetTimer.start();
        }
    }

    public function setKeyIds(up:String, down:String, left:String, right:String):void {
        _keyUP    = up;
        _keyDOWN  = down;
        _keyLEFT  = left;
        _keyRIGHT = right;
    }

    public function getAllKeyIds():Array {
        return [_keyUP, _keyDOWN, _keyLEFT, _keyRIGHT];
    }

    public function clearKey():void {
        _downV          = null;
        _downH          = null;
        _lightH.visible = false;
        _lightV.visible = false;
    }

    public function getNotDownKeyIds():Array {
        var keys:Array = [_keyUP, _keyDOWN, _keyLEFT, _keyRIGHT];

        var idv:int = keys.indexOf(_downV);
        if (idv != -1) {
            keys.splice(idv, 1);
        }

        var idh:int = keys.indexOf(_downH);
        if (idh != -1) {
            keys.splice(idh, 1);
        }
        return keys;
    }

    private function updateKeyId():void {
        if (!_downV && !_downH) {
            keyId = null;
        }
        keyId = [_downV, _downH];
    }

    private function updateMovePosition(X:Number, Y:Number):void {

        if (!_touchMoving) {
            _startTouchPoint ||= new Point(X, Y);
            if (Math.abs(X - _startTouchPoint.x) + Math.abs(Y - _startTouchPoint.y) > ScreenPadUtils.cm2pixel(0.3)) {
                _touchMoving = true;
            }
            return;
        }

        var right:Number = _orgBounds.x + _orgBounds.width;
        var down:Number  = _orgBounds.y + _orgBounds.height;
        var moved:Boolean;

        if (X > right) {
            moved     = true;
            display.x = X - display.width;
        }
        if (X < _orgBounds.x) {
            moved     = true;
            display.x = X;
        }
        if (Y > down) {
            moved     = true;
            display.y = Y - display.height;
        }
        if (Y < _orgBounds.y) {
            moved     = true;
            display.y = Y;
        }

        if (moved) {
            updateBounds();
        }
    }

    private function resetTimeHandler(e:TimerEvent):void {
        display.x = _resetPoint.x;
        display.y = _resetPoint.y;
        updateBounds();
    }

}
}
