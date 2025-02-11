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

package net.play5d.game.bvn.utils {
import net.play5d.game.bvn.interfaces.IAssetLoader;

public class ExtendAssetLoader implements IAssetLoader {
    include '../../../../../../include/_INCLUDE_.as';

    public function ExtendAssetLoader(extend:*) {
        if (!extend) {
            throw new Error('extend is null !');
        }
        _extend = extend;
    }
    private var _extend:*;

    public function loadXML(url:String, back:Function, fail:Function = null):void {
        _extend.loadXML(url, back, fail);
    }

    public function loadJSON(url:String, back:Function, fail:Function = null):void {
        _extend.loadJSON(url, back, fail);
    }

    public function loadSwf(url:String, back:Function, fail:Function = null, process:Function = null):void {
        _extend.loadSwf(url, back, fail, process);
    }

    public function loadSound(url:String, back:Function, fail:Function = null, process:Function = null):void {
        _extend.loadSound(url, back, fail, process);
    }

    public function loadBitmap(url:String, back:Function, fail:Function = null, process:Function = null):void {
        _extend.loadBitmap(url, back, fail, process);
    }

    public function dispose(url:String):void {
        _extend.dispose(url);
    }

    public function needPreLoad():Boolean {
        return _extend.needPreLoad();
    }

    public function loadPreLoad(back:Function, fail:Function = null, process:Function = null):void {
        _extend.loadPreLoad(back, fail, process);
    }
}
}
