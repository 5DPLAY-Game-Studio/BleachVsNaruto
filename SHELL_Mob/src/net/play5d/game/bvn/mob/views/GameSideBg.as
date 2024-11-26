package net.play5d.game.bvn.mob.views {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

public class GameSideBg extends Bitmap {
    public function GameSideBg(screenSize:Point, gameSize:Rectangle) {
        super(null, 'auto', false);
        update(screenSize, gameSize);
    }
    [Embed(source='/../assets/side_bg.png')]
    private var _sideBg:Class;
    [Embed(source='/../assets/side_shadow.png')]
    private var _sideShadow:Class;

    public function update(screenSize:Point, gameSize:Rectangle):void {

        if (this.bitmapData) {
            this.bitmapData.dispose();
            this.bitmapData = null;
        }

        screenSize.x = screenSize.x << 0;
        screenSize.y = screenSize.y << 0;

        gameSize.x      = gameSize.x << 0;
        gameSize.y      = gameSize.y << 0;
        gameSize.width  = gameSize.width << 0;
        gameSize.height = gameSize.height << 0;

        var bd:BitmapData = new BitmapData(screenSize.x, screenSize.y, false, 0);

        var sidebg:Bitmap = new _sideBg();
        sidebg.height     = screenSize.y;
        sidebg.scaleX     = sidebg.scaleY;

        var mtx:Matrix = new Matrix();
        mtx.scale(sidebg.scaleX, sidebg.scaleY);
        bd.draw(sidebg, mtx, null, null, new Rectangle(0, 0, gameSize.x, screenSize.y));

        var mtx2:Matrix        = mtx.clone();
        var rightOffset:Number = sidebg.width - (
                                 screenSize.x - gameSize.right
        );
        mtx2.translate((
                               gameSize.right - rightOffset
                       ) << 0, 0);
        var rect2:Rectangle = new Rectangle(gameSize.right, 0, screenSize.x, screenSize.y);
        bd.draw(sidebg, mtx2, null, null, rect2);

        var shadow:Bitmap = new _sideShadow();
        shadow.height     = screenSize.y;
        shadow.scaleX     = shadow.scaleY;

        var mtx3:Matrix = new Matrix();
        mtx3.scale(shadow.scaleX, shadow.scaleY);
        mtx3.translate((
                               gameSize.x - shadow.width + 1
                       ) << 0, 0);
        bd.draw(shadow, mtx3, null);

        var mtx4:Matrix = new Matrix();
        mtx4.scale(-shadow.scaleX, shadow.scaleY);
        mtx4.translate((
                               gameSize.right + shadow.width
                       ) << 0, 0);
        bd.draw(shadow, mtx4, null);

        this.bitmapData = bd;

        sidebg.bitmapData.dispose();
        shadow.bitmapData.dispose();
    }

    public function destory():void {
        try {
            this.parent.removeChild(this);
        }
        catch (e:Error) {
            trace(e);
        }
        if (this.bitmapData) {
            this.bitmapData.dispose();
            this.bitmapData = null;
        }
    }

}
}
