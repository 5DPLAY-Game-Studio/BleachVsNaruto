package net.play5d.game.bvn.mob.events {
import flash.events.Event;

public class LanEvent extends Event {

    public static const CLIENT_JOIN_SUCCESS:String = 'CLIENT_JOIN_SUCCESS';

    public function LanEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }
}
}
