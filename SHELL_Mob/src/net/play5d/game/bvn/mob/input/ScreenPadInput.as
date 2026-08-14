package net.play5d.game.bvn.mob.input {
import flash.display.Stage;

import net.play5d.game.bvn.interfaces.IGameInput;

public class ScreenPadInput implements IGameInput {
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

    public function initialize(stage:Stage):void {
    }

    public function setConfig(config:Object):void {
    }

    public function focus():void {
    }

    public function setDown(id:String, down:Boolean):void {
        isDownObj[id] = down;
    }

    public function anyKey():Boolean {
        return isDownObj['select'] || isDownObj['back'];
    }

    public function back():Boolean {
        return isDownObj['back'];
    }

    public function select():Boolean {
        return isDownObj['select'];
    }

    public function up():Boolean {
        return isDownObj['up'];
    }

    public function down():Boolean {
        return isDownObj['down'];
    }

    public function left():Boolean {
        return isDownObj['left'];
    }

    public function right():Boolean {
        return isDownObj['right'];
    }

    public function attack():Boolean {
        return isDownObj['attack'];
    }

    public function jump():Boolean {
        return isDownObj['jump'];
    }

    public function dash():Boolean {
        return isDownObj['dash'];
    }

    public function skill():Boolean {
        return isDownObj['skill'];
    }

    public function superSkill():Boolean {
        return isDownObj['superSkill'];
    }

    public function special():Boolean {
        return isDownObj['special'];
    }

    public function wankai():Boolean {
        return isDownObj['wankai'];
    }

    public function clear():void {
        isDownObj = {};
    }
}
}
