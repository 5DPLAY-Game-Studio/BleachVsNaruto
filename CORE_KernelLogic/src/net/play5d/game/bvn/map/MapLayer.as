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

package net.play5d.game.bvn.map {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.filters.BlurFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.game.bvn.GameConfig;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.GameQuality;
import net.play5d.game.bvn.data.MapLogoState;
import net.play5d.game.bvn.interfaces.IGameSprite;
import net.play5d.game.bvn.utils.GameLogger;

/**
 * 地图里的一层视图。
 *
 * <p>构造时视图为 null，则 <code>enabled</code> 保持 false，视图也留空。有视图时把视图的坐标挪到本层，视图自身归零。
 * 模糊只是换成半分辨率位图来显示，光学仍检查原始视图里的影片剪辑。位图按模糊整数值缓存。
 * <code>destroy</code> 只释放位图视图的像素，模糊缓存和显示列表不动。视图不是位图时，销毁什么都不做。</p>
 *
 * @see MapMain
 */
public class MapLayer extends Sprite {

    /**
     * 构造方法
     *
     * @param view 视图显示对象
     */
    public function MapLayer(view:DisplayObject) {
        if (!view) {
            return;
        }

        enabled = true;
        initView(view);
    }

    /**
     * 这一层是否可用。有视图的构造会写成 true。
     *
     * @default false
     */
    public var enabled:Boolean = false;

    /** @private */
    private var _view:DisplayObject;
    /** @private */
    private var _blurBitmaps:Object      = {};
    /** @private 未写入，光学渲染不靠它提前返回 */
    private var _smoothing:Boolean;
    /** @private */
    private var _currentShow:DisplayObject;
    /** @private 光学遮挡降频计数 */
    private var _opticalFrame:int;
    /** @private renderOptical 复用边界矩形 */
    private var _opticalRect:Rectangle   = new Rectangle();
    /** @private 光学检测降频间隔（逻辑帧） */
    private static const OPTICAL_GAP:int = 2;

    /**
     * 原始视图。构造时传入 null，这里就是 null。
     *
     * @return 视图显示对象。
     * @example
     * <listing version="3.0">
     * var view:DisplayObject = layer.getView();
     * </listing>
     */
    public function getView():DisplayObject {
        return _view;
    }

    /**
     * 按画质设置位图平滑，并按标志决定显示哪个 logo。
     *
     * <p>没有视图时直接返回。位图，以及精灵的直接子位图，只在画质为最佳时平滑。
     * 先藏起 <code>logo4399</code> 和 <code>logo_mine</code>，再按 <code>MAP_LOGO_STATE</code> 打开对应的一个。读取画质时配置缺失会抛错。</p>
     *
     * @throws TypeError 配置不存在时。
     * @example
     * <listing version="3.0">
     * layer.normalize();
     * </listing>
     */
    public function normalize():void {
        if (!_view) {
            return;
        }

        var b:Bitmap;
        if (_view is Bitmap) {
            b           = _view as Bitmap;
            b.smoothing = GameData.I.config.quality == GameQuality.BEST;
        }
        else if (_view is Sprite) {
            var sp:Sprite = _view as Sprite;
            for (var i:int = 0; i < sp.numChildren; i++) {
                var d:DisplayObject = sp.getChildAt(i);
                if (d is Bitmap) {
                    b           = d as Bitmap;
                    b.smoothing = GameData.I.config.quality == GameQuality.BEST;
                }
            }

            var logo1:DisplayObject = sp.getChildByName('logo4399');
            var logo2:DisplayObject = sp.getChildByName('logo_mine');

            if (logo1) {
                logo1.visible = false;
            }
            if (logo2) {
                logo2.visible = false;
            }

            switch (GameConfig.MAP_LOGO_STATE) {
            case MapLogoState.SHOW_4399:
                if (logo1) {
                    logo1.visible = true;
                }
                break;
            case MapLogoState.SHOW_MINE:
                if (logo2) {
                    logo2.visible = true;
                }
                break;
            }
        }
    }

    /**
     * 让挡住角色的影片剪辑变半透明。
     *
     * <p>没有视图、视图不是精灵，或没有子对象时直接返回。每两次调用才真正检查一次。
     * 角色列表为空时，影片剪辑的透明度改回 1。相交时透明度是 0.5，否则是 1。已销毁或区域为空的角色跳过。</p>
     *
     * @param gameSps 要检测的角色。null 或空数组会把影片剪辑透明度改回 1。
     * @example
     * <listing version="3.0">
     * layer.renderOptical(sprites);
     * </listing>
     */
    public function renderOptical(gameSps:Vector.<IGameSprite>):void {
        if (!_view || _smoothing) {
            return;
        }

        var sp:Sprite = _view as Sprite;
        if (!sp) {
            return;
        }

        var spLength:int = sp.numChildren;
        if (spLength < 1) {
            return;
        }

        if (++_opticalFrame < OPTICAL_GAP) {
            return;
        }
        _opticalFrame = 0;

        if (!gameSps || gameSps.length < 1) {
            for (var c:int = 0; c < spLength; c++) {
                var cd:DisplayObject = sp.getChildAt(c);
                if (cd is MovieClip) {
                    cd.alpha = 1;
                }
            }
            return;
        }

        var r:Rectangle = _opticalRect;
        var d:DisplayObject;
        var bds:Rectangle;
        for (var i:int = 0; i < spLength; i++) {
            d = sp.getChildAt(i);
            if (!(d is MovieClip)) {
                continue;
            }

            bds = d.getBounds(sp);
            r.setTo(bds.x + sp.x + this.x, bds.y + sp.y + this.y, bds.width, bds.height);

            // 如果相交，设置半透明
            d.alpha = checkHitGameSprite(r, gameSps) ? 0.5 : 1;
        }
    }

    /**
     * 释放位图视图的像素。
     *
     * <p>视图不是位图时什么都不做。模糊缓存不释放，对象也不从父级移除。</p>
     *
     * @example
     * <listing version="3.0">
     * layer.destroy();
     * </listing>
     */
    public function destroy():void {
        var b:Bitmap;
        if (_view is Bitmap) {
            b = _view as Bitmap;
            b.bitmapData.dispose();
        }
    }

    /**
     * 换成模糊位图，或在模糊值都不大于 0 时改回原视图。
     *
     * <p>没有视图时直接返回。位图按取整后的横纵模糊值缓存，绘制成一半尺寸再放大回去。出错只记日志。</p>
     *
     * @param blurX 横向模糊，默认 0。
     * @param blurY 纵向模糊，默认 0。
     * @example
     * <listing version="3.0">
     * layer.setSmoothing(2, 0);
     * </listing>
     */
    public function setSmoothing(blurX:Number = 0, blurY:Number = 0):void {
        if (!_view) {
            return;
        }

        try {
            if (blurX <= 0 && blurY <= 0) {
                show(_view);
                return;
            }

            var bp:Bitmap = getBlurBitmap(blurX, blurY);
            show(bp);
        }
        catch (e:Error) {
            GameLogger.error('fight', 'MapLayer.setSmoothing: ' + e);
        }
    }

    /**
     * 初始化视图显示对象
     *
     * @param view 视图显示对象
     */
    private function initView(view:DisplayObject):void {
        _view = view;
        show(_view);

        this.x = view.x;
        this.y = view.y;

        view.x = view.y = 0;
    }

    /**
     * 获取应用模糊滤镜后的位图
     *
     * @param blurX 横向模糊值
     * @param blurY 纵向模糊值
     * @return 应用模糊滤镜后的位图
     */
    private function getBlurBitmap(blurX:int = 5, blurY:int = 0):Bitmap {
        var id:String = blurX + '|' + blurY;
        // 如果有缓存，则使用缓存
        if (_blurBitmaps[id]) {
            return _blurBitmaps[id];
        }

        var b:Bitmap = drawBitmap(true, 0);
        GameLogger.debug('fight', 'addBlurBitmap ' + id);

        // 模糊滤镜
        var filter:BlurFilter = new BlurFilter(blurX, blurY, 1);
        var bd:BitmapData     = b.bitmapData;
        bd.applyFilter(bd, bd.rect, new Point(), filter);

        // 缓存
        _blurBitmaps[id] = b;
        return b;
    }

    /**
     * 显示
     *
     * @param v 显示对象
     */
    private function show(v:DisplayObject):void {

        // 如果当前显示的对象就是要显示的对象，返回
        if (_currentShow == v) {
            return;
        }

        // 如果不是，也就是来了新的显示对象
        if (_currentShow) {
            // 尝试移除旧的对象
            try {
                removeChild(_currentShow);
            }
            catch (e:Error) {
                GameLogger.error('fight', String(e));
            }
        }

        // 添加新的对象
        addChild(v);
        _currentShow = v;
    }

    /**
     * 检查是否碰触游戏元件
     *
     * @param rect 范围
     * @param gameSps 游戏元件
     * @return 是否碰触游戏元件
     */
    private static function checkHitGameSprite(rect:Rectangle, gameSps:Vector.<IGameSprite>):Boolean {
        var isHit:Boolean  = false;
        var area:Rectangle = null;

        for each (var sp:IGameSprite in gameSps) {
            if (!sp || sp.isDestroyed()) {
                continue;
            }

            area = sp.getArea();
            if (!area || area.isEmpty()) {
                continue;
            }

            // 检查当前元件是否与给定范围相交
            isHit = rect.intersects(area);
            if (isHit) {
                return true;
            }
        }

        return false;
    }

    /**
     * 绘制位图
     *
     * @param transparent 是否透明
     * @param fillColor 填充颜色
     * @return 绘制完成的位图
     */
    private function drawBitmap(transparent:Boolean = true, fillColor:uint = 0x000000):Bitmap {
        if (!_view) {
            return null;
        }

        // 位图
        var bitmap:Bitmap    = new Bitmap(new BitmapData(_view.width / 2, _view.height / 2, transparent, fillColor));
        // 边界
        var bounds:Rectangle = _view.getBounds(_view);
        // 矩阵
        var matrix:Matrix    = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);

        matrix.scale(0.5, 0.5);
        bitmap.bitmapData.draw(_view, matrix);

        bitmap.x      = bounds.x;
        bitmap.y      = bounds.y;
        bitmap.scaleX = bitmap.scaleY = 2;

        return bitmap;
    }
}
}
