package net.play5d.game.bvn.mob.screenpad {
public class ScreenPadBtn extends ScreenPadBtnBase {

    public function ScreenPadBtn() {
    }


    protected override function downState():void {
        display.scaleX = display.scaleY = _orgScale * 0.95;
        display.x += (
                             _orgBounds.width - display.width
                     ) * 0.5;
        display.y += (
                             _orgBounds.height - display.height
                     ) * 0.5;
    }

}
}
