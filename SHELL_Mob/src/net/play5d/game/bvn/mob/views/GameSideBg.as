package net.play5d.game.bvn.mob.views {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.game.bvn.utils.GameLogger;
import net.play5d.game.bvn.utils.UiBitmap;

public class GameSideBg extends Bitmap {
    public function GameSideBg(screenSize:Point, gameSize:Rectangle) {
        super(null, 'auto', false);
        update(screenSize, gameSize);
    }
    /** @private */
    private var _loading:Boolean;
    /** @private */
    private var _screenSize:Point;
    /** @private */
    private var _gameSize:Rectangle;

    public function update(screenSize:Point, gameSize:Rectangle):void {
        _screenSize = screenSize;
        _gameSize   = gameSize;

        var sidebg:Bitmap = UiBitmap.create('side_bg.png');
        var shadow:Bitmap = UiBitmap.create('side_shadow.png');
        if (!sidebg || !shadow) {
            if (sidebg) {
                sidebg.bitmapData.dispose();
            }
            if (shadow) {
                shadow.bitmapData.dispose();
            }
            if (_loading) {
                return;
            }
            _loading = true;
            UiBitmap.loadAll(['side_bg.png', 'side_shadow.png'], function ():void {
                _loading = false;
                update(_screenSize, _gameSize);
            }, function ():void {
                _loading = false;
            });
            return;
        }

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

    public function destroy():void {
        try {
            this.parent.removeChild(this);
        }
        catch (e:Error) {
            GameLogger.error('ui', String(e));
        }
        if (this.bitmapData) {
            this.bitmapData.dispose();
            this.bitmapData = null;
        }
    }

}
}
