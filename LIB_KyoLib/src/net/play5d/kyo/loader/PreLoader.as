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

package net.play5d.kyo.loader {
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.utils.getDefinitionByName;

public class PreLoader extends MovieClip {
    public function PreLoader() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddStage);

        stop();
    }

    public var showLoadbar:Boolean = true;
    protected var _mainClass:String;
    protected var _loadbar:LoaderBar;

    public function initlize(width:Number, height:Number):void {
        if (showLoadbar) {
            _loadbar           = new LoaderBar(800, 15);
            _loadbar.x         = 100;
            _loadbar.y         = 500;
            _loadbar.color     = 0x426F00;
            _loadbar.lineColor = 0x64A600;
            _loadbar.backColor = 0x1C2F00;
            _loadbar.initlize();
            addChild(_loadbar);
        }

        loaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress);
        loaderInfo.addEventListener(Event.COMPLETE, loadComplete);
    }

    protected function onProgress(p:Number):void {
        if (_loadbar) {
            _loadbar.update(p);
        }
    }

    protected function loadComplete(e:Event):void {
        if (_loadbar) {
            removeChild(_loadbar);
        }

        loaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
        loaderInfo.removeEventListener(Event.COMPLETE, loadComplete);

        this.gotoAndStop(2);
        var main:Class = getDefinitionByName(_mainClass) as Class;
        addChild(new main());
    }

    private function onAddStage(e:Event):void {
        var w:Number = stage.stageWidth - 200;
        var h:Number = stage.stageHeight - 50;

        initlize(w, h);
    }

    private function loadProgress(e:ProgressEvent):void {
        var p:Number = e.bytesLoaded / e.bytesTotal;
        onProgress(p);
    }

}
}
