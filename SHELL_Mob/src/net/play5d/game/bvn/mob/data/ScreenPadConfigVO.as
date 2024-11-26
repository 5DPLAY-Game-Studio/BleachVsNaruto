package net.play5d.game.bvn.mob.data {
public class ScreenPadConfigVO {

    public function ScreenPadConfigVO() {
    }
    /**
     * 按键模式
     */
    public var joyMode:int             = 1;
    /**
     * 透明度
     */
    public var joyAlpha:Number         = 0.7;
    /**
     * 位置，大小
     */
    public var joySet:Object;
    /**
     * 万解自动隐藏
     */
    public var wankaiAutoHide:Boolean  = true;
    /**
     * 特殊键自动隐藏
     */
    public var specialAutoHide:Boolean = true;
    /**
     * 必杀键自动隐藏
     */
    public var superSkillAutoHide:Boolean = true;

    public function toObj():Object {
        return {
            joyMode           : joyMode,
            joyAlpha          : joyAlpha,
            joySet            : joySet,
            wankaiAutoHide    : wankaiAutoHide,
            specialAutoHide   : specialAutoHide,
            superSkillAutoHide: superSkillAutoHide
        };
    }

    public function readObj(o:Object):void {
        if (!o) {
            return;
        }
        if (o.joyMode != undefined) {
            joyMode = o.joyMode;
        }
        if (o.joyAlpha != undefined) {
            joyAlpha = o.joyAlpha;
        }
        if (o.joySet != undefined) {
            joySet = o.joySet;
        }
        if (o.wankaiAutoHide != undefined) {
            wankaiAutoHide = o.wankaiAutoHide;
        }
        if (o.specialAutoHide != undefined) {
            specialAutoHide = o.specialAutoHide;
        }
        if (o.superSkillAutoHide != undefined) {
            superSkillAutoHide = o.bishaAutoHide;
        }
    }

    public function setValueByKey(k:String, v:Object):void {
        if (this.hasOwnProperty(k)) {
            this[k] = v;
        }
    }

}
}
