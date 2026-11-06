package net.play5d.game.bvn.mob.screenpad {
import net.play5d.game.bvn.utils.UiBitmap;

/**
 * 虚拟按键图片文件名。文件在 <code>assets/ui/bitmap</code>。
 *
 * @see UiBitmap
 */
public class ScreenPadAsset {

    public static const arrow:String   = 'arrow.png';
    public static const ok:String      = 'ok.png';
    public static const cancel:String  = 'cancel.png';
    public static const attack:String  = 'attack.png';
    public static const jump:String    = 'jump.png';
    public static const jump2:String   = 'jump2.png';
    public static const skill:String   = 'skill.png';
    public static const skill2:String  = 'skill2.png';
    public static const dash:String    = 'dash.png';
    public static const spskill:String = 'spskill.png';
    public static const special:String = 'special.png';
    public static const wanjie:String  = 'wanjie.png';
    public static const pause:String   = 'pause.png';
    public static const light:String   = 'light.png';

    /**
     * 读入全部按键图片。
     *
     * @param back 全部成功回调。
     * @param fail 失败回调。
     * @example
     * <listing version="3.0">
     * ScreenPadAsset.load(onReady, onFail);
     * </listing>
     */
    public static function load(back:Function, fail:Function):void {
        UiBitmap.loadAll([
            arrow, ok, cancel, attack, jump, jump2, skill, skill2,
            dash, spskill, special, wanjie, pause, light
        ], back, fail);
    }

}
}
