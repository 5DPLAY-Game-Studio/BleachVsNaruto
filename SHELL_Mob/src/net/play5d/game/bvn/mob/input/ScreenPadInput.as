package net.play5d.game.bvn.mob.input {
import flash.display.Stage;

import net.play5d.game.bvn.input.IGameInput;

public class ScreenPadInput implements IGameInput {
    public function ScreenPadInput() {
    }
    private var isDownObj:Object = {};

    private var _enabled:Boolean = true;

    public function get enabled():Boolean {
        return _enabled;
    }

    public function set enabled(v:Boolean):void {
        _enabled = v;
        if (!v) {
            isDownObj = {};
        }
    }

    public function initlize(stage:Stage):void {
    }

    public function setConfig(config:Object):void {
    }

    public function focus():void {
    }

    public function setDown(id:String, down:Boolean):void {
        isDownObj[id] = down;
    }

    public function anyKey():Boolean {
//			if(!_enabled) return false;
        return isDownObj['select'] || isDownObj['back'];
    }

    public function back():Boolean {
//			if(!_enabled) return false;
        return isDownObj['back'];
    }

    public function select():Boolean {
//			if(!_enabled) return false;
        return isDownObj['select'];
    }

    public function up():Boolean {
//			if(!_enabled) return false;
        return isDownObj['up'];
    }

    public function down():Boolean {
//			if(!_enabled) return false;
        return isDownObj['down'];
    }

    public function left():Boolean {
//			if(!_enabled) return false;
        return isDownObj['left'];
    }

    public function right():Boolean {
//			if(!_enabled) return false;
        return isDownObj['right'];
    }

    public function attack():Boolean {
//			if(!_enabled) return false;
        return isDownObj['attack'];
    }

    public function jump():Boolean {
//			if(!_enabled) return false;
        return isDownObj['jump'];
    }

    public function dash():Boolean {
//			if(!_enabled) return false;
        return isDownObj['dash'];
    }

    public function skill():Boolean {
//			if(!_enabled) return false;
        return isDownObj['skill'];
    }

    public function superSkill():Boolean {
//			if(!_enabled) return false;
        return isDownObj['superSkill'];
    }

    public function special():Boolean {
//			if(!_enabled) return false;
        return isDownObj['special'];
    }

    public function wankai():Boolean {
//			if(!_enabled) return false;
        return isDownObj['wankai'];
    }

    public function clear():void {
        isDownObj = {};
    }
}
}
