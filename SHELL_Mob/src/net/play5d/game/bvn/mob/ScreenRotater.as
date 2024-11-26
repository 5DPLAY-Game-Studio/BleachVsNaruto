package net.play5d.game.bvn.mob {
import flash.display.Stage;
import flash.display.StageOrientation;
import flash.events.AccelerometerEvent;
import flash.sensors.Accelerometer;

/**
 * 利用重力感应自动旋转
 */
public class ScreenRotater {
    private static var _i:ScreenRotater;

    public static function get I():ScreenRotater {
        _i ||= new ScreenRotater();
        return _i;
    }

    public function ScreenRotater() {
    }
    /**
     * 灵敏度，0.1 ~ 0.9
     */
    public var sensitivity:Number = 0.8;
    private var _accer:Accelerometer;
    private var _currentOrientation:String;
    private var _stage:Stage;

    public function isSupported():Boolean {
        return Accelerometer.isSupported;
    }

    public function init(stage:Stage):void {
        _stage = stage;
        if (!Accelerometer.isSupported) {
            stage.autoOrients = true;
            _stage.setOrientation(StageOrientation.ROTATED_RIGHT);
            return;
        }

        stage.autoOrients = false;

        setOrientation(StageOrientation.ROTATED_RIGHT);

        _accer = new Accelerometer();
        _accer.addEventListener(AccelerometerEvent.UPDATE, accUpdate);
    }

    private function setOrientation(v:String):void {
        if (_currentOrientation == v) {
            return;
        }
        _currentOrientation = v;
        _stage.setOrientation(v);
    }

    private function accUpdate(e:AccelerometerEvent):void {
        if (_currentOrientation == StageOrientation.ROTATED_LEFT) {
            if (e.accelerationY < -sensitivity) {
                setOrientation(StageOrientation.ROTATED_RIGHT);
                return;
            }
        }

        if (_currentOrientation == StageOrientation.ROTATED_RIGHT) {
            if (e.accelerationY < -sensitivity) {
                setOrientation(StageOrientation.ROTATED_LEFT);
                return;
            }
        }

    }


}
}
