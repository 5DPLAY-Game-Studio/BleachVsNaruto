/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package net.play5d.game.bvn.views.effects {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.ctrler.game_ctrls.GameCtrl;

/**
 * 全屏黑底。像素是画面的十分之一，再拉到整屏，不透明黑色。
 *
 * <p><code>fadeIn</code> 和 <code>renderAnimate</code> 是空的。<code>fadeOut</code> 摘掉自己和必杀立绘引用，不释放黑底像素。立绘影片销毁后仍留在显示列表里。</p>
 */
public class BlackBackView extends Sprite {

    /**
     * 铺上黑底。
     */
    public function BlackBackView() {
        super();

        var bd:BitmapData = new BitmapData(GameConfig.GAME_SIZE.x / 10, GameConfig.GAME_SIZE.y / 10, false, 0);
        _bg               = new Bitmap(bd);
        _bg.width         = GameConfig.GAME_SIZE.x;
        _bg.height        = GameConfig.GAME_SIZE.y;

        addChild(_bg);
    }
    private var _bishaFace:BishaFaceEffectView;
    private var isRenderFadeIn:Boolean;
    private var isRenderFadeOut:Boolean;
    private var _bg:Bitmap;

    /**
     * 摘掉黑底并释放像素，同时释放立绘位图。移除失败只吞掉。
     *
     * @example
     * <listing version="3.0">
     * back.destroy();
     * </listing>
     */
    public function destroy():void {
        if (_bg) {
            try {
                removeChild(_bg);
            }
            catch (e:Error) {
            }
            _bg.bitmapData.dispose();
            _bg = null;
        }
        removeBishaFace();
    }

    /**
     * 空实现。
     *
     * @example
     * <listing version="3.0">
     * back.renderAnimate();
     * </listing>
     */
    public function renderAnimate():void {
    }

    /**
     * 空实现。
     *
     * @example
     * <listing version="3.0">
     * back.fadeIn();
     * </listing>
     */
    public function fadeIn():void {
    }

    /**
     * 清掉立绘引用，并尝试从父级移除自己。没有父级时吞掉。黑底像素不释放。
     *
     * @example
     * <listing version="3.0">
     * back.fadeOut();
     * </listing>
     */
    public function fadeOut():void {
        removeBishaFace();
        try {
            parent.removeChild(this);
        }
        catch (e:Error) {
        }
    }

    /**
     * 显示必杀立绘。第一次会创建并加入。纵坐标是 <code>100 + 100 / 镜头缩放</code>，没有镜头时缩放按 1。缩放是 0 时变成 Infinity。每次都会从第 2 帧重播。
     *
     * @param faceid 脸槽编号。
     * @param face 脸图。
     * @throws TypeError 立绘影片或脸图缺失时。
     * @example
     * <listing version="3.0">
     * back.showBishaFace(1, face);
     * </listing>
     */
    public function showBishaFace(faceid:int, face:DisplayObject):void {
        if (!_bishaFace) {
            _bishaFace      = new BishaFaceEffectView();
            var zoom:Number = 1;
            if (GameCtrl.I && GameCtrl.I.gameState && GameCtrl.I.gameState.camera) {
                zoom = GameCtrl.I.gameState.camera.getZoom();
            }
            _bishaFace.mc.y = 100 + (
                    100 / zoom
            );
            addChild(_bishaFace.mc);
        }

        _bishaFace.setFace(faceid, face);
        _bishaFace.fadeIn();
    }

    private function removeBishaFace():void {
        if (_bishaFace) {
            _bishaFace.destroy();
            _bishaFace = null;
        }
    }


}
}
