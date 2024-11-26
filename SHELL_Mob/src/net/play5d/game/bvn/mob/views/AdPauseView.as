package net.play5d.game.bvn.mob.views {
import flash.display.Bitmap;
import flash.display.Sprite;

import net.play5d.game.bvn.mob.RootSprite;

public class AdPauseView extends Sprite {

    public function AdPauseView() {

        this.graphics.beginFill(0, 0.5);
        this.graphics.drawRect(0, 0, RootSprite.FULL_SCREEN_SIZE.x, RootSprite.FULL_SCREEN_SIZE.y);
        this.graphics.endFill();

        var btn:Bitmap = new _closeBtn();
        btn.scaleX     = RootSprite.FULL_SCREEN_SIZE.x / 800;
        btn.scaleY     = btn.scaleX;
        btn.x          = (
                                 RootSprite.FULL_SCREEN_SIZE.x - btn.width
                         ) / 2;
        btn.y          = (
                                 RootSprite.FULL_SCREEN_SIZE.y - btn.height
                         ) / 2;


        this.addChild(btn);

    }
    [Embed(source='/contbtn.png')]
    private var _closeBtn:Class;

}
}
