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
import flash.display.DisplayObject;
import flash.display.MovieClip;

import net.play5d.game.bvn.ctrler.AssetManager;

/**
 * 必杀立绘。影片在字段初始化时取出，取不到时后面的播放和换图会抛错。没有对应脸槽时 <code>setFace</code> 直接返回。换上的图固定改成 254×180，旧图不摘掉。
 */
public class BishaFaceEffectView {

    /**
     * 立绘影片。
     */
    public var mc:MovieClip     = AssetManager.I.getEffect('bisha_face_mc');
    private var _faceObj:Object = {};

    /**
     * 设置角色图。没有 <code>facemc</code> 加编号的槽时直接返回。图为 null 时抛错。
     *
     * @param faceId 脸槽编号，拼到 <code>facemc</code> 后面。
     * @param face 脸图。宽高会被写成 254 和 180。
     * @throws TypeError 影片或脸图为 null 时。
     */
    public function setFace(faceId:int, face:DisplayObject):void {
        var facemc:MovieClip = mc['facemc' + faceId];
        if (!facemc) {
            return;
        }

        _faceObj[faceId] = face;
        face.width       = 254;
        face.height      = 180;
        facemc.addChild(face);
    }

    /**
     * 从第 2 帧开始播。影片为 null 时抛错。
     *
     * @throws TypeError 影片为 null 时。
     * @example
     * <listing version="3.0">
     * view.fadeIn();
     * </listing>
     */
    public function fadeIn():void {
        mc.gotoAndPlay(2);
    }

    /**
     * 释放位图脸的像素。影片和其他类型的脸还留着。
     *
     * @example
     * <listing version="3.0">
     * view.destroy();
     * </listing>
     */
    public function destroy():void {
        for each(var i:DisplayObject in _faceObj) {
            if (i is Bitmap) {
                (
                        i as Bitmap
                ).bitmapData.dispose();
            }
        }
    }


}
}
