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
import net.play5d.game.bvn.GameQuality;
import net.play5d.game.bvn.data.GameData;
import net.play5d.game.bvn.data.MapLogoState;
import net.play5d.game.bvn.interfaces.IGameSprite;

/**
 * 地图图层
 */
public class MapLayer extends Sprite {
    include '../../../../../../include/_INCLUDE_.as';

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

    // 可用性
    public var enabled:Boolean = false;

    // 视图显示对象
    private var _view:DisplayObject;
    // 模糊滤镜位图
    private var _blurBitmaps:Object = {};
    // 是否平滑
    private var _smoothing:Boolean;
    // 当前显示对象
    private var _currentShow:DisplayObject;

    /**
     * 获取地图显示对象
     */
    public function getView():DisplayObject {
        return _view;
    }

    /**
     * 正常化
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
     * 渲染光学可见性（透明度变化）
     *
     * @param gameSps 指定游戏元件
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

        var r:Rectangle;
        var d:DisplayObject;
        for (var i:int = 0; i < spLength; i++) {
            d = sp.getChildAt(i);
            if (!(d is MovieClip)) {
                continue;
            }

            r = d.getBounds(sp);
            r.x += sp.x + this.x;
            r.y += sp.y + this.y;

            // 如果相交，设置半透明
            d.alpha = checkHitGameSprite(r, gameSps) ? 0.5 : 1;
        }
    }

    /**
     * 销毁
     */
    public function destroy():void {
        var b:Bitmap;
        if (_view is Bitmap) {
            b = _view as Bitmap;
            b.bitmapData.dispose();
        }
    }

    /**
     * 设置平滑效果
     *
     * @param blurX 横向模糊值
     * @param blurY 纵向模糊值
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
            trace('MapLayer.setSmoothing error ::', e);
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
        trace('addBlurBitmap', id);

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
//        for (var i:String in _blurBitmaps) {
//            if (_blurBitmaps[i] == v) {
//                continue;
//            }
//            try {
//                removeChild(_blurBitmaps[i]);
//            }
//            catch (e:Error) {
//                trace(e);
//            }
//        }
//
//        if (_view != v) {
//            try {
//                removeChild(_currentShow);
//            }
//            catch (e:Error) {
//                trace(e);
//            }
//        }
//
//        addChild(v);

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
                trace(e);
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
            if (!sp || sp.isDestoryed()) {
                continue;
            }

//            area = sp.getBodyArea();
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
