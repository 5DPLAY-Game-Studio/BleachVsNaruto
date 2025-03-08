package net.play5d.game.bvn.mob.utils {
import flash.events.Event;

public class TimerOutUtils {
    private static var _timers:Object = {};

    public static function setTimeout(func:Function, delay:int, ...params):int {
        var timer:InsTimer = new InsTimer(delay, func, params);
        timer.addEventListener(Event.COMPLETE, timerCompleteHandler);
        _timers[timer.id] = timer;
        return timer.id;
    }

    public static function clearTimeout(id:int):void {
        var timer:InsTimer = _timers[id];
        if (timer) {
            timer.removeEventListener(Event.COMPLETE, timerCompleteHandler);
            timer.clear();
        }
        delete _timers[id];
    }

    public static function pauseAllTimer():void {
        for (var i:String in _timers) {
            var t:InsTimer = _timers[i];
            t.pause();
        }
    }

    public static function resumeAllTimer():void {
        for (var i:String in _timers) {
            var t:InsTimer = _timers[i];
            t.resume();
        }
    }

    private static function resetTimer(id:int):void {
        var timer:InsTimer = _timers[id];
        if (timer) {
            timer.reset();
        }
    }

    public function TimerOutUtils() {
    }

    private static function timerCompleteHandler(e:Event):void {
        var timer:InsTimer = e.currentTarget as InsTimer;
        clearTimeout(timer.id);
    }


}
}

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

internal class InsTimer extends EventDispatcher {
    public function InsTimer(delay:Number, func:Function, params:Array) {
        this.id = (
                          Math.random() * 100000
                  ) << 0;
        _func   = func;
        _params = params;
        _timer  = new Timer(delay, 1);
        _timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerHandler);
        _timer.start();
    }
    public var id:int;
    private var _func:Function;
    private var _timer:Timer;
    private var _params:Array;

    public function pause():void {
        if (_timer) {
            _timer.stop();
        }
    }

    public function resume():void {
        if (_timer) {
            _timer.start();
        }
    }

    public function reset():void {
        if (_timer) {
            _timer.reset();
        }
    }

    public function clear():void {
        if (_timer) {
            _timer.stop();
            _timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerHandler);
            _timer = null;
        }
        _func   = null;
        _params = null;
    }

    private function timerHandler(e:TimerEvent):void {
        if (_func != null) {
            if (_params) {
                _func.apply(null, _params);
            }
            else {
                _func();
            }
            _func   = null;
            _params = null;
        }
        dispatchEvent(new Event(Event.COMPLETE));
    }

}
