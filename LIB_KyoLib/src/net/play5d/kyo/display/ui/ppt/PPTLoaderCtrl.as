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

package net.play5d.kyo.display.ui.ppt {
import flash.events.EventDispatcher;

public class PPTLoaderCtrl extends EventDispatcher {
    public function PPTLoaderCtrl() {
    }
    public var curIndex:int;
    public var totalIndex:int;
    private var _loaders:Array;

    public function loadQueue(loaders:Array):void {
        _loaders = loaders;

        curIndex   = 0;
        totalIndex = loaders.length;

        loadNext();
    }

    private function loadNext():void {
        if (_loaders.length < 1) {
            dispatchEvent(new PicPointerEvent(PicPointerEvent.LOAD_COMPLETE));
            return;
        }

        curIndex++;

        var l:PicLoader = _loaders.shift();
        l.load(loadSuccess, loadFail, loadProcess);

    }

    private function loadSuccess(l:PicLoader):void {
        loadNext();
    }

    private function loadFail(l:PicLoader):void {
        loadNext();
    }

    private function loadProcess(l:PicLoader, per:Number):void {
        dispatchEvent(new PicPointerEvent(PicPointerEvent.LOAD_PROCESS, per));
    }

}
}
