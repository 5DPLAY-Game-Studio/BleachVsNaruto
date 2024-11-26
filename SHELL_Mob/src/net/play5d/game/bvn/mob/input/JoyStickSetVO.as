package net.play5d.game.bvn.mob.input {
public class JoyStickSetVO {
    public function JoyStickSetVO(id:int, value:Number = 1) {
        this.id    = id;
        this.value = value;
    }
    public var id:int;

//		public function get ID():String{
//			return id+'_'+value;
//		}
    public var value:Number = 0;

    public function readObj(o:Object):void {
        this.id    = o.id;
        this.value = o.value;
    }

    public function toObj():Object {
        var o:Object = {};
        o.id         = this.id;
        o.value      = this.value;
        return o;
    }

}
}
