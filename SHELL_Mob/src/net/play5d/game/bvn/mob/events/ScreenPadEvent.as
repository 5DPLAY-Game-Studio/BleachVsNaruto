package net.play5d.game.bvn.mob.events {
import flash.events.Event;

import net.play5d.game.bvn.mob.screenpad.ScreenPadBtnBase;

public class ScreenPadEvent extends Event {
    public static const CUSTOM_SELECT:String = 'ScreenPadEvent_CUSTOM_SELECT';
    public static const CUSTOM_MOVING:String = 'ScreenPadEvent_CUSTOM_MOVING';

    public function ScreenPadEvent(
            type:String, screenPadBtn:ScreenPadBtnBase, bubbles:Boolean = false, cancelable:Boolean = false) {
        this.screenPadBtn = screenPadBtn;
        super(type, bubbles, cancelable);
    }
    public var screenPadBtn:ScreenPadBtnBase;
}
}
