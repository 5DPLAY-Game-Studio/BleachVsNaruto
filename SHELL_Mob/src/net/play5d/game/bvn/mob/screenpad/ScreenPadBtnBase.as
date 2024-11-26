package net.play5d.game.bvn.mob.screenpad {
import flash.display.Bitmap;
import flash.geom.Point;
import flash.geom.Rectangle;

public class ScreenPadBtnBase {
    public function ScreenPadBtnBase() {
    }
    public var moveAble:Boolean = false;
    public var display:Bitmap;
    public var touchPos:Point   = new Point();
    public var keyId:Object;
    public var areaAdd:Number = 0;
    protected var _orgScale:Number = 1;
    protected var _orgBounds:Rectangle;
    protected var _area:Rectangle;
    protected var _isDown:Boolean;
    protected var _visible:Boolean = true;

    public function init(size:Point = null):void {
        if (size) {
            if (size.x > 0 && size.y > 0) {
                display.width  = size.x;
                display.height = size.y;
            }
            else if (size.x > 0) {
                display.width  = size.x;
                display.scaleY = display.scaleX;
            }
            else {
                display.height = size.y;
                display.scaleX = display.scaleY;
            }
        }
        _orgScale = display.scaleX;
    }

    public function setScale(v:Number):void {
        _orgScale      = v;
        display.scaleX = display.scaleY = v;
    }

    public function isDown():Boolean {
        return _isDown;
    }

    public function setVisible(v:Boolean):void {
        _visible = v;
        if (display) {
            display.visible = v;
        }
    }

    public function onAdd():void {

    }

    public function onRemove():void {

    }

    public function initArea():void {

        _orgBounds        = new Rectangle();
        _orgBounds.x      = display.x;
        _orgBounds.y      = display.y;
        _orgBounds.width  = display.width;
        _orgBounds.height = display.height;

        _area = _orgBounds.clone();
        if (areaAdd != 0) {
            _area.x -= areaAdd;
            _area.y -= areaAdd;
            _area.width += areaAdd * 2;
            _area.height += areaAdd * 2;
        }
    }

    public function updateBounds():void {
        _orgBounds.x      = display.x;
        _orgBounds.y      = display.y;
        _orgBounds.width  = display.width;
        _orgBounds.height = display.height;
    }

    public function checkArea(x:Number, y:Number):Boolean {
        if (!_visible) {
            return false;
        }
        return _area.contains(x, y);
    }

    public final function touchDown(X:Number, Y:Number):void {
        if (_isDown) {
            return;
        }
        _isDown = true;
        onTouchDown(X, Y);
        downState();
    }

    public final function touchMove(X:Number, Y:Number):void {
        onTouchMove(X, Y);
        moveState();
    }

    public final function touchUP():void {
        if (!_isDown) {
            return;
        }
        _isDown = false;
        onTouchUp();
        upState();
    }

    public function setPosData(o:Object):void {
        if (display) {
            display.x      = o.x;
            display.y      = o.y;
            display.scaleX = display.scaleY = o.scale;
        }
    }

    public function getPosData():Object {
        return {
            x    : display.x,
            y    : display.y,
            scale: display.scaleX
        };
    }

    protected function onTouchDown(X:Number, Y:Number):void {

    }

    protected function onTouchUp():void {

    }

    protected function downState():void {

    }

    protected function upState():void {
        display.scaleX = display.scaleY = _orgScale;
        display.x      = _orgBounds.x;
        display.y      = _orgBounds.y;
    }

    protected function onTouchMove(X:Number, Y:Number):void {

    }

    protected function moveState():void {

    }

}
}
